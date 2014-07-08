'use strict';
var fs = require("fs");
var Protobuf = require("node-protobuf").Protobuf;
var ProtobufUtil = require('./ProtobufUtil');
var mitm = require('./man_in_the_middle');
var codes = require('./ServerCodes.js');
var MongoClient = require('mongodb').MongoClient;

var schema = 'Poker.RpcMessage';
var pb = new Protobuf(fs.readFileSync("../message.desc"));
var pu = new ProtobufUtil(pb, schema);

var realServerPort = 12345;
var fakeServerPort = 55555;

MongoClient.connect('mongodb://127.0.0.1:27017/test', function (err, db) {
	if (err) throw err;

	var mitmServer = mitm.createManInTheMiddleServer(pu, realServerPort, recordCallback);
	mitmServer.listen(fakeServerPort);

	function recordCallback(methodId, args, type, socketId, direction) {
		console.log(methodId.toString() + ', ' + args.toString() + ', ' + type + ', ' + socketId + ', ' + direction);
		db.collection('mitm').insert({
			methodId: methodId,
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

