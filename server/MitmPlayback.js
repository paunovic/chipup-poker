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
		console.log("Opened socket id " + socketId);
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
	console.log('_sendRequests currentRequestNumber=%d',this.currentRequestNumber);
	var request = this.requests[this.currentRequestNumber];

	while (request.direction === directions.C2S) {
		var methodId = this.serverCodes[request.method];
		var encodedMessage = this.protobufUtil.encode(methodId, request.args.buffer, request.type);
		this._writeMessageAndTestIfItsOk(encodedMessage, request.socketId);
		console.log(
		  "Sent request #%d, %s on socket id %d, %s", 
		  this.currentRequestNumber, 
		  request.method, 
		  request.socketId, 
		  this._parseLoginParams(methodId,request.args.buffer)
		 );
		request = this.requests[++this.currentRequestNumber];
	}
};

MitmPlayback.prototype._parseLoginParams = function (methodId, args) {
	return methodId === this.serverCodes.scLogin ? JSON.stringify(this.protobuf.Parse(args, 'Poker.LoginParams')) : '';
}


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


MitmPlayback.prototype._checkIfRequestMatch = function (socketId) {
	return function (err, methodId, args, type) {
		if (err) throw err;

		var methodName = this._getMethodName(methodId);
		if (this._methodShouldBeIgnored(methodName)) {
			console.log('ignoring incoming %s',methodName);
			return;
		}
		var requestInfo = "request #" + this.currentRequestNumber + " socket id " + socketId 
			+ ", " + methodName;


		console.log('_checkIfRequestMatch called! ' + requestInfo);

		
		if (this._methodShouldBeIgnored(methodName)) {
			this._continueToNextRequests();
			return;
		} 

		var response = this._checkIfSingleRequestMatch(methodId, args, type, this.currentRequestNumber);

		console.log('response code %d',response.code);

		if (response.code === this.REQUESTS_MATCH) {
			console.log("MATCH, " + requestInfo);
			this._continueToNextRequests();
			return;
		}
		else if (response.code === this.WRONG_DIRECTION 
		    || response.code === this.ARGS_DO_NOT_MATCH
		    || response.code === this.TYPE_DOES_NOT_MATCH) {
			throw new Error(response.explanation);
		}
		else if (response.code === this.METHODS_DO_NOT_MATCH) {
			// test if next requests match?
			for (var i = this.currentRequestNumber + 1; i < this.requests.length; i++) {
				if (this.requests[i].socketId !== socketId)
					continue;
				
				response = this._checkIfSingleRequestMatch(methodId, args, type, i);
				console.log('response code %d again',response.code);
				
				if (response.code === this.REQUESTS_MATCH) {
					console.log("MATCH, " + requestInfo);
					this._continueToNextRequests();
					return;
				}
				else if (response.code === this.WRONG_DIRECTION 
					|| response.code === this.ARGS_DO_NOT_MATCH
					|| response.code === this.TYPE_DOES_NOT_MATCH) {
					throw new Error("NO MATCH, " + requestInfo);
				} else {
					console.log('should this even happen?');
				}
			}
		}
		else {
			throw new Error('Unknown response code: ' + response.code);
		}
	};
};


MitmPlayback.prototype._continueToNextRequests = function () {
	++this.currentRequestNumber;
	this._sendRequests();
};

MitmPlayback.prototype._isServerToClientDirection = function (direction) {
	return direction === directions.S2C;
};

MitmPlayback.prototype.WRONG_DIRECTION = 1; // these should go directly on MitmPlayback, not the prototype
MitmPlayback.prototype.METHODS_DO_NOT_MATCH = 2;
MitmPlayback.prototype.ARGS_DO_NOT_MATCH = 3;
MitmPlayback.prototype.TYPE_DOES_NOT_MATCH = 4;
MitmPlayback.prototype.REQUESTS_MATCH = 5;

MitmPlayback.prototype._checkIfSingleRequestMatch = function (methodId, args, type, requestNum) {
	var requestFromDb = this.requests[requestNum];
	var methodName = this._getMethodName(methodId);
	var requestInfo = "request #" + requestNum + ", method " + methodName + ' vs ' + requestFromDb.method;

	if ( ! this._isServerToClientDirection(requestFromDb.direction)) {
		return {
			code: this.WRONG_DIRECTION,
			explanation: 'This request has a direction client to server, ' + requestInfo
		};
	}

	if (methodName !== requestFromDb.method) {
		return {
			code: this.METHODS_DO_NOT_MATCH,
			explanation: 'Methods do not match! ' + requestInfo
		};
	}

	var argsFromDb = requestFromDb.args.buffer;

	if (args.toString('hex') !== argsFromDb.toString('hex')) {
		if (!this.methodToTypeMap[methodName])
			throw new Error('Schema for code ' + methodName + ' not known');

		var argsParsed = this._makeArgsAndSanatize(args, methodId, argsFromDb, requestFromDb);
		var difference = diff(argsParsed.fromDb,argsParsed.fromServer);
		
		if (difference) {
			var message =  util.format("Args do not match! %s\nleft=db right=server\nserver: %j\ndb: %j\ndiff: %j",requestInfo,argsParsed.fromServer,argsParsed.fromDb,difference);

			return {
				code: this.ARGS_DO_NOT_MATCH,
				explanation: message
			};
		}
	}

	if (type !== requestFromDb.type) {
		return {
			code: TYPE_DOES_NOT_MATCH,
			explanation: 'Type param does not match! ' + requestInfo +' vs ' + requestFromDb.method
		};
	}

	return {
		code: this.REQUESTS_MATCH,
		explanation: ''
	};
};


MitmPlayback.prototype._makeArgsAndSanatize = function (args, methodId, argsFromDb, requestFromDb) {
	var methodName = this._getMethodName(methodId);
	var argsParsed = this.protobuf.Parse(args, this.methodToTypeMap[methodName]);
	var argsFromDbParsed = this.protobuf.Parse(argsFromDb, this.methodToTypeMap[requestFromDb.method]);

	if (methodId === this.serverCodes.srLoginReply) {
		argsParsed = this._sanitizeLoginReply(argsParsed);
		argsFromDbParsed = this._sanitizeLoginReply(argsFromDbParsed);
	} 
	else if (methodId === this.serverCodes.srTableStatsReply) {
		argsParsed = this._sanitizeTableStats(argsParsed);
		argsFromDbParsed = this._sanitizeTableStats(argsFromDbParsed);
	} 
	else if (methodId === this.serverCodes.seGameChange) {
		argsParsed.lasthandid = argsFromDbParsed.lasthandid;
	} 
	else if ([this.serverCodes.seTableStatus, codes.srTableSitOk].indexOf(methodId) !== -1) {
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

