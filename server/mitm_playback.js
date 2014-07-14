/*
TODO:
1. add code to control master.js to start/restart it everytime you run pinning tests and when you wipe gameState
2. random generator?
*/
'use strict';
var net = require('net');
var MongoClient = require('mongodb').MongoClient;
var fs = require("fs");
var Protobuf = require("node-protobuf").Protobuf;
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
	if (err) throw err;
	db.collection('gameState').remove(function(err) {
    	if(err) throw err;
		MongoClient.connect('mongodb://127.0.0.1:27017/test', function (err, db) {
			if (err) throw err;
			db.collection('mitm').find({
				$query: {},
				$orderby: { timestamp : 1 }
			}).toArray(replayAndTestAll);
		});
 });
});

function replayAndTestAll(err, requests) {
	if (err) throw err;
	var config = {
		requests: requests,
		host: host,
		port: port,
		protobuf: pb,
		protobufUtil: pu,
		methodToTypeMap: methodToTypeMap,
		serverCodes: serverCodes
	};

	var mitmPlayback = new MitmPlayback(config);
	mitmPlayback.startPlayback();
}