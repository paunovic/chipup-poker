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
var club = require('./club');
var Club = club.Club;
var makeGameProtobuf = require('./game').makeGameProtobuf;
var RT = require('./rt');
var omaha2 = require('./dag2/omaha');
var config = require('./config');
var differ = require('./differ');
var mdb = require('./db');

var Hand = deck.Hand;
var Game = require('./game').Game;
var Pot = require('./pot').Pot;
var myutils = require('./myutils');

var pb = new p(fs.readFileSync("../message.desc"));
var protoreader = require('./protoreader');
protoreader.init(pb,codes,[codes.seTableStatus,codes.seTableEvent,codes.srPong]);

dag.init();

// stats
var hands = 0;

var domain = "http://"+config.hostname+'/';
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

var conn,allUsers,allClubs,allCounters,avatars,allGames,bugs,handHistory,Installers,Config,FetchQueue,GameEvents,PokerProfile,gameState,clubBalances,debugLogs,diffs;
var emailRegister,emailChange1,emailChange2;
MongoClient.connect('mongodb://localhost:27017/poker',function (err,db) {
	if (err) {
		console.log(err);
		process.exit(1);
	}
	conn = db;
	club.init(db,activeUsers,activeGames,pb);
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
	gameState = db.collection('gameState');
	clubBalances = db.collection('clubBalances');
	diffs = db.collection('diffs');

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
		Game.init(db,activeGames,activeUsers,debugLogs,sharedconfig,getNextSequence,log,ClientSocket);
	});

	internalHttpServer = require('./httpServer').initHttpServer(db,activeUsers,sharedconfig,log,makeUserProtobuf);

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
				var obj = {login_status:'lrSuccess',status:status,reconnect_tables:statuses};
				console.log('login reply',obj);
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
function containsObjectID(list,id) {
	for (var x=0; x<list.length; x++) {
		if (myutils.compareObjectID(id,list[x])) return true;
	}
	return false;
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
	console.log('hello params',params);
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
					diffs.findOne({sourcehash:clientFile.hash,desthash:targetFile},function (err,diffRow) {
						assert.ifError(err);
						if (diffRow) {
							var UFI = { path: clientFile.path.replace('/','\\'), url:diffRow.url, file_type:'ufDiff', file_size:diffRow.size };
							toUpdate.push(UFI);
							cb();
						} else {
							conn.collection('objectSizes').findOne({_id:targetFile},function (err,sizeRow) {
								assert.ifError(err);
								if (sizeRow) {
									toUpdate.push({file_type:'ufFull',path:clientFile.path.replace('/','\\'),url:'http://'+config.staticserver+'/unpacked/objects/'+targetFile,file_size:sizeRow.size});
								} else {
									log('cant find original of %s',clientFile.path);
								}
								cb();
							});
							if (clientFile.hash) differ.makeDiff(clientFile.hash,targetFile,clientFile.path,diffs);
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
										if (myutils.compareObjectID(this.userid,out[i])) continue;
										if (myutils.compareObjectID(userid,out[i])) continue;
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
										if (myutils.compareObjectID(this.userid,out[i])) continue;
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
				if (!myutils.compareObjectID(club.owner,this.userid)) {
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
								if (myutils.compareObjectID(club.suspended[x],this.userid)) {
									this.reply(0,'your suspended in that club'); // FIXME
									release();
									return;
								}
							}
						}
						console.log(club);
						if (!myutils.compareObjectID(this.userid,club.owner) && (!club.members || !containsObjectID(club.members,this.userid)) && club.is_private) {
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
				if (!myutils.compareObjectID(club.owner,this.userid)) {
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
	this.log('params:%j',params);
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
	var types = {cmQuestions:'Questions',cmSuggestions:'Suggestions',cmOther:'Other',cmBugReport:'Bugs'};
	var queue = types[params.reason];
	RT.postTicket(queue,this.email,params.message);
	this.send(codes.srContactUsOk);
	token.stop();
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
