/*
TODO:
1. write code to wipe gameState collection on the beginning, you need to switch to 'poker' db first, or open new connection
2. add code to control master.js to start/restart it everytime you run pinning tests and when you wipe gameState
3. random generator?
*/
'use strict';
var net = require('net');
var MongoClient = require('mongodb').MongoClient;
var fs = require("fs");
var util = require("util");
var Protobuf = require("node-protobuf").Protobuf;
var ProtobufUtil = require('./ProtobufUtil');
var directions = require('./directions');
var serverCodes = require('./ServerCodes.js');
var methodToTypeMap = require("./method_to_type_map");
var diff = require("./object_diff");

var schema = 'Poker.RpcMessage';
var pb = new Protobuf(fs.readFileSync("../message.desc"));
var pu = new ProtobufUtil(pb, schema);
var port = process.argv[3] ? process.argv[3] : 12345;
var host = process.argv[2] ? process.argv[2] : 'localhost';
var socketId = 0;

MongoClient.connect('mongodb://127.0.0.1:27017/test', function (err, db) {
	if (err) throw err;

	var mitmCollection = db.collection('mitm');

	mitmCollection.find({
		$query: { socketId: socketId },
		$orderby: { timestamp : 1 }
	}).toArray(replayAndTestAll);
});

function replayAndTestAll(err, requests) {
	if (err) console.warn(err.message);

	var socket = net.connect(port, host, function () {
		socket.on('error', function (e) {
			throw e;
		});

		var counter = 0;
		sendRequests();

		socket.on('data', pu.createOnDataListenerFn(function (err, methodId, args, type) {
			if (err) throw err;
						
			for (var i = counter; i < requests.length; i++) {
				try {
					checkIfRequestMatch(err, methodId, args, type, i);
					console.log("Request #" + counter + " match!");
					++counter;
					sendRequests();
					return;
				} catch (e) {
					if (requests[i + 1].direction !== directions.S2C)
						checkIfRequestMatch(err, methodId, args, type, counter); // this will throw the original request mismatch error
				}
			}
		}));

		function checkIfRequestMatch(methodId, args, type, requestNum) {
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
				console.log("A-server, B-from db\n%j", difference, undefined, 2);

				if (difference.length != 0)
					throw new Error('Args do not match! ' + methodName + ' ' + currentRequestInfo);
			}

			if (type !== requestFromDb.type)
				throw new Error('Type param do not match! ' + currentRequestInfo);

			function makeArgsAndSanatize() {
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
			}
		}

		function sendRequests() {
			var request = requests[counter];

			while (request.direction === directions.C2S) {
				var methodId = serverCodes[request.method];
				var encodedMessage = pu.encode(methodId, request.args.buffer, request.type);
				writeMessageAndTestIfItsOk(encodedMessage, socket);
				request = requests[++counter];
			}
		}
	});
}

function sanitizeLoginReply(args) {
	var i,j;
	args.status.self.chips = 0;
	
	for(i = 0; i < args.status.users.length; i++) 
		args.status.users[i].chips = 0;
	
	for (i=0; i<args.status.clubs.length; i++) {
		var club = args.status.clubs[i];
		for (j=0; j<club.members.length; j++) {
			club.members[j].club_balance = 0;
		}
	}
	for (i=0; i<args.status.games.length; i++) {
		args.status.games[i].lasthandid = 0;
	}
	return args;
}
function sanitizeTableStats(args) {
	var i,j;
	for (i=0; i<args.reply.length; i++) {
		var reply = args.reply[i];
		for (j=0; j<reply.playerstats.length; j++) {
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
	for (i=0; i<args.players.length; i++) {
		args.players[i].chips = 0;
	}
	for (i=0; i<args.club_stats.length; i++) {
		var cs = args.club_stats[i];
		for (j=0; j<cs.player_stats.length; j++) {
			cs.player_stats[j].club_balance = 0;
		}
	}
	return args;
}
function sanitizeTableStatus(args) {
	args.rotation = 0;
	args.total_balance = 0;
	return args;
}

function writeMessageAndTestIfItsOk(encodedMessage, socket) {
	if (!socket.write(encodedMessage) && socket._handle) {
		console.log(
			'partial message write %d %s',
			socket.bufferSize,
			util.inspect({
				a: socket._handle.writeQueueSize,
				b: socket._writableState.length
			})
		);
	}

	if (socket._writableState.length > (256 * 1024))
		throw new Error('send overflow');
}