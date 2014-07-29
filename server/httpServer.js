"use strict";
/* global require,module,global,console,Buffer,escape */
var express = require('express');
var fs = require('fs');
var assert = require('assert');
var ObjectID = require('mongodb').ObjectID;
var util = require('util');
var crypto = require('crypto');
var async = require('async');
var child_process = require('child_process');
var http = require('http');
var https = require('https');
var heapdump = require('heapdump');
var mongoose = require('mongoose');
var jade = require('jade');
var generatePassword = require('password-generator');

var config = require('./config');
var MongoStore = require('./mongoStore');

var Game = require('./game').Game;
var Club = require('./club').Club;
var deck = require('./deck');
var myutils = require('./myutils');
var buildbot = require('./buildbot');
var installer = require('./installer');
var differ = require('./differ');
var RT = require('./rt');
var models = require('./db').models;
var user = require('./user');
var codes = require('./ServerCodes');
var SmtpConnection = require('./smtp');
var dag = require('./dag/build/Release/dag');
var error = require('./error');
var Tournament = require('./tournament');

module.exports.initHttpServer = initHttpServer;

var badConfLink = "Invalid confirmation link.";

var sharedconfig,emailChange2;

function initHttpServer() {
	sharedconfig = global.sharedconfig; // FIXME
	fs.readFile('views/password_change2.jade',{encoding:'utf8'},function (err,data) {
		emailChange2 = jade.compile(data,{filename:'views/password_change2.jade',pretty:true});
	});
	var server = new Server(global.activeUsers);
	return server;
}

function Server(activeUsersIN) {
	var app = express();
	this.httpServer = http.createServer(app);
	this.IO = require('socket.io').listen(this.httpServer,{log:false});
	differ.setIO(this.IO);
	var logger = require('morgan');
	app.use(logger());
	this.activeUsers = activeUsersIN; // FIXME

	this.sessionStore = new MongoStore(mongoose.connection.db,'sessions');
	this.IO.set('authorization',this.socketAuth.bind(this));
	app.use(express.cookieParser());
	app.use(express.session({secret:'ahQu6eey',key:'poker',store:this.sessionStore}));
	app.configure(function () {
		assert(fs.statSync('./upload'));
		app.use(express.bodyParser({uploadDir:'./upload'}));
	});
	app.use('/sync/',express.basicAuth('sync',config.syncpassword));
	app.use('/secure/',this.isSecureAuthed);
	app.set('view engine','jade');
	app.get('/secure/',this.secureIndex.bind(this));

	app.get('/secure/login',this.secureLogin.bind(this));
	app.get('/secure/logout',this.secureLogout.bind(this));
	app.get('/secure/changePassword',this.changePassword.bind(this));
	app.post('/secure/login',this.secureLoginPost.bind(this));
	app.post('/secure/changePassword',this.secureChangePasswordPost.bind(this));

	this.addSecure(app);

	app.get('/secure/performance',function (req,res) {
		var start = Date.now();
		mongoose.connection.db.collection('system.profile').find({}).limit(50).sort({ts:-1}).toArray(function (err,rows) {
			res.render('profile',{rows:rows,start:start});
		});
	});
	app.get('/secure/profile',this.profile.bind(this));
	app.get('/secure/billing',function (req,res) {
		var start = Date.now();
		mongoose.connection.db.collection('billing').find({TotalCost:{$gt:0}},{ProductCode:1,ProductName:1,UsageType:1,ItemDescription:1,CostBeforeTax:1,TotalCost:1,UsageQuantity:1,"user:Name":1,"user:service":1,year:1,month:1}).toArray(function (err,rows) { // FIXME
			res.render('billing',{billing:rows,start:start});
		});
	});
	app.get('/confirm',this.confirmAccount.bind(this));
	app.post('/secure/club_public',function (req,res) {
		Club.getClubById(new ObjectID(req.body.clubid),function (err,clubObj) {
			if (err == 'not found') {
				res.end('club not found');
				return;
			}
			assert.ifError(err);
			clubObj.goPublic(function (msg) {
				res.end(msg);
			});
		});
	});
	app.get('/secure/tournament_create',this.createTourn.bind(this));
	app.post('/secure/tournament_create',this.createTournPost.bind(this));
	app.get('/confirmchange',this.confirmChange.bind(this));
	app.get("/passwordreset",this.passwordReset.bind(this));
	app.post('/paypal_callback',this.paypalCallback.bind(this));
	app.get('/paypal',function (req,res) {
		res.render('paypal');
	});
	app.post('/error_upload',this.errorUpload.bind(this));
	app.get("/test",function (req,res) {
		res.send("<form method='post' action='/image_upload' enctype='multipart/form-data'><input type='file' name='avatar'><input type='submit'></form>");
	});
	
	app.get("/getavatar",this.getAvatar.bind(this));
	app.post("/uploadAvatar",this.uploadAvatar.bind(this));

	app.get("/install_chipuppoker.exe",function (req,res) {
		models.Config.findOne({_id:'installerid'},function (err,row) {
			assert.ifError(err);
			models.Installer.findOne({_id:row.value},function (err,row) {
				global.log('sending installer %j',row);
				if (config.diffserver) {
					res.sendfile('installers/'+row.name);
				} else {
					res.writeHead(302,{Location:'https://dev-server.chipuppoker.com/redirect/install_chipuppoker.exe?name='+row.name});
					res.end();
				}
			});
		}.bind(this));
	}.bind(this));
	app.get("/redirect/install_chipuppoker.exe",function (req,res) {
		models.Installer.findOne({name:req.query.name},function (err,row) {
			res.sendfile('installers/'+row.name);
		});
	}.bind(this));
	app.get("/debug_install_chipuppoker.exe",function (req,res) {
		models.Config.findOne({_id:'debuginstallerid'},function (err,row) {
			assert.ifError(err);
			models.Installer.findOne({_id:row.value},function (err,row) {
				global.log('sending debug installer %j',row);
				res.sendfile('installers/'+row.name);
			});
		}.bind(this));
	}.bind(this));
	app.post('/eval',function (req,res) {
		var state = req.body;
		console.log(state);
		var fakegame = { flop:{cards:state.flop}, turn:{cards:state.turn}, river:{cards:state.river}};
		var fakeusers = [{seat:0,hand:state.cards1},{seat:1,hand:state.cards2}];
		var result = dag.rankHands(fakegame,fakeusers);
		res.send(JSON.stringify(result));
	});
	app.post('/contactPost',this.contactPost);
	app.post('/newVersion',this.newVersion.bind(this));
	app.get('/secure/broadcast',function (req,res) {
		res.render('broadcast',{start:Date.now()});
	});
	app.post('/secure/sendBroadcast',function (req,res) {
		console.log(req.body);
		var ev = {event:'ceServerMessage',msg:{msg:req.body.msg}};
		for (var key in this.activeUsers) {
			this.activeUsers[key].send(codes.seChat,ev,'Poker.ChatEvent');
		}
		res.writeHead(302,{Location:'/secure/broadcast?success=true'}); // FIXME
		res.end();
	}.bind(this));
	//app.get('/fetchhands',this.fetchHands.bind(this));
	app.post('/sync/makeDiff',this.syncMakeDiff.bind(this));
	app.post('/secure/buildbot',function (req,res) {
		console.log(req.body);
		buildbot.doLogin(function () {
			buildbot.forceBuild('debug-win32',req.body.revision);
			buildbot.forceBuild('release-win32',req.body.revision);
			res.end(JSON.stringify('OK'));
		});
	});
	app.get('/pay',this.pay.bind(this));
	this.addSync(app);
	app.use(express.static('files'));
	app.use('/rawinstallers',express.static('installers'));
}
Server.prototype.pay = function (req,res) {
	console.log(req.query);
	if (!req.query.id) {
		res.end('invalid token');
		return;
	}
	models.PaypalRequest.findById(req.query.id,function (err,row) {
		if (err) {
			console.log('pay error',err);
			res.end('internal error');
			return;
		}
		console.log(row);
		res.render('pay',{row:row});
	}.bind(this));
}
Server.prototype.profile = function (req,res) {
	var start = Date.now();
	models.PokerProfile.aggregate({$group:{_id:'$tag', avg:{$avg:'$time'}, hits:{$sum:1}, cpuavg:{$avg:'$cputime'} }}, function (err,rows) {
		models.PokerProfile.find({time:{$gt:2000}},function (err,list) {
			res.render('profile2',{rows:rows,start:start,rawlist:list});
		});
	});
};
Server.prototype.syncMakeDiff = function (req,res) {
	var t = req.body;
	differ.makeDiff(t.sourcehash,t.desthash,t.path);
	res.end('STARTED');
};
Server.prototype.syncNewDiff = function (req,res) {
	var doc = req.body;
	var obj = new models.Diff(doc);
	obj.save(function (err,rows) {
		// might cause a duplicate key error, those are safe to ignore
		res.end('OK');
	});
};
Server.prototype.addSecure = function (app) {
	app.get('/secure/bugs',this.bugList.bind(this));
	app.get('/secure/bug',this.getBug.bind(this));
	app.get('/secure/screenshot',this.getScreenshot.bind(this));
	app.get('/secure/serverBugs',this.ServerBugsList.bind(this));
	app.get('/secure/users',this.userList.bind(this));
	app.get('/secure/user',this.getUser.bind(this));
	app.get('/secure/clubs',this.getClubs.bind(this));
	app.get('/secure/club',this.getClub.bind(this));
	app.get('/secure/game',this.getGame.bind(this));
	app.get('/secure/hand',this.getHand.bind(this));

	app.get('/secure/installers',this.installers_func.bind(this));
	app.post('/secure/installers',this.installers_func.bind(this));

	app.get('/secure/paypal',this.paypalLog.bind(this));
	app.post('/secure/newVersion',this.newVersion.bind(this));
	app.get('/secure/disk',this.getDisk.bind(this));
};
Server.prototype.addSync = function (app) {
	app.get('/sync/gitHook',this.gitHook.bind(this));
	app.post('/sync/newVersion',this.syncNewVersion.bind(this));
	app.post('/sync/newDiff',this.syncNewDiff.bind(this));
	app.post('/sync/assets',this.syncAssets.bind(this));
	app.get('/sync/assets',this.getAssets.bind(this));
};
Server.prototype.getAssets = function (req,res) {
	res.end(JSON.stringify(user.getAssets()));
}
Server.prototype.getHand = function (req,res) {
	var start = Date.now();
	models.HandHistory.findOne({_id:new ObjectID(req.query.id)},function (err,hand) {
		res.render('hand',{hand:hand,start:start});
	});
};
Server.prototype.createTourn = function (req,res) {
	res.render('tournament_create');
}
Server.prototype.createTournPost = function (req,res) {
	var str = req.body.start_date + ' ' + req.body.start_time;
	req.body.start_time = Math.round(new Date(str).getTime()/1000);
	Tournament.create(req.body,function (err) {
		if (err && ((err.name == 'ValidationError') || (err.name == 'CastError'))) {
			res.end(err.toString());
			return;
		}
		console.log('http body',req.body);
		res.end('test');
	});
}
Server.prototype.secureChangePasswordPost = function (req,res) {
	console.log(req.body);
	if (req.body.password != req.body.repeatPassword) {
		res.end('passwords dont match');
		return;
	}
	deck.getRandom(16,function (salt) {
		var hasher = crypto.createHash('sha256');
		hasher.update(salt);
		hasher.update(req.body.password);
		var hash = hasher.digest();
		models.Admin.findOne({username:req.session.username},function (err,instance) {
			assert.ifError(err);
			instance.password = hash;
			instance.salt = salt;
			instance.save(function (err) {
				assert.ifError(err);
				if (req.session.lastUrl) {
					res.writeHead(302,{Location:req.session.lastUrl});
				} else {
					res.writeHead(302,{Location:'/secure/'});
				}
				res.end('done');
			});
		});
	}.bind(this));
};
Server.prototype.secureLoginPost = function (req,res) {
	console.log(req.body);
	var username = req.body.username;
	var password = req.body.password;
	console.log('checking auth %s/%s',username,password);
	models.Admin.findOne({username:username},function (err,adminRow) {
		console.log('adminRow:%j',adminRow);
		if (adminRow) {
			if (!adminRow.salt) {
				if (adminRow.password == password) {
					req.session.authed = true;
					req.session.username = adminRow.username;
					res.writeHead(302,{Location:'/secure/changePassword'});
					res.end('sucess');
					return;
				}
			} else {
				var hasher = crypto.createHash('sha256');
				hasher.update(adminRow.salt);
				hasher.update(password);
				var hash = hasher.digest();
				if (hash.toString('hex') == adminRow.password.toString('hex')) {
					req.session.authed = true;
					req.session.username = adminRow.username;
					if (req.session.lastUrl) {
						res.writeHead(302,{Location:req.session.lastUrl});
					} else {
						res.writeHead(302,{Location:'/secure/'});
					}
					res.end('sucess');
					return;
				} else {
					res.end('no match');
					return;
				}
			}
		}
		res.end('fail');
	});
}
Server.prototype.getGame = function (req,res) {
	var start = Date.now();
	models.HandHistory.find({gameid:new ObjectID(req.query.id)}).limit(1000).sort({_id:-1}).exec(function (err,hands) {
		Game.getGame(new ObjectID(req.query.id),function (err,game) {
			game.Lock.writeLock(function (release) {
				res.render('game',{game:game,hands:hands,start:start,util:util});
				release();
			});
		});
	});
}
Server.prototype.getClub = function (req,res) {
	var start = Date.now();
	models.Clubs.findOne({_id:new ObjectID(req.query.id)},function (err,club) {
		var userids = [ club.owner ];
		if (club.members) {
			for (var x=0; x<club.members.length; x++) {
				userids.push(club.members[x]);
			}
		}
		models.Game.find({clubid:new ObjectID(req.query.id)},function (err,games) {
			// FIXME
			models.UserModel.collection.find({_id:{$in:userids}}).toArray(function (err,users) {
				var usermap = {};
				for (var x=0; x<users.length; x++) {
					usermap[users[x]._id] = users[x];
				}
				res.render('club',{club:club,games:games,start:start,users:usermap});
			});
		}.bind(this));
	}.bind(this));
}
Server.prototype.getClubs = function (req,res) {
	var start = Date.now();
	models.Clubs.find({},function (err,data) {
		res.render('clubs',{clubs:data,start:start});
	});
}
Server.prototype.changePassword = function (req,res) {
	res.render('changePassword');
}
Server.prototype.getBug = function (req,res) {
	var start = Date.now();
	models.Bugs.findOne({_id:new ObjectID(req.query.id)},function (err,row) {
		res.render('bug',{bug:row,start:start});
	});
}
Server.prototype.getScreenshot = function (req,res) {
	models.Bugs.findOne({_id:new ObjectID(req.query.id)},function (err,row) {
		res.set({"Content-Disposition":'filename="'+row._id+'.png"','Content-Type':'image/png'});
		res.send(row.ScreenShot);
	});
}
Server.prototype.secureIndex = function (req,res) {
	res.render('secure_index');
}
Server.prototype.secureLogin = function (req,res) {
	res.render('secure_login');
}
Server.prototype.secureLogout = function (req,res) {
	req.session.destroy(function (err) {
		res.writeHead(302,{Location:'/secure/login'});
		res.end('sucess');
	});
}
Server.prototype.bugList = function (req,res) {
	var start = Date.now();
	models.Bugs.find({},function (err,data) {
		res.render('bugs',{bugs:data,start:start});
	});
}
Server.prototype.ServerBugsList = function (req,res) {
	var start = Date.now();
	if (req.query.delete) {
		models.ServerError.remove({_id:req.query.delete},function () {});
	}
	models.ServerError.find().sort({_id:-1}).exec(function (err,data) {
		res.render('serverErrors',{rows:data,start:start});
	});
}
Server.prototype.userList = function (req,res) {
	var start = Date.now();
	models.UserModel.find({},function (err,data) {
		var sum = 0;
		for (var x=0; x<data.length; x++) {
			if (data[x].chips) sum += data[x].chips;
		}
		res.render('users',{users:data,start:start,sum:sum});
	});
}
Server.prototype.getUser = function (req,res) {
	var start = Date.now();
	models.UserModel.findById(req.query.id,function (err,row) {
		models.Clubs.find({$or:[ {members:new ObjectID(req.query.id)}, {owner:new ObjectID(req.query.id)} ]},function (err,clubs) {
			var self = this.activeUsers[row._id];
			var obj = {user:row,clubs:clubs,start:start,online:self,util:util}
			res.render('user',obj);
		}.bind(this));
	}.bind(this));
}
Server.prototype.installers_func = function (req,res) {
	var start = Date.now();
	console.log(req.body);
	var showlist = true;
	if (req.query.showlist) showlist = true;
	function makeDeleter(id) {
		return function (cb) {
			models.Installer.findOne({_id:new ObjectID(id)},function (err,row) {
				if (row) {
					fs.unlink('installers/'+row.name,function (err) {
					});
					row.remove(function () {});
				}
				// FIXME, delete the raw objects if they are unused
				cb();
			}.bind(this));
		}.bind(this);
	}
	function makeActivator(id) {
		return function (cb) {
			models.Installer.findOne({_id:new ObjectID(id)},function (err,row) {
				assert.ifError(err);
				if (row) {
					if (row.debug == 'release') {
						models.Config.findOne({_id:'installerid'},function (err,entry) {
							assert.ifError(err);
							entry.value = new ObjectID(id);
							entry.save(function (err) {
								assert.ifError(err);
								sharedconfig.latestVersion = row.version;
								cb();
							});
						});
					} else {
						models.Config.findOne({_id:'debuginstallerid'},function (err,entry) {
							assert.ifError(err);
							entry.value = new ObjectID(id);
							entry.save(function (err) {
								assert.ifError(err);
								sharedconfig.latestDebugVersion = row.version;
								cb();
							});
						});
					}
				} else cb();
			}.bind(this));
		}.bind(this)
	}
	var jobs = [];
	if (req.body) {
		if (req.body.activate_release) {
			jobs.push(makeActivator.call(this,req.body.activate_release));
		}
		if (req.body.activate_debug) {
			jobs.push(makeActivator.call(this,req.body.activate_debug));
		}
	}
	for (var key in req.body) {
		var res2 = /^delete_(.*)$/.exec(key);
		if (res2) {
			console.log(res2);
			jobs.push(makeDeleter.call(this,res2[1]));
		}
	}
	var latestVersion = '';
	var latestMsg = '';
	if (config.diffserver) {
		jobs.push(function (cb) {
			fs.readFile('/home/poker/gits/poker.git/refs/heads/master',{encoding:'utf8'},function (err,body) {
				latestVersion = body.trim();
				var child = child_process.spawn('git',['log','-1',latestVersion],{cwd:'/home/poker/gits/poker.git/',stdio:['pipe','pipe','pipe']});
				child.stdout.setEncoding('utf8');
				child.stdout.on('data',function (data) {
					latestMsg += data;
				});
				child.on('close',function () {
					cb();
				});
			});
		});
	}
	var user_stats;
	jobs.push(function (cb) {
		models.UserModel.collection.aggregate({$group:{_id:'$currentVersion',hits:{$sum:1}}},function (err,rows) {
			user_stats = rows;
			cb();
		});
	}.bind(this));
	console.log('jobs: %j', jobs);
	console.log('running jobs');
	async.parallel(jobs,finish2.bind(this));
	function finish2() {
		models.Installer.find().sort({_id:1}).exec(function(err,data) {
			models.Config.findOne({_id:'installerid'},function (err,row) {
				var activeRelease;
				for (var x=0; x<data.length; x++) {
					if (data[x]._id.toString() == row.value.toString()) {
						console.log(data[x]);
						activeRelease = data[x];
					}
					for (var y=0; y<user_stats.length; y++) {
						if (myutils.compareObjectID(data[x]._id,user_stats[y]._id)) {
							data[x].used_by = user_stats[y].hits;
							console.log(data[x]);
						}
					}
				}
				models.Config.findOne({_id:'debuginstallerid'},function (err,row2) {
					res.render('installers',{installers:data,start:start,pubver:row.value,debugver:row2.value,activeRelease:activeRelease,showlist:showlist,revision:latestVersion,latestMsg:latestMsg,diffserver:config.diffserver});
				});
			}.bind(this));
		}.bind(this));
	}
}
Server.prototype.goOnline = function () {
	this.httpServer.listen(3000);
}
Server.prototype.socketAuth = function (handshakeData,callback) {
	var parsed = false;
	var test = require('./node_modules/express/node_modules/connect');
	var cookieModule = require('./node_modules/express/node_modules/cookie');
	if (handshakeData.headers.cookie) {
		var cookies = cookieModule.parse(handshakeData.headers.cookie);
		parsed = test.utils.parseSignedCookies(cookies,'ahQu6eey');
	}
	if (parsed && parsed.poker) {
		this.sessionStore.get(parsed.poker,function (err,session) {
			if (session.authed) {
				callback(null,true);
			} else {
				callback(null,false);
			}
		});
	} else {
		callback(null,false);
	}
}
Server.prototype.isSecureAuthed = function (req,res,next) {
	if (req.session.authed) return next();
	if (req.url == '/login') {
		return next(); // allow the login page
	} else {
		req.session.lastUrl = req.originalUrl;
		res.writeHead(302,{Location:'/secure/login'});
		res.end('you must first login');
	}
}
Server.prototype.getDisk = function (req,res) {
	var start = Date.now();
	mongoose.connection.db.stats(function (err,stats) {
		mongoose.connection.db.collectionNames(function (err,names) {
			var out = [];
			var input = [];
			for (var x=0; x<names.length; x++) {
				input.push(names[x].name);
			}
			input.sort();
			async.eachLimit(input,1,function (item,cb) {
				mongoose.connection.db.collection(item.split('.')[1]).stats(function (err,stats) {
					if (!stats) {
						console.log('name:%s stats:',item,stats);
						cb();
						return;
					}
					out.push(stats);
					cb();
				});
			}.bind(this),function done(err) {
				res.render('disk',{dbstats:stats,start:start,stats:out});
			});
		}.bind(this));
	}.bind(this));
}
Server.prototype.confirmAccount = function (req,res) {
	if (!req.query.code) {
		res.send("error, code missing");
		return;
	}
	if (req.query.code.length != 36) {
		res.send(badConfLink);
		return;
	}
	models.UserModel.findOne({authcode:req.query.code},function (err,user) {
		if (!user) {
			res.send(badConfLink);
			return;
		}
		user.authed = true;
		delete user.authcode;
		user.save(function (err) {
			assert.ifError(err);
			console.log('email confirm time',user);
			res.send("E-Mail address successfully verified.");
			var conn = this.activeUsers[user._id];
			if (!conn) return;
			// FIXME
			models.UserModel.collection.findOne({_id:user._id},function (err,self) {
				conn.send(codes.seAccountConfirmed,self,'Poker.User');
			});
		}.bind(this));
	}.bind(this));
}
Server.prototype.confirmChange = function (req,res) {
	if (!req.query.code) {
		res.send("error, code missing");
		return;
	}
	if (req.query.code.length != 36) {
		res.send(badConfLink);
		return;
	}
	models.UserModel.findOne({changecode:req.query.code},function (err,user) {
		if (!user) {
			res.send(badConfLink);
			return;
		}
		var age = Date.now() - user.changetime;
		console.log('code age',age);
		if (age > (sharedconfig.ChangeExpireTime*1000)) {
			delete user.changecode;
			delete user.changetime;
			user.save(function (err) {
				assert.ifError(err);
				res.send("error, change code expired");
			}.bind(this));
			return;
		}
		user.email = user.newemail;
		user.authed = true;
		delete user.newemail;
		delete user.changecode;
		delete user.authcode;
		user.save(function (err) {
			assert.ifError(err);
			console.log('email change time',user);
			res.send("E-Mail address successfully changed.");
			var conn = this.activeUsers[user._id];
			if (!conn) return;
			// FIXME
			models.UserModel.collection.findOne({_id:user._id},function (err,self) {
				conn.send(codes.seAccountConfirmed,self,'Poker.User');
			});
		}.bind(this));
	}.bind(this));
}
Server.prototype.passwordReset = function (req,res) {
	if (!req.query.code) {
		res.send("error, code missing");
		return;
	}
	if (req.query.code.length != 36) {
		res.send(badConfLink);
		return;
	}
	models.UserModel.findOne({forgotcode:req.query.code},function (err,user) {
		if (!user) {
			res.send(badConfLink);
			return;
		}
		var age = Date.now() - user.forgottime;
		console.log('reset code age',age);
		if (age > (sharedconfig.ForgotExpireTime*1000)) {
			delete user.forgotcode;
			delete user.forgottime;
			user.save(function (err) {
				assert.ifError(err);
				res.send("Password reset link expired.");
			}.bind(this));
			return;
		}
		var newpassword = generatePassword();
		deck.getRandom(16,function (salt) {
			var hasher = crypto.createHash('sha256');
			hasher.update(salt);
			hasher.update(newpassword);
			var hash = hasher.digest();
			user.password = hash;
			user.salt = salt;
			delete user.forgotcode;
			delete user.forgottime;
			user.save(function (err) {
				assert.ifError(err);
				console.log('password change time',user);
				res.send("Password changed, new password sent to your E-Mail.");
				var test = new SmtpConnection();
				var message = emailChange2({password:newpassword});
				test.sendMail(user.email,'From: ChipUP Poker <service@chipuppoker.com>\r\nTo: '+user.displayname+'<'+user.email+'>\r\nContent-Type: text/html\r\nSubject: New Password Issued\r\n\r\n'+message,function cb(err,ret) {
					console.log('cb',err,ret);
					if (err) {
						console.log('password reset email error',err);
						return;
					}
				});
			});
		}.bind(this));
	}.bind(this));
}
Server.prototype.errorUpload = function (req,res) {
	// fields are req.body.MailFrom MailSubject MailBody
	var body = req.body;
	var doc = { MailFrom:body.MailFrom, MailSubject:body.MailSubject, MailBody:body.MailBody };
	async.parallel([function (cb1) {
		fs.readFile(req.files.ScreenShot.path,function (err,data) {
			doc.ScreenShot = data;
			fs.unlink(req.files.ScreenShot.path);
			cb1();
		});
		},function (cb2) {
		fs.readFile(req.files.BugReport.path,{encoding:'utf8'},function (err,data) {
			doc.BugReport = data;
			fs.unlink(req.files.BugReport.path);
			cb2();
		});
		}],function done() {
			var obj = new models.Bugs(doc);
			obj.save(function (err) {
				console.log(err,obj);
				res.send(200);
			});
		}.bind(this));
}
/*Server.prototype.fetchHands = function (req,res) {
	// FIXME
	var token = profiler.start('fetchhands-outer');
	// new Buffer(g._id.toString(),'hex')
	FetchQueue.findOne({querycode:req.query.uuid},function (err,query) {
		assert.ifError(err);
		console.log(query.query);
		console.log('query size %d',JSON.stringify(query).length);
		var reqs = query.query.games;
		async.each(reqs,function (req,cb) {
			console.log('finding all history in game %j',req.gameid.buffer);
			handHistory.find({gameid:toMongoId(req.gameid.buffer),seq:{$gt:req.lasthandid}},{seq:1,totalrake:1,players:1,cards:1,endtime:1,balance_changes:1}).toArray(function (res2,hands) {
				var token2 = profiler.start('fetchhands-inner1');
				var start = Date.now();
				assert.ifError(err);
				for (var x=0; x<hands.length; x++) {
					var row = hands[x];
					if (!row.balance_changes) {
						console.log('balance_changes missing on hh %s',row._id);
						hands[x] = null;
						continue;
					}
					if (!row.totalrake) {
						console.log('totalrake missing on hh %s',row._id);
						hands[x] = null;
						continue;
					}
					row._id = fromMongoId(row._id);
					row.tablecards = [];
				}
				var end = Date.now();
				token2.stop();
				log('did %d hands in %dms',hands.length,end-start);
				models.Game.findOne({_id:toMongoId(req.gameid.buffer)},{clubid:1},function (err,game) {
					assert.ifError(err);
					GameEvents.find({gameid:game._id}).toArray(function (err,events) {
						var start = Date.now();
						var obj = {clubid: fromMongoId(game.clubid), gameid: req.gameid.buffer, rows:hands, events:events};

						var token2 = profiler.start('fetchhands-inner2');
						var out = pb.Serialize({reply:[obj]},'Poker.FetchHandHistoryReply');
						var end = Date.now();
						log('serialized in %dms',end-start);
						token2.stop();
						res.write(out);
						cb();
					});
				});
			});
		},function done() {
			//res.writeHead(200,{'Content-Length': out.length});
			res.end();
			token.stop();
		});
	});
}*/
Server.prototype.getAvatar = function (req,res) {
	var id = req.query.id;
	global.log('getting avatar %j %d %s',req.query,id.length,id);
	if (id == 'default') {
		fs.readFile('resources/default_avatar.jpg',function (err,data) {
			if (err) throw err;
			res.send(data);
		});
		return;
	}
	var raw = new Buffer(id,'hex');
	var base64 = raw.toString('base64');
	models.Avatars.findOne({_id:base64},function (err,row) {
		if (!row) {
			res.send(404);
			return;
		}
		var filename = req.query.id+"."+row.ext;
		console.log(filename);
		res.set({"Content-Disposition":'attachment; filename="'+filename+'"'});
		res.send(row.image);
	});
}
Server.prototype.uploadAvatar = function (req,res) {
	//console.log('files',req.headers);
	//console.log('version',req.httpVersionMajor,req.httpVersionMinor);
	fs.readFile(req.files.avatar.path,function (err,data) {
		var extension = req.files.avatar.originalFilename.split('.').pop();
		var hasher = crypto.createHash('sha256');
		hasher.update(data);
		var hash = hasher.digest('base64');
		models.Avatars.findOne({_id:hash},function (err,row) {
			if (err) {
				console.log('error',err);
				res.send(JSON.stringify({error:err}));
				return;
			}
			if (row) {
				var out = new Buffer(hash,'base64');
				console.log('sending dup id',out);
				res.send(200,out);
			} else {
				var obj = new models.Avatars({_id:hash,image:data,size:data.length,created:Date.now(),ext:extension});
				obj.save(function (err) {
					if (err) {
						console.log('error',err);
						res.send(JSON.stringify(err));
						return;
					}
					var out = new Buffer(obj._id,'base64');
					//console.log('sending unique id',out);
					res.send(200,out);
					fs.unlink(req.files.avatar.path);
				});
			}
		}.bind(this));
	}.bind(this));
}
Server.prototype.gitHook = function (req,res) {
	res.end();
	fs.readFile('/home/poker/gits/poker.git/refs/heads/master',{encoding:'utf8'},function (err,body) {
		var latestVersion = body.trim();
		var latestMsg = '';
		var child = child_process.spawn('git',['log','-1',latestVersion],{cwd:'/home/poker/gits/poker.git/',stdio:['pipe','pipe','pipe']});
		child.stdout.setEncoding('utf8');
		child.stdout.on('data',function (data) {
			latestMsg += data;
		});
		child.on('close',function () {
			this.IO.sockets.emit('new_revision',{hash:latestVersion,msg:latestMsg});
		}.bind(this));
	}.bind(this));
}
Server.prototype.newVersion = function newVersion(req,res) {
	// FIXME, add basicAuth
	console.log('query',req.query);
	console.log('files',req.files);
	var name1 = req.files.installer.path.split('/')[1];
	console.log(name1);
	var version = req.query.version;
	if (!version) version = req.body.version;

	var revision = req.query.revision;
	if (!revision) revision = req.body.revision;

	var debug = req.query.debug;
	if (!debug) debug = req.body.debug;

	fs.rename(req.files.installer.path,'installers/'+name1,function (err) {
		assert.ifError(err);
		var obj = new models.Installer({name:name1,version:version,revision:revision,debug:debug,size:req.files.installer.size});
		obj.save(function (err) {
			assert.ifError(err);
			global.log('new version recorded: %j',obj);
			installer.unpackInstaller(obj,function (success) {
				var key1;
				if (success) {
					if (debug == 'debug') key1 = 'debuginstallerid';
					else key1 = 'installerid';
					//Config.update({_id:key1},{$set:{value:row[0]._id}},function(err,res2) {
					//	assert.ifError(err);
					//});
					obj.ts = obj._id.getTimestamp().toString();
					this.IO.sockets.emit('new_installer',obj);
					res.send('OK');
				} else {
					res.send('error');
				}
			}.bind(this));
		}.bind(this));
	}.bind(this));
}
Server.prototype.syncAssets = function (req,res) {
	console.log(req.body);
	user.assetSync(req.body);
	res.end('OK');
};
Server.prototype.syncNewVersion = function (req,res) {
	console.log(req.body);
	req.body.installer._id = new ObjectID(req.body.installer._id);
	var obj = new models.Installer(req.body.installer);
	obj.save(function (err,reply) {
		console.log(err,reply);
		async.each(req.body.sizes,function (row,cb) {
			models.ObjectSize.create(row,cb);
		}.bind(this),function () {
			res.end('OK');
		});
	}.bind(this));
}
Server.prototype.paypalCallback = function (req,res) {
	var host;
	if (req.body.test_ipn) host = 'www.sandbox.paypal.com';
	else host = 'www.paypal.com';
	var raw_post = [];
	for (var key in req.body) {
		raw_post.push(key+'='+escape(req.body[key]));
	}
	raw_post.push('cmd=_notify-validate');
	raw_post = raw_post.join('&');
	var req2 = https.request({
		hostname:host,
		port:443,
		path:'/cgi-bin/webscr',
		method:'POST',
		headers:{
			'Content-length':raw_post.length
		}},function (res2) {
			res2.setEncoding('utf8');
			var buffer = '';
			res2.on('data',function (chunk) {
				buffer += chunk;
			});
			res2.on('end',function () {
				if ((res2.statusCode == 200) && (buffer.trim() == 'VERIFIED')) {
					console.log('all good');
					console.log(req.body);
					models.IPN_Hit.create({reply:buffer.trim(),params:req.body},function (err,doc) {
						assert.ifError(err);
						res.send(200,'');
					});
				} else {
					res.send(500,'problem verifying data');
					console.log('error, reply:',buffer);
					console.log(res2.statusCode,res2.headers);
				}
			}.bind(this));
		}.bind(this));
	req2.write(raw_post);
	req2.end();
}
Server.prototype.paypalLog = function (req,res) {
	models.IPN_Hit.find(function (err,rows) {
		res.render('paypal_secure',{rows:rows});
	});
}
Server.prototype.contactPost = function (req,res) {
	console.log(req.body);
	RT.postTicket(req.body.type,req.body.name+" <"+req.body.email+">",req.body.message,function () {
		res.writeHead(302,{Location:'/contact.html?success=true'}); // FIXME
		res.end();
	});
}
