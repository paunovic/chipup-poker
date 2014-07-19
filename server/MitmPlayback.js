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

	this.currentRequestNumber = 0;
	this.sockets = [];
};


MitmPlayback.prototype.WRONG_DIRECTION = 1; 
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
		console.log("%d\tOpened socket",socketId);
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
	var request = this.requests[this.currentRequestNumber];
	console.log('%d\t_sendRequests considering req#%d %j',request.socketId,this.currentRequestNumber,request);

	while (request.direction === directions.C2S) {
		var methodId = this.serverCodes[request.method];
		var encodedMessage = this.protobufUtil.encode(methodId, request.args.buffer, request.type);
		this._writeMessageAndTestIfItsOk(encodedMessage, request.socketId);
		console.log("%d\tSent request #%d, %s, %s",
			request.socketId,
			this.currentRequestNumber, 
			request.method, 
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
		var requestInfo = "request #" + this.currentRequestNumber + " socket id " + socketId 
			+ ", " + methodName;

		if (this._methodShouldBeIgnored(methodName)) {
			console.log('%d\tignoring ', socketId,requestInfo);
			return;
		}

		console.log('%d\t_checkIfRequestMatch called! %s',socketId,requestInfo);

		var response = this._checkIfSingleRequestMatch(methodId, args, type, this.currentRequestNumber, socketId);

		if (response.code === this.REQUESTS_MATCH) {
			console.log("%d\tMATCH, %s",socketId,requestInfo);
			this._continueToNextRequests();
			return;
		}
		else if (response.code === this.WRONG_DIRECTION 
		    || response.code === this.ARGS_DO_NOT_MATCH
		    || response.code === this.TYPE_DOES_NOT_MATCH) {
			throw new Error(response.explanation);
		}
		else if (response.code === this.METHODS_DO_NOT_MATCH
			|| response.code === this.SOCKETS_DO_NOT_MATCH) {
			// check if next requests match?
			for (var i = this.currentRequestNumber + 1; i < this.currentRequestNumber + 30; i++) {
				if (this.requests[i].socketId !== socketId) {
					console.log("%d\t\trequest from db #%d from db is for different socket (socketId %d), I'm skipping it",socketId,i,this.requests[i].socketId);
					continue;
				}

				console.log("%d\t\tchecking if %s can match request #%d from db, %j",socketId,methodName,i,this.requests[i]);
				response = this._checkIfSingleRequestMatch(methodId, args, type, i, socketId);
				
				if (response.code === this.REQUESTS_MATCH) {
					console.log("MATCH, " + requestInfo);
					this._continueToNextRequests();
					return;
				}
				else if (response.code === this.ARGS_DO_NOT_MATCH
					|| response.code === this.TYPE_DOES_NOT_MATCH) {
					throw new Error(response.explanation);
				} 
			}
			
			throw new Error("I've checked next requests and there is no match for " + requestInfo);
		}
		else {
			throw new Error('Unknown response code: ' + response.code);
		}
	};
};


MitmPlayback.prototype._continueToNextRequests = function () {
	++this.currentRequestNumber;
	console.log('%d\t_continueToNextRequests advanced to request %d',this.requests[this.currentRequestNumber].socketId,this.currentRequestNumber);
	this._sendRequests();
};

MitmPlayback.prototype._isServerToClientDirection = function (direction) {
	return direction === directions.S2C;
};

MitmPlayback.prototype._checkIfSingleRequestMatch = function (methodId, args, type, requestNum, socketId) {
	var requestFromDb = this.requests[requestNum];
	var methodName = this._getMethodName(methodId);
	var requestInfo = "SocketId " + socketId + " request #" + requestNum + ", method " + methodName + ' vs ' + requestFromDb.method;

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
	
	if (socketId !== requestFromDb.socketId) {
		return {
			code: this.SOCKETS_DO_NOT_MATCH,
			explanation: 'Sockets do not match! ' + requestInfo
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
			code: this.TYPE_DOES_NOT_MATCH,
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

