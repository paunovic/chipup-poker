'use strict';
var fs = require("fs");
var Protobuf = require("node-protobuf").Protobuf;
var ProtobufUtil = require('./ProtobufUtil');
var mitm = require('./man_in_the_middle');
var codes = require('./ServerCodes.js');

var schema = 'Poker.RpcMessage';
var pb = new Protobuf(fs.readFileSync("../message.desc"));
var pu = new ProtobufUtil(pb, schema);
//var message = pu.encode(codes.srChangeClubDetailsReply, {	status: 'csNameExists' }, 'Poker.ClubCommandReply');

var realServerPort = 12345;
var fakeServerPort = 55555;
var mitmServer = mitm.createManInTheMiddleServer(pu, realServerPort, fakeServerPort, recordCallback);

function recordCallback(methodId, args) {
	console.log(methodId.toString() + ', ' + args.toString());


	/*
	var MongoClient = require('mongodb').MongoClient
		, format = require('util').format;

	MongoClient.connect('mongodb://127.0.0.1:27017/test', function(err, db) {
		if(err) throw err;

		var collection = db.collection('test_insert');
		collection.insert({a:2}, function(err, docs) {

			collection.count(function(err, count) {
				console.log(format("count = %s", count));
			});

			// Locate all the entries using find
			collection.find().toArray(function(err, results) {
				console.dir(results);
				// Let's close the db
				db.close();
			});
		});
	});
	*/
}