"use strict";
var util = require("util");
var directions = require('./directions');
var diff = require('deep-diff');
var net = require('net');

module.exports = MitmPlayback;

function MitmPlayback(config) {
	this.requests = config.requests;
	this.host = config.host;
	this.port = config.port;
	this.protobuf = config.protobuf;
	this.protobufUtil = config.protobufUtil;
	this.serverCodes = config.serverCodes;
	this.methodToTypeMap = config.methodToTypeMap;
	this.socketIds = config.socketIds;

	this.currentRequestNumber = 0;
	this.sockets = [];
};


MitmPlayback.prototype.IGNORE_METHODS = ["scPing", "srPong", "srTableStatsReply"];


MitmPlayback.prototype.startPlayback = function() {
	this.socketIds.forEach(function(socketId) {
		this._openNewSocket(socketId, this._checkIfAllSocketsAreConnected.bind(this));
	}, this);
};


MitmPlayback.prototype._openNewSocket = function (socketId, callback) {
	var self = this;
	var socket = net.connect(this.port, this.host, function () {
		socket.on('error', function (err) { throw err; });
		socket.on('data', self.protobufUtil.createOnDataListenerFn(self._checkIfNextRequestsMatch(socketId).bind(self)));
		self.sockets[socketId] = socket;
		console.log("Opened socket id " + socketId);
		callback();
	});
};


MitmPlayback.prototype._checkIfAllSocketsAreConnected = function(callback) {
	var allConnected = true;
	this.socketIds.forEach(function(socketId) {
		if (!this.sockets[socketId]) allConnected = false;
	}, this);

	if (allConnected) this._sendRequests();
};


MitmPlayback.prototype._sendRequests = function() {
	var request = this.requests[this.currentRequestNumber];

	while (request.direction === directions.C2S) {
		var methodId = this.serverCodes[request.method];
		var encodedMessage = this.protobufUtil.encode(methodId, request.args.buffer, request.type);
		this._writeMessageAndTestIfItsOk(encodedMessage, request.socketId);
		console.log("Sent request #" + this.currentRequestNumber);
		request = this.requests[++this.currentRequestNumber];
	}
};


MitmPlayback.prototype._writeMessageAndTestIfItsOk = function (encodedMessage, socketId) {
	var socket = this.sockets[socketId];

	if (!socket.write(encodedMessage) && socket._handle) {
		console.log(
			'partial message write %d %s',
			this.socket.bufferSize,
			util.inspect({
				a: socket._handle.writeQueueSize,
				b: socket._writableState.length
			})
		);
	}

	if (socket._writableState.length > (256 * 1024))
		throw new Error('Send overflow!');
		
	console.log("Sent message on socket id " + socketId);
};


MitmPlayback.prototype._checkIfNextRequestsMatch = function (socketId) {
	return function (err, methodId, args, type) {
		if (err) throw err;

		var methodName = this.serverCodes.reverse[methodId];
		if (this.IGNORE_METHODS.indexOf(methodName) !== -1) return;
					
		for (var i = this.currentRequestNumber; i < this.requests.length; i++) {
			if (this.requests[i].socketId !== socketId) 
				continue;
	
			try {
				this._checkIfSingleRequestMatch(methodId, args, type, i);
				console.log("Received request #" + this.currentRequestNumber + ", match! " + methodName);
				++this.currentRequestNumber;
				this._sendRequests();
				return;
			} catch (e) {
				console.log(e.message);
				if (this.requests[i + 1].direction !== directions.S2C)
					this._checkIfSingleRequestMatch(methodId, args, type, this.currentRequestNumber); // this will throw the original request mismatch error
			}
		}
	};
};


MitmPlayback.prototype._checkIfSingleRequestMatch = function (methodId, args, type, requestNum) {

	var currentRequestInfo = "request #" + requestNum;
	var requestFromDb = this.requests[requestNum];

	if (requestFromDb.direction !== directions.S2C)
		throw new Error('Received response from the server out of order!');

	var methodName = this.serverCodes.reverse[methodId];

	if (methodName !== requestFromDb.method)
		throw new Error('Methods do not match! ' + currentRequestInfo + ' ' + methodName + ' vs ' + requestFromDb.method);

	var argsFromDb = requestFromDb.args.buffer;

	if (args.toString('hex') !== argsFromDb.toString('hex')) {
		debugger;
		if (!this.methodToTypeMap[methodName])
			throw new Error('schema for code ' + methodName + ' not known');

		var argsParsed = this._makeArgsAndSanatize(args, methodId, argsFromDb, requestFromDb);
		var difference = diff(argsParsed.fromServer, argsParsed.fromDb);
		console.log("A-server, B-from db\n%j\n%j\n%j\n", argsParsed.fromServer, argsParsed.fromDb, difference);
	}

	if (type !== requestFromDb.type)
		throw new Error('Type param do not match! ' + currentRequestInfo);
};


MitmPlayback.prototype._makeArgsAndSanatize = function (args, methodId, argsFromDb, requestFromDb) {
	debugger;
	var methodName = this.serverCodes.reverse[methodId];
	var argsParsed = this.protobuf.Parse(args, this.methodToTypeMap[methodName]);
	var argsFromDbParsed = this.protobuf.Parse(argsFromDb, this.methodToTypeMap[requestFromDb.method]);

	if (methodId === this.serverCodes.srLoginReply) {
		argsParsed = this._sanitizeLoginReply(argsParsed);
		argsFromDbParsed = this._sanitizeLoginReply(argsFromDbParsed);
	} else if (methodId === this.serverCodes.srTableStatsReply) {
		argsParsed = this._sanitizeTableStats(argsParsed);
		argsFromDbParsed = this._sanitizeTableStats(argsFromDbParsed);
	} else if (methodId === this.serverCodes.seGameChange) {
		argsParsed.lasthandid = argsFromDbParsed.lasthandid;
	} else if ([this.serverCodes.seTableStatus, codes.srTableSitOk].indexOf(methodId) !== -1) {
		argsParsed = this._sanitizeTableStatus(argsParsed);
		argsFromDbParsed = this._sanitizeTableStatus(argsFromDbParsed);
	}
	return {fromServer: argsParsed, fromDb: argsFromDbParsed};
};


MitmPlayback.prototype._sanitizeLoginReply = function (args) {
	var i,j;
	args.status.self.chips = 0;
	
	for(i = 0; i < args.status.users.length; i++) 
		args.status.users[i].chips = 0;
	
	for (i = 0; i < args.status.clubs.length; i++) {
		var club = args.status.clubs[i];

		for (j = 0; j < club.members.length; j++) 
			club.members[j].club_balance = 0;	
	}

	for (i = 0; i < args.status.games.length; i++) 
		args.status.games[i].lasthandid = 0;
	
	return args;
};


MitmPlayback.prototype._sanitizeTableStats = function (args) {
	var i, j;

	for (i = 0; i < args.reply.length; i++) {
		var reply = args.reply[i];

		for (j = 0; j < reply.playerStats.length; j++) {
			console.log(reply.playerStats[j]);
			delete reply.playerStats[j].userid;
			reply.playerStats[j].balance = 0;
			reply.playerStats[j].rakecontrib = 0;
			reply.playerStats[j].hands = 0;
			delete reply.playerStats[j].buyins;
			delete reply.playerStats[j].cashouts;
			reply.playerStats[j].secondsplayed = 0;
		}

		reply.hands = 0;
	}

	for (i = 0; i < args.players.length; i++) 
		args.players[i].chips = 0;
	
	for (i = 0; i < args.club_stats.length; i++) {
		var cs = args.club_stats[i];

		for (j = 0; j < cs.player_stats.length; j++) 
			cs.player_stats[j].club_balance = 0;
	}
	return args;
};


MitmPlayback.prototype._sanitizeTableStatus = function (args) {
	args.rotation = 0;
	args.total_balance = 0;
	return args;
};

