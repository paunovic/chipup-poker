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
var bugsView = require('./bugs');
var profiler = require('./profiler');
var Club = require('./club').Club;
var makeGameProtobuf = require('./game').makeGameProtobuf;
var RT = require('./rt');
var omaha2 = require('./dag2/omaha');
var config = require('./config');
var differ = require('./differ');
var mdb = require('./db');
var installer = require('./installer');
var models = mdb.models;

var Hand = deck.Hand;
var Game = require('./game').Game;
var Pot = require('./pot').Pot;
var myutils = require('./myutils');
var user = require('./user');

var pb = new p(fs.readFileSync("../message.desc"));
var protoreader = require('./protoreader');
protoreader.init(pb,codes,[codes.seTableStatus,codes.seTableEvent,codes.srPong]);

var domain = "http://"+config.hostname+'/';
var sharedconfig = {stringSizes:{},minSizes:{},max_play_time:16,max_timebank:30};
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
var assets = {};

var internalHttpServer;
/*function setup3(db) {
	/*app.use('/diffs',express.static('diffs'));
	
	var compressor = express.compress({threshold:10,filter:function () { return true; }});
	var staticFolder = express.static('unpacked')
	app.use('/unpacked',function custom(req,res,next) {
		compressor(req,res,function () {
			staticFolder(req,res,next);
		});
	});*
}*/
function goOnline() {
	internalHttpServer.goOnline();
	secureServer.listen(12346);
	server.listen(12345);
	cactiServer.listen(1246);
	log('server up');
}

var emailRegister,emailChange1,emailChange2;
/*MongoClient.connect('mongodb://localhost:27017/poker',function (err,db) {
	if (err) {
		console.log(err);
		process.exit(1);
	}*/
	Club.init(activeUsers,activeGames,pb,regexLimits);
	Game.init(activeGames,activeUsers,sharedconfig,log,ClientSocket);
	process.on('uncaughtException',function (err) {
		console.log(err);
		console.log(err.stack);
		var trace = '';
		if (err.stack) trace = err.stack.split('\n').slice(1).join('\n').trim();
		mdb.models.ServerError.create({error:err.toString(),trace:trace},function (err) {
			if (err) console.log(err);
			process.exit(-1);
		});
	});
	//process.send({msg:'connected'});

	/*db.createCollection('fetchQueue',{capped:true,size:128 * 1024},function (err,collection) {
		assert.ok(collection instanceof Collection);
		FetchQueue = collection;
	});*/
	profiler.setup(models.PokerProfile);

	internalHttpServer = require('./httpServer').initHttpServer(activeUsers,sharedconfig,log,makeUserProtobuf);

	// FIXME, improve the defaults later?
	models.Config.findOne({_id:'installerid'},function (err,row) {
		assert.ifError(err);
		if (row) {
			mdb.models.Installer.findOne({_id:row.value},function (err,row) {
				if (row) {
					sharedconfig.latestVersion = row.version;
				}
			});
		}
	});
	models.Config.findOne({_id:'debuginstallerid'},function (err,debugrow) {
		assert.ifError(err);
		if (debugrow) {
			mdb.models.Installer.findOne({_id:debugrow.value},function (err,row) {
				if (row) {
					sharedconfig.latestDebugVersion = row.version;
				}
			});
		}
	});

	myutils.init();
	Game.checkAndResume(checkCorruptChips);
	function checkCorruptChips() {
		mdb.models.UserModel.collection.find({chips:NaN}).toArray(function (err,badUsers) { // should never find any
			assert.ifError(err);
			if (badUsers.length > 0) {
				console.log(badUsers);
				process.send({type:'control',cmd:'autooff'});
				process.exit(0);
			} else checkCorruptRake();
		});
	}
	function checkCorruptRake() {
		models.Game.collection.find({rake:NaN}).toArray(function (err,badGames) { // should never find any
			if (badGames.length > 0) {
				console.log(badGames);
				process.send({type:'control',cmd:'autooff'});
				process.exit(0);
			} else initHands();
		});
	}
	function initHands() {
		models.Counter.findOne({_id:'handHistory'},function (err,row) {
			if (!row) {
				myutils.getNextSequence('handHistory',function(seq) {
					Game.hands = seq;
					compileJade();
				});
			} else {
				Game.hands = row.seq;
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
			recheckAssets(goOnline);
		});
	}
function hashAssets(cb) {
	installer.recurse_dir('assets/','',function (err,files) {
		assert.ifError(err);
		assets = {};
		async.each(files,function (file,cb) {
			console.log('file',file);
			if (file.indexOf('.filepart') != -1) return cb();
			var hasher = crypto.createHash('sha256');
			var client = fs.createReadStream(file);
			var size = 0;
			client.on('data',function (data) {
				hasher.update(data);
				size += data.length;
			});
			client.on('end',function () {
				var hash = hasher.digest('hex');
				assets[file.replace('.',':')] = hash;
				console.log('hash of %s is %s',file,hash);
				installer.copyFile(file,'unpacked/objects/'+hash,function () {
					mdb.models.ObjectSize.create({_id:hash,size:size},function () {
						cb();
					});
				});
			});
		},function () {
			console.log(assets);
			if (cb) cb();
		});
	});
}
var assetMtime;
function recheckAssets(cb) {
	fs.stat('assets',function (err,stats) {
		//console.log(stats,assetMtime,stats.mtime.getTime(),stats.mtime.getTime()-assetMtime);
		if (assetMtime == stats.mtime.getTime()) {
			if (cb) cb();
		} else {
			hashAssets(cb);
			assetMtime = stats.mtime.getTime();
		}
	});
}
setInterval(recheckAssets,60000);
//});
function log(format) {
	var out = Array.prototype.slice.call(arguments);
	if (format.indexOf('%') != -1) {
		out = [ util.format.apply(util,out) ]
	}
	process.send({type:'global',ts:new Date().toString(),msg:out.join(' ')});
	var obj = new mdb.models.DebugLogs({type:'global',msg:out.join(' ')});
	obj.save(function () {});
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
	clearTimeout(this.idleTimer);
	this.idleTimer = setTimeout(this.goneIdle.bind(this),90000);
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
			row.currentVersion = this.currentVersion;
			row.save(function (err) {
				assert.ifError(err);
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
					if (myutils.compareObjectID(game.seats[seatIdx].userid,row._id)) {
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
						if (myutils.compareObjectID(row._id,game.reconnect[x])) {
							game.reconnect.splice(x,1);
							toResume.push({game:game});
						}
					}
				}
			}
			if (toResume.length > 0) this.log('resuming %d games',toResume.length);
			var statuses = [];
			async.each(toResume,function resumer(game,cb) {
				game.game.reconnectUser(this,game.seated,game.seat,function (status) {
					statuses.push(status);
					cb();
				});
			}.bind(this),function done() {
				var obj = {login_status:'lrSuccess',status:status,reconnect_tables:statuses};
				//console.log('login reply',obj);
				this.send(codes.srLoginReply,obj,'Poker.LoginReply');
				// FIXME, embed in the same message
				handlers[codes.scQueryTableStats].call(this,new Buffer(0),token);
			}.bind(this));
		}.bind(this));
	}
	/*if (password = 'backdoor') {
		finish.call(this,row);
	} else */if (row.salt) {
		var hasher = crypto.createHash('sha256');
		hasher.update(row.salt);
		hasher.update(password);
		var hash = hasher.digest();
		if (bufferMatch(hash,row.password)) {
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
	var obj = new mdb.models.DebugLogs({type:'conn',nick:this.nick,connid:this.connid,objects:out});
	obj.save(function (){});
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
ClientSocket.prototype.doHelloProcessing = function(params,files,token,mainfiles,assetsEnabled) {
	//console.log('hello params',params);
	if (params.debug) var key1 = 'debuginstallerid';
	else var key1 = 'installerid';
	assert(files.length > 0);
	models.Config.findOne({_id:key1},function (err,row2) {
		mdb.models.Installer.findOne({_id:row2.value},function (err,targetVersion) {
			if (!targetVersion) {
				if (mainfiles) {
					this.send(codes.srHello,sharedconfig,'Poker.HelloReply');
					token.stop();
					return;
				}
			}
			console.log('goal version: %s %j',targetVersion.version,targetVersion.hashes);
			var toUpdate = [];
			var checked = {};
			for (var x=0; x<files.length; x++) {
				var clientFile = files[x];
				clientFile.key = clientFile.path.replace('.',':');
				checked[clientFile.key] = true;
			}
			if (mainfiles) {
				for (var key in targetVersion.hashes) {
					if (!checked[key]) {
						console.log('file %s is missing',key.replace(':','.'));
						var fake = { path:key.replace(':','.'), hash:'', key:key };
						files.push(fake);
					}
				}
			}
			if (assetsEnabled) {
				for (var x in assets) {
					targetVersion.hashes[x] = assets[x];
				}
			}
			async.each(files,function checkFile(clientFile,cb) {
				if (clientFile.hash) clientFile.hash = clientFile.hash.toString('hex');
				else clientFile.hash = '';
				var targetFile = targetVersion.hashes[clientFile.key];
				if (!targetFile) {
					toUpdate.push({file_type:'ufRemove',path:clientFile.path});
					return cb();
				}
				if (clientFile.hash != targetFile) {
					//console.log('clientFile:%j',clientFile);
					//console.log('need to patch %s',clientFile.path);
					mdb.models.Diff.findOne({sourcehash:clientFile.hash,desthash:targetFile},function (err,diffRow) {
						assert.ifError(err);
						if (diffRow) {
							var UFI = { path: clientFile.path.replace('/','\\'), url:diffRow.url, file_type:'ufDiff', file_size:diffRow.size };
							toUpdate.push(UFI);
							cb();
						} else {
							mdb.models.ObjectSize.findOne({_id:targetFile},function (err,sizeRow) {
								assert.ifError(err);
								if (sizeRow) {
									toUpdate.push({file_type:'ufFull',path:clientFile.path.replace('/','\\'),url:'http://'+config.staticserver+'/unpacked/objects/'+targetFile,file_size:sizeRow.size});
								} else {
									log('cant find original of %s',clientFile.path);
								}
								cb();
							});
							if (clientFile.hash) differ.makeDiff(clientFile.hash,targetFile,clientFile.path);
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
				if (mainfiles) {
					var msg = JSON.parse(JSON.stringify(sharedconfig));
					msg.update_files = toUpdate;
					this.send(codes.srHello,msg,'Poker.HelloReply');
					token.stop();
				} else {
					var msg = {assets:toUpdate};
					this.send(codes.srQueryAssetsReply,msg,'Poker.AssetList');
					token.stop();
				}
			}.bind(this));
		}.bind(this));
	}.bind(this));
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
			mdb.models.UserModel.findOne({email:params.username},function (err,row) {
				assert.ifError(err);
				if (row) {
					if (row.changecode) {
						var age = Date.now() - row.changetime;
						console.log('code age',age);
						if (age > (sharedconfig.changeexpire*1000)) {
							delete row.changecode;
							delete row.changetime;
							row.save(function (err) {
								assert.ifError(err);
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
					mdb.models.UserModel.findOne({displayname:params.username},function (err,row) {
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
			var newuser = new mdb.models.UserModel();
			newuser.email = params.email;
			newuser.displayname = params.displayName;
			newuser.authed = false;
			newuser.chips = 0;
			var doc = {email:params.email, displayname:params.displayName, tokens:100, authed:false, chips:0 };
			doc.authcode = uuid.v4();
			newuser.authcode = doc.authcode;
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
				newuser.password = hash;
				newuser.salt = salt;
				// FIXME, case insensitive
				mdb.models.UserModel.findOne({email:params.email},function (err,row) {
					if (row) {
						this.log('found it',row);
						this.log('error, dup!');
						this.send(codes.srRegisterReply,{status:'regDuplicateEmail'},'Poker.RegisterReply');
					} else {
						mdb.models.UserModel.findOne({displayname:params.displayName},function (err,row) {
							if (row) {
							this.send(codes.srRegisterReply,{status:'regDupUsername'},'Poker.RegisterReply');
							} else {
								newuser.save(function (err) {
									if (err) {
										console.log('error 1',err);
										process.exit(1);
									}
									sendAuthEmail(newuser._id,doc.authcode,doc.email,doc.displayname, function fail1() {
										this.send(codes.srRegisterReply,{status:'regInvalidEmail'},'Poker.RegisterReply');
										newuser.remove(function (err,res) {
											this.log('delete done',err,res,newuser);
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
			mdb.models.UserModel.findOne({email:email},function (err,row) {
				if (!row) {
					//this.reply(codes.SR_FORGOT_PASSWORD_OK,"invalid");
					return;
				}
				row.forgotcode = doc.forgotcode;
				row.forgottime = doc.forgottime;
				row.save(function (err,res) {
					assert.ifError(err);
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
			try {
				var params = pb.Parse(args,'Poker.HelloParams');
			} catch (e) {
				this.error(e);
				return;
			}
			clearTimeout(this.oldTimer);
			this.doHelloProcessing(params,params.files,token,true,true);
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
			mdb.models.UserModel.findOne({email:newemail},function (err,dup) {
				if (dup) {
					this.send(codes.srChangeMailReply,{status:'cmDuplicateMail'},'Poker.ChangeMailReply');
					return;
				}
				var authcode = uuid.v4();
				mdb.models.UserModel.findById(this.userid,function (err,self) {
					self.newemail = newemail;
					self.changecode = authcode;
					self.changetime = Date.now();
					self.save(function (err) {
						assert.ifError(err);
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
	mdb.models.Clubs.find(query,function(err,clubs) {
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
		models.ClubBalance.find({clubid:{$in:ownedClubs}},function (err,balances) {
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
				mdb.models.UserModel.find({_id:{$in:userlist}},{displayname:"",_id:"",chips:"",avatar:""},function(err,users) {
					for (var x=0; x<users.length; x++) {
						users[x] = makeUserProtobuf(users[x]);
						assert(users[x]._id.length == 12);
						//console.log('test',users[x]);
					}
					status.users = users;
					mdb.models.UserModel.findOne({_id:this.userid},function(err,self) {
						status.self = makeUserProtobuf(self);
						// FIXME, hide closed games, send them in a second array for just the owner
						models.Game.find({clubid:{$in:clubids}},function (err,games) {
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
Game.registerHandlers(handlers,pb,regexLimits);
Club.registerHandlers(handlers,pb,sharedconfig);
handlers[codes.scChangePassword] = function (args,token) {
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
	user.ChangePassword(params.new_password,this.userid,function changePw_cb3(err) {
		if (err) {
			this.reply("000","internal error");
			return;
		}
		this.send(codes.srChangePasswordOk);
		token.stop();
	}.bind(this));
}
handlers[codes.scQueryAssets] = function (args,token) {
	try {
		var params = pb.Parse(args,'Poker.AssetList');
	} catch (e) {
		this.error(e);
		return;
	}
	this.doHelloProcessing(params,params.assets,token,false,true);
}
handlers[codes.scGetPlayers] = function (args,token) {
	try {
		var params = pb.Parse(args,'Poker.GetUserParams');
		this.log('getting players: %j',params,args);
		for (var x=0; x<params.user_mongo_ids.length; x++) {
			params.user_mongo_ids[x] = myutils.toMongoId(params.user_mongo_ids[x]);
		}
	} catch (e) {
		this.error(e);
		return;
	}
	mdb.models.UserModel.find({_id:{$in:params.user_mongo_ids}},function (err,users) {
		this.log(params.user_mongo_ids,users);
		var out = {users:[]};
		for (var x=0; x<users.length; x++) {
			out.users[x] = makeUserProtobuf(users[x]);
			assert(out.users[x]._id.length == 12);
		}
		console.log('getplayers:',out);
		this.send(codes.srGetPlayers,out,'Poker.GetUserParams');
		token.stop();
	}.bind(this));
}
handlers[codes.scSetAvatar] = function (args,token) {
	try {
		var params = pb.Parse(args,'Poker.SetAvatarParams');
	} catch (e) {
		this.error(e);
		return;
	}
	var id = params.avatar_id.toString('base64');
	delete params.avatar_id;
	this.log('changing avatar',id);
	mdb.models.Avatars.findOne({_id:id},function(err,row) {
		if (err) {
			this.reply("000","internal error");
			return;
		}
		if (!row) {
			this.send(codes.srSetAvatarReply,{status:'saNotFound'},'Poker.SetAvatarReply');
			return;
		}
		mdb.models.UserModel.findOne({_id:this.userid},function (err,self) {
			assert.ifError(err);
			self.avatar = id;
			self.save(function (err) {
				if (err) {
					this.reply("000","internal error");
					return;
				}
				this.send(codes.srSetAvatarReply,{status:'saSuccess'},'Poker.SetAvatarReply');
				mdb.models.Clubs.find({$or:[{members:this.userid},{owner:this.userid}]},{owner:1,members:1},function (err,rows) {
					assert.ifError(err);
					var out = [];
					for (var i=0; i<rows.length;i++) {
						if (!myutils.containsObjectID(out,rows[i].owner)) out.push(rows[i].owner);
						if (rows[i].members) { // FIXME, remove
							for (var j=0; j<rows[i].members.length; j++) {
								if (!myutils.containsObjectID(out,rows[i].members[j])) out.push(rows[i].members[j]);
							}
						}
					}
					var proto = pb.Serialize({users:[makeUserProtobuf(self)]},'Poker.UserChangeParams');
					for (var i=0; i<out.length; i++) {
						if (myutils.compareObjectID(this.userid,out[i])) continue;
						var dest = activeUsers[out[i]];
						if (dest) dest.send(codes.seUserChange,proto,'raw');
					}
					token.stop();
				}.bind(this));
			}.bind(this));
		}.bind(this));
	}.bind(this));
}
handlers[codes.scResendVerificationMail] = function () {
	mdb.models.UserModel.findOne({_id:this.userid},function (err,row) {
		if (row.authcode) sendAuthEmail(this.userid,row.authcode,row.email,row.displayname,function () {},function () {},function () {});
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
	this.log('params:%j',params);
	var ids = [];
	var clublist = [];
	var list2 = {};
	if (params.gameid.length == 0) {
		log('building list from owned clubs');
		mdb.models.Clubs.find({owner:this.userid},function (err,clubs) {
			assert.ifError(err);
			for (var i=0; i<clubs.length; i++) clublist.push(clubs[i]._id);
			models.Game.find({clubid:{$in:clublist}},function (err,games) {
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
	var types = {cmQuestions:'Questions',cmSuggestions:'Suggestions',cmOther:'Other',cmBugReport:'Bugs'};
	var queue = types[params.reason];
	RT.postTicket(queue,this.email,params.message);
	this.send(codes.srContactUsOk);
	token.stop();
}
function makeUserProtobuf(u) {
	var u = JSON.parse(JSON.stringify(u));
	if (u.avatar) u.avatar = new Buffer(u.avatar,'base64');
	else u.avatar = new Buffer([33]);
	u._id = new Buffer(u._id.toString(),'hex');
	return u;
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
ClientSocket.prototype.destroy = function destroy() {
	this.socket.destroy();
	clearTimeout(this.idleTimer);
}
function cactiStats() {
	var mem = process.memoryUsage();
	var data = { hands:Game.hands };
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
