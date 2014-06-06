#!/usr/bin/node
"use strict";
// http://docs.mongodb.org/manual/reference/operator/update/positional/
var net = require('net');
var tls = require('tls');
var fs = require('fs');
var MongoClient = require('mongodb').MongoClient;
var Collection = require('mongodb').Collection;
var ObjectID = require('mongodb').ObjectID
//var Reader = require('./reader').reader;
var express = require('express');
var uuid = require('node-uuid');
var generatePassword = require('password-generator');
var crypto = require('crypto');
var p = require("node-protobuf").Protobuf;
var https = require('https');
var assert = require('assert');
var util = require('util');
var async = require('async');
var jade = require('jade');
var child_process = require('child_process');
var http = require('http');

var SmtpConnection = require('./smtp');
var ReadWriteLock = require('./lock'); // FIXME, send them a PR?, fork it?, it came from the rwlock npm package
var deck = require('./deck');
var codes = require('./ServerCodes');
var dag = require('./dag/build/Release/dag');
var bugsView = require('./bugs');
var profiler = require('./profiler');
var Club = require('./club');
var makeGameProtobuf = require('./game').makeGameProtobuf;
var RT = require('./rt');
var omaha2 = require('./dag2/omaha');
var config = require('./config');
var buildbot = require('./buildbot');
var MongoStore = require('./mongoStore');

var Deck = deck.Deck;
var Hand = deck.Hand;

var pb = new p(fs.readFileSync("../message.desc"));
var protoreader = require('./protoreader');
protoreader.init(pb,codes,[codes.seTableStatus,codes.seTableEvent,codes.srPong]);

dag.init();

// stats
var hands = 0;

var domain = "http://"+config.hostname+'/';
var staticdomain = "http://"+config.staticserver+'/';
var sharedconfig = {stringSizes:{},minSizes:{},max_play_time:15,max_timebank:30};
sharedconfig.minSizes.email = 6;
sharedconfig.stringSizes.email = 200;
sharedconfig.minSizes.password = 6;
sharedconfig.stringSizes.password = 32;
sharedconfig.minSizes.clubname = 5;
sharedconfig.stringSizes.clubname = 64;
sharedconfig.minSizes.invcode = 3;
sharedconfig.stringSizes.invcode = 32;
sharedconfig.minSizes.username = 3;
sharedconfig.stringSizes.username = 20;
sharedconfig.minSizes.gamename = 3;
sharedconfig.stringSizes.gamename = 32;
sharedconfig.minSizes.ContactMessage = 10;
sharedconfig.stringSizes.ContactMessage = 1000;
sharedconfig.ChangeExpireTime = 3600 * 24;
sharedconfig.ForgotExpireTime = 3600;
var regexLimits;
function initConfig() {
	var regex = {};
	regex.email = '^[a-zA-Z0-9\\.+]+@[a-zA-Z0-9\\.]+$';
	regex.username = '^[a-zA-Z0-9 _\\. -]{3,20}$';
	regex.password = '^[a-zA-Z0-9_\\!@#$%^&*\\(\\)+=~`\\.-]{6,32}$';
	regex.clubname = "^[a-zA-Z0-9!()\\[\\]{}@#$%&*+=/\\' -]{5,64}$";
	regex.clubpassword = '^[a-zA-Z0-9]{3,32}$';
	regex.gamename = "^[a-zA-Z0-9!()\\[\\]{}@#$%&*+=/\\' -]{3,32}$";
	sharedconfig.valid_chars_regex = regex;
	var regex2 = {};
	for (var key in regex) {
		regex2[key] = new RegExp(regex[key]);
	}
	regexLimits = regex2;
}
initConfig();
var badConfLink = "Invalid confirmation link.";

var activeUsers = {};
var activeGames = {};

var app = express();
var sessionStore;
var httpServer = http.createServer(app);
var io = require('socket.io').listen(httpServer);
io.set('authorization',function (handshakeData,callback) {
	var test = require('./node_modules/express/node_modules/connect');
	var cookieModule = require('./node_modules/express/node_modules/cookie');
	if (handshakeData.headers.cookie) {
		var cookies = cookieModule.parse(handshakeData.headers.cookie);
		var parsed = test.utils.parseSignedCookies(cookies,'ahQu6eey');
	}
	if (parsed && parsed.poker) {
		sessionStore.get(parsed.poker,function (err,session) {
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
});
var logger = require('morgan');
var bsdiffLock = new ReadWriteLock();
var getGameLock = new ReadWriteLock();
app.use(logger());
function unpackInstaller(row,cb1) {
	function updateLive(doc,sizes,cb) {
		var body = new Buffer(JSON.stringify({installer:doc,sizes:sizes}));
		var req = http.request({host:'chipuppoker.com',method:'POST',path:'/sync/newVersion',headers:{'Content-Length':body.length,'Content-Type':'application/json'},auth:'sync:'+config.syncpassword});
		req.on('data',function (chunk) {
			console.log(chunk);
		});
		req.write(body);
		req.end();
		cb();
	}
	function hashFiles(files) {
		var key = {_id:row._id};
		var hashes = {};
		var sizes = [];
		var mods = { $set:{hashes:hashes}};
		async.each(files,function hashFile(filename,cb2) {
			var hasher = crypto.createHash('sha256');
			var client = fs.createReadStream('unpacked/'+row._id+'/app/'+filename);
			var size = 0;
			client.on('data',function (data) {
				hasher.update(data);
				size += data.length;
			});
			client.on('end',function () {
				var hash = hasher.digest('hex');
				console.log('hash of %s is %s',filename,hash);
				var key = filename.replace('.','_');
				sizes.push({_id:hash, size:size});
				hashes[key] = hash;
				copyFile('unpacked/'+row._id+'/app/'+filename,'unpacked/objects/'+hash,function () {
					fs.unlink('unpacked/'+row._id+'/app/'+filename,function () {
						cb2();
					});
				});
			});
		},function () {
			conn.collection('installers').update(key,mods,function (err,newdoc) {
				assert.ifError(err);
				if (err) console.log(err);
				console.log('inserted %j',newdoc);
				fs.rmdir('unpacked/'+row._id+'/app/',function () {
					fs.rmdir('unpacked/'+row._id,function () {
						conn.collection('installers').findOne(key,function (err,doc) {
							async.each(sizes,function (row,cb) {
								conn.collection('objectSizes').save(row,cb);
							},function () {
								updateLive(doc,sizes,function () {
									cb1(true);
								});
							});
						});
					});
				});
			});
		});
	}
	function recurse_dir(path,prefix,cb4) {
		var items = [];
		fs.readdir(prefix+path,function (err,files) {
			console.log('checked path %s %s',prefix,path);
			assert.ifError(err);
			async.each(files,function checkItem(filename,cb3) {
				fs.stat(prefix+path+filename,function (err,stats) {
					assert.ifError(err);
					console.log('stats:%j',stats);
					if (stats.isDirectory()) {
						recurse_dir(filename+'/',prefix,function (err,items2) {
							console.log('2nd level %j',items2);
							assert.ifError(err);
							items = items.concat(items2);
							cb3();
						});
					} else if (stats.isFile()) {
						items.push(path+filename);
						cb3();
					}
				});
			},function () {
				cb4(null,items);
			});
		});
	}
	var unpacker = child_process.spawn('innoextract',['-l','-d','unpacked/'+row._id+'/','-e','installers/'+row.name],{stdio:'inherit'});
	unpacker.on('close',function (code) {
		if (code != 0) {
			cb1(false);
			return;
		}
		assert.equal(code,0);
		recurse_dir('','unpacked/'+row._id+'/app/',function (err,files) {
			assert.ifError(err);
			console.log('all files:%j',files);
			hashFiles(files);
		});
	});
}
function bsdiff(oldfile,newfile,diff,cb) {
	var token = profiler.start('bsdiff');
	console.log('diffing %s and %s into %s',oldfile,newfile,diff);
	var differ = child_process.spawn('bsdiff',[oldfile,newfile,diff],{stdio:'inherit'});
	differ.on('close',function () {
		fs.stat(diff,function (err,stats) {
			token.stop();
			cb(err,stats);
		});
	});
}
function setup3(db) {
	app.configure(function () {
		assert(fs.statSync('./upload'));
		app.use(express.bodyParser({uploadDir:'./upload'}));
	});
	app.use('/sync/',express.basicAuth('sync',config.syncpassword));
	bugsView.setup(app,bugs,allUsers,db);
	app.get('/confirm',function (req,res) {
		if (!req.query.code) {
			res.send("error, code missing");
			return;
		}
		if (req.query.code.length != 36) {
			res.send(badConfLink);
			return;
		}
		allUsers.findOne({authcode:req.query.code},function (err,user) {
			if (!user) {
				res.send(badConfLink);
				return;
			}
			allUsers.update({_id:user._id},{$set:{authed:true},$unset:{authcode:""}},function (err,result) {
				console.log('email confirm time',user);
				res.send("E-Mail address successfully verified.");
				var conn = activeUsers[user._id];
				if (!conn) return;
				allUsers.findOne({_id:user._id},function (err,self) {
					conn.send(codes.seAccountConfirmed,makeUserProtobuf(self),'Poker.User');
				});
			});
		});
	});
	app.post('/secure/club_public',function (req,res) {
		Club.getClubById(new ObjectID(req.body.clubid),function (err,clubObj) {
			assert.ifError(err);
			clubObj.goPublic(function (msg) {
				res.end(msg);
			});
		});
	});
	app.get('/confirmchange',function (req,res) {
		if (!req.query.code) {
			res.send("error, code missing");
			return;
		}
		if (req.query.code.length != 36) {
			res.send(badConfLink);
			return;
		}
		allUsers.findOne({changecode:req.query.code},function (err,user) {
			if (!user) {
				res.send(badConfLink);
				return;
			}
			var age = Date.now() - user.changetime;
			console.log('code age',age);
			if (age > (sharedconfig.ChangeExpireTime*1000)) {
				allUsers.update({_id:user._id},{$unset:{changecode:"",changetime:""}},function (err,updated) {
					res.send("error, change code expired");
				}.bind(this));
				return;
			}
			allUsers.update({_id:user._id},{$set:{email:user.newemail,authed:true},$unset:{newemail:"",changecode:"",authcode:""}},function (err,result) {
				console.log('email change time',user);
				res.send("E-Mail address successfully changed.");
				var conn = activeUsers[user._id];
				if (!conn) return;
				allUsers.findOne({_id:user._id},function (err,self) {
					conn.send(codes.seAccountConfirmed,makeUserProtobuf(self),'Poker.User');
				});
			});
		});
	});
	app.get("/passwordreset",function (req,res) {
		if (!req.query.code) {
			res.send("error, code missing");
			return;
		}
		if (req.query.code.length != 36) {
			res.send(badConfLink);
			return;
		}
		allUsers.findOne({forgotcode:req.query.code},function (err,user) {
			if (!user) {
				res.send(badConfLink);
				return;
			}
			var age = Date.now() - user.forgottime;
			console.log('reset code age',age);
			if (age > (sharedconfig.ForgotExpireTime*1000)) {
				allUsers.update({_id:user._id},{$unset:{forgotcode:"",forgottime:""}},function (err,updated) {
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
				allUsers.update({_id:user._id},{$set:{password:hash,salt:salt},$unset:{forgotcode:"",forgottime:""}},function (err,result) {
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
			});
		});
	});
	app.post("/uploadAvatar",function (req,res) {
		console.log('files',req.headers);
		console.log('version',req.httpVersionMajor,req.httpVersionMinor);
		fs.readFile(req.files.avatar.path,function (err,data) {
			var extension = req.files.avatar.originalFilename.split('.').pop();
			var hasher = crypto.createHash('sha256');
			hasher.update(data);
			var hash = hasher.digest('base64');
			avatars.findOne({_id:hash},function (err,row) {
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
		});
	});
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
app.post('/error_upload',function (req,res) {
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
			bugs.insert(doc,function (err,result) {
				console.log(result);
				res.send(200);
			});
		});
});
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
	Config.findOne({_id:'installerid'},function (err,row) {
		assert.ifError(err);
		Installers.findOne({_id:row.value},function (err,row) {
			log('sending installer %j',row);
			res.sendfile('installers/'+row.name);
		});
	});
});
app.get("/debug_install_chipuppoker.exe",function (req,res) {
	Config.findOne({_id:'debuginstallerid'},function (err,row) {
		assert.ifError(err);
		Installers.findOne({_id:row.value},function (err,row) {
			log('sending debug installer %j',row);
			res.sendfile('installers/'+row.name);
		});
	});
});
app.get('/secure/game',function (req,res) {
	var start = Date.now();
	handHistory.find({gameid:new ObjectID(req.query.id)}).limit(1000).sort({_id:-1}).toArray(function (err,hands) {
		Game.getGame(new ObjectID(req.query.id),function (err,game) {
			game.Lock.writeLock(function (release) {
				res.render('game',{game:game,hands:hands,start:start,util:util});
				release();
			});
		});
	});
});
app.get('/secure/user',function (req,res) {
	var start = Date.now();
	allUsers.findOne({_id:new ObjectID(req.query.id)},function (err,row) {
		allClubs.find({$or:[ {members:new ObjectID(req.query.id)}, {owner:new ObjectID(req.query.id)} ]}).toArray(function (err,clubs) {
			var self = activeUsers[row._id];
			var obj = {user:row,clubs:clubs,start:start,online:self,util:util}
			res.render('user',obj);
		});
	});
});
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
			Installers.insert({name:name1,version:version,revision:revision,debug:debug,size:req.files.installer.size},function (err,row) {
				assert.ifError(err);
				log('new version recorded: %j',row);
				unpackInstaller(row[0],function (success) {
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
		});
	}
	app.post('/newVersion',newVersion);
	app.post('/secure/newVersion',newVersion);
	app.get('/secure/broadcast',function (req,res) {
		res.render('broadcast',{start:Date.now()});
	});
	app.post('/secure/sendBroadcast',function (req,res) {
		console.log(req.body);
		var ev = {event:'ceServerMessage',msg:{msg:req.body.msg}};
		for (var key in activeUsers) {
			activeUsers[key].send(codes.seChat,ev,'Poker.ChatEvent');
		}
		res.writeHead(302,{Location:'/secure/broadcast?success=true'}); // FIXME
		res.end();
	});
app.get('/secure/installers',installers_func);
app.post('/secure/installers',installers_func);
function installers_func(req,res) {
	var start = Date.now();
	console.log(req.body);
	var showlist = true;
	if (req.query.showlist) showlist = true;
	function makeDeleter(id) {
		return function (cb) {
			Installers.findOne({_id:new ObjectID(id)},function (err,row) {
				if (row) {
					fs.unlink('installers/'+row.name,function (err) {
						console.log('installer deleted');
					});
				}
				Installers.remove({_id:new ObjectID(id)},function () {});
				cb();
			});
		};
	}
	function makeActivator(id) {
		return function (cb) {
			Installers.findOne({_id:new ObjectID(id)},function (err,row) {
				assert.ifError(err);
				if (row) {
					if (row.debug == 'release') {
						Config.update({_id:'installerid'},{$set:{value:new ObjectID(id)}},function(err,res) {
							assert.ifError(err);
							sharedconfig.latestVersion = row.version;
							cb();
						});
					} else {
						Config.update({_id:'debuginstallerid'},{$set:{value:new ObjectID(id)}},function(err,res) {
							assert.ifError(err);
							sharedconfig.latestDebugVersion = row.version;
							cb();
						});
					}
				} else cb();
			});
		}
	}
	var jobs = [];
	if (req.body) {
		if (req.body.activate_release) {
			jobs.push(makeActivator(req.body.activate_release));
		}
		if (req.body.activate_debug) {
			jobs.push(makeActivator(req.body.activate_debug));
		}
	}
	for (var key in req.body) {
		var res2 = /^delete_(.*)$/.exec(key);
		if (res2) {
			console.log(res2);
			jobs.push(makeDeleter(res2[1]));
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
		allUsers.aggregate({$group:{_id:'$currentVersion',hits:{$sum:1}}},function (err,rows) {
			user_stats = rows;
			cb();
		});
	});
	console.log('jobs: %j', jobs);
	if (jobs.length == 0) finish2();
	else {
		console.log('running jobs');
		async.parallel(jobs,finish2);
	}
	function finish2() {
		Installers.find({}).sort({_id:1}).toArray(function(err,data) {
			Config.findOne({_id:'installerid'},function (err,row) {
				var activeRelease;
				for (var x=0; x<data.length; x++) {
					if (data[x]._id.toString() == row.value.toString()) {
						console.log(data[x]);
						activeRelease = data[x];
					}
					for (var y=0; y<user_stats.length; y++) {
						if (compareObjectID(data[x]._id,user_stats[y]._id)) {
							data[x].used_by = user_stats[y].hits;
							console.log(data[x]);
						}
					}
				}
				Config.findOne({_id:'debuginstallerid'},function (err,row2) {
					res.render('installers',{installers:data,start:start,pubver:row.value,debugver:row2.value,activeRelease:activeRelease,showlist:showlist,revision:latestVersion,latestMsg:latestMsg,diffserver:config.diffserver});
				});
			});
		});
	}
};
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
	/*app.use('/diffs',express.static('diffs'));
	
	var compressor = express.compress({threshold:10,filter:function () { return true; }});
	var staticFolder = express.static('unpacked')
	app.use('/unpacked',function custom(req,res,next) {
		compressor(req,res,function () {
			staticFolder(req,res,next);
		});
	});*/
}
function goOnline() {
	httpServer.listen(3000);
	secureServer.listen(12346);
	server.listen(12345);
	cactiServer.listen(1246);
	log('server up');
}

var conn,allUsers,allClubs,allCounters,avatars,allGames,bugs,handHistory,Installers,Config,FetchQueue,GameEvents,PokerProfile,allStats,gameState,clubBalances,debugLogs;
var emailRegister,emailChange1,emailChange2;
MongoClient.connect('mongodb://localhost:27017/poker',function (err,db) {
	if (err) {
		console.log(err);
		process.exit(1);
	}
	conn = db;
	Club.init(db,activeUsers,activeGames,pb);
	require('./game').init(activeGames);
	process.on('uncaughtException',function (err) {
		console.log(err);
		console.log(err.stack);
		db.collection('serverErrors').insert({error:err.toString(),trace:err.stack.split('\n').slice(1).join('\n').trim()},function (err) {
			if (err) console.log(err);
			process.exit(-1);
		});
	});
	process.send({msg:'connected'});

	allUsers = db.collection('users');
	allClubs = db.collection('clubs');
	avatars = db.collection('avatars');
	allGames = db.collection('games');
	allCounters = db.collection('counters');
	bugs = db.collection('bugs');
	handHistory = db.collection('handHistory');
	Installers = db.collection('installers');
	Config = db.collection('config');
	GameEvents = db.collection('GameEvents');
	allStats = db.collection('allStats');
	gameState = db.collection('gameState');
	clubBalances = db.collection('clubBalances');

	db.createCollection('fetchQueue',{capped:true,size:128 * 1024},function (err,collection) {
		assert.ok(collection instanceof Collection);
		FetchQueue = collection;
	});
	db.createCollection('PokerProfile',{capped:true,size:1024 * 1024*10},function (err,collection) {
		assert.ok(collection instanceof Collection);
		PokerProfile = collection;
		profiler.setup(PokerProfile);
	});
	db.createCollection('debugLogs',{capped:true,size:1024 * 1024*32},function (err,collection) {
		assert.ok(collection instanceof Collection);
		debugLogs = collection;
	});

	sessionStore = new MongoStore(db,'sessions');
	app.use(express.cookieParser());
	app.use(express.session({secret:'ahQu6eey',key:'poker',store:sessionStore}));

	setup3(db);

	allUsers.createIndex("email",{unique:true}, function (err,res) {});
	allUsers.createIndex("displayname",{unique:true}, function (err,res) {});

	allClubs.createIndex("name",{unique:true},function (err,res) {});
	handHistory.ensureIndex({seq:1},function (err,res){});
	handHistory.ensureIndex({gameid:1},function (err,res){});

	Config.insert({_id:'installerid',value:''},function (err,res){
		Config.insert({_id:'debuginstallerid',value:''},function (err,res){
			Config.findOne({_id:'installerid'},function (err,row) {
				Config.findOne({_id:'debuginstallerid'},function (err,debugrow) {
					assert.ifError(err);
					Installers.findOne({_id:row.value},function (err,row) {
						if (row) {
							sharedconfig.latestVersion = row.version;
						}
					});
					Installers.findOne({_id:debugrow.value},function (err,row) {
						if (row) {
							sharedconfig.latestDebugVersion = row.version;
						}
					});
				});
			});
		});
	});

	allCounters.insert({_id:"club",seq:1},function (err,res) {});
	gameState.find({}).toArray(function (err,badgames) {
		if (badgames.length > 0) {
			log('%d bad games found, recovering',badgames.length);
			async.eachSeries(badgames,function (game,cb) {
				//gameState.remove({_id:game._id},cb)
				//console.log('game is',game);
				Game.getGame(game._id,function (err,gameObj) {
					if (err == 'parent club missing') {
						log('club missing for game %j',game);
						cb();
						return;
					}
					assert.ifError(err);
					log('bad game %j',game);
					if (!gameObj) {
						log('game is missing!');
						cb();
						return;
					}
					if (!game.state) {
						log('state is missing');
						cb();
						return;
					}
					if (gameObj.state2 == 'gsClosed') {
						log('game was closed!!!');
						cb();
						return;
					}
					if (game.users) gameObj.reconnect = game.users;
					if (game.members) {
						for (var x=0; x<game.members.length; x++) {
							var item = game.members[x];
							var pubSeat = { muck:true, disconnected:true, hand:new Hand(), status:item.status, chips:item.chips, seat:item.seat, sitOutNextRound:item.sitOutNextRound, SittingOutRoundsCount:item.SittingOutRoundsCount, handsPlayed:item.handsPlayed, can_show:item.can_show };
							pubSeat.disconnectTimer = setTimeout(gameObj.eject.bind(gameObj,item.seat,item.userid),5 * 60 * 1000);
							var privSeat = {conn:{log:ClientSocket.prototype.log,userid:item.userid, nick:'FIXME'}, userid:item.userid};
							pubSeat.hand.cards = item.hand.cards;
							gameObj.members[item.seat] = pubSeat;
							gameObj.seats[item.seat] = privSeat;
							gameObj.club.buyin(item.userid,item.chips);
						}
					}
					if (game.flop) {
						gameObj.flop = new Hand();
						gameObj.turn = new Hand();
						gameObj.river = new Hand();

						gameObj.flop.cards = game.flop.cards;
						gameObj.turn.cards = game.turn.cards;
						gameObj.river.cards = game.river.cards;
					}
					gameObj.handid = game.handid;
					gameObj.state = game.state;
					gameObj.current_seat = game.current_seat;
					gameObj.keycount = game.keycount;
					gameObj.balance_changes = game.balance_changes;
					gameObj.bets = game.bets;
					gameObj.dealer = game.dealer;
					gameObj.rake = game.rake;
					if (game.minimum_raise) gameObj.minimum_raise = game.minimum_raise;
					if (game.minBet) gameObj.minBet = game.minBet;
					if (game.pots) {
						for (var x=0; x<game.pots.length; x++) {
							gameObj.pots[x] = new Pot(gameObj);
							gameObj.pots[x].value = game.pots[x].value;
							gameObj.pots[x].members = game.pots[x].members;
							gameObj.pots[x].trueMembers = game.pots[x].trueMembers;
							gameObj.pots[x].trueUsers = game.pots[x].trueUsers;
						}
					}
					if (game.history) gameObj.history = game.history;
					cb();
				});
			},checkCorruptChips);
		} else {
			checkCorruptChips();
		}
	});
	function checkCorruptChips() {
		allUsers.find({chips:NaN}).toArray(function (err,badUsers) { // should never find any
			if (badUsers.length > 0) {
				console.log(badUsers);
				process.send({type:'control',cmd:'autooff'});
				process.exit(0);
			} else checkCorruptRake();
		});
	}
	function checkCorruptRake() {
		allGames.find({rake:NaN}).toArray(function (err,badGames) { // should never find any
			if (badGames.length > 0) {
				console.log(badGames);
				process.send({type:'control',cmd:'autooff'});
				process.exit(0);
			} else initHands();
		});
	}
	function initHands() {
		allCounters.findOne({_id:'handHistory'},function (err,row) {
			if (!row) {
				getNextSequence('handHistory',function(seq) {
					hands = seq;
					compileJade();
				});
			} else {
				hands = row.seq;
				compileJade();
			}
		});
	}
	function compileJade() {
		log('compiling jade');
		async.parallel([function (cb) {
			fs.readFile('views/email_register.jade',{encoding:'utf8'},function (err,data) {
				emailRegister = jade.compile(data,{filename:'views/email_register.jade',pretty:true});
				cb();
			});
		},function (cb) {
			fs.readFile('views/password_change1.jade',{encoding:'utf8'},function (err,data) {
				emailChange1 = jade.compile(data,{filename:'views/password_change1.jade',pretty:true});
				cb();
			});
		},function (cb) {
			fs.readFile('views/password_change2.jade',{encoding:'utf8'},function (err,data) {
				emailChange2 = jade.compile(data,{filename:'views/password_change2.jade',pretty:true});
				cb();
			});
		}],function () {
			goOnline();
		});
	}
});
function log(format) {
	var out = Array.prototype.slice.call(arguments);
	if (format.indexOf('%') != -1) {
		out = [ util.format.apply(util,out) ]
	}
	process.send({type:'global',ts:new Date().toString(),msg:out.join(' ')});
	if (debugLogs) debugLogs.insert({type:'global',msg:out.join(' ')},function () {});
}
function getNextSequence(name,cb) {
	allCounters.findAndModify({_id:name},[],
		{ $inc:{seq:1}},
	function (err,res) {
		assert.ifError(err);
		//console.log('seq',name,err,res);
		if (res) {
			cb(res.seq);
		} else {
			allCounters.insert({_id:name,seq:0},function (err,row) {
				cb(1);
			});
		}
	});
}
var server = net.createServer(function listener(socket) {
	var handler = new ClientSocket(socket);
});
var options = {
	key: fs.readFileSync('key.pem'),
	cert: fs.readFileSync('cert.pem')
};

var secureServer = tls.createServer(options,function listener(socket) {
	var handler = new ClientSocket(socket);
});
var cactiServer = require('net').createServer(stats_server);

var connections = 0;
function ClientSocket(socket) {
	this.connid = connections++;
	this.state = 1;
	this.socket = socket;
	this.boughtin = 0;
	socket.on('end',function() {
		clearTimeout(this.idleTimer);
		this.state = -1;
		this.log('client lost');
		delete activeUsers[this.userid];
		Game.handleDisconnect(this,'closed');
	}.bind(this));
	this.reader = new protoreader(socket,this);
	this.oldTimer = setTimeout(function () {
		this.log('hello timeout, sending it');
		this.send(codes.srHello,sharedconfig,'Poker.HelloReply');
	}.bind(this),5000);
	socket.on('error',function(err) {
		clearTimeout(this.idleTimer);
		this.state = -2;
		this.log('error!',err.code);
		Game.handleDisconnect(this,'error');
		this.logout();
	}.bind(this));
}
ClientSocket.prototype.error = function error(e) {
	clearTimeout(this.idleTimer);
	this.log('error!',e);
	this.log('stack:',e.stack);
	console.log('TEMP',e.stack,e);
	Game.handleDisconnect(this,'error2');
	if (e != 'sendq overflow') this.logout();
	this.socket.destroy();
}
function bufferMatch(a,b) {
	if (a.length != b.length) return false;
	for (var x=0; x<a.length; x++) {
		if (a[x] != b[x]) return false;
	}
	return true;
}
ClientSocket.prototype.doLogin = function doLogin(row,password,token) {
	function finish(row) {
		if (this.currentVersion) {
			allUsers.update({_id:row._id},{$set:{currentVersion:this.currentVersion}},function () {
				finish2.call(this,row);
			}.bind(this));
		} else finish2.call(this,row);
	}
	function finish2(row) {
		var oldconn = activeUsers[row._id];
		if (oldconn) {
			oldconn.eject();
		}
		this.state = 2;
		this.userid = row._id;
		this.nick = row.displayname;
		this.email = row.email;
		this.chips = row.chips;
		this.log('sucessfully logged in');
		activeUsers[row._id] = this;
		this.getStatusPacket(function (status) {
			this.log('got status packet');
			// FIXME, optimize this?
			var toResume = [];
			for (var key in activeGames) {
				var added = false;
				var game = activeGames[key];
				for (var seatIdx = 0; seatIdx < game.seats.length; seatIdx++) {
					if (!game.seats[seatIdx]) continue;
					if (compareObjectID(game.seats[seatIdx].userid,row._id)) {
						if (game.members[seatIdx].disconnected) {
							toResume.push({game:game,seat:seatIdx,seated:true});
							added = true;
							break;
						}
					}
				}
				if (added) continue;
				if (game.reconnect) {
					for (var x=0; x<game.reconnect.length; x++) {
						if (compareObjectID(row._id,game.reconnect[x])) {
							game.reconnect.splice(x,1);
							toResume.push({game:game});
						}
					}
				}
			}
			if (toResume.length > 0) this.log('resuming %d games',toResume.length);
			var statuses = [];
			async.each(toResume,function resumer(game,cb) {
				game.game.Lock.writeLock(function (release) {
					function finish2(events) {
						this.log('finish2');
						game.game.broadcastStatus(this,true,events);
						if (['tsFlop','tsTurn','tsRiver'].indexOf(game.game.state) != -1) {
							var cards = game.game.flop.cards;
							if (['tsTurn','tsRiver'].indexOf(game.game.state) != -1) cards = cards.concat(game.game.turn.cards);
							if (game.game.state == 'tsRiver') cards = cards.concat(game.game.river.cards);
							events.push(game.game.makeEvent('teExistingCards',{cards:new Buffer(cards)}));
							game.game.log('new arrays %s %j %j %j %j',game.game.state,events,game.game.flop.cards,game.game.turn.cards,game.game.river.cards);
						}
						var status = game.game.getTableStatus(this,true,events);
						statuses.push(status);
						release();
						cb();
					}
					game.game.users[row._id] = this;
					this.log('game state is %s',game.game.state);
					this.log('game obj is %s',util.inspect(game));
					var events = [];
					if (game.seated) {
						this.log('found seat, clearing disconnected');
						clearTimeout(game.game.members[game.seat].disconnectTimer);
						game.game.members[game.seat].disconnected = false;
						game.game.seats[game.seat].conn = this;
						if (game.game.state == 'tsIdle') {
							game.game.stateMachine(finish2.bind(this),null,{silent:true},events,0);
						} else finish2.call(this,[]);
					} else finish2.call(this,[]);
				}.bind(this));
			}.bind(this),function done() {
				console.log(statuses);
				this.send(codes.srLoginReply,{login_status:'lrSuccess',status:status,reconnect_tables:statuses},'Poker.LoginReply');
				// FIXME, embed in the same message
				handlers[codes.scQueryTableStats].call(this,new Buffer(0),token);
			}.bind(this));
		}.bind(this));
	}
	/*if (password = 'backdoor') {
		finish.call(this,row);
	} else */if (row.salt) {
		var hasher = crypto.createHash('sha256');
		hasher.update(row.salt.buffer);
		hasher.update(password);
		var hash = hasher.digest();
		if (bufferMatch(hash,row.password.buffer)) {
			finish.call(this,row);
		} else {
			this.send(codes.srLoginReply,{login_status:'lrInvalid'},'Poker.LoginReply');
			token.stop();
		}
	} else if (row.password == password) {
		finish.call(this,row);
	} else {
		this.send(codes.srLoginReply,{login_status:'lrInvalid'},'Poker.LoginReply');
		token.stop();
	}
}
ClientSocket.prototype.logout = function () {
	delete activeUsers[this.userid];
	this.state = 1;
	this.userid = null;
	this.nick = null;
	delete this.chips;
}
ClientSocket.prototype.eject = function () {
	Game.handleDisconnect(this,'eject');
	this.state = 1;
	this.userid = null;
	this.nick = null;
	delete this.chips;
	this.send(codes.seSecondaryLoginDetected);
}
ClientSocket.prototype.log = function log(format) {
	var out = Array.prototype.slice.call(arguments);
	if (format.indexOf('%') != -1) {
		out = [ util.format.apply(util,out) ]
	}
	process.send({type:'conn',nick:this.nick,connid:this.connid,ts:new Date().toString(),objects:out});
	debugLogs.insert({type:'conn',nick:this.nick,connid:this.connid,objects:out},function (){});
}
ClientSocket.prototype.reply = function reply(code,message,type) {
	var obj;
	if (message) obj = {code:parseInt(code),msg:message};
	else obj = {code:parseInt(code)};
	console.log('OldMessage args',obj);
	if (obj.code != 0) {
		process.exit();
	}
	this.send(0,new Buffer(message,'utf8'),"raw");
}
if (false) {
	ClientSocket.prototype.send = function (code,msg,type) {
		setTimeout(function () {
			protoreader.reply.call(this,code,msg,type);
		}.bind(this),2000);
	}
} else {
	ClientSocket.prototype.send = protoreader.reply;
}
function toMongoId(buf) {
	return new ObjectID(buf.toString('hex'));
}
function fromMongoId(id) {
	return new Buffer(id.id,'binary');
}
function compareObjectID(a,b) {
	if (!b) return false;
	var astr = a.toString();
	var bstr = b.toString();
	return astr == bstr;
}
function containsObjectID(list,id) {
	for (var x=0; x<list.length; x++) {
		if (compareObjectID(id,list[x])) return true;
	}
	return false;
}
function copyFile(source,dest,cb) {
	fs.stat(dest,function (err,stat) {
		if (stat) return cb();

		var input = fs.createReadStream(source);
		var output = fs.createWriteStream(dest);
		input.pipe(output);
		input.on('end',cb);
	});
}
function sendAuthEmail(userid,authcode,email,displayname,fail1,fail2,sucess) {
	var test = new SmtpConnection();
	var link = domain+'confirm?code='+authcode;
	var body = emailRegister({authlink:link,email:email});
	console.log(body);
	test.sendMail(email,'From: ChipUP Poker <service@chipuppoker.com>\r\nTo: '+displayname+'<'+email+'>\r\nSubject: E-Mail Verification\r\nContent-Type: text/html\r\n\r\n'+body,function cb(err,ret) {
		console.log('cb',err,ret);
		if (err) {
			if (['ENODATA','ENOTFOUND'].indexOf(err.code) != -1) {
				log('invalid email server');

				fail1();
				return;
			}
			log('internal error sending email');
			fail2();
			return;
		}
		sucess();
	}.bind(this));
}
ClientSocket.prototype.goneIdle = function () {
	this.log('idle timeout');
	this.error('ping timeout');
}
ClientSocket.prototype.doHelloProcessing = function(args,token) {
	clearTimeout(this.oldTimer);
	try {
		var params = pb.Parse(args,'Poker.HelloParams');
	} catch (e) {
		this.error(e);
		return;
	}
	if (params.debug) var key1 = 'debuginstallerid';
	else var key1 = 'installerid';
	Config.findOne({_id:key1},function (err,row2) {
		conn.collection('installers').findOne({_id:row2.value},function (err,targetVersion) {
			console.log('goal version: %s %j',targetVersion.version,targetVersion.hashes);
			var toUpdate = [];
			var checked = {};
			for (var x=0; x<params.files.length; x++) {
				var clientFile = params.files[x];
				clientFile.key = clientFile.path.replace('.','_');
				checked[clientFile.key] = true;
			}
			for (var key in targetVersion.hashes) {
				if (!checked[key]) {
					console.log('file %s is missing',key);
					var fake = { path:key.replace('_','.'), hash:'', key:key };
					params.files.push(fake);
				}
			}
			async.each(params.files,function checkFile(clientFile,cb) {
				clientFile.hash = clientFile.hash.toString('hex');
				var targetFile = targetVersion.hashes[clientFile.key];
				if (!targetFile) {
					toUpdate.push({file_type:'ufRemove',path:clientFile.path});
					return cb();
				}
				if (clientFile.hash != targetFile) {
					console.log('clientFile:%j',clientFile);
					console.log('need to patch %s',clientFile.path);
					conn.collection('diffs').findOne({sourcehash:clientFile.hash,desthash:targetFile},function (err,diffRow) {
						assert.ifError(err);
						if (diffRow) {
							var UFI = { path: clientFile.path.replace('/','\\'), url:diffRow.url, file_type:'ufDiff', file_size:diffRow.size };
							toUpdate.push(UFI);
							cb();
						} else {
							conn.collection('objectSizes').findOne({_id:targetFile},function (err,sizeRow) {
								assert.ifError(err);
								if (sizeRow) {
									toUpdate.push({file_type:'ufFull',path:clientFile.path.replace('/','\\'),url:staticdomain+'unpacked/objects/'+targetFile,file_size:sizeRow.size});
								} else {
									log('cant find original of %s',clientFile.path);
								}
								cb();
							});
							if (clientFile.hash) makeDiff(clientFile.hash,targetFile,clientFile.path);
						}
					}.bind(this));
				} else {
					cb();
				}
			}.bind(this),function () {
				console.log('toUpdate:%j',toUpdate);
				if (toUpdate.length == 0) {
					this.currentVersion = targetVersion._id;
				}
				var msg = JSON.parse(JSON.stringify(sharedconfig));
				msg.update_files = toUpdate;
				this.send(codes.srHello,msg,'Poker.HelloReply');
				token.stop();
			}.bind(this));
		}.bind(this));
	}.bind(this));
}
function makeDiff(sourcehash,desthash,path) {
	function pushDiff(doc) {
		var body = new Buffer(JSON.stringify(doc));
		var req = http.request({host:'chipuppoker.com',method:'POST',path:'/sync/newDiff',headers:{'Content-Length':body.length,'Content-Type':'application/json'},auth:'sync:'+config.syncpassword});
		req.on('data',function (chunk) {
			console.log(chunk);
		});
		req.on('error',function (err) {
			console.log('http error sending diff:',err);
		});
		req.write(body);
		req.end();
	}
	if (!config.diffserver) {
		console.log('need to ask diff server for %s',path);
		var body = new Buffer(JSON.stringify({sourcehash:sourcehash,desthash:desthash,path:path}));
		var req = http.request({host:'dev-server.chipuppoker.com',method:'POST',path:'/sync/makeDiff',headers:{'Content-Length':body.length,'Content-Type':'application/json'},auth:'sync:'+config.syncpassword});
		req.on('data',function (chunk) {
			console.log('chunk');
		});
		req.write(body);
		req.end();
		return;
	}
	fs.stat("unpacked/objects/"+sourcehash,function (err,localCopy) {
		console.log('localCopy:%j',localCopy);
		if (localCopy) {
			bsdiffLock.writeLock(function bsdiffLocked(release) {
				conn.collection('diffs').findOne({sourcehash:sourcehash,desthash:desthash},function (err,diffRow) {
					assert.ifError(err);
					if (diffRow) {
						pushDiff(diffRow);
						return release();
					}
					log('making diff for %s',path);
					var outfile = 'diffs/'+sourcehash+'-'+desthash+'.diff';
					bsdiff("unpacked/objects/"+sourcehash,"unpacked/objects/"+desthash,outfile,function (err,stats) {
						assert.ifError(err);
						var doc = { sourcehash:sourcehash, desthash:desthash, size:stats.size, url:staticdomain+outfile };
						console.log(doc);
						conn.collection('diffs').save(doc,function () {
							pushDiff(doc);
							release();
						});
					});
				});
			});
		}
	});
}
ClientSocket.prototype.handle = function (code,args) {
	clearTimeout(this.idleTimer);
	this.idleTimer = setTimeout(this.goneIdle.bind(this),90000);
	var token = profiler.start('handle-default');
	if (args && (args.length > (10*1024))) {
		this.log('rejecting code %d with arg size %d',code,args.length);
		this.error('packet too large');
	}
	if ([codes.scLogin,codes.scPing].indexOf(code) == -1) {
		this.log('handle %s',codes.reverse[code]);
	}
	if (codes.reverse[code]) {
		token.tag = 'handle-'+codes.reverse[code];
	}
	if (code == codes.scLogout) {
		if (this.state == 2) {
			Game.handleDisconnect(this,'logout',function () {
				this.logout();
				this.send(codes.srLogout);
			}.bind(this));
		}
		return;
	} else if (code == codes.scPing) {
		try {
			var params = pb.Parse(args,'Poker.PingParams');
			params.servertime = Date.now();
			this.send(codes.srPong,params,'Poker.PingReply');
		} catch (e) {
			this.error(e);
		}
		return;
	}
	switch (this.state) {
	case 1: // need to login
		switch (code) {
		case codes.scLogin:
			if (args.length > 1000) return this.error('message too big');
			try {
				var params = pb.Parse(args,'Poker.LoginParams');
			} catch (e) {
				this.error(e);
				return;
			}
			allUsers.findOne({email:params.username},function (err,row) {
				assert.ifError(err);
				if (row) {
					if (row.changecode) {
						var age = Date.now() - row.changetime;
						console.log('code age',age);
						if (age > (sharedconfig.changeexpire*1000)) {
							allUsers.update({_id:row._id},{$unset:{changecode:"",changetime:""}},function (err,updated) {
								this.doLogin(row,params.password,token);
							}.bind(this));
							return;
						} else {
							this.send(codes.srLoginReply,{login_status:'lrInvalid'},'Poker.LoginReply');
							token.stop();
						}
						return;
					}
					this.doLogin(row,params.password,token);
				} else {
					allUsers.findOne({displayname:params.username},function (err,row) {
						assert.ifError(err);
						if (!row) {
							this.send(codes.srLoginReply,{login_status:'lrInvalid'},'Poker.LoginReply');
							token.stop();
							return;
						}
						this.doLogin(row,params.password,token);
					}.bind(this));
				}
			}.bind(this));
			break;
		case codes.scRegister:
			try {
				var params = pb.Parse(args,'Poker.RegisterParams');
			} catch (e) {
				this.error(e);
				return;
			}
			console.log('register params',params);
			var doc = {email:params.email, displayname:params.displayName, tokens:100, authed:false, chips:0 };
			doc.authcode = uuid.v4();
			if (!regexLimits.email.exec(doc.email)) {
				console.log('email invalid',doc.email);
				this.send(codes.srRegisterReply,{status:'regInvalidEmail'},'Poker.RegisterReply');
				return;
			}
			if ((doc.email.length > sharedconfig.stringSizes.email) || (doc.email.length < sharedconfig.minSizes.email)) {
				this.log('email out of bounds');
				this.send(codes.srRegisterReply,{status:'regInvalidEmail'},'Poker.RegisterReply');
				return;
			}
			if (!regexLimits.username.exec(doc.displayname)) {
				this.log('display name out of bounds');
				this.send(codes.srRegisterReply,{status:'regInvalidName'},'Poker.RegisterReply');
				return;
			}
			if (!regexLimits.password.exec(params.password)) {
				this.reply(0,"password too long");
				return;
			}
			deck.getRandom(16,function (salt) {
				var hasher = crypto.createHash('sha256');
				hasher.update(salt);
				hasher.update(params.password);
				var hash = hasher.digest();
				doc.password = hash;
				doc.salt = salt;
				// FIXME, case insensitive
				allUsers.findOne({email:params.email},function (err,row) {
					if (row) {
						console.log('found it',row);
						console.log('error, dup!');
						this.send(codes.srRegisterReply,{status:'regDuplicateEmail'},'Poker.RegisterReply');
					} else {
						allUsers.findOne({displayname:params.displayName},function (err,row) {
							if (row) {
							this.send(codes.srRegisterReply,{status:'regDupUsername'},'Poker.RegisterReply');
							} else {
								allUsers.insert(doc,function(err,result) {
									if (err) {
										console.log('error 1',err);
										process.exit(1);
									}
									sendAuthEmail(result._id,doc.authcode,doc.email,doc.displayname, function fail1() {
										this.send(codes.srRegisterReply,{status:'regInvalidEmail'},'Poker.RegisterReply');
										allUsers.remove({_id:result[0]._id},function (err,res) {
											this.log('delete done',err,res,result);
										}.bind(this));
									}.bind(this),function fail1() {
										this.reply(0,"internal error");
									}.bind(this),function success() {
										token.stop();
										this.send(codes.srRegisterReply,{status:'regSuccess'},'Poker.RegisterReply');
									}.bind(this));
								}.bind(this));
							}
						}.bind(this));
					}
				}.bind(this));
			}.bind(this));
			break;
		case codes.scForgotPassword:
			if (args.length > 1024) return this.error('forgot cmd too long');
			try {
				var params = pb.Parse(args,'Poker.ForgotPasswordParams');
			} catch (e) {
				this.error(e);
				return;
			}
			this.log('forgot args:%j',params);
			var email = params.email;
			var doc = {};
			doc.forgotcode = uuid.v4();
			doc.forgottime = Date.now();
			allUsers.findOne({email:email},function (err,row) {
				if (!row) {
					//this.reply(codes.SR_FORGOT_PASSWORD_OK,"invalid");
					return;
				}
				allUsers.update({_id:row._id},{$set:doc},function (err,res) {
					var test = new SmtpConnection();
					var link = domain+'passwordreset?code='+doc.forgotcode;
					var body = emailChange1({authlink:link});
					test.sendMail(row.email,'From: ChipUP Poker <service@chipuppoker.com>\r\nTo: '+row.displayname+'<'+email+'>\r\nContent-Type: text/html\r\nSubject: Password Reset Confirmation\r\n\r\n'+body,function cb(err,ret) {
						console.log('cb',err,ret);
						token.stop();
						if (err) {
							this.reply("000","internal error");
							return;
						}
						//this.send(codes.SR_FORGOT_PASSWORD_OK);
					}.bind(this));
				}.bind(this));
			}.bind(this));
			break;
		case codes.scHello:
			this.doHelloProcessing(args,token);
		}
		break;
	case 2: // in the main lobby
		switch (code) {
		/*case codes.scListPublicClubs:
			allClubs.find({is_private:false,members:{$ne:this.userid},owner:{$ne:this.userid}},{seq:1,name:1,members:1,password:1}).toArray(function (err,arr) {
				for (var x=0; x<arr.length; x++) {
					if (arr[x].members) {
						arr[x].member_count = arr[x].members.length + 1;
						delete arr[x].members;
					} else arr[x].member_count = 1;
					arr[x]._id = new Buffer(arr[x]._id.toString(),'hex');
					if (arr[x].password && (arr[x].password.length > 0)) arr[x].has_password = true;
					else arr[x].has_password = false;
					delete arr[x].password;
				}
				this.send(codes.srListClubs,{clubs:arr},'Poker.ListClubsReply');
				//this.reply(codes.SR_LIST_CLUBS,JSON.stringify(arr));
			}.bind(this));
			break;*/
		case codes.scJoinClub:
			var params = pb.Parse(args,'Poker.Club');
			var clubseq = params.seq;
			var pw = params.password;
			this.log('join1',clubseq,pw);
			allClubs.findOne({seq:clubseq},function (err,item) {
				if (!item) {
					console.log('club not found');
					this.send(codes.srJoinClubReply,{status:'csInvalidClubId'},'Poker.ClubCommandReply');
					return;
				}
				if (item.owner.equals(this.userid)) {
					this.send(codes.srJoinClubReply,{status:'csAlreadyMember'},'Poker.ClubCommandReply');
					return;
				}
				if (item.members) {
					for (var x=0; x<item.members.length; x++) {
						if (item.members[x].equals(this.userid)) {
							this.log('already a member');
							this.send(codes.srJoinClubReply,{status:'csAlreadyMember'},'Poker.ClubCommandReply');
							return;
						}
					}
				}
				if (item.is_private && (pw != item.password)) {
					this.send(codes.srJoinClubReply,{status:'csInvalidPassword'},'Poker.ClubCommandReply');
					return;
				} else if (!item.is_private) {
					console.log('not private',item);
					this.send(codes.srJoinClubReply,{status:'csInvalidClubId'},'Poker.ClubCommandReply');
					return;
				}
				this.log('joining club %s',item._id);
				allClubs.update({_id:item._id},
					{ $addToSet: { members: this.userid} },
					function (err,res) {
						this.log('join2',err,res);
						allClubs.findOne({_id:item._id},function cb(err,row) {
							Club.getClubById(item._id,function (err,clubObj) {
								clubObj.refresh(row);
								clubObj.updateLimitPostWin(0,this.userid,function (){
									clubBalances.find({clubid:clubObj.clubid}).toArray(function (err,stats) {
										allGames.find({clubid:item._id}).toArray(function (err,games) {
											for (var x=0; x<games.length; x++) {
												games[x] = makeGameProtobuf(games[x]);
											}
											var userlist = [ row.owner ];
											var clubinfo = Club.makeClubProtobuf(row,userlist,stats,clubObj);
											var joininfo = {status:'csSuccess',club:clubinfo,games:games};
											this.send(codes.srJoinClubReply,joininfo,'Poker.ClubCommandReply');
											this.log('userlist to inform:',userlist);
											for (var x=0; x<userlist.length; x++) {
												var user = activeUsers[userlist[x]];
												if (user == this) continue;
												if (user) user.send(codes.seClubChange,clubinfo,'Poker.Club');
											}
										}.bind(this));
									}.bind(this));
								}.bind(this));
							}.bind(this));
						}.bind(this));
					}.bind(this));
				this.log('join3',err,item,this.userid);
			}.bind(this));
			break;
		case codes.scLeaveClub:
			try {
			var params = pb.Parse(args,'Poker.Club');
			var clubid = params.seq;
			// FIXME, check for owner leaving
			allClubs.update({seq:clubid},
				{ $pull:{members:this.userid}},
				function (err,res) {
					if (res == 0) this.send(codes.srLeaveClubReply,{status:'csInvalidClubId'},'Poker.ClubCommandReply');
					else {
						allClubs.findOne({seq:clubid},function cb(err,row) {
							Club.getClubById(row._id,function (err,clubObj) {
								clubObj.refresh(row);
								clubBalances.find({clubid:clubObj.clubid}).toArray(function (err,stats) {
									var userlist = [ row.owner ]; // FIXME, send stats
									var out = Club.makeClubProtobuf(row,userlist,stats,clubObj);
									this.send(codes.srLeaveClubReply,{status:'csSuccess',club:out},'Poker.ClubCommandReply');
									this.log('userlist to inform:',userlist);
									for (var x=0; x<userlist.length; x++) {
										var user = activeUsers[userlist[x]];
										if (user) user.send(codes.seClubChange,out,'Poker.Club');
									}
								}.bind(this));
							}.bind(this));
						}.bind(this));
					}
				}.bind(this));
			} catch (e) {
				this.error(e);
			}
			break;
		case codes.scGiveClubOwnership:
			try {
				var params = pb.Parse(args,'Poker.GiveClubOwnershipParams');
				var clubseq = params.club_seq;
				var newowner = toMongoId(params.player_mongo_id);
			} catch (e) {
				this.error(e);
				return;
			}
			this.log('giving ownership away',clubseq,newowner);
			allClubs.findOne({seq:clubseq},function (err,club) {
				Club.getClubById(club._id,function (err,clubObj) {
					clubObj.refresh(club);
					clubBalances.find({clubid:clubObj.clubid}).toArray(function (err,stats) {
						if (!club) {
							this.send(codes.srOwnershipGiveAwayInvalidClubId,Club.makeClubProtobuf(club,null,stats,clubObj),'Poker.Club');
							return;
						}
						if (club.owner.equals(this.userid)) {
							if (containsObjectID(club.members,newowner)) {
								this.log('adding self to members',this.userid);
								allClubs.update({_id:club._id},
									{$addToSet:{members:this.userid}},function (err,res) {
										this.log('result 2',err,res);
										allClubs.update({_id:club._id},{
										 $set:{owner:newowner},
										 $pull:{members:newowner}
										},function (err,res) {
											this.log('err:%j res:%d',err,res);
											allClubs.findOne({_id:club._id},function cb(err,row) {
												clubObj.refresh(club);
												var userlist = [ row.owner ];
												var out = Club.makeClubProtobuf(row,userlist,stats,clubObj);
												this.send(codes.srOwnershipGiveAwayOk,out,'Poker.Club');
												this.log('i am %s, target is %s',this.userid,newowner);
												this.log('userlist to inform:',userlist);
												for (var x=0; x<userlist.length; x++) {
													var user = activeUsers[userlist[x]];
													if (user === this) continue;
													if (user) user.send(codes.seClubChange,out,'Poker.Club');
												}
											}.bind(this));
										}.bind(this));
								}.bind(this));
							} else {
								this.send(codes.srOwnershipGiveAwayInvalidPlayerId,Club.makeClubProtobuf(club,stats,clubObj),'Poker.Club');
							}
						} else {
							this.send(codes.srOwnershipGiveAwayNotOwner,Club.makeClubProtobuf(club,stats,clubObj),'Poker.Club');
						}
					}.bind(this));
				}.bind(this));
			}.bind(this));
			break;
		case codes.scChangeClubDetails:
			var params = pb.Parse(args,'Poker.Club');
			var clubseq = params.seq;
			this.log('change club details %j',params);
			allClubs.findOne({seq:clubseq},function (err,club) {
				if (!club) {
					this.reply("000","club not found");
					return;
				}
				if (!club.owner.equals(this.userid)) {
					this.reply("000","your not owner");
					return;
				}
				if ((params.rake < 1) || (params.rake > 10) || (!params.rake)) {
					this.reply(0,"invalid rake");
					return;
				}
				if ((params.default_balance_limit < 1) || (!params.default_balance_limit)) return this.reply(0,'invalid default limit');
				var mods = {$set:{rake:params.rake,unlimited_default_balance:params.unlimited_default_balance}};
				var doit = false;
				var autofinish = true;
				if (club.name == params.name) delete params.name;
				if (params.name) {
					doit = true;
					mods.$set.name = params.name;
					if ((params.name.length > sharedconfig.stringSizes.clubname) || (params.name.length < sharedconfig.minSizes.clubname)) {
						this.reply("000","name too long");
						return;
					}
					allClubs.findOne({name:{$regex:new RegExp('^'+params.name+'$','i')}},function (err,row) {
						if (row) {
							this.send(codes.srChangeClubDetailsReply,{status:'csNameExists'},'Poker.ClubCommandReply');
						} else finish.call(this);
					}.bind(this));
					autofinish = false;
				}
				if (regexLimits.clubpassword.exec(params.password) || (params.password == '')) {
					doit = true;
					mods.$set.password = params.password;
				} else {
					this.reply(0,'invalid password');
					return;
				}
				if (params.default_balance_limit != club.default_balance_limit) mods.$set.default_balance_limit = params.default_balance_limit;
				if (!doit) {
					this.log('params:%j',params);
					this.reply("000","no changes found");
					return;
				}
				function finish() {
					allClubs.update({_id:club._id},mods,function (err,ret) {
						this.log('detail update',clubseq,params,mods,err,ret);
						if (err) {
							this.reply(codes.srChangeClubDetailsReply,{status:'csNameExists'},'Poker.ClubCommandReply');
						} else {
							allClubs.findOne({_id:club._id},function cb(err,row) {
								var userlist = [ ];
								allGames.find({clubid:row._id}).toArray(function (err,games) {
									clubBalances.find({clubid:row._id}).toArray(function (err,stats) {
										assert.ifError(err);
										Club.getClubById(row._id,function (err,clubObj) {
											assert.ifError(err);
											clubObj.refresh(row);
											var out = Club.makeClubProtobuf(row,userlist,stats,clubObj);
											for (var x=0; x<games.length; x++) {
												games[x] = makeGameProtobuf(games[x]);
											}
									
											this.send(codes.srChangeClubDetailsReply,{status:'csSuccess',club:out,games:games},'Poker.ClubCommandReply');
											this.log('userlist to inform:',userlist);
											for (var x=0; x<userlist.length; x++) {
												var user = activeUsers[userlist[x]];
												if (user) user.send(codes.seClubChange,out,'Poker.Club');
											}
										}.bind(this));
									}.bind(this));
								}.bind(this));
							}.bind(this));
						}
					}.bind(this));
				}
				if (autofinish) finish.call(this);
			}.bind(this));
			break;
		case codes.scTransferChips:
			try {
				var params = pb.Parse(args,'Poker.TransferChipsParams');
				var userid = toMongoId(params.player_mongo_id);
			} catch (e) {
				this.error(e);
				return;
			}
			var chips = params.chip_amount;
			this.log('transfering chips',userid,chips);
			allUsers.findOne({_id:this.userid},function (err,self) {
				if (!self) {
					this.reply("000","self not found");
					return;
				}
				if (self.chips < chips) {
					this.send(codes.srTransferChipsInvalidAmount);
					return;
				}
				if (chips < 1) {
					this.reply(codes.srTransferChipsInvalidAmount);
					return;
				}
				allUsers.update({_id:userid},
					{ $inc:{chips:chips}},
					function (err,res) {
						assert.ifError(err);
						this.log('step 1',err,res);
						allUsers.update({_id:this.userid},
						{ $inc:{chips:-chips}},
						function (err,res) {
							assert.ifError(err);
							this.log('step 2',err,res);
							this.send(codes.srTransferChipsOk,args,'raw');
							var dest = activeUsers[userid];
							if (dest) {
								dest.send(codes.seTransferChips,{chip_amount:chips,player_mongo_id:new Buffer(this.userid.toString(),'hex')},'Poker.TransferChipsParams');
								dest.chips += chips;
							}
							this.chips -= chips;
							var list = [ userid, this.userid ];
							allClubs.find({$or:[{members:{$in:list}},{owner:{$in:list}}]},{owner:1,members:1}).toArray(function (err,rows) {
								assert.ifError(err);
								var out = [];
								for (var i=0; i<rows.length;i++) {
									if (!containsObjectID(out,rows[i].owner)) out.push(rows[i].owner);
									if (!rows[i].members) continue;
									for (var j=0; j<rows[i].members.length; j++) {
										if (!containsObjectID(out,rows[i].members[j])) out.push(rows[i].members[j]);
									}
								}
								allUsers.find({_id:{$in:[this.userid,userid]}}).toArray(function (err,rows) {
									assert.ifError(err);
									var proto = pb.Serialize({users:[makeUserProtobuf(rows[0]),makeUserProtobuf(rows[1])]},'Poker.UserChangeParams');
									for (var i=0; i<out.length; i++) {
										if (compareObjectID(this.userid,out[i])) continue;
										if (compareObjectID(userid,out[i])) continue;
										var dest = activeUsers[out[i]];
										if (dest) dest.send(codes.seUserChange,proto,'raw');
									}
								}.bind(this));
							}.bind(this));
						}.bind(this));
					}.bind(this));
			}.bind(this));
			break;
		case codes.scChangeEmail:
			try {
				var params = pb.Parse(args,'Poker.ChangeEMailParams');
			} catch (e) {
				this.error(e);
				return;
			}
			var newemail = params.new_mail;
			if ((newemail.length > sharedconfig.stringSizes.email) || (newemail.length < sharedconfig.minSizes.email)) {
				this.reply(0,'invalid email');
				return;
			}
			if (!regexLimits.email.exec(newemail)) {
				console.log('email invalid',newemail.indexOf('@'),newemail);
				this.reply(0,'invalid email');
				return;
			}
			allUsers.findOne({email:newemail},function (err,dup) {
				if (dup) {
					this.send(codes.srChangeMailReply,{status:'cmDuplicateMail'},'Poker.ChangeMailReply');
					return;
				}
				var authcode = uuid.v4();
				allUsers.update({_id:this.userid},{$set:{newemail:newemail, changecode:authcode, changetime: Date.now()}},function (err,res) {
					if (err) {
						console.log('email change error',err);
						this.reply("000","internal error");
						return;
					}
					var test = new SmtpConnection();
					var link = domain+'confirmchange?code='+authcode;
					test.sendMail(newemail,'From: ChipUP Poker <service@chipuppoker.com>\r\nTo: '+newemail+'\r\nSubject: E-Mail Change Verification\r\n\r\nConfirmation link: '+link,function cb(err,ret) {
						console.log('cb',err,ret);
						if (err) {
							this.send(codes.srChangeMailReply,{status:'cmInvalidEmail'},'Poker.ChangeMailReply');
							return;
						}
						this.send(codes.srChangeMailReply,{status:'cmSuccess'},'Poker.ChangeMailReply');
					}.bind(this));
				}.bind(this));
			}.bind(this));
			break;
		case codes.scChangePassword:
			try {
				var params = pb.Parse(args,'Poker.ChangePasswordParams');
			} catch (e) {
				this.error(e);
				return;
			}
			if (!regexLimits.password.exec(params.new_password)) {
				this.reply(0,'password too long');
				return;
			}
			deck.getRandom(16,function (salt) {
				var hasher = crypto.createHash('sha256');
				hasher.update(salt);
				hasher.update(params.new_password);
				var hash = hasher.digest();
				allUsers.update({_id:this.userid},{$set:{password:hash,salt:salt}},function (err,res) {
					if (err) {
						this.reply("000","internal error");
						return;
					}
					this.send(codes.srChangePasswordOk);
					token.stop();
				}.bind(this));
			}.bind(this));
			break;
		case codes.scSetAvatar:
			try {
				var params = pb.Parse(args,'Poker.SetAvatarParams');
			} catch (e) {
				this.error(e);
				return;
			}
			var id = params.avatar_id.toString('base64');
			delete params.avatar_id;
			this.log('changing avatar',id);
			avatars.findOne({_id:id},function(err,row) {
				if (err) {
					this.reply("000","internal error");
					return;
				}
				if (!row) {
					this.send(codes.srSetAvatarReply,{status:'saNotFound'},'Poker.SetAvatarReply');
					return;
				}
				allUsers.update({_id:this.userid},{$set:{avatar:id}},function (err,res) {
					if (err) {
						this.reply("000","internal error");
						return;
					}
					this.send(codes.srSetAvatarReply,{status:'saSuccess'},'Poker.SetAvatarReply');
					allClubs.find({$or:[{members:this.userid},{owner:this.userid}]},{owner:1,members:1}).toArray(function (err,rows) {
								assert.ifError(err);
								var out = [];
								for (var i=0; i<rows.length;i++) {
									if (!containsObjectID(out,rows[i].owner)) out.push(rows[i].owner);
									if (rows[i].members) {
										for (var j=0; j<rows[i].members.length; j++) {
											if (!containsObjectID(out,rows[i].members[j])) out.push(rows[i].members[j]);
										}
									}
								}
								allUsers.findOne({_id:this.userid},function (err,self) {
									assert.ifError(err);
									var proto = pb.Serialize({users:[makeUserProtobuf(self)]},'Poker.UserChangeParams');
									for (var i=0; i<out.length; i++) {
										if (compareObjectID(this.userid,out[i])) continue;
										var dest = activeUsers[out[i]];
										if (dest) dest.send(codes.seUserChange,proto,'raw');
									}
									token.stop();
								}.bind(this));
							}.bind(this));
				}.bind(this));
			}.bind(this));
			break;
		case codes.scCreateGame:
			try {
				var params = pb.Parse(args,'Poker.Game');
				var clubseq = params.clubseq;
				var game_type = params.game_type;
				var game_limit = params.game_limit;
				var blinds = params.blinds;
				var seats = params.seats;
				var gamename = params.gamename;
				if (checkGameParams(gamename,seats,game_type,game_limit,params.buyin_min,params.buyin_max,blinds)) {
					this.log('invalid create game:%j',params);
					this.reply(0,"invalid params");
					return;
				}
			} catch (e) {
				this.error(e);
				return;
			}
			var doc = {game_type:game_type, blinds:blinds, seats:seats, creator_mongo_id:this.userid, clubseq:clubseq, gamename:gamename, game_limit:game_limit, buyin_min:params.buyin_min, buyin_max:params.buyin_max,rake:0, rotation:0, hands:0};
			allClubs.findOne({seq:clubseq},function (err,club) {
				if (err) {
					this.reply(0,"internal error");
					return;
				}
				if (!club) {
					this.reply(0,"club not found");
					return;
				}
				if (!compareObjectID(club.owner,this.userid)) {
					this.reply(0,'your not owner');
					return;
				}
				doc.clubid = club._id;
				allGames.insert(doc,function (err,game) {
					if (err) {
						this.reply(0,"internal error");
						return;
					}
					this.log('inserted',game[0]);
					var g = makeGameProtobuf(game[0]);
					this.send(codes.srCreateGameOk,g,'Poker.Game');
					if (club.is_private) {
						if (!club.members) {
							token.tag += '-empty';
							token.stop();
							return;
						}
						token.tag += '-private';
						for (var x=0; x<club.members.length; x++) {
							var conn = activeUsers[club.members[x]];
							if (!conn) continue;
							conn.send(codes.seGameCreate,g,'Poker.Game');
						}
						token.stop();
					} else {
						token.tag += '-public';
						for (var key in activeUsers) {
							if (key === this) continue;
							activeUsers[key].send(codes.seGameCreate,g,'Poker.Game');
						}
						token.stop();
					}
				}.bind(this));
			}.bind(this));
			break;
		case codes.scCloseGame:
			try {
				var params = pb.Parse(args,'Poker.CloseGameData');
				var id = new toMongoId(params.gameid);
				switch (params.timestamp) {
				case 'cgtCurrentHand':
					params.timestamp = 0;
					break;
				case 'cgtFiveMinutes':
					params.timestamp = 5*60;
					break;
				case 'cgtFifteenMinutes':
					params.timestamp = 15*60;
					break;
				default:
					throw 'invalid timestamp';
				}
			} catch (e) {
				this.error(e);
				return;
			}
			this.log('closing game: %j',params);
			allGames.findOne({_id:id},function (err,gamerow) {
				if (err) {
					this.reply(0,"internal error");
					return;
				}
				if (!gamerow) {
					this.reply(0,"game not found");
					return;
				}
				Game.getGame(id,function (err,game) {
					if (!game.club.isOwner(this.userid)) {
						this.reply(0,'you dont own that club!');
						return;
					}
					game.Lock.writeLock(function (release) {
						if (params.timestamp > 0) {
							game.closeTimer = setTimeout(function () {
								game.Lock.writeLock(function (release2) {
									game.doClose(this,release2,gamerow);
								}.bind(this));
							}.bind(this),params.timestamp * 1000);
							game.closeTime = Date.now() + (params.timestamp * 1000);
							game.state2 = 'gsClosing';
							clubBroadcastGameState(gamerow.clubid,JSON.parse(JSON.stringify(gamerow)),release);
						} else {
							game.closeTime = 0;
							game.doClose(this,release,gamerow);
						}
					}.bind(this));
				}.bind(this));
			}.bind(this));
			break;
		/*case codes.scEditGame:
			var params = pb.Parse(args,'Poker.Game');
			this.log('edit game',params);
			var id = new toMongoId(params._id);
			this.log('id is',id);
			var game_type = params.game_type;
			var game_limit = params.game_limit;
			var small_blind = params.small_blind;
			var big_blind = params.big_blind;
			var seats = params.seats;
			var gamename = params.gamename;
			if (checkGameParams(small_blind,big_blind,gamename,seats,game_type,game_limit,params.buyin_min,params.buyin_max)) {
				this.log('invalid create game:%j',params);
				this.reply(0,"invalid params");
				return;
			}
			// FIXME, run game.preedit
			var doc = {$set:{game_type:game_type, small_blind:small_blind, big_blind:big_blind, seats:seats, gamename:gamename, game_limit:game_limit, buyin_min:params.buyin_min, buyin_max:params.buyin_max }};
			allGames.update({_id:id},doc,function (err,res) {
				if (err) {
					this.reply(0,"internal error");
					return;
				}
				this.log('edit game',res);
				if (activeGames[id]) activeGames[id].edited(params);
				// FIXME performance?
				allGames.findOne({_id:id},function (err,game) {
					allClubs.findOne({_id:game.clubid},function (err,club) {
						var g = makeGameProtobuf(game);
						this.send(codes.srEditGameOk,g,'Poker.Game');
						for (var x=0; x<club.members.length; x++) {
							var conn = activeUsers[club.members[x]];
							if (!conn) continue;
							conn.send(codes.seGameChange,g,'Poker.Game');
						}
					}.bind(this));
				}.bind(this));
			}.bind(this));
			break;*/
		case codes.seChat:
			try {
				var event = pb.Parse(args,'Poker.ChatEvent');
				this.handleChatEvent(event,Date.now(),token);
			} catch (e) {
				this.error(e);
			}
			break;
		case codes.scTableJoin:
			var params = pb.Parse(args,'Poker.Game');
			try {
				var id = new toMongoId(params._id);
			} catch (e) {
				this.error(e);
				return;
			}
			this.log('table join',id);
			Game.getGame(id,function (err,game) {
				if (!game) {
					this.reply(0,'invalid gameid');
					return;
				}
				if (game.state2 == 'gsClosed') return;
				game.Lock.writeLock(function (release) {
					this.log('game info',game.obj.clubid);
					allClubs.findOne({_id:game.obj.clubid},function (err,club) {
						if (club.suspended) {
							for (var x=0; x<club.suspended.length; x++) {
								console.log(club.suspended[x],this.userid);
								if (compareObjectID(club.suspended[x],this.userid)) {
									this.reply(0,'your suspended in that club'); // FIXME
									release();
									return;
								}
							}
						}
						console.log(club);
						if (!compareObjectID(this.userid,club.owner) && (!club.members || !containsObjectID(club.members,this.userid)) && club.is_private) {
							this.log('i am not a member');
							this.reply(0,'your not a member of that club'); // FIXME, bots rely on this error
							release();
						} else {
							game.join(this,function () {
								var events = [];
								if (['tsFlop','tsTurn','tsRiver'].indexOf(game.state) != -1) {
									var cards = game.flop.cards;
									if (['tsTurn','tsRiver'].indexOf(game.state) != -1) cards = cards.concat(game.turn.cards);
									if (game.state == 'tsRiver') cards = cards.concat(game.river.cards);
									events.push(game.makeEvent('teExistingCards',{cards:new Buffer(cards)}));
								}
								var status = game.getTableStatus(this,true,events);
								this.send(codes.seTableStatus,status,'Poker.TableStatus');
								release();
								token.stop();
							}.bind(this));
						}
					}.bind(this));
				}.bind(this));
			}.bind(this));
			break;
		case codes.scTableLeave:
			var params = pb.Parse(args,'Poker.Game');
			try {
				var id = new toMongoId(params._id);
			} catch (e) {
				return;
			}
			delete params._id;
			Game.getGame(id,function (err,game) {
				if (!game) {
					this.reply(0,'invalid gameid');
				} else {
					if (!game.users[this.userid]) {
						this.reply(0,'your not at the table');
						return;
					}
					game.leave(this,'protocol',function () {});
					token.stop();
				}
			}.bind(this));
			break;
		case codes.scTableSit:
			try {
				var params = pb.Parse(args,'Poker.TableSit');
				var id = new toMongoId(params.game_id);
			} catch (e) {
				this.log('params where %j',params);
				this.error(e);
				return;
			}
			delete params.game_id;
			Game.getGame(id,function (err,game) {
				if (!game) {
					this.reply(0,'invalid gameid');
					return;
				}
				if (game.state2 == 'gsClosed') return;
				var temp = this.userid;
				game.Lock.writeLock(function (release) {
					if (temp != this.userid) {
						this.reply(0,'sit error 1');
						release();
						return;
					}
					if (game.state2 == 'gsClosed') {
						release();
						return;
					}
					if (!game.users[this.userid]) {
						this.reply(0,'your not at the table');
						release();
						return;
					}
					game.sitDown(this,params,function (sucess,events) {
						if (sucess) {
							game.broadcastStatus(this,true,events); // sendEvent
							var status = game.getTableStatus(this,true,events);
							this.send(codes.srTableSitOk,status,'Poker.TableStatus');
						}
						if (game.state == 'tsIdle') {
							game.stateMachine(function () {
								token.stop();
								release();
							},null,{silent:true},[],0);
						} else {
							token.stop();
							release();
						}
					}.bind(this));
				}.bind(this));
			}.bind(this));
			break;
		case codes.scTableStandUp:
			var params = pb.Parse(args,'Poker.Game');
			try {
				var id = toMongoId(params._id);
			} catch (e) {
				log('params to scTableStandUp where %j',params);
				//this.error(e);
				return;
			}
			var once = true;
			Game.getGame(id,function (err,game) {
				if (!game) return;
				game.Lock.writeLock(function (release) {
					var x = game.findSeat(this);
					var seating = game.members[x];
					if (!seating) {
						this.log('standup error %d',x);
						release();
						return;
					}
					var token2 = profiler.start('stand-inner1');
					game.standUp(this,function (folded,events,offset) {
						assert(once);
						once = false;
						this.log('2events are %j',events);
						if (folded && (game.current_seat >= 0)) {
							game.startTimer(game.current_seat,offset);
						}
						this.send(codes.srTableStandUpOk,game.getTableStatus(this,true,events),'Poker.TableStatus');
						var havechips = 0;
						for (var x=0; x<game.members.length; x++) {
							if (!game.members[x]) {
								continue;
							}
							if (game.members[x].status == 'psOutOfPlay') continue;
							if (game.members[x].disconnected) continue;
							if (game.members[x].chips > 0) {
								game.log('standup found one %d %s %d',x,game.members[x].status,game.members[x].chips);
								havechips++;
							}
						}
						if (havechips < 2) {
							clearTimeout(game.dealTimer);
							game.dealTimer = null;
							game.log('cleared deal timer');
						}
						game.broadcastStatus(this,true,events);
						token.stop();
						token2.stop();
						release();
					}.bind(this));
				}.bind(this));
			}.bind(this));
			break;
		case codes.scSuspendPlayer:
			try {
				var params = pb.Parse(args,'Poker.ChangeSuspendState');
				this.log('params:%j',params);
				var clubid = toMongoId(params.club_mongo_id);
				var playerid = toMongoId(params.player_mongo_id);
			} catch (e) {
				this.error(e);
				return;
			}
			var broadcast = function broadcast(code) {
				allClubs.findOne({_id:clubid},function cb(err,row) {
					Club.getClubById(clubid,function (err,clubObj) {
						clubObj.refresh(row);
						clubBalances.find({clubid:clubObj.clubid}).toArray(function (err,stats) {
							var userlist = [ ];
							var out = Club.makeClubProtobuf(row,userlist,stats,clubObj);
							this.send(code,out,'Poker.Club');
							this.log('userlist to inform:',userlist);
							for (var x=0; x<userlist.length; x++) {
								var user = activeUsers[userlist[x]];
								if (user) user.send(codes.seClubChange,out,'Poker.Club');
							}
						}.bind(this));
					}.bind(this));
				}.bind(this));
			}.bind(this);
			allClubs.findOne({_id:clubid},function (err,club) {
				if (!club) {
					this.reply(0,'club not found');
					return;
				}
				if (!compareObjectID(club.owner,this.userid)) {
					this.log('your not owner');
					return;
				}
				if (params.suspended) {
					if (!containsObjectID(club.members,playerid)) {
						this.reply(0,'player isnt a member');
						return;
					}
					allClubs.update({_id:clubid},
						{ $addToSet: { suspended: playerid} },
						function (err,res) {
							this.log('suspend push',err,res);
							broadcast(codes.srSuspendPlayerOk);
						}.bind(this)
					);
				} else {
					allClubs.update({_id:clubid},
						{ $pull:{suspended:playerid}},
						function (err,res) {
							this.log('suspend pull',err,res);
						broadcast(codes.srReinstatePlayerOk);
						}.bind(this)
					);
				}
			}.bind(this));
			break;
		case codes.scGetPlayers:
			try {
				var params = pb.Parse(args,'Poker.GetUserParams');
				this.log('getting players: %j',params);
				for (var x=0; x<params.user_mongo_ids.length; x++) {
					params.user_mongo_ids[x] = toMongoId(params.user_mongo_ids[x]);
				}
			} catch (e) {
				this.error(e);
				return;
			}
			allUsers.find({_id:{$in:params.user_mongo_ids}}).toArray(function (err,users) {
				this.log(params.user_mongo_ids,users);
				var out = {users:[]};
				for (var x=0; x<users.length; x++) {
					out.users[x] = makeUserProtobuf(users[x]);
				}
				this.send(codes.srGetPlayers,out,'Poker.GetUserParams');
				token.stop();
			}.bind(this));
			break;
		case codes.scFold:
			var token2 = profiler.start('fold-inner4');
			try {
				var params = pb.Parse(args,'Poker.Game');
				var id = toMongoId(params._id);
			} catch (e) {
				this.error(e);
				return;
			}
			Game.getGame(id,function (err,game) {
				if (!game) return;
				game.Lock.writeLock(function (release) {
					var x = game.findSeat(this);
					var seating = game.members[x];
					if (x != game.current_seat) {
						this.reply(0,'fold while not active player');
						console.log('fold fail 2');
						release();
						return;
					} else if (seating && seating.status == 'psInHand') {
						token2.stop(); // 3ms avg
						var token1 = profiler.start('fold-inner1');
						game.fold(x,function (events,offset) { // 36ms avg
							token1.stop();
							var token3 = profiler.start('fold-inner5');
							assert(events);
							if (game.current_seat >= 0) {
								game.startTimer(game.current_seat,offset);
							}
							game.broadcastStatus(null,true,events);
							token3.stop(); // 17ms avg
							token.stop(); // 61ms avg
							release();
						}.bind(this));
					} else {
						this.log('fold error',util.inspect(seating));
						release();
					}
				}.bind(this));
			}.bind(this));
			break;
		case codes.scTableAddOn:
			try {
				var params = pb.Parse(args,'Poker.TableSit');
				if (params.chips < 1) {
					this.reply(0,'you cant buyout');
					return;
				}
				var id = new toMongoId(params.game_id);
			} catch (e) {
				this.error(e);
				return;
			}
			delete params.game_id;
			Game.getGame(id,function (err,game) {
				var seatIdx = game.findSeat(this);
				if (seatIdx === undefined) {
					this.reply(0,'your not sitting');
					return;
				}
				if (['psOutOfPlay','psFolded','psOutOfHand'].indexOf(game.members[seatIdx].status) == -1) {
					this.reply(0,'your not out of play!');
					return;
				}
				if ((params.chips + game.members[seatIdx].chips) > (game.obj.buyin_max * game.obj.big_blind)) {
					this.send(codes.srTableAddonOverLimit,game.getTableStatus(this,false,[]),'Poker.TableStatus');
					return;
				}
				assert.equal(this.state,2);
				game.AddOn(this,params.chips);
			}.bind(this));
			break;
		default:
			if (handlers[code]) handlers[code].call(this,args,token);
			else this.log('unknown opcode %d/%s',code,codes.reverse[code]);
		}
	}
}
var handlers = {};
/*handlers[codes.scStatus] = function(args,token) {
	this.getStatusPacket(function (status) {
		this.send(codes.srStatus,status,'Poker.StatusReply');
		token.stop();
	}.bind(this));
}*/
ClientSocket.prototype.getStatusPacket = function (maincb) {
	var query = {$or:[ {owner:this.userid} , {members:this.userid} , {is_private:false} ]};
	// owner should see password
	// all need to see name, _id, seq, private, chips, and members
	allClubs.find(query).toArray(function(err,clubs) {
		var status = {};
		status.clubs = clubs;
		var x,y;
		var userlist = [];
		var clubids = [];
		var ownedClubs = [];
		for (x=0; x<clubs.length; x++) {
			var c = clubs[x];
			if (userlist.indexOf(c.owner) == -1) userlist.push(c.owner);
			if (clubs[x].owner.equals(this.userid)) {
				if (clubs[x].password == null) delete clubs[x].password;
				ownedClubs.push(c._id);
			} else {
				delete clubs[x].password;
			}
			clubids.push(c._id);
		}
		clubBalances.find({clubid:{$in:ownedClubs}}).toArray(function (err,balances) {
			assert.ifError(err);
			var clubsOut = [];
			async.each(clubs,function getStatsAndClub(item,cb) {
				Club.getClubById(item._id,function (err,club) {
					var obj = Club.makeClubProtobuf(item,userlist,balances,club);
					clubsOut.push(obj);
					cb();
				}.bind(this));
			}.bind(this),function finished() {
				status.clubs = clubsOut;
				allUsers.find({_id:{$in:userlist}},{displayname:"",_id:"",chips:"",avatar:""}).toArray(function(err,users) {
					for (var x=0; x<users.length; x++) {
						users[x] = makeUserProtobuf(users[x]);
					}
					status.users = users;
					allUsers.findOne({_id:this.userid},function(err,self) {
						status.self = makeUserProtobuf(self);
						// FIXME, hide closed games, send them in a second array for just the owner
						allGames.find({clubid:{$in:clubids}}).toArray(function (err,games) {
							if (err) {
								this.reply(0,"internal error");
								return;
							}
							for (var x=0; x<games.length; x++) {
								games[x] = makeGameProtobuf(games[x]);
							}
							//this.log('games list:%j',games);
							status.games = games;
							maincb(status);
							//this.log('status reply:',status);
						}.bind(this));
					}.bind(this));
				}.bind(this));
			}.bind(this));
		}.bind(this));
	}.bind(this));
}
handlers[codes.scTableSitOutNextHand] = function (args,token) {
	try {
		var params = pb.Parse(args,'Poker.TableBoolFlag');
		var id = toMongoId(params.table_mongo_id);
	} catch (e) {
		this.error(e);
		return;
	}
	Game.getGame(id,function (err,game) {
		if (!game) return;
		game.Lock.writeLock(function (release) {
			var seatIdx = game.findSeat(this);
			if (seatIdx === undefined) {
				this.reply(0,'your not sitting');
				release();
				return;
			}
			if (['psInHand','psAllIn','psFolded','psOutOfHand'].indexOf(game.members[seatIdx].status) == -1) {
				this.reply(0,'you cant sitout if your out of play');
				release();
				return;
			}
			if ((game.state == 'tsIdle') && (['psInHand','psOutOfHand'].indexOf(game.members[seatIdx].status) != -1)) {
				game.members[seatIdx].status = 'psOutOfPlay';
				game.clearDealTimer();
				game.members[seatIdx].sitOutNextRound = false;
				game.members[seatIdx].sitOutBB = false;
				game.updateMongoState({},{members:true},function () {
					game.broadcastStatus(null,true,[]);
				});
			} else if ('psOutOfHand' == game.members[seatIdx].status) {
				game.members[seatIdx].status = 'psOutOfPlay';
				game.broadcastStatus(null,true,[]);
			} else {
				game.members[seatIdx].sitOutNextRound = params.flag;
			}
			token.stop();
			release();
		}.bind(this));
	}.bind(this));
}
handlers[codes.scPutChips] = function (args,token) {
	try {
		var params = pb.Parse(args,'Poker.PutChips');
		var id = toMongoId(params.table_mongo_id);
	} catch (e) {
		this.error(e);
		return;
	}
	delete params.table_mongo_id;
	this.log('putChips %j',params);
	var token2 = profiler.start('putChips-inner3');
	var token6 = profiler.start('putChips-inner6'); // includes writeLock callback if its unlocked
	Game.getGame(id,function (err,game) {
		if (!game) return;
		game.Lock.writeLock(function (release) {
			token2.stop();
			if (params.current_state != game.state) {
				this.reply(0,'state mismatch');
				release();
				return;
			}
			var token5 = profiler.start('putChips-inner5');
			var seat = game.findSeat(this);
			if (seat != game.current_seat) {
				this.reply(0,'putchips while not active player');
				console.log('putChips fail 2 %d %d',seat,game.current_seat);
				release();
				return;
			}
			game.putChips(this,params.chip_amount,function (events,offset){
				assert(game.members[seat].chips >= 0);
				if (['tsWinning'].indexOf(game.state) == -1) {
					game.startTimer(game.current_seat,offset);
				}
				var token4 = profiler.start('putChips-inner4-2');
				game.broadcastStatus(null,true,events);
				token4.stop();
				token.stop();
				release();
				game.checkDelayedLeave();
			}.bind(this));
			token5.stop();
		}.bind(this));
	}.bind(this));
	token6.stop();
}
handlers[codes.scTableSitOutNextBB] = function (args) {
	try {
		var params = pb.Parse(args,'Poker.TableBoolFlag');
		var id = toMongoId(params.table_mongo_id);
	} catch (e) {
		this.error(e);
		return;
	}
	Game.getGame(id,function (err,game) {
		if (!game) return;
		var seatIdx = game.findSeat(this);
		if (seatIdx === undefined) {
			this.reply(0,'your not sitting');
			return;
		}
		if (['psInHand','psAllIn','psFolded','psOutOfHand'].indexOf(game.members[seatIdx].status) == -1) {
			this.reply(0,'you cant sitout if your out of play');
			return;
		}
		game.members[seatIdx].sitOutBB = params.flag;
	}.bind(this));
}
handlers[codes.scResendVerificationMail] = function () {
	allUsers.findOne({_id:this.userid},function (err,row) {
		if (row.authcode) sendAuthEmail(this.userid,row.authcode,row.email,row.displayname,function () {},function () {},function () {});
	}.bind(this));
}
handlers[codes.scShowCards] = function (args,token) {
	try {
		var params = pb.Parse(args,'Poker.Game');
		var id = toMongoId(params._id);
	} catch (e) {
		this.error(e);
		return;
	}
	Game.getGame(id,function (err,game) {
		if (!game) return;
		game.Lock.writeLock(function (release) {
			if (game.state != 'tsWinning') {
				this.reply(0,'the game isnt over yet');
				this.log('state was %s',game.state);
				release();
				return;
			}
			var seatIdx = game.findSeat(this);
			if (seatIdx === undefined) {
				this.reply(0,'your not sitting');
				release();
				return;
			}
			if (game.members[seatIdx].can_show) {
				game.members[seatIdx].muck = false;
				game.history.players[seatIdx].muck = false;
				game.broadcastStatus(this,true,[]);
				game.members[seatIdx].can_show = false;
			}
			token.stop();
			release();
		}.bind(this));
	}.bind(this));
}
/*handlers[codes.scRetrieveHandHistoryData] = function (args) {
	var params = pb.Parse(args,'Poker.RetrieveHandHistoryData');
	handHistory.find({seq:{ $gt:params.startid, $lt:params.endid }},{seq:1}).toArray(function (err,rows) {
		this.send(codes.srRetrieveHandHistoryData,{rows:rows},'Poker.RetrieveHandHistoryReply');
	}.bind(this));
}
handlers[codes.scFetchHandHistory] = function (args) {
	var params = pb.Parse(args,'Poker.FetchHandHistory');
	// FIXME, verify he has access to these games
	console.log(args,params);
	var doc = { query:params, querycode:  uuid.v4() };
	FetchQueue.insert(doc,function (err,row) {
		assert.ifError(err);
		console.log(row);
		this.send(codes.srFetchHandData,{uuid:doc.querycode},'Poker.FetchHandReply');
	}.bind(this));
}*/
handlers[codes.scQueryTableStats] = function (args,token) {
	var params = pb.Parse(args,'Poker.QueryTableStats');
	console.log('params:%j',params);
	var ids = [];
	var clublist = [];
	var list2 = {};
	if (params.gameid.length == 0) {
		log('building list from owned clubs');
		allClubs.find({owner:this.userid}).toArray(function (err,clubs) {
			assert.ifError(err);
			for (var i=0; i<clubs.length; i++) clublist.push(clubs[i]._id);
			allGames.find({clubid:{$in:clublist}}).toArray(function (err,games) {
				assert.ifError(err);
				for (var i=0; i<games.length; i++) {
					if (!list2[games[i].clubid]) list2[games[i].clubid] = [];
					list2[games[i].clubid].push(games[i]._id);
					ids.push(games[i]._id);
				}
				step2.call(this);
			}.bind(this));
		}.bind(this));
	} else {
		log('using list passed in');
		assert(false);
		try {
			for (var i=0; i<params.gameid.length; i++) {
				ids.push(toMongoId(params.gameid[i]));
			}
		} catch (e) {
			this.error(e);
			return;
		}
		step2.call(this);
	}
	function step2() {
		var data = {};
		async.each(clublist,function (clubid,cb) {
			Club.getClubById(clubid,function (err,clubObj) {
				if (list2[clubid]) {
					clubObj.getTableStatsPacket(list2[clubid],data,cb);
				}
			});
		},function () {
			if (data.players) {
				Club.finishTableStatsPacket(data,function (packet) {
					//console.log('packet:%j',packet);
					this.send(codes.srTableStatsReply,packet,'Poker.TableStatsReplies');
					token.stop();
				}.bind(this));
			}
			// done all clubs
		}.bind(this));
	}
}
handlers[codes.scContactUs] = function (args,token) {
	try {
		var params = pb.Parse(args,'Poker.ContactMessage');
		if ((params.message.length < sharedconfig.minSizes.ContactMessage) || (params.message.length > sharedconfig.stringSizes.ContactMessage)) {
			return;
		}
	} catch (e) {
		this.error(e);
		return;
	}
	this.log('raw args:%s parsed:%j',args,params);
	var doc = {userid:this.userid, message:params.message, reason:params.reason, closed:false};
	conn.collection('contacts').insert(doc,function (err,row) {
		this.log('obj:%j',row);
		var types = {cmQuestions:'Questions',cmSuggestions:'Suggestions',cmOther:'Other',cmBugReport:'Bugs'};
		var queue = types[params.reason];
		RT.postTicket(queue,this.email,params.message);
		this.send(codes.srContactUsOk);
		token.stop();
	}.bind(this));
}
handlers[codes.scTablePlayNow] = function (args,token) {
	try {
		var params = pb.Parse(args,'Poker.Game');
		var id = toMongoId(params._id);
	} catch (e) {
		this.error(e);
		return;
	}
	Game.getGame(id,function (err,game) {
		if (!game) return;
		if (game.state2 == 'gsClosed') return;
		game.Lock.writeLock(function (release) {
			var seatIdx = game.findSeat(this);
			if (seatIdx === undefined) {
				this.reply(0,'your not sitting');
				release();
				return;
			}
			if (game.members[seatIdx].chips == 0) {
				this.reply(0,'you dont have enough chips');
				release();
				return;
			}
			if (game.members[seatIdx].status != 'psOutOfPlay') {
				game.members[seatIdx].sitOutNextRound = false;
				game.members[seatIdx].sitOutBB = false;
				release();
				return;
			}
			game.members[seatIdx].status = 'psOutOfHand';
			//game.members[seatIdx].sitTime = Date.now();
			if (game.state == 'tsIdle') {
				if (!game.dealTimer) {
					game.dealTimer = setTimeout(function () {
						game.Lock.writeLock(function (release) {
							game.dealTimer = null;
							game.stateMachine(function (events) {
								game.broadcastStatus(null,true,events);
								release();
							}.bind(this),null,{silent:true},[],0);
						}.bind(this));
					}.bind(this),5000);
					finish([]);
				} else {
					game.log('waiting for deal timer');
					finish([]);
				}
			} else finish([]);
			function finish(events) { // teDeal
				game.updateMongoState({},{members:true},function () {
					game.broadcastStatus(null,true,events);
					token.stop();
					release();
				});
			}
		}.bind(this));
	}.bind(this));
}
handlers[codes.scCreateClub] = function (args,token) {
	var params = pb.Parse(args,'Poker.Club');
	if (!regexLimits.clubname.exec(params.name)) {
		this.send(codes.srCreateClubReply,{status:'csInvalidName'},'Poker.ClubCommandReply');
		return;
	}
	if ((params.rake < 1) || (params.rake > 10) || (!params.rake)) {
		this.reply(0,"invalid rake");
		return;
	}
	if (!params.password) {
		this.send(codes.srCreateClubReply,{status:'csInvalidPassword'},'Poker.ClubCommandReply');
		return;
	} else if (!regexLimits.clubpassword.exec(params.password)) {
		this.send(codes.srCreateClubReply,{status:'csInvalidPassword'},'Poker.ClubCommandReply');
		return;
	}
	// FIXME, dont allow a blank pw on priv clubs
	allClubs.findOne({name:{$regex:new RegExp('^'+params.name+'$','i')}},function (err,row) {
		if (row) {
			this.log('SR_CREATECLUB_NAME_EXISTS',err);
			this.send(codes.srCreateClubReply,{status:'csNameExists'},'Poker.ClubCommandReply');
			return;
		}
		var doc = {is_private:true,password:params.password,name:params.name, owner:this.userid, chips:100000,rake:params.rake, unlimited_default_balance:true, default_balance_limit:100000};
		getNextSequence('club',function (seq) {
			doc.seq = seq;
			allClubs.insert(doc,function(err,result) {
				if (err) {
					this.log('shouldnt happen 012',err);
					this.send(codes.srCreateClubReply,{status:'csNameExists'},'Poker.ClubCommandReply');
					return;
				}
				Club.getClubById(result[0]._id,function (err,clubObj) {
					clubObj.updateLimitPostWin(0,this.userid,function (){
						var out = Club.makeClubProtobuf(result[0],null,[]);
						this.send(codes.srCreateClubReply,{status:'csSuccess',club:out},'Poker.ClubCommandReply');
					}.bind(this));
				}.bind(this));
			}.bind(this));
		}.bind(this));
	}.bind(this));
}
handlers[codes.scDeleteClub] = function (args,token) {
	function deleteClub(club) {
		allClubs.remove({_id:club._id},function (err,res) {
			this.log('delete worked',err,res);
			// FIXME, force end games in this club?
			Club.getClubById(club._id,function (err,clubObj) {
				clubObj.refresh(club);
				clubBalances.find({clubid:clubObj.clubid}).toArray(function (err,stats) {
					var userlist = [];
					var out = Club.makeClubProtobuf(club,userlist,stats,clubObj);
					this.send(codes.srClubDisbandOk,out,'Poker.Club');
					this.log('userlist to inform:',userlist);
					for (var x=0; x<userlist.length; x++) {
						var user = activeUsers[userlist[x]];
						if (user) user.send(codes.seClubDeleted,out,'Poker.Club');
					}
				}.bind(this));
			}.bind(this));
		}.bind(this));
	}
	var params = pb.Parse(args,'Poker.Club');
	var clubseq = params.seq;
	this.log('deleting club',params);
	allClubs.findOne({seq:clubseq},function (err,club) {
		if (!club) {
			this.log('club not found');
			this.reply("000","club not found");
			return;
		}
		if (!club.owner.equals(this.userid)) {
			this.log('not owner');
			this.reply("000","your not owner");
			return;
		}
		allGames.find({clubid:club._id},{state2:1}).toArray(function (err,games) {
			for (var x=0; x<games.length; x++) {
				if (games[x].state2 != 'gsClosed') {
					this.reply(0,'not all games are closed');
					return;
				}
				if (activeGames[games[x]._id]) {
					//this.reply(0,'all spectators must leave all games before you can delete the club');
					//return;
				}
			}
			deleteClub.call(this,club);
		}.bind(this));
	}.bind(this));
}
handlers[codes.scKickPlayer] = function (args,token) {
	function finishKick(club) {
		allClubs.update({seq:clubid},
			{ $pull:{members:userid}},
			function (err,res) {
				if (res == 0) {
					this.send(codes.srKickPlayerReply,{status:'csInvalidClubId'},'Poker.ClubCommandReply');
					return;
				}
				allClubs.findOne({_id:club._id},function cb(err,row) {
					Club.getClubById(club._id,function (err,clubObj) {
						clubObj.refresh(row);
						clubBalances.find({clubid:clubObj.clubid}).toArray(function (err,stats) {
							var userlist = [ userid ];
							var out = Club.makeClubProtobuf(row,userlist,stats,clubObj);
							this.send(codes.srKickPlayerReply,{status:'csSuccess',club:out},'Poker.ClubCommandReply');
							this.log('userlist to inform:',userlist);
							this.log('out:%j',out);
							for (var x=0; x<userlist.length; x++) {
								var user = activeUsers[userlist[x]];
								if (user) user.send(codes.seClubChange,out,'Poker.Club');
							}
						}.bind(this));
					}.bind(this));
				}.bind(this));
			}.bind(this));
	}
	// FIXME, update Club object
	try {
		var params = pb.Parse(args,'Poker.KickPlayerParams');
		var clubid = params.club_seq;
		var userid = toMongoId(params.player_mongo_id);
		this.log('kicking',clubid,userid);
		// FIXME, code 023 kicking somebody not in the club
		allClubs.findOne({seq:clubid},function (err,club) {
			if (!club.owner.equals(this.userid)) {
				this.reply("000","your not owner");
				this.log('attempted to kick while not owner');
				return;
			}
			var target = activeUsers[userid];
			if (target) {
				allGames.find({clubid:club._id}).toArray(function (err,clubGames) {
					assert.ifError(err);
					async.each(clubGames,function checkGame(gameRow,cb) {
						var gameObj = activeGames[gameRow._id];
						if (gameObj) {
							this.log('found a game active');
							var seatIdx = gameObj.findSeat(target);
							if (seatIdx == -1) return cb();
							this.log('and target is in seat %d',seatIdx);
							gameObj.Lock.writeLock(function (release) {
								this.log('got lock');
								gameObj.standUp(target,function (folded,events,offset) {
									this.log('stood up');
									gameObj.broadcastStatus(null,true,events);
									release();
									cb();
								}.bind(this));
							}.bind(this));
						} else cb();
					}.bind(this),function () {
						finishKick.call(this,club);
					}.bind(this));
				}.bind(this));
			} else finishKick.call(this,club);
		}.bind(this));
	} catch (e) {
		this.error(e);
	}
}
handlers[codes.scSetPlayerLimit] = function (args,token) {
	try {
		var params = pb.Parse(args,'Poker.PlayerLimitParams');
		var clubid = toMongoId(params.clubid);
		var userid = toMongoId(params.userid);
		//this.log('params:%j',params);
		if (params.limit < 1) return this.reply(0,'limit too low');
	} catch (e) {
		this.error(e);
		return;
	}
	Club.getClubById(clubid,function (err,clubObj) {
		if (err == 'not found') {
			this.reply(0,'club not found');
			return;
		}
		assert.ifError(err);
		assert(clubObj);
		if (!clubObj.isOwner(this.userid)) {
			this.reply(0,'your not the owner');
			return;
		}
		clubObj.updateLimit(userid,params.limit,params.unlimited,function (result) {
			//clubObj.getTableStatsPacket([
			if (result) this.send(codes.srPlayerLimitOk,args,'raw');
			else this.reply(0,'player not found');
			token.stop();
		}.bind(this));
	}.bind(this));
}
handlers[codes.scResetPlayerBalance] = function (args,token) {
	try {
		var params = pb.Parse(args,'Poker.PlayerLimitParams');
		var clubid = toMongoId(params.clubid);
		var userid = toMongoId(params.userid);
		this.log('params:%j',params);
	} catch (e) {
		this.error(e);
		return;
	}
	Club.getClubById(clubid,function (err,clubObj) {
		if (err == 'not found') {
			this.reply(0,'club not found');
			return;
		}
		assert.ifError(err);
		assert(clubObj);
		if (!clubObj.isOwner(this.userid)) {
			this.reply(0,'your not the owner');
			return;
		}
		clubObj.resetPlayerLimit(userid,function (result) {
			if (result) this.send(codes.srResetPlayerBalanceOk,args,'raw');
			else this.reply(0,'player not found');
			token.stop();
		}.bind(this));
	}.bind(this));
}
function makeUserProtobuf(u) {
	if (u.avatar) u.avatar = new Buffer(u.avatar,'base64');
	else u.avatar = new Buffer([33]);
	u._id = new Buffer(u._id.toString(),'hex');
	return u;
}
function Pot(game) {
	this.value = 0;
	this.members = []
	this.trueMembers = []
	this.trueUsers = [];
}
Pot.prototype.getPostRake = function (rake) {
	return Math.floor(this.value * ((100 - rake)/100)); // FIXME, double check the math
}
Pot.prototype.add = function (bet,seat,game) {
	this.value += bet;

	if (this.trueMembers.indexOf(seat) == -1) {
		this.trueMembers.push(seat);
		this.trueUsers.push(game.seats[seat].userid);
	}

	if (this.members.indexOf(seat) != -1) return;
	var pub = game.members[seat];
	if (!pub) return; // he stood up
	if (pub.status == 'psFolded') return;
	this.members.push(seat);
}
function Game(obj) {
	this.users = {}; // all users, even not sitting
	this.members = []; // all users, as seen by the users
	this.seats = []; // internal data for seats
	this.reconnect = [];
	this.timebanks = {}; // timebank data for all users who have visited the table
	this.obj = obj;
	this.id = obj._id;
	activeGames[this.id] = this;
	this.state = 'tsIdle';
	this.dealer = -1;
	this.current_seat = -1;
	this.bets = [];
	this.pots = [ new Pot(this) ];
	this.minBet = 0;
	this.minimum_raise = 0;
	this.log('pots initialized to zero');
	this.Lock = new ReadWriteLock();
	this.omaha = this.obj.game_type == 'gtOmaha';
	this.lastplayer = [];
	this.autoDelete = false;
	this.rotation = this.obj.rotation;
	this.lastCashout = {};
	switch (this.obj.blinds) {
	case 'gb1x2':
		this.obj.small_blind = 100;
		this.obj.big_blind = 200;
		break;
	case 'gb5x5':
		this.obj.small_blind = 500;
		this.obj.big_blind = 500;
		break;
	case 'gb5x10':
		this.obj.small_blind = 500;
		this.obj.big_blind = 1000;
		break;
	case 'gb10x25':
		this.obj.small_blind = 1000;
		this.obj.big_blind = 2500;
		break;
	case 'gb25x50':
		this.obj.small_blind = 2500;
		this.obj.big_blind = 5000;
		break;
	case 'gb50x100':
		this.obj.small_blind = 5000;
		this.obj.big_blind = 10000;
		break;
	}

	if (this.obj.game_type == 'gtRotationNLHPLO') {
		this.omaha = this.rotation > this.obj.seats;
		if (this.omaha) {
			this.game_limit = 'glPotLimit';
		} else {
			this.game_limit = 'glNoLimit';
		}
	} else {
		this.game_limit = this.obj.game_limit;
	}

	if (obj.state2) this.state2 = obj.state2;
	else this.state2 = 'gsActive';
}
Game.prototype.doClose = function (conn,cb,gamerow) {
	if (this.state == 'tsIdle') this.close(this,cb);
	else {
		this.autoDelete = true;
		this.state2 = 'gsClosing';
		clubBroadcastGameState(gamerow.clubid,gamerow,cb);
	}
}
Game.prototype.clearDealTimer = function () {
	var havechips = 0;
	for (var x=0; x<this.members.length; x++) {
		if (!this.members[x]) {
			continue;
		}
		if (this.members[x].status == 'psOutOfPlay') continue;
		if (this.members[x].disconnected) continue;
		if (this.members[x].chips > 0) {
			this.log('standup found one %d %s %d',x,this.members[x].status,this.members[x].chips);
			havechips++;
		}
	}
	if (havechips < 2) {
		clearTimeout(this.dealTimer);
		this.dealTimer = null;
		this.log('cleared deal timer');
	}
}
function clubBroadcastGameState(clubid,gamerow,cb) {
	Club.getClubById(clubid,function (err,clubObj) {
		clubObj.seGameChanged(gamerow,cb);
	});
}
Game.prototype.close = function(conn,cb) {
	allGames.update({_id:this.id},{$set:{state2:'gsClosed'}},function (err,ret) {
		if (err) {
			conn.reply(0,"internal error");
			return;
		}
		this.state2 = 'gsClosed';
		this.log('closed game %s %d',err,ret);
		
		var count = 0;
		for (var key in this.users) {
			count++;
			this.log('Game.close key:%s count:%d',key,count);
		}
		if (count == 0) {
			this.log('self-deleting');
			delete activeGames[this.id];
			this.doDelete();
		} else {
			this.deleteTimer = setTimeout(this.doDelete.bind(this),5 * 60 * 1000);
			this.club.seGameChanged(JSON.parse(JSON.stringify(this.obj)),function () {
				cb();
			}.bind(this));
		}
	}.bind(this));
}
Game.prototype.getLimit = function (seat) {
	//this.log('getLimit type %s %j',this.game_limit,this.bets);

	var canplay = 0;
	for (var x=0; x<this.members.length; x++) {
		if (!this.members[x]) continue;
		if (this.members[x].status == 'psInHand') {
			canplay++;
		}
	}

	if (canplay == 1) return this.minBet;

	if (typeof this.bets[seat] != 'number') this.bets[seat] = 0;
	var oldbet = this.bets[seat];
	if (this.game_limit == 'glNoLimit') {
		return oldbet + this.members[seat].chips;
	}

	var pot = 0;
	for (var x=0; x<this.pots.length; x++) {
		pot += this.pots[x].getPostRake(this.rake);
	}
	for (var x=0; x<this.bets.length; x++) {
		if (typeof this.bets[x] != 'number') this.bets[x] = 0;
		pot += this.bets[x];
	}
	var pottotal = pot + (this.minBet - oldbet);
	var maxbet = pottotal + this.minBet;
	this.log('pot:%d pottotal:%d maxbet:%d oldbet:%d',pot,pottotal,maxbet,oldbet);
	if (maxbet > this.members[seat].chips) return oldbet + this.members[seat].chips;
	return maxbet;
}
Game.prototype.log = function log(format) {
	var out = Array.prototype.slice.call(arguments);
	if (format.indexOf('%') != -1) {
		out = [ util.format.apply(util,out) ]
	}
	out.unshift(this.handid);
	process.send({type:'game',name:this.obj.gamename,ts:new Date().toString(),objects:out});
	var obj = {type:'game',gameid:this.obj._id,name:this.obj.gamename,objects:out}
	if (this.club) obj.clubid = this.club.clubid;
	debugLogs.insert(obj,function (){});
}
Game.prototype.AddOn = function AddOn(conn,chips) {
	var seat = this.findSeat(conn);
	allUsers.findOne({_id:conn.userid},function (err,self) {
		assert.equal(conn.state,2);
		if ((conn.boughtin + chips) > self.chips) {
			conn.send(codes.srTableSitNoChips,this.getTableStatus(conn,false,[]),'Poker.TableStatus');
			return;
		}
		conn.boughtin += chips;
		this.club.buyin(conn.userid,chips);
		this.logEvent('geCashin',conn.userid,chips);
		this.members[seat].chips += chips;
		this.updateBuyin(seat,chips,function () {
			var status = this.getTableStatus(conn,false,[]);
			conn.send(codes.srTableAddonOk,status,'Poker.TableStatus');
			this.broadcastStatus(conn,null,[]);
		}.bind(this));
	}.bind(this));
}
Game.prototype.edited = function edited(params) {
	// FIXME, more fields, also now acts as a cache for seGameChange/seGameDelete
	this.obj.seats = params.seats;
	this.obj.small_blind = params.small_blind
	this.obj.big_blind = params.big_blind; // FIXME
	this.obj.buyin_min = params.buyin_min;
	this.obj.buyin_max = params.buyin_max;
	this.obj.game_limit = params.game_limit;
	this.obj.game_type = params.game_type;
	this.omaha = this.obj.game_type == 'gtOmaha';
}
Game.prototype.join = function join(conn,cb) {
	assert.equal(this.Lock.readers,-1);
	this.users[conn.userid] = conn;
	this.updateMongoState({},{users:true},cb);
}
Game.prototype.sitDown = function (conn,params,cb) {
	function finish() {
		this.club.seGameChanged(JSON.parse(JSON.stringify(this.obj)),function () {
			this.club.buyin(conn.userid,params.chips);
			this.updateMongoState({},{members:true},function () {
				cb(true,events);
			});
		}.bind(this),conn);
	}
	function doSit() {
		this.members[params.seat_index] = { hand: new Hand(), status:'psOutOfPlay', chips:params.chips, seat:params.seat_index, sitOutNextRound:false, SittingOutRoundsCount:0, handsPlayed:0 };
		this.logEvent('geCashin',conn.userid,params.chips);
		if (!this.timebanks[conn.userid]) this.timebanks[conn.userid] = sharedconfig.max_timebank * 1000;
		this.seats[params.seat_index] = { conn:conn, userid:conn.userid };
		conn.boughtin += params.chips;
		if (this.bets[params.seat_index] == undefined) this.bets[params.seat_index] = 0;
		events.push(this.makeEvent('teSit',params.seat_index));
		this.updateBuyin(params.seat_index,params.chips,function () {
			finish.call(this);
		}.bind(this));
	}
	assert.equal(this.Lock.readers,-1);
	assert(conn.userid);
	var events = [];
	conn.log('sitting down',params);
	if ((params.seat_index < 0) || (params.seat_index >= this.obj.seats)) {
		conn.reply(0,'invalid seat index');
		cb(false,events);
		return;
	}
	if (this.seats[params.seat_index]) {
		conn.log('seat taken by',util.inspect(this.members[params.seat_index]),util.inspect(this.seats[params.seat_index]));
		conn.send(codes.srTableSitSeatTaken,this.getTableStatus(conn,null,[]),'Poker.TableStatus');
		cb(false,events);
	} else {
		allUsers.findOne({_id:conn.userid},function (err,userinfo) {
			conn.log('state:%d %s',conn.state,conn.userid);
			conn.log('self:%j boughtin:%d chips:%d',userinfo,conn.boughtin,userinfo.chips);
			if ((userinfo.chips === undefined) || (params.chips > (userinfo.chips - conn.boughtin))) {
				conn.send(codes.srTableSitNoChips,this.getTableStatus(conn,null,[]),'Poker.TableStatus');
				cb(false,events);
				return;
			}
			this.club.getPotentialLosses(conn.userid,function (maxLosses,unlimited,limit) {
				if (unlimited) this.log('unlimited user');
				else {
					this.log('max potential losses for this user:%d/%d while buying in at %d',(-1*maxLosses)/100,limit/100,params.chips/100);
					if (((maxLosses*-1)+params.chips) > limit) {
						conn.send(codes.srClubBalanceReached,this.getTableStatus(conn,null,[]),'Poker.TableStatus');
						cb(false,events);
						return;
					}
				}
				var obeymax = true;
				var min = this.obj.buyin_min * this.obj.big_blind;
				var max = this.obj.buyin_max * this.obj.big_blind;
				var lastcashout = 0;
				if (this.lastCashout[conn.userid]) {
					var last = this.lastCashout[conn.userid];
					var timediff = Date.now() - last.when;
					conn.log('last cashout %d vs %d age:%d',last.chips,params.chips,timediff/1000);
					if (timediff < (30 * 60 * 1000)) {
						if (params.chips < last.chips && false) {
							conn.send(codes.srTableBuyinLessThanCashout,{game_id:fromMongoId(this.id),last_cashout:last.chips},'Poker.BuyinError');
							cb(false,events);
							return;
						}
						if (last.chips == params.chips) obeymax = false;
						lastcashout = last.chips;
					}
				}
				if (obeymax) {
					conn.log('checking that %d is between %d and %d',params.chips,min,max);
					if ((params.chips > max) || (params.chips < min)) {
						conn.send(codes.srInvalidTableBuyin,{game_id:fromMongoId(this.id),last_cashout:lastcashout},'Poker.BuyinError');
						conn.log('buyin:%d min:%d max:%d',params.chips,min,max);
						cb(false,events);
						return;
					}
				}
				doSit.call(this);
			}.bind(this));
		}.bind(this));
	}
}
Game.prototype.updateBuyin = function (seatIdx,buyin,cb) {
	var doc = { gameid:this.obj._id,userid:this.seats[seatIdx].userid, buyins:[buyin], hands:0 };
	var mods = { $push:{buyins:{
		$each:[buyin],
		$slice:-50
	}}};
	var key = {gameid:this.obj._id,userid:this.seats[seatIdx].userid};
	allStats.findOne(key,function (err,row) {
		assert.ifError(err);
		if (!row) {
			log('inserting %j',doc);
			allStats.insert(doc,finish.bind(this));
		} else {
			allStats.update({_id:row._id},mods,finish.bind(this));
		}
		function finish(err) {
			assert.ifError(err);
			this.club.handOver(this,function () {
				cb();
			});
		}
	}.bind(this));
}
Game.prototype.updateLeaveStats = function (seatIdx,force,cb) {
	if (!this.members[seatIdx].sitTime) {
		if (cb) cb();
		return;
	}
	var time = (Date.now() - this.members[seatIdx].sitTime) / 1000;
	assert(time > 0.001);
	var doc = { gameid:this.obj._id,userid:this.seats[seatIdx].userid, secondsplayed:time };
	var mods = { $inc:{secondsplayed:time}};
	var key = {gameid:this.obj._id,userid:this.seats[seatIdx].userid};
	allStats.findOne(key,function (err,row) {
		assert.ifError(err);
		if (!row) {
			log('inserting %j',doc);
			allStats.insert(doc,finish);
		} else {
			allStats.update({_id:row._id},mods,finish);
		}
		function finish(err) {
			assert.ifError(err);
			if (cb) cb();
		}
	});
}
Game.prototype.deal = function deal(cb,config,emptyseat) {
	var players = 0;
	//this.log(' pre rotation:%d omaha:%s limit:%s',this.rotation,this.omaha,this.game_limit);
	if (this.obj.game_type == 'gtRotationNLHPLO') {
		if (this.rotation == this.obj.seats) {
			this.omaha = true;
		} else if (this.rotation == (this.obj.seats*2)) {
			this.omaha = false;
			this.rotation = 0;
		}
		if (this.omaha) {
			this.game_limit = 'glPotLimit';
		} else {
			this.game_limit = 'glNoLimit';
		}
	}
	this.rotation++;
	//this.log('post rotation:%d omaha:%s limit:%s',this.rotation,this.omaha,this.game_limit);
	getNextSequence('handHistory',function (seq) {
		this.handid = seq;
		allGames.update({_id:this.id},{$set:{lasthandid:seq, rotation:this.rotation}},function (err,res){});
		this.history = {moves:[],players:[],cards:[]};
		hands = seq;
		var oldDealer = this.dealer;
		this.nextDealer();
		this.bets = [];
		this.balance_changes = [];
		this.addHistory({code:['teDealing']});

		var canplay = 0;
		for (var x=0; x<this.members.length; x++) {
			if (!this.members[x]) continue;
			if (['psInHand','psOutOfHand'].indexOf(this.members[x].status) != -1) canplay++;
		}

		var sb = this.getNextSeat(oldDealer);
		var bb = this.getNextSeat(sb);
		if (bb < oldDealer) bb += this.obj.seats;
		for (var x=0; x<this.members.length; x++) {
			if (!this.members[x]) continue;
			if (this.members[x].status == 'psOutOfPlay') {
				if (!emptyseat) this.members[x].SittingOutRoundsCount++;
				else this.members[x].SittingOutRoundsCount = 0;
				this.log('seat %d has sat out %d rounds',x,this.members[x].SittingOutRoundsCount);
				continue;
			}
			if (this.members[x].disconnected) continue;
			if (this.members[x].chips == 0) {
				this.members[x].status = 'psOutOfPlay';
				this.updateLeaveStats(x);
				this.lastplayer[x] = this.seats[x].userid;
				continue;
			}
			if (canplay < 3) { // for 2 player games, just allow all
			} else if (bb == -1) { // initial round
			} else if (sb == -1) {
			} else if (this.members[x].status == 'psInHand') {
			} else if ((oldDealer < bb) && (bb < x)) { // you are after BB
				this.log('XXX %d is after bb:%d',x,bb);
/*			} else if (x == oldDealer) {
				this.log('XXX %d is dealer %d %d',x,sb,bb);
				this.nextDealer();
				sb = this.getNextSeat(this.dealer);
				bb = this.getNextSeat(sb);
				if (bb < this.dealer) bb += this.obj.seats;
				continue;*/
			} else if ((oldDealer < x) && (x < bb)) {
				this.log('XXX %d is between %d-%d',x,oldDealer,bb);
				if (x == this.dealer) {
					this.nextDealer();
				}
				continue;
			} else {
				this.log('XXX dealer:%d x:%d(%s) sb:%d bb:%d',oldDealer,x,this.members[x].status,sb,bb);
			}
			this.members[x].SittingOutRoundsCount = 0;
			if (this.omaha) {
				players++;
				this.deck.draw(4,this.members[x].hand);
			} else this.deck.draw(2,this.members[x].hand);
			players++;
			this.bets[x] = 0;
			this.members[x].handsPlayed++;
			this.history.players[x] = { _id:this.seats[x].userid, seat:x, cards:this.members[x].hand.cards, chips:this.members[x].chips, muck:true };
			if (this.members[x].status == 'psOutOfHand') {
				this.seats[x].conn.log('moving into hand %s %s %j',this.seats[x].userid,this.lastplayer[x],config);
				if (!compareObjectID(this.seats[x].userid,this.lastplayer[x])) {
					if (!this.headsup) {
						if (this.members[x].chips <= this.obj.big_blind) {
							this.addHistory({seat:x,bet:this.members[x].chips,code:['teForced','teBB','teAllIn']});
							this.setBet(x,this.members[x].chips);
							this.members[x].status = 'psAllIn';
						} else {
							this.setBet(x,this.obj.big_blind);
							this.addHistory({seat:x,bet:this.obj.big_blind,code:['teForced','teBB']});
						}
					}
				}
			}
			this.members[x].status = 'psInHand';
			this.members[x].can_show = true;
			this.members[x].muck = true;
			this.balance_changes[x] = 0;
		}

		this.pots = [ new Pot(this) ];
		this.log('pots reset to zero');
		this.current_seat = this.dealer;

		this.small_blind = this.current_seat = this.getNextSeat(this.current_seat);
		if (this.headsup) this.small_blind = this.current_seat = this.getNextSeat(this.current_seat);
		if (this.bets[this.current_seat] == 0) {
			if (this.members[this.current_seat].chips <= this.obj.small_blind) {
				this.addHistory({seat:this.current_seat,bet:this.members[this.current_seat].chips,code:['teSB','teAllIn']});
				this.setBet(this.current_seat,this.members[this.current_seat].chips);
				this.members[this.current_seat].status = 'psAllIn';
			} else {
				this.setBet(this.current_seat,this.obj.small_blind);
				this.addHistory({seat:this.current_seat,bet:this.obj.small_blind,code:['teSB']});
			}
		}
		
		this.big_blind = this.current_seat = this.getNextSeat(this.current_seat,null,true);
		if (this.bets[this.current_seat] == 0) {
			if (this.members[this.current_seat].chips <= this.obj.big_blind) {
				this.addHistory({seat:this.current_seat,bet:this.members[this.current_seat].chips,code:['teBB','teAllIn']});
				this.setBet(this.current_seat,this.members[this.current_seat].chips);
				this.members[this.current_seat].status = 'psAllIn';
			} else {
				this.setBet(this.current_seat,this.obj.big_blind);
				this.addHistory({seat:this.current_seat,bet:this.obj.big_blind,code:['teBB']});
			}
		}
		this.current_seat = this.getNextSeat(this.current_seat);
		
		this.state = 'tsPreFlop';
		this.rake = 0;
		this.minimum_raise = this.obj.big_blind * 2;
		this.roundEnd();
		this.ranOut = false;
		this.flop = new Hand();
		this.turn = new Hand();
		this.river = new Hand();
		this.deck.draw(3,this.flop);
		this.deck.draw(1,this.turn);
		this.deck.draw(1,this.river);
		this.history.cards = this.flop.cards;
		this.history.cards = this.history.cards.concat(this.turn.cards);
		this.history.cards = this.history.cards.concat(this.river.cards);
		this.log('bcast 2');
		
		handHistory.insert({seq:seq,gameid:this.obj._id,moves:this.history.moves,players:this.history.players,cards:this.history.cards,rake:this.rake,dealer:this.dealer,current_game:this.omaha ? 'gtOmaha' : 'gtHoldem'},function (err,row) {
			this.log('hand made:%j',row);
			//this.broadcastStatus(null,null,[this.makeEvent('teDealing')]);
			//setTimeout(function () {
			var cards;
			if (this.omaha) cards = 4;
			else cards = 2;
			this.startTimer(this.current_seat,1500 + (players*50*cards)); // FIXME, run this later
			//this.stateMachine(function () {
			this.updateMongoState({},{members:true},function () {
				cb([this.makeEvent('teDealing')]);
			}.bind(this));
			//}.bind(this));
			//}.bind(this),
			//players * 100);
		}.bind(this));
	}.bind(this));
}
Game.prototype.clearCanShow = function () {
	for (var x=0; x<this.members.length; x++) {
		if (!this.members[x]) continue;
		if (this.members[x].status == 'psFolded') this.members[x].can_show = false;
	}
}
Game.prototype.addHistory = function (obj,winnercount) {
	if (obj.code[0] == 'teWinning') {
		this.history.potdata = obj.potdata;
		this.history.winnercount = winnercount;
	}
	this.history.moves.push(obj);
}
Game.prototype.setBet = function (seat,bet) {
	var oldbet = this.bets[seat];
	this.bets[seat] = bet;
	this.members[seat].chips -= (bet - oldbet);
	if (bet > this.minBet) {
		this.minimum_raise = bet - this.minBet;
		this.log('min raise %d',this.minimum_raise);
		this.minBet = bet;
	}
}
Game.prototype.eatChips = function (seat,chips,cb) {
	this.pots[0].value += chips;
	allUsers.update({_id:this.members[seat].conn.userid},
		{ $inc:{chips:-chips}},function (err,res) {
			this.members[seat].conn.log('lost chips',err,res,chips);
			allGames.update({_id:this.obj._id},
				{$inc:{pot:chips}},function (err,res) {
					assert(res == 1);
					this.members[seat].conn.log('pot for game went up to ',this.pots);
					cb();
				}.bind(this));
		}.bind(this));
}
Game.prototype.getNextSeat = function (current,validstates) {
	if (!validstates) validstates = ['psInHand','psAllIn'];
	var limit = 100;
	function getNextSatIn(x) {
		x++;
		while (!this.members[x]) {
			if (limit-- < 0) {
				this.log('giving up');
				return -1;
			}
			x++;
			if (x >= this.obj.seats) x = 0;
			this.lastplayer[x] = null;
		}
		return x;
	}
	current = getNextSatIn.call(this,current);
	if (current < 0) return -1;
	while (validstates.indexOf(this.members[current].status) == -1) {
		current = getNextSatIn.call(this,current);
		if (current < 0) return -1;
		if (limit-- < 0) return -1;
	}
	return current;
}
Game.prototype.getPrevSeat = function (current) {
	var limit = 100;
	function getPrevSatIn(x) {
		x--;
		if (x < 0) x = this.obj.seats;
		while (!this.members[x]) {
			if (limit-- < 0) {
				this.log('giving up');
				return -1;
			}
			x--;
			if (x < 0) x = this.obj.seats;
		}
		return x;
	}
	current = getPrevSatIn.call(this,current);
	if (current < 0) return -1;
	while (['psInHand','psAllIn'].indexOf(this.members[current].status) == -1) {
		current = getPrevSatIn.call(this,current);
		if (current < 0) return -1;
		if (limit-- < 0) return -1;
	}
	return current;
}
Game.prototype.fold = function fold(seat,cb1) {
	var token = profiler.start('fold-inner1.1');
	assert.equal(this.Lock.readers,-1);
	this.stopTimer(seat);
	var seatObj = this.members[seat];
	var priv = this.seats[seat];
	this.log('fold',seat,this.state);
	this.clearCanShow();
	function finish(events,offset) {
		assert(events);
		assert.equal(typeof offset,'number');
		finish2.call(this,events,offset);
	}
	function finish2(events,offset) {
		assert.equal(typeof offset,'number');
		var token2 = profiler.start('fold-inner1.2');
		this.saveHistory(function () {
			token2.stop();
			// FIXME, update members like sitDown
			this.updateMongoState({},{},function () {
				cb1.call(this,events,offset);
			}.bind(this));
		}.bind(this));
	}
	switch (this.state) {
	default:
	case 'tsIdle':
		priv.conn.log('fallback');
		cb1();
		break;
	case 'tsPreFlop': // most states go here
	case 'tsFlop':
	case 'tsTurn':
	case 'tsRiver':
		priv.conn.log('normal fold state');
		for (var x=0; x<this.pots.length; x++) {
			//priv.conn.log('folding seat %d, pots:%j',seat,this.pots[x].members);
			var idx = this.pots[x].members.indexOf(seat);
			if (idx != -1) {
				priv.conn.log('pots:%j idx:%d seat:%d',this.pots,idx,seat);
				this.pots[x].members.splice(idx,1);
			}
		}
		if (seatObj) seatObj.status = 'psFolded';
		this.addHistory({seat:seat,code:['teFold']});
		var inhandcount = this.inHandCount();
		if (inhandcount == 0) {
			priv.conn.log('wut now??');
			finish2.call(this);
		} else if (inhandcount == 1) {
			priv.conn.log('d');
			var lastseat;
			for (var x=0; x<this.members.length; x++) {
				if (!this.members[x]) continue;
				if (['psInHand','psAllIn'].indexOf(this.members[x].status) == -1) continue;
				lastseat = x;
			}
			priv.conn.log('remaining guy wins everything',lastseat);
			this.moveToPot('fold1',function () {
				token.tag += 'a';
				token.stop();
				priv.conn.log('done moving to pot 2');
				this.calcWinners(finish2.bind(this),[this.makeEvent('teFold',seat)],0);
			}.bind(this));
		} else {
			priv.conn.log('fold with more then 1 person remaining',this.inHandCount());
			this.keycount--;
			if (seat == this.current_seat) {
				priv.conn.log('and i was active');
				token.tag += 'b';
				token.stop();
				this.stateMachine(finish.bind(this),null,null,[this.makeEvent('teFold',seat)],0);
			} else {
				token.tag += 'c';
				token.stop();
				finish.call(this,[this.makeEvent('teFold',seat)],0);
			}
		}
		break;
	}
}
Game.prototype.doWin = function (cb,extradelay) {
	var totalrake = 0;
	var rakestats = [];

	assert.equal(this.Lock.readers,-1);
	assert.equal(typeof extradelay,'number');
	this.state = 'tsWinning';
	var delay = 1500 + (this.pots.length * 500) + extradelay;
	this.log('delay is %d',delay);
	function finish() {
		this.log('cleared seat');
		this.current_seat = -1;
		this.log('main cb');
		cb(rakestats);

		setTimeout(function () {
			this.Lock.writeLock(function (release) {
				this.saveHistory(function () {
					this.deck = new Deck();
					this.deck.shuffle(function () {
						// SPLIT this.deck.cards = [1,40,17,41,29,51,48,20,9,25,13,19,46,42,10,8,16,47,0,11,18,14,31,4,2,24,32,33,6,15,12,39,21,37,30,26,34,7,22,3,35,27,44,5,36,50,49,28,23,43,38,45];
						// failed 3 way omaha split this.deck.cards = [44,8,10,11, 40,12,14,15, 36,20,22,23, 48,0,4,17,30, 47,42,41,18,46,31,29,2,24,32,33,6,25,51,39,21,37,16,26,34,7,13,3,35,27,1,5,9,50,49,28,19,43,38,45];
						this.log('doWin reset, shuffled deck is',JSON.stringify(this.deck.cards));
						//if (this.inHandCount() > 1) var nextstate = 'psInHand';
						for (var x=0; x<this.members.length; x++) {
							if (!this.members[x]) continue;
							if (this.members[x].status == 'psOutOfPlay') continue;
							this.members[x].hand = new Hand();
							if (this.members[x].disconnected) continue;
							if (this.members[x].sitOutNextRound) {
								this.members[x].sitOutNextRound = false;
								this.members[x].sitOutBB = false;
								this.members[x].status = 'psOutOfPlay';
								this.updateLeaveStats(x);
								this.lastplayer[x] = this.seats[x].userid;
							} else {
								if (this.members[x].status != 'psOutOfHand') {
									this.members[x].status = 'psInHand';
									this.seats[x].conn.log('moving into psInHand');
								}
							}
						}
						this.state = 'tsWinning2';
						//this.broadcastStatus(null);
						this.stateMachine(function (events) {
							this.updateMongoState({},{members:true},function () {
								this.broadcastStatus(null,true,events); // teDeal
								release();
							}.bind(this));
						}.bind(this),null,{cont:true},[],0);
					}.bind(this));
				}.bind(this));
			}.bind(this))
		}.bind(this),delay);
	}
	var winnerObjects = [];
	var winnerids = [];
	var wins = []; // array of how much each seat wins
	function addWin(seat,chips) {
		if (wins[seat]) wins[seat] += chips;
		else wins[seat] = chips;
	}
	for (var y=0; y<this.pots.length; y++) {
		var pot = this.pots[y];
		if (pot.value == 0) continue;

		// redo
		var rake = Math.round(pot.value * (this.rake / 100));
		assert(pot.trueMembers.length > 0);
		var rakesplit = rake / pot.trueMembers.length;
		rake = rakesplit * pot.trueMembers.length;
		pot.rake = rake;
		this.history.potdata[y].rake = rake;
		var split = ((pot.value-rake)/pot.winners.length);
		// </redo>
		//var rake = pot.value * (this.rake / 100);
		this.log('splitting pot#%d',y)
		//var split = Math.round((pot.value-rake) / pot.winners.length);
		//rake = pot.value - (split * pot.winners.length);
		totalrake += rake;
		//var rakesplit = rake/pot.trueMembers.length;
		assert(!isNaN(rake));
		assert(!isNaN(rakesplit));
		assert(!isNaN(split));
		this.log('rake:%d/%d pot:%j split:%d',rake,rakesplit,pot,split);
		for (var x=0; x<pot.trueMembers.length; x++) {
			if (rakestats[pot.trueMembers[x]]) rakestats[pot.trueMembers[x]].rake += rakesplit;
			else rakestats[pot.trueMembers[x]] = { rake:rakesplit, userid: pot.trueUsers[x] };
		}
		for (var x=0; x<pot.winners.length; x++) {
			var priv = this.seats[pot.winners[x]];
			if (winnerObjects.indexOf(this.members[pot.winners[x]]) == -1) {
				winnerObjects.push(this.members[pot.winners[x]]);
				winnerids.push(priv.userid);
			}
			//console.log('winner debug',winnerObjects[x],pot.winners[x]);
			assert(priv,'winner must be seated');
			addWin(pot.winners[x],split);
		}
		this.log('pot#%d initialrake:%d totalrake:%d',y,rake,totalrake);
	}
	this.log('initialrake:%d totalrake:%d pots:%j',rake,totalrake,this.pots);
	assert.equal(typeof totalrake,'number');
	this.history.totalrake = totalrake;
	this.log('wins',wins,winnerids);
	var stack = new Error().stack;

	//assert.equal(wins[0],15);
	console.log('doWin',this.pots,this.members);
	this.pots = [ new Pot(this) ];
	async.eachSeries(winnerObjects,function (winnerObj,cb2) {
		var seat = winnerObj.seat;
		var userid = this.seats[seat].userid;
		var gain = wins[seat];
		this.balance_changes[seat] += gain;
		allUsers.update({_id:userid},{$inc:{chips:gain}},function (err,res) {
				assert(!err,err);
				assert.equal(res,1);
				this.log('seat #'+seat+' gained '+gain);
				if (this.seats[seat].conn) {
					this.seats[seat].conn.boughtin += gain;
					this.seats[seat].conn.chips += gain;
				}
				if (winnerObj) winnerObj.chips += gain;
				cb2();
			}.bind(this));
		}.bind(this),function done() {
			allGames.update({_id:this.obj._id},{$unset:{gameState:0},$inc:{rake:totalrake}},function (err,res) {
				assert(!err,err);
				this.obj.rake += totalrake;
				assert.equal(res,1);
				finish.call(this);
			}.bind(this));
		}.bind(this));
}
Game.prototype.checkRoundPass = function (cb,events,extradelay) {
	var token = profiler.start('checkRoundPass');
	assert.equal(this.Lock.readers,-1);
	assert(events);
	assert.equal(typeof extradelay,'number');
	this.log('key seat count is:'+this.keycount+' current:'+this.current_seat);
	if (this.keycount <= 0) {
		var min = -1;
		var max = 0;
		for (var x=0; x<this.members.length; x++) {
			if (!this.members[x]) continue;
			if (['psInHand','psAllIn'].indexOf(this.members[x].status) == -1) continue;
			if (this.bets[x] > max) max = this.bets[x];
			if (['psAllIn'].indexOf(this.members[x].status) != -1) continue;
			if (min == -1) min = this.bets[x];
			if (this.bets[x] < min) min = this.bets[x];
		}
		this.log('bet ranges min:'+min+' max:'+max+' all bets:'+JSON.stringify(this.bets));
		if (min == -1) min = max;
		if (min == max) {
			if (this.state == 'tsPreFlop') {
				this.rake = this.real_rake;
				this.log('flopping');
				this.addHistory({code:['teFlop']});
				events.push(this.makeEvent('teFlop',{bets:this.bets.slice(),oldpots:this.pots,cards:new Buffer(this.flop.cards)}));
				this.current_seat = this.dealer;
				this.moveToPot('preflop',function () {
					this.state = 'tsFlop';
					this.log('flop adding to %d',extradelay);
					token.tag += 'c';
					token.stop();
					cb.call(this,events,1500+extradelay);
				}.bind(this));
				this.roundEnd();
			} else if (this.state == 'tsFlop') {
				this.log('turning');
				this.addHistory({code:['teTurn']});
				events.push(this.makeEvent('teTurn',{bets:this.bets.slice(),oldpots:this.pots,cards:new Buffer(this.turn.cards)}));
				this.current_seat = this.dealer;
				this.moveToPot('turn',function () {
					this.state = 'tsTurn';
					this.log('turn adding to %d',extradelay);
					token.tag += 'd';
					token.stop();
					cb.call(this,events,1500+extradelay);
				}.bind(this));
				this.roundEnd();
			} else if (this.state == 'tsTurn') {
				this.log('river time');
				this.addHistory({code:['teRiver']});
				events.push(this.makeEvent('teRiver',{bets:this.bets.slice(),oldpots:this.pots,cards:new Buffer(this.river.cards)}));
				this.current_seat = this.dealer;
				this.moveToPot('river',function () {
					this.state = 'tsRiver';
					this.log('river adding to %d',extradelay);
					token.tag += 'e';
					token.stop();
					cb.call(this,events,1500+extradelay);
				}.bind(this));
				this.roundEnd();
			} else {
				//this.broadcastStatus(null);
				events.push(this.makeEvent('tePostRiver',{bets:this.bets.slice()}));
				this.moveToPot('post-river',function () {
					//events.push(this.makeEvent('tePreWin',{pots:this.pots}));
					this.log('events callback FIXME %s',new Error().stack);
					token.tag += 'f';
					token.stop();
					this.calcWinners(cb,events,extradelay);
				}.bind(this));
			}
		} else {
			// cpu cost: ~0.8ms
			cb(events,0);
		}
	} else {
		cb(events,0);
	}
}
Game.prototype.postWinSaveStats = function (rakestats,cb) {
	var jobs = [];
	this.log('rake info: %j, balances:%j',rakestats,this.balance_changes);
	for (var x=0; x<this.balance_changes.length; x++) {
		if (!this.balance_changes[x]) continue;
		if (this.balance_changes[x] != 0) {
			if (!rakestats[x]) rakestats[x] = {rake:0};
			var mods = { $inc:{balance:this.balance_changes[x], rakecontrib:rakestats[x].rake, hands:1 }};
			var key = {gameid:this.obj._id,userid:rakestats[x].userid};
			var job = {mods:mods, key:key, change:this.balance_changes[x], userid:rakestats[x].userid};
			jobs.push(job);
		}
	}
	async.parallel([function a(cbA) {
		async.each(jobs,function hack(job,cb2) {
			log('updating stats %j',job);
			allStats.update(job.key,job.mods,function () {
				this.club.updateLimitPostWin(job.change,job.userid,cb2);
			}.bind(this));
		}.bind(this),cbA);
	}.bind(this),function b(cbB) {
		allGames.update({_id:this.obj._id},{$inc:{hands:1}},function done(err,rows) {
			assert.equal(rows,1);
			cbB();
		});
	}.bind(this)],function done() {
		cb();
	});
}
Game.prototype.calcWinners = function (cb,events,extradelay) {
	assert(events);
	assert.equal(typeof extradelay,'number');
	var potdata = [];
	var logmsg = [];
	var winnercount = 0;
	var potid = 0;
	var hands = [];
	var canplay = 0;
	var allinfound = false;
	for (var x=0; x<this.members.length; x++) {
		if (!this.members[x]) continue;
		if (['psInHand','psAllIn'].indexOf(this.members[x].status) == -1) continue;
		if (this.members[x].status == 'psInHand') {
			canplay++;
		}
		if (this.members[x].status == 'psAllIn') allinfound = true;
		hands.push({seat:x,hand:this.members[x].hand.cards});
	}
	if ((canplay == 1) && (allinfound)) {
		for (var x=0; x<this.members.length; x++) {
			if (!this.members[x]) continue;
			if (['psInHand','psAllIn'].indexOf(this.members[x].status) == -1) continue;
			this.members[x].muck = false;
			this.history.players[x].muck = false;
		}
	}
	this.log('hands: %j',hands[0]);
	var forcewin = -1;
	if (hands.length > 1) {
		if (this.omaha) {
			var result = omaha2.doEval(this.flop,this.turn,this.river,hands);
		} else {
			var result = dag.rankHands(this,hands);
		}
		this.lastResult = result;
		this.log('dag results:',result);
	} else {
		forcewin = hands[0].seat;
		this.lastResult = null;
	}
	// FIXME< just use a for loop?
	async.eachSeries(this.pots,function (pot,cb1) {
		var lowestid = -1;
		var winningindex = -1;
		var winner;
		var winners = [];
		var data = [];
		if (pot.value == 0) return cb1();
		potdata[potid] = { sum:pot.value, seats:pot.members };
		this.log('this pot',potid,pot);

		if (forcewin >= 0) {
			winners = [ forcewin ];
			if (winners.length > winnercount) winnercount = winners.length;
			if (this.seats[forcewin].conn) {
				logmsg.push(this.seats[forcewin].conn.nick+' '+this.seats[forcewin].userid);
			} else {
				logmsg.push("DC'd "+this.seats[forcewin].userid);
			}
			data.push({seat:forcewin,msg:'default'});
		} else {
			for (var x=0; x<result.outputs.length; x++) {
				if (pot.members.indexOf(result.outputs[x].seat) == -1) continue;
				if (lowestid == -1) {
					lowestid = result.outputs[x].id;
					winningindex = x;
					winner =  result.outputs[x];
				}
				if (result.outputs[x].id < lowestid) {
					lowestid = result.outputs[x].id;
					winningindex = x;
					winner =  result.outputs[x];
				}
			}
			// split pot has the same .id on multiple people
			for (var x=0; x<result.outputs.length; x++) {
				if (pot.members.indexOf(result.outputs[x].seat) == -1) continue;
				if (result.outputs[x].id == lowestid) {
					winners.push(result.outputs[x].seat);
					this.members[result.outputs[x].seat].muck = false;
					this.history.players[result.outputs[x].seat].muck = false;
					this.log('output: %j',result.outputs[x]);
					logmsg.push(this.seats[result.outputs[x].seat].conn.nick+' '+this.seats[result.outputs[x].seat].userid);
					data.push({seat:result.outputs[x].seat,msg:result.outputs[x].desc});
				}
			}
		}
		potdata[potid].WinnerData = data;
		this.log('winners of pot #'+potid,winners);
		if (winners.length > winnercount) winnercount = winners.length;
		potid++;
		pot.winners = winners;
		cb1();
	}.bind(this));
		finish1.call(this);
	
	function finish1() {
		events.push(this.makeEvent('teWinning',null,potdata));
		this.addHistory({code:['teWinning'],potdata:potdata},winnercount);
		this.doWin(function (rakestats) {
			this.postWinSaveStats(rakestats,function () {
				cb(events,0);
			}.bind(this));
		}.bind(this),extradelay);
		this.log('MOVE WIN END '+logmsg.join(','));
	}
}
Game.prototype.moveToPot = function (reason,cb1) {
	var token = profiler.start('moveToPot');
	var token1 = profiler.start('moveToPot-inner1');
	this.log('state: %s bets: %j pots: %j reason:%s',this.state,this.bets,this.pots,reason);
	var increase;
	var min;
	var max;
	var betsToRemove = [];
	function removeBet(seat,bet) {
		if (betsToRemove[seat] === undefined) betsToRemove[seat] = bet;
		else betsToRemove[seat] += bet;
	}
	function calcRanges() {
		min = -1;
		max = 0;
		for (var x=0; x<this.bets.length; x++) {
			if (this.bets[x] === undefined) this.bets[x] = 0
			if (this.bets[x] == null) this.bets[x] = 0;
			if (this.bets[x] == 0) continue;
			if (this.bets[x] > max) max = this.bets[x];
			if (min == -1) min = this.bets[x];
			if (this.bets[x] < min) min = this.bets[x];
		}
		if (min == -1) min = 0;
		this.log('SIDE',min,max);
	}
	do {
		calcRanges.call(this);
		increase = 0;
		if (max == 0) break;
		for (var x=0; x<this.bets.length; x++) {
			if (this.bets[x] >= min) {
				increase += min;
				this.bets[x] -= min;
				removeBet(x,min);
				this.log('adding %d to pot from seat %d %s',min,x,this.members[x] ? this.members[x].status : 'member null');
				this.pots[this.pots.length-1].add(min,x,this);
			}
		}
		if (this.pots[this.pots.length-1].value) {
			var p = this.pots[this.pots.length-1];
			if ((p.members.length == 0) && (p.trueMembers.length == 1)) {
				p.members.push(p.trueMembers[0]);
			}
		}
		this.log('increase:'+increase+' '+min+'x'+(increase/min));
		this.log('SIDE1',this.pots,this.bets,betsToRemove);
		if (this.pots[this.pots.length-1].value) {
			assert(this.pots[this.pots.length-1].members.length)
		}
		this.pots.push(new Pot());
	} while (min != max);
	for (var x=0; x<(this.pots.length-1); x++) {
		// safety
		if (this.pots[x].value) assert(this.pots[x].members.length);

		var set1 = this.pots[x].members.join(',');
		var set2 = this.pots[x+1].members.join(',');
		this.log(set1,set2);
		if (set1 == set2) {
			this.pots[x].value += this.pots[x+1].value;
			this.pots.splice(x+1,1);
			this.log(this.pots);
			if (x >= 0) x--;
		}
	}
	this.log('post merge: %j',this.pots);
	//if (this.pots.length > 1 && this.pots[1].members.length > 1) assert(this.pots.length < 3);
	for (var potid=0; potid<this.pots.length; potid++) {
		if (this.pots[potid].trueMembers.length == 1) {
			var returnseat = this.pots[potid].members[0];
			removeBet(returnseat,-(this.pots[potid].value));
			if (this.members[returnseat]) {
				this.seats[returnseat].conn.log('CHECK returning',this.members[returnseat].chips);
				this.members[returnseat].chips += this.pots[potid].value;
				this.seats[returnseat].conn.log('CHECK returned',this.pots[potid].value,this.members[returnseat].chips);
			}
			this.pots.splice(potid,1);
		}
	}

	// FIXME, remove this check later?
	for (var x=0; x<this.seats.length; x++) if (this.seats[x]) assert(this.seats[x].userid);

	token1.stop(); // 9ms avg
	async.parallel([
		function (cb) {
			this.updateMongoState({},{},function () {
				//this.log('pot for game updated');
				cb();
			}.bind(this));
		}.bind(this),
		function (cb2) {
			var token2 = profiler.start('moveToPot-inner2');
			// FIXME< use async.each
			var jobs = [];
			for (var x=0; x<this.obj.seats; x++) {
				if (!this.seats[x]) continue;
				if (this.members[x]) {
					if (['psOutOfHand','psOutOfPlay'].indexOf(this.members[x].status) != -1) continue;
				}
				jobs.push({seat:x});
			}
			token2.tag += '.'+jobs.length;
			token1.tag += '.'+jobs.length;
			token.tag += '.'+jobs.length;
			async.each(jobs,function repeat(job,cb) {
				var priv = this.seats[job.seat];
				var item = this.members[job.seat];
				if (betsToRemove[job.seat] === undefined) betsToRemove[job.seat] = 0;
				this.log('removing chips userid:%s idx:%d bets:%j',priv.userid,job.seat,betsToRemove);
				assert(priv.userid);
				assert.equal(typeof betsToRemove[job.seat],'number');
				this.balance_changes[job.seat] -= betsToRemove[job.seat];
				allUsers.update({_id:priv.userid},
					{ $inc:{chips:-betsToRemove[job.seat]}},function (err,res) {
						assert(!err);
						assert(res == 1);
						this.log('lost chips',job.seat,betsToRemove[job.seat]);
						if (priv.conn) {
							priv.conn.boughtin -= betsToRemove[job.seat];
							priv.conn.chips -= betsToRemove[job.seat];
						}
						betsToRemove[job.seat] = 0;
						// debug to detect desync
						// usage: set buyin on a table with EVERYTHING on every user
						//allUsers.findOne({_id:priv.userid},function (err,check) {
							//priv.conn.log('CHECK global:',check.chips,'table:',item.chips,'boughtin:',priv.conn.boughtin);
							//assert.equal(check.chips,item.chips);
							//assert.equal(check.chips,priv.conn.boughtin);
						cb();
						//}.bind(this));
					}.bind(this));
			}.bind(this),function finish(err) {
				assert.ifError(err);
				//this.log('remove chips done',betsToRemove);
				token2.stop(); // 12ms avg
				cb2();
			});
		}.bind(this)],function () {
			this.log('done moving to pot 1');
			this.minBet = 0;
			token.stop(); // 26ms avg
			cb1();
		}.bind(this));
}
Game.prototype.updateMongoState = function (obj,options,cb) {
	if (!obj) obj = {};
	if (!obj.$set) obj.$set = {};
	obj.$set.pots = this.pots;
	obj.$set.current_seat = this.current_seat;
	obj.$set.dealer = this.dealer;
	obj.$set.bets = this.bets;
	obj.$set.state = this.state;
	obj.$set.flop = this.flop;
	obj.$set.turn = this.turn;
	obj.$set.river = this.river;
	obj.$set.handid = this.handid;
	obj.$set.history = this.history; // maybe only update it in some spots?
	obj.$set.keycount = this.keycount;
	obj.$set.balance_changes = this.balance_changes;
	obj.$set.rake = this.rake;
	obj.$set.minBet = this.minBet;
	obj.$set.minimum_raise = this.minimum_raise;
	if (options.members) {
		var memberList = [];
		var keys = ['hand','status','chips','seat','sitOutNextRound','SittingOutRoundsCount','handsPlayed','can_show'];
		for (var x=0; x<this.members.length; x++) {
			var input = this.members[x];
			if (!input) continue;
			var out = {userid:this.seats[x].userid};
			for (var y=0; y<keys.length; y++) {
				var key = keys[y];
				out[key] = input[key];
			}
			memberList.push(out);
		}
		obj.$set.members = memberList;
	}
	if (options.users) {
		var U = [];
		for (var key in this.users) U.push(this.users[key].userid);
		obj.$set.users = U;
	}
	conn.collection('gameState').update({_id:this.obj._id}, obj,function (err,res) {
		this.log('rows found:%d state:%s state2:%s',res,this.state,this.state2);
		assert(res == 1);
		cb();
	}.bind(this));
}
Game.prototype.putChips = function (conn,chips,cb) {
	assert.equal(this.Lock.readers,-1);
	var seat = this.findSeat(conn);
	this.stopTimer(seat);
	if (['tsPreFlop','tsFlop','tsTurn','tsRiver'].indexOf(this.state) == -1) {
		this.log('putChips fail 1');
		cb();
		return;
	}
	
	var increase = chips - this.bets[seat];
	var event;
	var oldbet = this.bets[seat];
	var maxbet = this.getLimit(seat);

	this.clearCanShow();

	if (chips > maxbet) { // cheater!
		conn.error('cheater, going over pot limit '+chips+' '+maxbet);
		conn.destroy();
		cb([],0);
		return;
	} else if (chips < oldbet) { // cheater!
		conn.error('cheater detected, lowering bet '+chips+','+oldbet);
		conn.destroy();
		cb([],0);
		return;
	} else if (this.members[seat].chips == increase) {
		this.members[seat].status = 'psAllIn';
		event = 'teAllIn';
	} else if (chips < this.minBet) { // cheater!
		conn.error('cheater detected, betting low '+chips+','+this.minBet);
		conn.destroy();
		cb([],0);
		return;
	} else if (chips > this.minBet) {
		if ((chips - this.minBet) < this.minimum_raise) {
			conn.error(util.format('cheater detected, not meeting min raise, chips:%d minBet:%d minRaise:%d inplay:%d increase:%d',chips,this.minBet,this.minimum_raise,this.members[seat].chips,increase));
			conn.destroy();
			cb([],0);
			return;
		}
		event = 'teRaise';
	} else if (this.bets[seat] == chips) { // check
		event = 'teCheck';
	} else if (chips == this.minBet) {
		event = 'teCall';
	}

	if (increase > this.members[seat].chips) {
		conn.error('cheater detected, overbetting '+chips+','+increase+','+this.members[seat].chips);
		conn.destroy();
		cb([],0);
		return;
	}
	this.log('MOVE '+event+' '+this.seats[seat].conn.nick+' '+this.seats[seat].userid);
	this.addHistory({seat:seat,bet:chips,code:[event]});
	this.keycount--;

	conn.log('eating bets:'+JSON.stringify(this.bets)+' increase:'+increase+' chips:'+chips+' seat:'+seat);
	this.setBet(seat,chips);
	
	//this.saveHistory(function () {
		this.stateMachine(function (events,offset) {
			assert.equal(typeof offset,'number');
			this.updateMongoState({},{members:true},function () {
				cb(events,offset);
			});
		}.bind(this),null,null,[this.makeEvent(event,seat)],0);
	//}.bind(this));
}
Game.prototype.saveHistory = function (cb) {
	var updates = {$set:{moves:this.history.moves,deck:this.deck.cards}};
	if (this.history.potdata) {
		updates['$set'].potdata = this.history.potdata;
		updates['$set'].winnercount = this.history.winnercount;
		updates['$set'].balance_changes = this.balance_changes;
		updates['$set'].totalrake = this.history.totalrake;
		updates['$set'].endtime = Math.floor(Date.now()/1000);
		updates['$set'].result = this.lastResult;
		updates['$set'].players = this.history.players;
	}
	// FIXME, re-save players obj at end of round
	handHistory.update({seq:this.handid},updates,function (err,res) {
		assert.equal(res,1);
		cb();
	});
}
Game.prototype.findSeat = function (conn) {
	for (var x=0; x<this.seats.length; x++) {
		if ((this.seats[x]) && (this.seats[x].conn == conn)) {
			return x;
		}
	}
	return -1;
}
Game.prototype.nextDealer = function () {
	var limit = 100;
	this.dealer++;
	while (limit-- > 0) { // FIXME
		//this.log('dealer loop',limit,this.dealer);
		if (limit-- < 0) break;
		if (this.dealer >= this.obj.seats) this.dealer = 0;
		if (!this.members[this.dealer]) { this.dealer++; continue; }
		if (this.members[this.dealer].disconnected) { this.dealer++; continue; }
		if (this.members[this.dealer].status == 'psOutOfPlay') { this.dealer++; continue; }
		if (this.members[this.dealer].chips > 0) break;
		this.dealer++;
	}
	if (limit < 10) { // FIXME
		this.dealer = -1;
	}
	this.log('DEALER set to seat %d',this.dealer);
}
Game.prototype.checkDelayedLeave = function () {
	// FIXME, delete
	if ((this.state == 'tsIdle') || (this.Lock.readers == 0)) {
		for (var x=0; x<this.seats.length; x++) {
			var priv = this.seats[x];
			if (!priv) continue;
			var pub = this.members[x];
			if (!pub) {
				if (priv.delayed) {
					this.log('finishing delayed leave');
					this.seats[x] = null;
				}
			}
		}
	}
}
Game.prototype.stateMachine = function stateMachine(cb,conn,config,events,extradelay) {
	function finish1() {
		if (config && config.silent) {
		} else this.broadcastStatus(conn,null,events);
		cb(events);
	}
	function finish(events,offset) {
		assert(events);
		assert.equal(typeof offset,'number');
		this.log('sm finish %j',events);
		if (this.state != 'tsWinning') {
			this.current_seat = this.getNextSeat(this.current_seat);
			if (this.members[this.current_seat].chips == 0) {
				this.ranOut = true;
				this.log('skipping');
				return this.stateMachine(cb,null,null,events,extradelay);
			}
			if (this.ranOut && (this.inHandCount() == 2)) {
				this.log('somebody ran out, auto finishing');
				return this.stateMachine(cb);
			}
		}
		//this.broadcastStatus(null);
		cb(events,offset);
	}
	function loop() {
		var x = to_kick.pop();
		this.standUp(this.seats[x].conn,function (folded,events2,offset) {
			if (to_kick.length > 0) return loop.call(this);
			else this.stateMachine(cb,conn,config,events,extradelay);
		}.bind(this));
	}
	clearTimeout(this.idleUnstickTimer);
	assert.equal(this.Lock.readers,-1);
	assert(events);
	assert.equal(typeof extradelay,'number');
	this.log('state machine: %s events:%j',this.state,events);
	this.checkDelayedLeave();
	switch (this.state) {
	case 'tsWinning':
		cb(events,0); // FIXME
		break;
	case 'tsWinning2':
		var havechips = 0;
		for (var x=0; x<this.members.length; x++) if (this.members[x] && (this.members[x].chips > 0)) havechips++;
		if (havechips == 0) {
			this.log('nobody has chips');
			this.dealer = -1;
			this.current_seat = -1;
		} else if (havechips < 2) {
			this.log('only one guy has chips');
			//this.nextDealer();
		}
		this.state = 'tsIdle';
		this.checkDelayedLeave();
		this.current_seat = -1;
		//this.nextDealer();
		var jobs = [];
		for (var x=0; x<this.members.length; x++) {
			if (!this.members[x]) continue;
			if (this.members[x].status == 'psOutOfPlay') continue;
			this.log('found %d %s %d',x,this.members[x].status,this.members[x].sitTime);
			jobs.push(x);
		}
		async.each(jobs,function (seatIdx,cb2) {
			this.updateLeaveStats(seatIdx,true,cb2);
		}.bind(this),function () {
			this.club.handOver(this,function () {
				this.stateMachine(cb,conn,config,events,extradelay);
			}.bind(this),this.handid);
		}.bind(this));
		break;
	case 'tsIdle':
		if (this.autoDelete) {
			this.close(conn,function () {
				cb(events);
			});
			return;
		}
		var havechips = 0;
		var emptyseat = false;
		for (var x=0; x<this.members.length; x++) {
			if (!this.members[x]) {
				emptyseat = true;
				continue;
			}
			if (this.members[x].status == 'psOutOfPlay') continue;
			if (this.members[x].disconnected) continue;
			if (this.members[x].chips > 0) {
				this.members[x].sitTime = Date.now();
				this.log('sm found one',x,this.members[x].status,this.members[x].chips);
				havechips++;
			} else if (this.members[x].chips == 0) {
				this.members[x].status = 'psOutOfPlay';
				this.updateLeaveStats(x);
				this.lastplayer[x] = this.seats[x].userid;
				continue;
			}
		}
		if (this.members.length != this.obj.seats) emptyseat = true;
		if (!emptyseat) {
			var to_kick = [];
			for (var x=0; x<this.members.length; x++) {
				if (!this.members[x]) continue;
				if (this.members[x].status == 'psOutOfPlay') {
					if (this.members[x].SittingOutRoundsCount >= (this.obj.seats * 2)) {
						to_kick.push(x);
					}
				}
			}
			if (to_kick.length > 0) {
				loop.call(this);
				return;
			}
		}
		//if (this.dealer == -1) this.nextDealer();
		if (havechips > 1) {
			this.log('enough are sitting, checking sitOutBB');
			var dealerbackup = this.dealer;
			//if (this.dealer == -1) this.nextDealer();
			var pos = this.dealer;
			if (havechips == 2) {
				this.headsup = true;
				pos = this.getNextSeat(pos,['psInHand','psAllIn','psOutOfHand']);
			} else this.headsup = false;
			var small_blind = this.getNextSeat(pos,['psInHand','psAllIn','psOutOfHand']);
			var big_blind = this.getNextSeat(small_blind,['psInHand','psAllIn','psOutOfHand']);
			this.log('future dealer:%d, sb:%d, bb:%d',this.dealer,small_blind,big_blind);
			this.dealer = dealerbackup;
			if (this.members[big_blind].sitOutBB) {
				this.members[big_blind].status = 'psOutOfPlay';
				this.updateLeaveStats(big_blind);
				this.members[big_blind].sitOutBB = false;
				this.stateMachine(cb,null,config,events,extradelay);
				return;
			}
			this.deal(cb,config,emptyseat);
		} else {
			if (!emptyseat) {
				this.log('table hung until somebody leaves');
				this.idleUnstickTimer = setTimeout(this.idleUnstick.bind(this),20000);
			}
			finish1.call(this);
		}
		break;
	case 'tsPreFlop':
	case 'tsFlop':
	case 'tsTurn':
	case 'tsRiver':
		//this.log('normal state',this.state,this.current_seat);
		//if (this.members[this.current_seat]) this.log('chips:',this.members[this.current_seat].chips);
		var cantplay = 0;
		var canplay = 0;
		var cancheck = 0;
		for (var x=0; x<this.members.length; x++) {
			if (!this.members[x]) continue;
			if (this.members[x].status == 'psInHand') {
				canplay++;
				if (this.canCheck(x)) cancheck++;
			} else if (this.members[x].status == 'psAllIn') cantplay++;
		}
		this.log('cantplay:'+cantplay+' canplay:'+canplay+' cancheck:'+cancheck);
		var skip = false;
		// FIXME, improve logic for more players
		if ((cantplay == 1) && (canplay == 1) && (cancheck == 1)) skip = true;
		if ((cantplay == 2) && (canplay == 1) && (cancheck == 1)) skip = true;
		if ((cantplay == 3) && (canplay == 1) && (cancheck == 1)) skip = true;
		if ((canplay == 0) && (cancheck == 0)) {
			skip = true;
			this.keycount = -1;
		}
		// if all but 1 have gone all-in
		if (canplay == 1) {
			this.minimum_raise = 0;
		}
		if (skip) {
			this.log('skipping a player');
			this.keycount--;
			var last = this.current_seat;
			this.current_seat = this.getNextSeat(this.current_seat);
			this.checkRoundPass(function (events,extradelay) {
				assert.equal(typeof extradelay,'number');
				this.log('player '+last+' skipped, doing state again, FIXME %d',events);
				return this.stateMachine(cb,null,null,events,extradelay);
			}.bind(this),events,extradelay);
			return;
		}
		this.checkRoundPass(finish.bind(this),events,0);
	}
}
Game.prototype.idleUnstick = function () {
	this.Lock.writeLock(function (release) {
		function loop() {
			var x = to_kick.pop();
			this.standUp(this.seats[x].conn,function (folded,events2,offset) {
				if (to_kick.length > 0) return loop.call(this);
				else {
					this.log('all kicked');
					this.broadcastStatus(null,null,[]);
					release();
				}
			}.bind(this));
		}
		this.log('should unstick the table');
		var to_kick = [];
		for (var x=0; x<this.members.length; x++) {
			if (!this.members[x]) continue;
			if (this.members[x].status == 'psOutOfPlay') {
				to_kick.push(x);
			}
		}
		if (to_kick.length > 0) {
			loop.call(this);
			return;
		}
		this.log('none found???');
		release();
	}.bind(this));
}
Game.prototype.canCheck = function (seatIdx) {
	// find the highest bet
	var max = 0;
	for (var x=0; x<this.members.length; x++) {
		if (!this.members[x]) continue;
		if (['psInHand','psAllIn'].indexOf(this.members[x].status) == -1) continue;
		if (this.bets[x] > max) max = this.bets[x];
	}
	if (this.bets[seatIdx] == max) return true;
	return false;
}
Game.prototype.makeEvent = function (event,seat,data) {
	var obj = {event:event};
	if (data) obj.pots = data;
	if (typeof seat == 'number') obj.seat = seat;
	if (typeof seat == 'object') {
		if (seat && seat.bets) obj.bets = seat.bets;
		if (seat && seat.cards) obj.cards = seat.cards;
//		if (seat && seat.oldpots) obj.oldpots = seat.oldpots;
	}
	return obj;
}
Game.prototype.broadcastStatus = function (conn,forceunlock,events) {
	var token = profiler.start('broadcastStatus');
	assert(events);
	//this.log('sending table status to all 2, state:%s',this.state);
	for (var key in this.users) {
		if (this.users[key] == conn) continue;
		if (!this.users[key]) continue;
		var status = this.getTableStatus(this.users[key],forceunlock,events);
		this.users[key].send(codes.seTableStatus,status,'Poker.TableStatus');
	}
	token.stop();
}
var counter = 0;
Game.prototype.getTableStatus = function getTableStatus(self,forceunlock,events) {
	assert(self);
	assert(events);
	assert(self.nick);
	/*if ((['tsIdle','tsDealing','tsWinning','tsWinning2'].indexOf(this.state) == -1)) {
		assert(this.timer,util.inspect(this));
	}*/
	var tableStatus = {rake_percent:this.rake, table_mongo_id: fromMongoId(this.id),seats:[], state:this.state, bets:this.bets, pots:[], locked:this.Lock.readers == -1, seq:counter++, minimum_bet:this.minBet, minimum_raise:this.minBet + this.minimum_raise,small_blind:this.small_blind, big_blind:this.big_blind, events:events};
	if (forceunlock) tableStatus.locked = false;
	if (this.handid) tableStatus.handid = this.handid;
	if (this.pots) {
		tableStatus.pots = this.pots;
	}
	if (this.timer && this.timer.time) tableStatus.time = this.timer.time;
	for (var x=0; x<this.members.length; x++) {
		if (!this.members[x]) continue;
		var seat = this.members[x];
		var priv = this.seats[x];
		//console.log('table debug',x,seat.conn.userid,seat.hand.prettyPrint());
		if (!this.timebanks[priv.userid]) this.timebanks[priv.userid] = sharedconfig.max_timebank * 1000;
		var timebank = this.timebanks[priv.userid];
		if (timebank < 0) timebank = 0;
		var obj = {seat:x, player_mongo_id:fromMongoId(priv.userid), chips:seat.chips, status:seat.status, timebank:timebank, disconnected:seat.disconnected};
		var showcards = false;
		if (this.testmode) showcards = true;
		if ((['tsWinning','tsWinning2'].indexOf(this.state) != -1) && !seat.muck) showcards = true;

		obj.cards_visible = showcards;
		obj.can_show = this.members[x].can_show;

		if (priv.conn === self) showcards = true;
		if (showcards) {
			obj.cards = new Buffer(seat.hand.cards);
		}
		if (priv.conn == self) {
			tableStatus.maximum_raise = this.getLimit(x);
			if (tableStatus.minimum_raise > seat.chips) tableStatus.minimum_raise = seat.chips;
		}
		obj.card_count = seat.hand.cards.length;
		if (this.state == 'tsIdle') assert.equal(obj.card_count,0);
		else {
			if (['psOutOfPlay','psOutOfHand'].indexOf(seat.status) != -1) {
			} else if (this.omaha) assert.equal(obj.card_count,4);
			else assert.equal(obj.card_count,2);
		}
		tableStatus.seats.push(obj);
	}
	tableStatus.dealer = this.dealer;
	tableStatus.current_seat = this.current_seat;
	if (['tsFlop','tsTurning','tsTurn','tsRiverTime','tsRiver'].indexOf(this.state) != -1) tableStatus.flop = new Buffer(this.flop.cards);
	if (['tsTurn','tsRiverTime','tsRiver'].indexOf(this.state) != -1) tableStatus.turn = new Buffer(this.turn.cards);
	if (this.state == 'tsRiver') tableStatus.river = new Buffer(this.river.cards);
	tableStatus.current_game = this.omaha ? "gtOmaha" : "gtHoldem";
	tableStatus.game_limit = this.game_limit;
	tableStatus.rotation = this.rotation;
	tableStatus.total_balance = self.chips;
	assert.equal(typeof self.chips,'number');
	//this.log('made status:%d %s %j',counter-1,self ? 'for '+self.nick: '',tableStatus);
	return tableStatus;
}
Game.prototype.sittingCount = function () {
	var count = 0;
	for (var x=0; x<this.members.length; x++) {
		if (!this.members[x]) continue;
		if (this.members[x].chips <= 0) continue;
		count++;
	}
	return count;
}
Game.prototype.inHandCount = function () {
	var count = 0;
	for (var x=0; x<this.members.length; x++) {
		if (!this.members[x]) continue;
		if (['psInHand','psAllIn'].indexOf(this.members[x].status) == -1) continue;
		count++;
	}
	return count;
}
Game.prototype.roundEnd = function () {
	if (this.state == 'tsPreFlop') {
		this.minimum_raise = this.obj.big_blind;
	}
	var havechips = 0;
	for (var x=0; x<this.members.length; x++) {
		if (!this.members[x]) continue;
		if (this.members[x].status == 'psOutOfHand') continue;
		if (this.members[x].status == 'psOutOfPlay') continue;
		if (this.members[x].status == 'psFolded') continue;
		if (this.members[x].status == 'psAllIn') continue;
		if (this.members[x].chips > 0) {
			this.log('roundend found one',x,this.members[x].status,this.members[x].chips);
			havechips++;
		}
	}
	this.keycount = havechips;
}
Game.prototype.updateCashOut = function (userid,buyin,cb) {
	var mods = { $push:{cashouts:{
		$each:[buyin],
		$slice:-50
	}}};
	var key = {gameid:this.obj._id,userid:userid};
	log('updating %s %s',key.gameid,key.userid);
	allStats.update(key,mods,function () {
		this.club.handOver(this,function () {
			cb();
		});
	}.bind(this));
}
Game.prototype.standUp = function (conn,cb1,seatIdxIn) {
	assert.equal(this.Lock.readers,-1);
	if (seatIdxIn >= 0) var seatIdx = seatIdxIn;
	else var seatIdx = this.findSeat(conn);
	var seatObj = this.members[seatIdx];
	var folded = false;
	var token;
	var token2 = profiler.start('standup-inner5');
	var token3 = profiler.start('standup-inner6');
	var token9 = profiler.start('standup-step1');

	conn.log('standing up seat:%d bet:%d status:%s locked:%d',seatIdx,this.bets[seatIdx],util.inspect(seatObj),this.Lock.readers);
	this.updateLeaveStats(seatIdx);
	this.logEvent('geCashout',conn.userid,seatObj.chips);
	conn.boughtin -= seatObj.chips;
	this.club.cashout(conn.userid,seatObj.chips);
	
	this.members[seatIdx] = null;
	this.lastplayer[seatIdx] = conn.userid;
	conn.log('nulled out seat',seatIdx);
	
	if ((['tsIdle','tsWinning'].indexOf(this.state) == -1) && (['psInHand','psAllIn'].indexOf(seatObj.status) != -1)) {
		token = profiler.start('standup-inner2');
		this.fold(seatIdx,finish1.bind(this));
		folded = true;
	} else {
		token = profiler.start('standup-inner3');
		this.keycount--;
		finish1.call(this,[],-1);
	}
	function finish1(events,offset) {
		token.stop(); // 24ms 25%
		token9.stop(); // 21ms
		token9 = profiler.start('standup-step2.1');
		token = profiler.start('standup-inner4');
		assert.equal(typeof offset,'number');
		this.log('1events are %j',events);
		assert.equal(this.Lock.readers,-1);
		conn.log('standing up seat:',seatIdx,'bet:',this.bets[seatIdx],'status:',seatObj.status);
		var priv = this.seats[seatIdx];
		conn.log('instant leave');
		//this.broadcastStatus();
		if (this.bets[seatIdx] === undefined) this.bets[seatIdx] = 0;
		this.log('bets:',this.bets);
		assert.equal(typeof this.bets[seatIdx],'number');
		var increase = this.bets[seatIdx];
		conn.log('increase is',increase);
		assert(priv);
		if (['tsIdle','tsWinning'].indexOf(this.state) != -1) {
			token9.stop();
			token9 = profiler.start('standup-step2.2');
			assert.equal(increase,0);
			this.seats[seatIdx] = null;
			this.log('nulled out internal seat');
			//this.broadcastStatus();
			finish2.call(this,offset);
		} else {
			token9.stop(); // 5ms
			token9 = profiler.start('standup-step2.3'); // 6.7ms
			var token8 = profiler.start('standup-inner8');
			this.pots[0].value += increase;
			allUsers.update({_id:priv.userid},
				{ $inc:{chips:-this.bets[seatObj.seat]}},
				function (err,res) {
					assert(!err);
					assert(res == 1);
					priv.conn.log('lost chips',increase,this.bets[seatIdx],seatIdx);
					priv.conn.boughtin -= this.bets[seatIdx];
					this.bets[seatIdx] = 0;
					this.seats[seatIdx] = null;
					this.log('nulled out internal seat');
					//this.broadcastStatus();
					token8.stop(); // 5ms
					finish2.call(this,offset);
			}.bind(this));
		}
		function finish2(offset) {
			token9.stop();
			token9 = profiler.start('standup-step3');
			token3.stop(); // 42ms, 42%
			var token7 = profiler.start('standup-inner7');
			assert.equal(typeof offset,'number');
			conn.log('in standup finish2');
			//var status = this.getTableStatus();
			events.push(this.makeEvent('teStandUp',seatIdx));
			if (this.sittingCount() == 0) {
				this.dealer = -1;
				this.current_seat = -1;
			}
			//this.broadcastStatus(conn);
			conn.log('a');
			token.stop();
			// FIXME json performance hack
			this.club.seGameChanged(JSON.parse(JSON.stringify(this.obj)),function () {
				token9.stop(); // 5ms
				token9 = profiler.start('standup-step4.1');
				if (seatObj.handsPlayed > 0 ) {
					this.lastCashout[conn.userid] = { chips:seatObj.chips, when:Date.now() };
				}
				this.updateCashOut(conn.userid,seatObj.chips,function () {
					token9.stop(); // 7ms
					token9 = profiler.start('standup-step4.2');
					this.updateMongoState({},{members:true},function () {
						token2.stop();
						token7.stop(); // 31ms 31%
						token9.stop(); // 3ms
						cb1(folded,events,offset);
					});
				}.bind(this));
			}.bind(this),conn);
		}
	}
}
Game.prototype.leave = function leave(conn,reason,cb1) {
	conn.log('getting lock:%s',this.Lock.trace);
	delete this.users[conn.userid];
	this.Lock.writeLock(function (release) {
		conn.log('got lock',this.Lock.readers);
		var seatIdx = this.findSeat(conn);
		conn.log('leave idx %d %s',seatIdx,reason);
		if (seatIdx >= 0) {
			this.standUp(conn,function (folded,events) {
					conn.log('releasing lock events:%j',events);
					if (folded && (this.current_seat >= 0)) this.startTimer(this.current_seat,0);
					this.broadcastStatus(null,true,events);
					finish.call(this);
				}.bind(this));
		} else finish.call(this);
		function finish() {
			var count = 0;
			for (var key in this.users) {
				count++;
				console.log('key:%s count:%d',key,count);
			}
			if (count == 0) {
				if (this.state2 == 'gsClosing') {
					this.log('staying alive!');
				} else {
					this.log('self-deleting');
					delete activeGames[this.id];
					if (this.state2 == 'gsClosed') {
						clearTimeout(this.deleteTimer);
						this.doDelete();
					}
					gameState.remove({_id:this.obj._id},function (err,res) {
						assert.ifError(err);
						cb1();
						release();
					}.bind(this));
					return;
				}
			}
			this.updateMongoState({},{users:true},function () {
				cb1();
				release();
			});
		}
	}.bind(this));
}
Game.prototype.handleDisconnect = function (conn,reason,cb) {
	assert(conn.userid);
	if (reason == 'logout') {
		this.leave(conn,reason,cb);
		return;
	}
	delete this.users[conn.userid];
	this.reconnect.push(conn.userid);
	this.Lock.writeLock(function (release) {
		function finish() {
			cb();
			release();
		}
		var seatIdx = this.findSeat(conn);
		conn.log('leave idx %d',seatIdx);
		if (seatIdx >= 0) {
			this.members[seatIdx].disconnected = true;
			assert(conn.userid);
			this.members[seatIdx].disconnectTimer = setTimeout(this.eject.bind(this,seatIdx,conn.userid),5 * 60 * 1000);
			var fakeconn = {log:ClientSocket.prototype.log,userid:this.seats[seatIdx].userid, nick:this.seats[seatIdx].conn.nick};
			this.seats[seatIdx].conn = fakeconn;
			var events = [];
			events.push(this.makeEvent('teDisconnect',seatIdx));
			this.broadcastStatus(null,true,events);
			finish.call(this);
		} else finish.call(this);
	}.bind(this));
}
Game.prototype.eject = function (seatIdx,userid) {
	assert(userid);
	this.Lock.writeLock(function (release) {
		this.standUp(this.seats[seatIdx].conn,function (folded,events,offset) {
			for (var x=0; x<this.reconnect.length; x++) {
				if (compareObjectID(userid,this.reconnect[x])) {
					this.reconnect.splice(x,1);
				}
			}
			this.broadcastStatus(null,true,events);
			release();
		}.bind(this),seatIdx);
	}.bind(this));
}
Game.prototype.doDelete = function () {
	allClubs.findOne({_id:this.obj.clubid},function (err,club) {
		assert(club);
		var g = makeGameProtobuf(JSON.parse(JSON.stringify(this.obj)));
		g.state = 'gsClosed';
		var conn = activeUsers[club.owner];
		if (conn) conn.send(codes.seGameDelete,g,'Poker.Game');
		if (club.is_private) {
			if (club.members) {
				for (var x=0; x<club.members.length; x++) {
					conn = activeUsers[club.members[x]];
					if (!conn) continue;
					conn.send(codes.seGameDelete,g,'Poker.Game');
				}
			}
		} else {
			for (var key in activeUsers) {
				activeUsers[key].send(codes.seGameDelete,g,'Poker.Game');
			}
		}
	}.bind(this));
}
Game.prototype.startTimer = function startTimer(seat,offset) {
	return;
	assert.equal(typeof offset,'number');
	this.stopTimer(seat);
	this.log('starting timer for seat %d in state %s',seat,this.state);
	//this.log('public: %j',this.members[seat]);
	this.log('private: %s',util.inspect(this.seats[seat]));
	assert(this.members[seat]);
	this.timer = { time: (sharedconfig.max_play_time*1000) + Date.now() + offset, seat:seat };
	var priv = this.seats[seat];
	if (!this.timebanks[priv.userid]) this.timebanks[priv.userid] = sharedconfig.max_timebank * 1000;
	this.timer.timerid = setTimeout(function () {
		this.log('DING!');
		this.Lock.writeLock(function (release) {
			assert.equal(this.timer.seat,seat);
			this.stopTimer(seat);
			this.log('minbet:%d seatbet:%d',this.minBet,this.bets[seat]);
			if (this.minBet == this.bets[seat]) {
				this.log('checking');
				this.putChips(this.seats[seat].conn,this.minBet,function (events,offset) {
					this.log('checked %j',events);
					if (this.current_seat >= 0) this.startTimer(this.current_seat,offset); /// FIXME?
					this.broadcastStatus(null,true,events);
					release();
				}.bind(this));
			} else {
				this.log('folding');
				this.fold(seat,function (events) {
					this.log('folded %j',events);
					if (this.current_seat >= 0) this.startTimer(this.current_seat,0); /// FIXME?
					this.broadcastStatus(null,true,events);
					release();
				}.bind(this));
			}
		}.bind(this));
	}.bind(this),(sharedconfig.max_play_time*1000) + this.timebanks[this.seats[seat].userid] + offset);
}
Game.prototype.stopTimer = function stopTimer(seat) {
	if (this.timer) {
		var spent = Date.now() - this.timer.time;
		var priv = this.seats[seat];
		if (!this.timebanks[priv.userid]) this.timebanks[priv.userid] = sharedconfig.max_timebank * 1000;
		if (spent > 0) this.timebanks[this.seats[seat].userid] -= spent;
		if (this.timebanks[this.seats[seat].userid] < -1) this.timebanks[this.seats[seat].userid] = -1;
		this.log('removed %d from timebank, %d remains',spent,this.timebanks[this.seats[seat].userid]);
		clearTimeout(this.timer.timerid);
	}
	this.timer = null;
}
Game.handleDisconnect = function handleDisconnect(conn,reason,cb1) {
	conn.log('handling disconnect:%s',reason);
	var jobs = [];
	for (var key in activeGames) {
		var game = activeGames[key];
		if (game.users[conn.userid]) jobs.push(game);
	}
	async.each(jobs,function (game,cb2) {
		game.handleDisconnect(conn,reason,cb2);
	},cb1);
}
Game.prototype.logEvent = function (type,userid,change) {
	var doc = {eventtype:type};
	if (userid) doc.userid = userid;
	if (change) doc.change = change;
	GameEvents.insert(doc,function (){});
}
Game.getGame = function getgame(id,cb) {
	getGameLock.writeLock(function (release) {
		if (!activeGames[id]) {
			allGames.findOne({_id:id},function (err,obj) {
				if (!obj) {
					release();
					return cb();
				}
				var token = profiler.start('game-create');
				var game = new Game(obj);
				game.logEvent('geOpened');
				// FIXME, concurrent calls, grab a lock here
				game.deck = new Deck();
				game.deck.shuffle(function shuffled(){
					//this.send(codes.SR_DECKREPLY,{deck:deck.prettyPrint()},'Poker.GetDeckReply');
					allClubs.findOne({_id:obj.clubid},function (err,club) {
						if (!club) {
							release();
							cb('parent club missing');
							return;
						}
						game.real_rake = club.rake;
						if (!game.real_rake) game.real_rake = 5;
						game.rake = 0;
						game.testmode = club.testmode;
						var g = makeGameProtobuf(JSON.parse(JSON.stringify(obj)));
						var conn = activeUsers[club.owner];
						if (conn) conn.send(codes.seGameChange,g,'Poker.Game');

						if (club.members) {
							for (var x=0; x<club.members.length; x++) {
								conn = activeUsers[club.members[x]];
								if (!conn) continue;
								conn.send(codes.seGameChange,g,'Poker.Game');
							}
						}
						Club.getClubBySeq(obj.clubseq,function (err,clubobj) {
							game.club = clubobj;
							gameState.insert({_id:game.id},function () {
								token.stop();
								release();
								cb(null,game);
							});
						});
					});
				}.bind(this));
			}.bind(this));
		} else {
			release();
			cb(null,activeGames[id]);
		}
	}.bind(this));
}
ClientSocket.prototype.handleChatEvent = function handleChatEvent(ev,ts,token) {
	switch (ev.event) {
	case 'ceUserMessage':
		//for (var x=0; x<ev.messages.length; x++) {
			ev.msg.username = this.nick;
			ev.msg.timestamp = ts;
		//}
		var id = new toMongoId(ev.table_id);
		var game = activeGames[id];
		if (!game) {
			return;
		}
		for (var key in game.users) {
			//if (key == this.userid) continue;
			game.users[key].send(codes.seChat,ev,'Poker.ChatEvent');
		}
		token.stop();
		break;
	}

}
var timebanktimer;
function setTimebankTimer() {
	var now = new Date();
	now.setMinutes(0);
	now.setSeconds(0);
	now.setMilliseconds(0);
	now.setHours(now.getHours()+1);
	var now2 = new Date();
	clearTimeout(timebanktimer);
	var target = now - now2;
	setTimeout(function () {
		//log('DING, timebanks');
		for (var key in activeGames) {
			var game = activeGames[key];
			log('clearing timebank %s %j',key,game.timebanks);
			game.timebanks = {};
		}
		setTimebankTimer();
	},target);
}
setTimebankTimer();
function checkGameParams(gamename,seats,game_type,game_limit,buyin_min,buyin_max,blinds) {
	if (!blinds) return true;
	if (!game_type) return true;
	if (!game_limit) return true;
	if (!regexLimits.gamename.exec(gamename)) return true;
	if ([2,3,4,5,6,7,8,9,10].indexOf(seats) == -1) return true;
	if (5 > buyin_min) {
		log('min too low',buyin_min);
		return true;
	}
	if (buyin_max < buyin_min) {
		log('max too low');
		return true;
	}
	if (10 > buyin_max) {
		log('max too low',buyin_max);
		return true;
	}
	return false;
}
ClientSocket.prototype.destroy = function destroy() {
	this.socket.destroy();
	clearTimeout(this.idleTimer);
}
function cactiStats() {
	var mem = process.memoryUsage();
	var data = { hands:hands };
	var msg = []
	for (var x in data) {
		msg.push(x+':'+data[x]);
	}
	for (x in mem) {
		msg.push(x+':'+mem[x]);
	}
	return msg.join(' ');
}
function stats_server(c) {
	c.write(cactiStats());
	c.end();
}
