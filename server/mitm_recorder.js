'use strict';
/*
How to use:
1) empty gameState collection from poker db
2) start server (node master.js)
3) run this file
4) run bots, node testclient fastbot set1 localhost 55555, (55555) is the fake server port, se below

* if you want to run again, stop the server, empty gameState and then run the server again

*/
var fs = require("fs");
var Protobuf = require("node-protobuf").Protobuf;
var ProtobufUtil = require('./ProtobufUtil');
var mitm = require('./mitm');
var MongoClient = require('mongodb').MongoClient;
var serverCodes = require('./ServerCodes.js');

var pb = new Protobuf(fs.readFileSync("../message.desc"));
var pu = new ProtobufUtil(pb, 'Poker.RpcMessage');

var realServerPort = 12345;
var fakeServerPort = 55555;

MongoClient.connect('mongodb://127.0.0.1:27017/test', function (err, db) {
	if (err) throw err;

	db.collection('mitm').remove({}, function (err, result) {
		if (err) throw err;

		var mitmServer = mitm.createManInTheMiddleServer(pu, realServerPort, recordCallback);
		mitmServer.listen(fakeServerPort);
	});

	function recordCallback(methodId, args, type, socketId, direction) {
		db.collection('mitm').insert({
			method: serverCodes.reverse[methodId],
			args: args,
			type: type,
			socketId: socketId,
			direction: direction,
			timestamp: Date.now()
		}, function (err, inserted) {
			if (err) console.warn(err.message);
		});
	}
});
