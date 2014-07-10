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
	}).toArray(function (err, requests) {
		if (err) console.warn(err.message);

		var socket = net.connect(port, host, function () {
			socket.on('error', function (e) {
				throw e;
			});

			var counter = 0;
			sendRequests();

			socket.on('data', pu.createOnDataListenerFn(checkIfRequestsMatch));
			
			function checkIfRequestsMatch(err, methodId, args, type) {
				if (err) throw err;
				var currentRequestInfo = 'SocketId' + socketId + " request #" + counter;

				var requestFromDb = requests[counter];

				if (requestFromDb.direction !== directions.S2C) 
					throw new Error('Received response from the server out of order!');
				
				var methodName = serverCodes.reverse[methodId];
				
				if (methodName !== requestFromDb.method) 
					throw new Error('Methods do not match! ' + currentRequestInfo);

				var argsFromDb = requestFromDb.args.buffer;

				if (util.inspect(args).substring(8) != util.inspect(argsFromDb).substring(12)) {
					debugger;
					var argsParsed = pb.Parse(args, methodToTypeMap[methodName]);
					argsParsed = zeroOutChips(argsParsed);
					//var argsJson = JSON.stringify(argsParsed, undefined, 2);
					var argsFromDbParsed = pb.Parse(argsFromDb, methodToTypeMap[requestFromDb.method]);
					argsFromDbParsed = zeroOutChips(argsFromDbParsed);
					//var argsFromDbJson = JSON.stringify(argsFromDbParsed, undefined, 2);
					
					var difference = diff(argsParsed, argsFromDbParsed);
					console.log("A-server, B-from db\n" + JSON.stringify(difference), undefined, 2);
		
					/*		
					if (argsJson !== argsFromDbParsed) {
						console.log("Args saved in the db:\n" + argsFromDbJson);
						console.log("Args I just got from the server:\n" + argsJson);
						throw new Error('Args do not match! SocketId' + socketId + " request #" + counter);
					}
					*/	
					//console.log("Args saved in the db: " + util.inspect(argsFromDbParsed));
					throw new Error('Args do not match! ' + currentRequestInfo);		
				}
				
				if (type !== requests[counter].type) 
					throw new Error('Type param do not match! ' + currentRequestInfo);

				console.log("Request #" + counter + " match!");

				++counter;
				sendRequests();
			}

			function sendRequests() {
				var request = requests[counter];

				while (request.direction === directions.C2S) {
					var methodId = serverCodes[request.method];
					var encodedMessage = pu.encode(methodId, request.args, request.type);
					writeMessageAndTestIfItsOk(encodedMessage, socket);
					++counter;
				}
			}
		});
	});
});

function zeroOutChips(args) {
  args.status.self.chips = 0;
  
  for(var i = 0; i < args.status.users.length; i++) 
	  args.status.users[i].chips = 0;	  
	  
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