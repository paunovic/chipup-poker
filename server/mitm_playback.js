/*
How to use:
1) empty gameState collection from poker db
2) start server (node master.js)
3) run this file

* if you want to run again, stop the server, empty gameState and then run the server again

TODO:
1. add code to control master.js to start/restart it everytime you run pinning tests and when you wipe gameState
2. random generator?
*/
'use strict';
var net = require('net');
var MongoClient = require('mongodb').MongoClient;
var fs = require("fs");
var Protobuf = require("node-protobuf").Protobuf;
var assert = require('assert');

var ProtobufUtil = require('./ProtobufUtil');
var serverCodes = require('./ServerCodes.js');
var methodToTypeMap = require("./method_to_type_map");
var MitmPlayback = require("./MitmPlayback");

var schema = 'Poker.RpcMessage';
var pb = new Protobuf(fs.readFileSync("../message.desc"));
var pu = new ProtobufUtil(pb, schema);
var port = process.argv[3] ? process.argv[3] : 12345;
var host = process.argv[2] ? process.argv[2] : 'localhost';

MongoClient.connect('mongodb://127.0.0.1:27017/poker', function (err, db) {
	assert.ifError(err);
	db.collection('gameState').remove(function(err) {
		assert.ifError(err);
		MongoClient.connect('mongodb://127.0.0.1:27017/test', function (err, db) {
			assert.ifError(err);
			var mitm = db.collection('mitm');
			mitm.distinct('socketId', function(err, socketIds) {
				assert.ifError(err);
				mitm.find({method:{$nin:MitmPlayback.prototype.IGNORE_METHODS}}).sort({ _id : 1 }).toArray(function (err, requests) {
					assert.ifError(err);
					var config = {
						requests: requests,
						host: host,
						port: port,
						protobuf: pb,
						protobufUtil: pu,
						methodToTypeMap: methodToTypeMap,
						serverCodes: serverCodes,
						socketIds: socketIds
					};

					var mitmPlayback = new MitmPlayback(config);
					mitmPlayback.startPlayback();
				});
			});
		});
	});
});
