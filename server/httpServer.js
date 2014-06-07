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

var config = require('./config');
var MongoStore = require('./mongoStore');

var Game = require('./game').Game;
var deck = require('./deck');
var myutils = require('./myutils');
var buildbot = require('./buildbot');
var installer = require('./installer');

module.exports.initHttpServer = initHttpServer;

var sharedconfig,log;

function initHttpServer(db,activeUsers,sharedconfigIN,logIN) {
	sharedconfig = sharedconfigIN;
	log = logIN;
	var server = new Server(db,activeUsers);
	return server;
}

function Server(db,activeUsersIN) {
	var app = express();
	this.httpServer = http.createServer(app);
	this.db = db;
	var io = require('socket.io').listen(this.httpServer,{log:false});
	var logger = require('morgan');
	app.use(logger());
	this.activeUsers = activeUsersIN;
	var PokerProfile = db.collection('PokerProfile');
	this.bugs = db.collection('bugs');
	this.serverErrors = db.collection('serverErrors');
	this.users = db.collection('users');
	this.clubs = db.collection('clubs');
	this.games = db.collection('games');
	this.handHistory = db.collection('handHistory');
	this.admin = db.collection('admin');
	this.installers = db.collection('installers');
	this.config = db.collection('config');
	this.avatars = db.collection('avatars');

	this.sessionStore = new MongoStore(db,'sessions');
	io.set('authorization',this.socketAuth.bind(this));
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

	app.get('/secure/reports',function (req,res) {
		if (req.query.close) {
			db.collection('contacts').update({_id:new ObjectID(req.query.close)},{$set:{closed:true}},function (err) {
				console.log(err);
			});
		}
		db.collection('contacts').find({closed:false}).toArray(function (err,reports) {
			var userids = [];
			for (var x=0; x<reports.length; x++) {
				userids.push(reports[x].userid);
			}
			this.users.find({_id:{$in:userids}}).toArray(function (err,users) {
				var usermap = {};
				for (var x=0; x<users.length; x++) {
					usermap[users[x]._id] = users[x];
				}
				res.render('reports',{reports:reports,users:usermap});
			});
		}.bind(this));
	}.bind(this));
	app.get('/secure/performance',function (req,res) {
		var start = Date.now();
		db.collection('system.profile').find({}).limit(50).sort({ts:-1}).toArray(function (err,rows) {
			res.render('profile',{rows:rows,start:start});
		});
	});
	app.get('/secure/profile',function (req,res) {
		var start = Date.now();
		PokerProfile.aggregate({$group:{_id:'$tag', avg:{$avg:'$time'}, hits:{$sum:1} }}, function (err,rows) {
			PokerProfile.find({time:{$gt:2000}}).toArray(function (err,list) {
				res.render('profile2',{rows:rows,start:start,rawlist:list});
			});
		});
	});
	app.get('/secure/disk',this.getDisk.bind(this));
	app.get('/secure/billing',function (req,res) {
		var start = Date.now();
		db.collection('billing').find({TotalCost:{$gt:0}},{ProductCode:1,ProductName:1,UsageType:1,ItemDescription:1,CostBeforeTax:1,TotalCost:1,UsageQuantity:1,"user:Name":1,"user:service":1,year:1,month:1}).toArray(function (err,rows) {
			res.render('billing',{billing:rows,start:start});
		});
	});
	app.get('/confirm',this.confirmAccount.bind(this));
	app.post('/secure/club_public',function (req,res) {
		Club.getClubById(new ObjectID(req.body.clubid),function (err,clubObj) {
			assert.ifError(err);
			clubObj.goPublic(function (msg) {
				res.end(msg);
			});
		});
	});
	app.get('/confirmchange',this.confirmChange.bind(this));
	app.get("/passwordreset",this.passwordReset.bind(this));
	app.post("/uploadAvatar",function (req,res) {
		console.log('files',req.headers);
		console.log('version',req.httpVersionMajor,req.httpVersionMinor);
		fs.readFile(req.files.avatar.path,function (err,data) {
			var extension = req.files.avatar.originalFilename.split('.').pop();
			var hasher = crypto.createHash('sha256');
			hasher.update(data);
			var hash = hasher.digest('base64');
			this.avatars.findOne({_id:hash},function (err,row) {
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
					avatars.insert({_id:hash,image:data,size:data.length,created:Date.now(),ext:extension},function (err,row) {
						if (err) {
							console.log('error',err);
							res.send(JSON.stringify(err));
							return;
						}
						var out = new Buffer(row[0]._id,'base64');
						console.log('sending unique id',out);
						res.send(200,out);
						fs.unlink(req.files.avatar.path);
					});
				}
			});
		}.bind(this));
	}.bind(this));
	app.post('/paypal_callback',function (req,res) {
		if (req.body.test_ipn) var host = 'www.sandbox.paypal.com';
		else var host = 'www.paypal.com';
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
						db.collection('IPN_hits').insert({reply:buffer.trim(),params:req.body},function (err,doc) {
							assert.ifError(err);
							res.send(200,'');
						});
					} else {
						res.send(500,'problem verifying data');
						console.log('error, reply:',buffer);
						console.log(res2.statusCode,res2.headers);
					}
				});
			});
		req2.write(raw_post);
		req2.end();
	});
	app.get('/paypal',function (req,res) {
		res.render('paypal');
	});
	app.get('/secure/paypal',function (req,res) {
		db.collection('IPN_hits').find().toArray(function (err,rows) {
			res.render('paypal_secure',{rows:rows});
		})
	});
	app.post('/error_upload',this,errorUpload.bind(this));
	app.get("/test",function (req,res) {
		res.send("<form method='post' action='/image_upload' enctype='multipart/form-data'><input type='file' name='avatar'><input type='submit'></form>");
	});
app.get("/getavatar",function (req,res) {
	var id = req.query.id;
	log('getting avatar %j %d %s',req.query,id.length,id);
	if (id == 'default') {
		fs.readFile('resources/default_avatar.jpg',function (err,data) {
			if (err) throw err;
			res.send(data);
		});
		return;
	}
	var raw = new Buffer(id,'hex');
	var base64 = raw.toString('base64');
	avatars.findOne({_id:base64},function (err,row) {
		if (!row) {
			res.send(404);
			return;
		}
		var filename = req.query.id+"."+row.ext;
		console.log(filename);
		res.set({"Content-Disposition":'attachment; filename="'+filename+'"'});
		res.send(row.image.buffer);
	});
});
app.get("/install_chipuppoker.exe",function (req,res) {
	this.config.findOne({_id:'installerid'},function (err,row) {
		assert.ifError(err);
		this.installers.findOne({_id:row.value},function (err,row) {
			log('sending installer %j',row);
			res.sendfile('installers/'+row.name);
		});
	}.bind(this));
}.bind(this));
app.get("/debug_install_chipuppoker.exe",function (req,res) {
	this.config.findOne({_id:'debuginstallerid'},function (err,row) {
		assert.ifError(err);
		this.installers.findOne({_id:row.value},function (err,row) {
			log('sending debug installer %j',row);
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
	app.post('/contactPost',function (req,res) {
		console.log(req.body);
		RT.postTicket(req.body.type,req.body.name+" <"+req.body.email+">",req.body.message,function () {
			res.writeHead(302,{Location:'http://testing.chipuppoker.com/contact.html?success=true'}); // FIXME
			res.end();
		});
	});
	function newVersion(req,res) {
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
			this.installers.insert({name:name1,version:version,revision:revision,debug:debug,size:req.files.installer.size},function (err,row) {
				assert.ifError(err);
				log('new version recorded: %j',row);
				installer.unpackInstaller(io,row[0],db.collection('installers'),db.collection('objectSizes'),function (success) {
					if (success) {
						if (debug == 'debug') var key1 = 'debuginstallerid';
						else var key1 = 'installerid';
						//Config.update({_id:key1},{$set:{value:row[0]._id}},function(err,res2) {
						//	assert.ifError(err);
						//});
						row[0].ts = row[0]._id.getTimestamp().toString();
						io.sockets.emit('new_installer',row[0]);
						res.send('OK');
					} else {
						res.send('error');
					}
				});
			});
		}.bind(this));
	}
	app.post('/newVersion',newVersion.bind(this));
	app.post('/secure/newVersion',newVersion.bind(this));
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
app.get('/fetchhands',function (req,res) {
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
				allGames.findOne({_id:toMongoId(req.gameid.buffer)},{clubid:1},function (err,game) {
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
});
	app.post('/sync/newVersion',function (req,res) {
		console.log(req.body);
		req.body.installer._id = new ObjectID(req.body.installer._id);
		conn.collection('installers').save(req.body.installer,function (err,reply) {
			console.log(err,reply);
			async.each(req.body.sizes,function (row,cb) {
				conn.collection('objectSizes').save(row,cb);
			},function () {
				res.end('OK');
			});
		});
	});
	app.post('/sync/makeDiff',function (req,res) {
		var t = req.body;
		makeDiff(t.sourcehash,t.desthash,t.path);
		res.end('STARTED');
	});
	app.post('/secure/buildbot',function (req,res) {
		console.log(req.body);
		buildbot.doLogin(function () {
			buildbot.forceBuild('debug-win32',req.body.revision);
			buildbot.forceBuild('release-win32',req.body.revision);
			res.end(JSON.stringify('OK'));
		});
	});
	app.post('/sync/newDiff',function (req,res) {
		var doc = req.body;
		doc._id = new ObjectID(doc._id);
		conn.collection('diffs').save(doc,function (err,rows) {
			res.end('OK');
		});
	});
	app.get('/sync/gitHook',function (req,res) {
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
				io.sockets.emit('new_revision',{hash:latestVersion,msg:latestMsg});
			});
		});
	});
	app.use(express.static('files'));
	app.use('/rawinstallers',express.static('installers'));
}
Server.prototype.getHand = function (req,res) {
	var start = Date.now();
	this.handHistory.findOne({_id:new ObjectID(req.query.id)},function (err,hand) {
		res.render('hand',{hand:hand,start:start});
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
		this.admin.update({username:req.session.username},{$set:{password:hash, salt:salt }},function (err,rows) {
			assert.ifError(err);
			if (req.session.lastUrl) {
				res.writeHead(302,{Location:req.session.lastUrl});
			} else {
				res.writeHead(302,{Location:'/secure/'});
			}
			res.end('done');
		});
	}.bind(this));
}
Server.prototype.secureLoginPost = function (req,res) {
	var username = req.body.username;
	var password = req.body.password;
	console.log('checking auth %s/%s',username,password);
	this.admin.findOne({username:username},function (err,adminRow) {
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
				hasher.update(adminRow.salt.buffer);
				hasher.update(password);
				var hash = hasher.digest();
				if (hash.toString('hex') == adminRow.password.buffer.toString('hex')) {
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
	this.handHistory.find({gameid:new ObjectID(req.query.id)}).limit(1000).sort({_id:-1}).toArray(function (err,hands) {
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
	this.clubs.findOne({_id:new ObjectID(req.query.id)},function (err,club) {
		var userids = [ club.owner ];
		if (club.members) {
			for (var x=0; x<club.members.length; x++) {
				userids.push(club.members[x]);
			}
		}
		this.games.find({clubid:new ObjectID(req.query.id)}).toArray(function (err,games) {
			this.users.find({_id:{$in:userids}}).toArray(function (err,users) {
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
	this.clubs.find({}).toArray(function (err,data) {
		res.render('clubs',{clubs:data,start:start});
	});
}
Server.prototype.changePassword = function (req,res) {
	res.render('changePassword');
}
Server.prototype.getBug = function (req,res) {
	var start = Date.now();
	this.bugs.findOne({_id:new ObjectID(req.query.id)},function (err,row) {
		res.render('bug',{bug:row,start:start});
	});
}
Server.prototype.getScreenshot = function (req,res) {
	this.bugs.findOne({_id:new ObjectID(req.query.id)},function (err,row) {
		res.set({"Content-Disposition":'filename="'+row._id+'.png"','Content-Type':'image/png'});
		res.send(row.ScreenShot.buffer);
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
	this.bugs.find({}).toArray(function (err,data) {
		res.render('bugs',{bugs:data,start:start});
	});
}
Server.prototype.ServerBugsList = function (req,res) {
	var start = Date.now();
	if (req.query.delete) {
		this.serverErrors.remove({_id:new ObjectID(req.query.delete)},function () {});
	}
	this.serverErrors.find().sort({_id:-1}).toArray(function (err,data) {
		res.render('serverErrors',{rows:data,start:start});
	});
}
Server.prototype.userList = function (req,res) {
	var start = Date.now();
	this.users.find({}).toArray(function (err,data) {
		var sum = 0;
		for (var x=0; x<data.length; x++) {
			if (data[x].chips) sum += data[x].chips;
		}
		res.render('users',{users:data,start:start,sum:sum});
	});
}
Server.prototype.getUser = function (req,res) {
	var start = Date.now();
	this.users.findOne({_id:new ObjectID(req.query.id)},function (err,row) {
		this.clubs.find({$or:[ {members:new ObjectID(req.query.id)}, {owner:new ObjectID(req.query.id)} ]}).toArray(function (err,clubs) {
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
			this.installers.findOne({_id:new ObjectID(id)},function (err,row) {
				if (row) {
					fs.unlink('installers/'+row.name,function (err) {
						console.log('installer deleted');
					});
				}
				this.installers.remove({_id:new ObjectID(id)},function () {});
				cb();
			}.bind(this));
		}.bind(this);
	}
	function makeActivator(id) {
		return function (cb) {
			this.installers.findOne({_id:new ObjectID(id)},function (err,row) {
				assert.ifError(err);
				if (row) {
					if (row.debug == 'release') {
						this.config.update({_id:'installerid'},{$set:{value:new ObjectID(id)}},function(err,res) {
							assert.ifError(err);
							sharedconfig.latestVersion = row.version;
							cb();
						});
					} else {
						this.config.update({_id:'debuginstallerid'},{$set:{value:new ObjectID(id)}},function(err,res) {
							assert.ifError(err);
							sharedconfig.latestDebugVersion = row.version;
							cb();
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
		this.users.aggregate({$group:{_id:'$currentVersion',hits:{$sum:1}}},function (err,rows) {
			user_stats = rows;
			cb();
		});
	}.bind(this));
	console.log('jobs: %j', jobs);
	console.log('running jobs');
	async.parallel(jobs,finish2.bind(this));
	function finish2() {
		this.installers.find({}).sort({_id:1}).toArray(function(err,data) {
			this.config.findOne({_id:'installerid'},function (err,row) {
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
				this.config.findOne({_id:'debuginstallerid'},function (err,row2) {
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
	var test = require('./node_modules/express/node_modules/connect');
	var cookieModule = require('./node_modules/express/node_modules/cookie');
	if (handshakeData.headers.cookie) {
		var cookies = cookieModule.parse(handshakeData.headers.cookie);
		var parsed = test.utils.parseSignedCookies(cookies,'ahQu6eey');
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
		log('unauthorized ip: %s',ip);
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
	this.db.stats(function (err,stats) {
		this.db.collectionNames(function (err,names) {
			var out = [];
			var input = [];
			for (var x=0; x<names.length; x++) {
				input.push(names[x].name);
			}
			input.sort();
			async.eachLimit(input,1,function (item,cb) {
				this.db.collection(item.split('.')[1]).stats(function (err,stats) {
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
	this.users.findOne({authcode:req.query.code},function (err,user) {
		if (!user) {
			res.send(badConfLink);
			return;
		}
		this.users.update({_id:user._id},{$set:{authed:true},$unset:{authcode:""}},function (err,result) {
			console.log('email confirm time',user);
			res.send("E-Mail address successfully verified.");
			var conn = activeUsers[user._id];
			if (!conn) return;
			this.users.findOne({_id:user._id},function (err,self) {
				conn.send(codes.seAccountConfirmed,makeUserProtobuf(self),'Poker.User');
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
	this.users.findOne({changecode:req.query.code},function (err,user) {
		if (!user) {
			res.send(badConfLink);
			return;
		}
		var age = Date.now() - user.changetime;
		console.log('code age',age);
		if (age > (sharedconfig.ChangeExpireTime*1000)) {
			this.users.update({_id:user._id},{$unset:{changecode:"",changetime:""}},function (err,updated) {
				res.send("error, change code expired");
			}.bind(this));
			return;
		}
		this.users.update({_id:user._id},{$set:{email:user.newemail,authed:true},$unset:{newemail:"",changecode:"",authcode:""}},function (err,result) {
			console.log('email change time',user);
			res.send("E-Mail address successfully changed.");
			var conn = activeUsers[user._id];
			if (!conn) return;
			this.users.findOne({_id:user._id},function (err,self) {
				conn.send(codes.seAccountConfirmed,makeUserProtobuf(self),'Poker.User');
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
	this.users.findOne({forgotcode:req.query.code},function (err,user) {
		if (!user) {
			res.send(badConfLink);
			return;
		}
		var age = Date.now() - user.forgottime;
		console.log('reset code age',age);
		if (age > (sharedconfig.ForgotExpireTime*1000)) {
			this.users.update({_id:user._id},{$unset:{forgotcode:"",forgottime:""}},function (err,updated) {
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
			this.users.update({_id:user._id},{$set:{password:hash,salt:salt},$unset:{forgotcode:"",forgottime:""}},function (err,result) {
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
			this.bugs.insert(doc,function (err,result) {
				console.log(result);
				res.send(200);
			});
		}.bind(this));
}
