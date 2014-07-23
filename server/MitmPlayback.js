"use strict";
var util = require("util");
var diff = require('deep-diff');
var net = require('net');
var directions = require('./directions');

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

	this.sockets = [];
};

MitmPlayback.prototype.METHODS_DO_NOT_MATCH = 2;
MitmPlayback.prototype.ARGS_DO_NOT_MATCH = 3;
MitmPlayback.prototype.TYPE_DOES_NOT_MATCH = 4;
MitmPlayback.prototype.SOCKETS_DO_NOT_MATCH = 5;
MitmPlayback.prototype.REQUESTS_MATCH = 6;

MitmPlayback.prototype.IGNORE_METHODS = ["scPing", "srPong", "srTableStatsReply", "seGameChange"];

MitmPlayback.prototype.startPlayback = function() {
	this.socketIds.forEach(function(socketId) {
		this._openNewSocket(socketId);
	}, this);
};

MitmPlayback.prototype._openNewSocket = function (socketId) {
	var self = this;
	var socket = net.connect(this.port, this.host, function () {
		socket.on('error', function (err) { throw err; });
		socket.on('data', self.protobufUtil.createOnDataListenerFn(self._checkIfRequestMatch(socketId).bind(self)));
		self.sockets[socketId] = socket;
		console.log("Opened socket %d", socketId);
		self._checkIfAllSocketsAreConnected();
	});
};

MitmPlayback.prototype._checkIfAllSocketsAreConnected = function() {
	var allConnected = true;
	this.socketIds.forEach(function(socketId) {
		if (!this.sockets[socketId]) allConnected = false;
	}, this);

	if (allConnected) this._sendRequests();
};

MitmPlayback.prototype._sendRequests = function() {
	while (this.requests[0].direction === directions.C2S) {
		var request = this.requests.shift();
		var methodId = this._getMethodId(request.method);
		var encodedMessage = this.protobufUtil.encode(methodId, request.args.buffer, request.type);
		this._writeMessageAndTestIfItsOk(encodedMessage, request.socketId);
		console.log("Sent request %s, socketId %d %s",
			request.method, 
			request.socketId,
			this._parseLoginParams(methodId, request.args.buffer)
		);
	}
};

MitmPlayback.prototype._parseLoginParams = function (methodId, args) {
	return methodId === this.serverCodes.scLogin ? JSON.stringify(this.protobuf.Parse(args, 'Poker.LoginParams')) : '';
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
};

MitmPlayback.prototype._getMethodName = function (methodId) {
	return this.serverCodes.reverse[methodId];
};

MitmPlayback.prototype._methodShouldBeIgnored = function (methodName) {
	return this.IGNORE_METHODS.indexOf(methodName) !== -1;
};

MitmPlayback.prototype._getRequest = function (position) {
	return this.requests.slice(position, position + 1)[0];
};

MitmPlayback.prototype._deleteRequest = function (position) {
	this.requests.splice(position, 1);
};

MitmPlayback.prototype._makeRequestObject = function (methodName, args, socketId, type) {
	return {
		method: methodName,
		args: { buffer: args },
		socketId: socketId,
		type: type
	};
};

MitmPlayback.prototype._testIfRequestsMatch = function(receivedRequest, position) {
	var requestInfo = receivedRequest.method + ", socket id " + receivedRequest.socketId;
	console.log(requestInfo + ' _testIfRequestsMatch called!');
	var requestFromDb = this._getRequest(position);

	if ( ! this._isServerToClientDirection(requestFromDb.direction)) {
		console.log("\t%s from db has wrong direction, checking next requests from db...", requestFromDb.method);
		return this._testIfRequestsMatch(receivedRequest, ++position);
	}

	var result = this._compareRequests(receivedRequest, requestFromDb);

	if (result.code === this.REQUESTS_MATCH) {
		console.log(requestInfo + " MATCH");
		this._deleteRequest(position);
		this._sendRequests();
		return;
	}
	else if (result.code === this.ARGS_DO_NOT_MATCH
		|| result.code === this.TYPE_DOES_NOT_MATCH) {
		throw new Error(result.explanation);
	}
	else if (result.code === this.METHODS_DO_NOT_MATCH
		|| result.code === this.SOCKETS_DO_NOT_MATCH) {
		console.log("\t" + result.explanation);
		return this._testIfRequestsMatch(receivedRequest, ++position);
	}
}


MitmPlayback.prototype._checkIfRequestMatch = function (socketId) {
	return function (err, methodId, args, type) {
		if (err) throw err;

		var methodName = this._getMethodName(methodId);
		var requestInfo = methodName + ", socket id " + socketId;

		console.log(requestInfo + ' _checkIfRequestMatch called! ');

		if (this._methodShouldBeIgnored(methodName)) {
			console.log(requestInfo + 'IGNORED ');
			return;
		}

		var receivedRequest = this._makeRequestObject(methodName, args, socketId, type);
		this._testIfRequestsMatch(receivedRequest, 0);
	};
};

MitmPlayback.prototype._isServerToClientDirection = function (direction) {
	return direction === directions.S2C;
};

MitmPlayback.prototype._compareRequests = function (receivedRequest, requestFromDb) {
	var requestInfo = "socketId " + receivedRequest.socketId + ", " + receivedRequest.method + ' vs ' + requestFromDb.method;

	if (receivedRequest.method !== requestFromDb.method) {
		return {
			code: this.METHODS_DO_NOT_MATCH,
			explanation: 'Methods do not match! ' + requestInfo
		};
	}
	
	if (receivedRequest.socketId !== requestFromDb.socketId) {
		return {
			code: this.SOCKETS_DO_NOT_MATCH,
			explanation: 'Sockets do not match! ' + requestInfo
		};
	}

	if (receivedRequest.args.buffer.toString('hex') !== requestFromDb.args.buffer.toString('hex')) {
		if (!this.methodToTypeMap[receivedRequest.method])
			throw new Error('Schema for code ' + receivedRequest.method + ' not known');

		var argsParsed = this._makeArgsAndSanatize(receivedRequest, requestFromDb);
		var difference = diff(argsParsed.fromDb, argsParsed.fromServer);
		
		if (difference) {
			var message = util.format("Args do not match! %s\nleft=db right=server\nserver: %j\ndb: %j\ndiff: %j", requestInfo, argsParsed.fromServer, argsParsed.fromDb, difference);

			return {
				code: this.ARGS_DO_NOT_MATCH,
				explanation: message
			};
		}
	}

	if (receivedRequest.type !== requestFromDb.type) {
		return {
			code: this.TYPE_DOES_NOT_MATCH,
			explanation: 'Type param does not match! ' + requestInfo
		};
	}

	return {
		code: this.REQUESTS_MATCH,
		explanation: ''
	};
};


MitmPlayback.prototype._getMethodId = function (methodName) {
	return this.serverCodes[methodName];
};


MitmPlayback.prototype._makeArgsAndSanatize = function (receivedRequest, requestFromDb) {
	debugger;
	var receivedArgsParsed = this.protobuf.Parse(receivedRequest.args.buffer, this.methodToTypeMap[receivedRequest.method]);
	var argsFromDbParsed = this.protobuf.Parse(requestFromDb.args.buffer, this.methodToTypeMap[requestFromDb.method]);
	var receivedMethodId = this._getMethodId(receivedRequest.method);

	return this._sanatizeArgs(argsFromDbParsed, receivedArgsParsed, receivedMethodId);
};


MitmPlayback.prototype._sanatizeArgs = function (argsFromDbParsed, receivedArgsParsed, receivedMethodId) {
	if (receivedMethodId === this.serverCodes.srLoginReply) {
		receivedArgsParsed = this._sanitizeLoginReply(receivedArgsParsed);
		argsFromDbParsed = this._sanitizeLoginReply(argsFromDbParsed);
	} 
	else if (receivedMethodId === this.serverCodes.srTableStatsReply) {
		receivedArgsParsed = this._sanitizeTableStats(receivedArgsParsed);
		argsFromDbParsed = this._sanitizeTableStats(argsFromDbParsed);
	} 
	else if (receivedMethodId === this.serverCodes.seGameChange) {
		receivedArgsParsed.lasthandid = argsFromDbParsed.lasthandid;
	} 
	else if ([this.serverCodes.seTableStatus, codes.srTableSitOk].indexOf(methodId) !== -1) {
		receivedArgsParsed = this._sanitizeTableStatus(receivedArgsParsed);
		argsFromDbParsed = this._sanitizeTableStatus(argsFromDbParsed);
	}

	return {fromServer: receivedArgsParsed, fromDb: argsFromDbParsed};
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

