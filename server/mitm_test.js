'use strict';
var schema = 'Poker.RpcMessage';
var s2p = require('./protobuf_util');
var protobuf = require("node-protobuf");

var realServerPort = 5678;
var fakeServerPort = 1234;
var mitmServer = require(./man_in_the_middle).createManInTheMiddleServer(protobuf, schema, realServerPort, fakeServerPort, recordCallback);


function recordCallback(methodId, args) {
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
}