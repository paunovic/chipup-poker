#!/usr/bin/node
"use strict";
// http://docs.mongodb.org/manual/reference/operator/update/positional/
var net = require('net');
var tls = require('tls');
var fs = require('fs');
var MongoClient = require('mongodb').MongoClient;
var Collection = require('mongodb').Collection;
var ObjectID = require('mongodb').ObjectID;
//var Reader = require('./reader').reader;
var express = require('express');
var crypto = require('crypto');
var p = require("node-protobuf");
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
var profiler = require('profiler');
var Club = require('./club').Club;
var makeGameProtobuf = require('./game').makeGameProtobuf;
var RT = require('./rt');
var config = require('./config');
var differ = require('./differ');
var mdb = require('./db');
mdb.open('poker');
var models = mdb.models;

var pb = new p(fs.readFileSync("../message.desc"));
// NOTE: must be ran before requiring any module that uses it
global.pb = pb; //FIXME, maybe always reference this via global too?

var Hand = deck.Hand;
var Game = require('./game').Game;
var Pot = require('./pot').Pot;
var myutils = require('./myutils');
var user = require('./user');
var Tournament = require('./tournament');

var Protoreader = require('./protoreader');
Protoreader.init(pb,codes,[codes.seTableStatus,codes.seTableEvent,codes.srPong,codes.PerClientMsgEvent,codes.seChat,codes.scTableSit,codes.scTableJoin,codes.scLogin,codes.scStatus,codes.seGameChange,codes.PerGameMsgEvent]);

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
global.sharedconfig = sharedconfig; // FIXME, always reference it via global

var regexLimits;
function initConfig() {
	var regex = {},key,regex2;
	regex.email = '^[a-zA-Z0-9\\.+]+@[a-zA-Z0-9\\.]+$';
	regex.username = '^[a-zA-Z0-9 _\\. -]{3,20}$';
	regex.password = '^[a-zA-Z0-9_\\!@#$%^&*\\(\\)+=~`\\.-]{6,32}$';
	regex.clubname = "^[a-zA-Z0-9!()\\[\\]{}@#$%&*+=/\\' -]{5,64}$";
	regex.clubpassword = '^[a-zA-Z0-9]{3,32}$';
	regex.gamename = "^[a-zA-Z0-9!()\\[\\]{}@#$%&*+=/\\' -]{3,32}$";
	sharedconfig.valid_chars_regex = regex;
	regex2 = {};
	for (key in regex) {
		regex2[key] = new RegExp(regex[key]);
	}
	regexLimits = regex2;
}
initConfig();

var activeUsers = {};
global.activeUsers = activeUsers; // FIXME, always reference via global
var activeGames = {}; // FIXME, move to game.js

var internalHttpServer;
/*function setup3(db) {
	app.use('/diffs',express.static('diffs'));
	
	var compressor = express.compress({threshold:10,filter:function () { return true; }});
	var staticFolder = express.static('unpacked')
	app.use('/unpacked',function custom(req,res,next) {
		compressor(req,res,function () {
			staticFolder(req,res,next);
		});
	});*
}*/
function goOnline() {
	Tournament.core.commonLock.writeLock(function (release) {
		Tournament.core.resetTimer(function () {
			release();
			internalHttpServer.goOnline();
			secureServer.listen(12346);
			server.listen(12345);
			cactiServer.listen(1246);
			log('server up');
		});
	});
}
function pullActiveVersions() {
	var req = https.request({host:'chipuppoker.com',path:'/sync/getActive',auth:'sync:'+config.syncpassword},function (res) {
		res.setEncoding('utf8');
		res.on('data',function (chunk) {
			console.log('chunk',chunk);
		});
		res.on('end',function () {
			console.log('done');
		});
		res.on('error',function (err) {
			console.log('http error sending activate:',err);
		});
	});
	req.end();
}

/*MongoClient.connect('mongodb://localhost:27017/poker',function (err,db) {
	if (err) {
		console.log(err);
		process.exit(1);
	}*/
	Club.init(activeGames,regexLimits);
	Game.init(activeGames);
	//process.send({msg:'connected'});

	/*db.createCollection('fetchQueue',{capped:true,size:128 * 1024},function (err,collection) {
		assert.ok(collection instanceof Collection);
		FetchQueue = collection;
	});*/
	profiler.setup(models.PokerProfile);
pullActiveVersions();

	internalHttpServer = require('./httpServer').initHttpServer();

	// FIXME, improve the defaults later?
	var prefix;
	if (config.diffserver) prefix='dev';
	else prefix = 'live';
	models.Config.findOne({_id:prefix+'_installerid'},function (err,row) {
		assert.ifError(err);
		if (row) {
			mdb.models.Installer.findOne({_id:row.value},function (err,row) {
				if (row) {
					sharedconfig.latestVersion = row.version;
				}
			});
		}
	});
	models.Config.findOne({_id:prefix+'_debuginstallerid'},function (err,debugrow) {
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
		// FIXME, redo this
		assert(regexLimits);
		user.UserInit(regexLimits,goOnline);
	}

//});
function log(format) {
	var out = Array.prototype.slice.call(arguments),obj;
	if (format.indexOf('%') != -1) {
		out = [ util.format.apply(util,out) ];
	}
	process.send({type:'global',ts:new Date().toString(),msg:out.join(' ')});
	obj = new mdb.models.DebugLogs({type:'global',msg:out.join(' ')});
	obj.save(function () {});
}
global.log = log;
var server = net.createServer(function listener(socket) {
	var handler = new user.ClientSocket(socket);
});
var options = {
	key: fs.readFileSync('key.pem'),
	cert: fs.readFileSync('cert.pem')
};

var secureServer = tls.createServer(options,function listener(socket) {
	var handler = new user.ClientSocket(socket);
});
var cactiServer = require('net').createServer(stats_server);


function toMongoId(buf) {
	return new ObjectID(buf.toString('hex'));
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
function cactiStats() {
	var mem = process.memoryUsage();
	var data = { hands:Game.hands };
	var msg = [];
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
