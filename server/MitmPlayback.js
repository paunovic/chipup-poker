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
	debugger;
	var allConnected = true;
	this.socketIds.forEach(function(socketId) {
		if (!this.sockets[socketId]) allConnected = false;
	}, this);

	if (allConnected) this._sendRequests();
};


MitmPlayback.prototype._sendRequests = function() {
	debugger;
	var request = this.requests[this.currentRequestNumber];

	while (request.direction === directions.C2S) {
		var methodId = this.serverCodes[request.method];
		var encodedMessage = this.protobufUtil.encode(methodId, request.args.buffer, request.type);
		this._writeMessageAndTestIfItsOk(encodedMessage, request.socketId);
		request = this.requests[++this.currentRequestNumber];
	}
};


MitmPlayback.prototype._writeMessageAndTestIfItsOk = function (encodedMessage, socketId) {
	debugger;
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
};


MitmPlayback.prototype._checkIfNextRequestsMatch = function (socketId) {
	debugger;
	return function (err, methodId, args, type) {
		debugger;
		if (err) throw err;
					
		for (var i = this.currentRequestNumber; i < this.requests.length; i++) {
			if (requests[i].socketId !== socketId) 
				continue;
	
			try {
				this._checkIfSingleRequestMatch(methodId, args, type, i);
				var methodName = this.serverCodes.reverse[methodId];
				console.log("Request #" + this.currentRequestNumber + " match! " + methodName);
				++this.currentRequestNumber;
				this._sendRequests();
				return;
			} catch (e) {
				if (this.requests[i + 1].direction !== directions.S2C)
					this._checkIfSingleRequestMatch(methodId, args, type, this.currentRequestNumber); // this will throw the original request mismatch error
			}
		}
	};
};


MitmPlayback.prototype._checkIfSingleRequestMatch = function (methodId, args, type, requestNum) {
	// find socket id by iterating thru sockets array and see which one matches the current socket
	var currentRequestInfo = 'SocketId' + socketId + " request #" + requestNum;

	var requestFromDb = requests[requestNum];

	if (requestFromDb.direction !== directions.S2C)
		throw new Error('Received response from the server out of order!');

	var methodName = serverCodes.reverse[methodId];

	if (methodName !== requestFromDb.method)
		throw new Error('Methods do not match! ' + currentRequestInfo + ' ' + methodName + ' vs ' + requestFromDb.method);

	var argsFromDb = requestFromDb.args.buffer;

	if (args.toString('hex') !== argsFromDb.toString('hex')) {
		if (!methodToTypeMap[methodName])
			throw new Error('schema for code ' + methodName + ' not known');

		var argsParsed = makeArgsAndSanatize();
		var difference = diff(argsParsed.fromServer, argsParsed.fromDb);
		console.log("A-server, B-from db\n%j\n%j\n%j\n", argsParsed.fromServer,argsParsed.fromDb,difference);
	}

	if (type !== requestFromDb.type)
		throw new Error('Type param do not match! ' + currentRequestInfo);
};


MitmPlayback.prototype._makeArgsAndSanatize = function () {
	var argsParsed = pb.Parse(args, methodToTypeMap[methodName]);
	var argsFromDbParsed = pb.Parse(argsFromDb, methodToTypeMap[requestFromDb.method]);

	if (methodId === serverCodes.srLoginReply) {
		argsParsed = sanitizeLoginReply(argsParsed);
		argsFromDbParsed = sanitizeLoginReply(argsFromDbParsed);
	} else if (methodId === serverCodes.srTableStatsReply) {
		argsParsed = sanitizeTableStats(argsParsed);
		argsFromDbParsed = sanitizeTableStats(argsFromDbParsed);
	} else if (methodId === serverCodes.seGameChange) {
		argsParsed.lasthandid = argsFromDbParsed.lasthandid;
	} else if ([serverCodes.seTableStatus, codes.srTableSitOk].indexOf(methodId) !== -1) {
		argsParsed = sanitizeTableStatus(argsParsed);
		argsFromDbParsed = sanitizeTableStatus(argsFromDbParsed);
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
	var i,j;

	for (i = 0; i < args.reply.length; i++) {
		var reply = args.reply[i];

		for (j = 0; j < reply.playerstats.length; j++) {
			console.log(reply.playerstats[j]);
			delete reply.playerstats[j].userid;
			reply.playerstats[j].balance = 0;
			reply.playerstats[j].rakecontrib = 0;
			reply.playerstats[j].hands = 0;
			delete reply.playerstats[j].buyins;
			delete reply.playerstats[j].cashouts;
			reply.playerstats[j].secondsplayed = 0;
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

