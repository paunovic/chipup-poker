var Core = require('./core');
var async = require('async');
var http = require('http');
var MongoClient = require('mongodb').MongoClient;

var mdb = require('./db');
var myutils = require('./myutils');


exports.club = {
	makeanddelete: function (test) {
		var activeUsers = {};
		var activeGames = {};
		var club = require('./club');
		mdb.open();
		MongoClient.connect('mongodb://localhost:27017/poker',function (err,db) {
			club.init(db,activeUsers,activeGames,Core.pb);
			myutils.init(db);
			db.collection('users').findOne(function (err,user) {
				test.ok(user);
				club.Club.createClub('clubname','password',user._id,5,function (worked,clubObj) {
					test.ok(worked);
					test.done();
				});
			});
		});
	},
	goPublic: function (test) {
		var activeUsers = {};
		var activeGames = {};
		var club = require('./club');
		var game = require('./game');
		test.expect(7);
		activeUsers['fake'] = { send: function(code,object,type) {
			test.ok(true);
		}};
		mdb.open();
		MongoClient.connect('mongodb://localhost:27017/poker',function (err,db) {
			test.ok(true);
			club.init(db,activeUsers,activeGames,Core.pb);
			game.Game.init(db,activeGames,activeUsers,{},null,null,null);
			db.collection('clubs').findOne(function (err,row) {
				test.ok(true);
				db.collection('users').findOne(function (err,userRow) {
					//console.log('userRow',userRow);
					test.ok(true);
					db.collection('clubBalances').insert({clubid:row._id,userid:userRow._id,balance:0,balance_limit:0,unlimited_limit:true},function (err) {
						test.ok(true);
						club.Club.getClubById(row._id,function (err,clubobj) {
							test.ok(true);
							//console.log('clubobj',clubobj);
							clubobj.goPublic(function () {
								test.ok(true);
								test.done();
								db.close();
								mdb.close();
							});
						});
					});
				});
			});
		});
	},suspend: function (test) {
		var activeUsers = {};
		var activeGames = {};
		var club = require('./club');
		test.expect(5);
		mdb.open();
		MongoClient.connect('mongodb://localhost:27017/poker',function (err,db) {
			test.ok(true);
			club.init(db,activeUsers,activeGames,Core.pb);
			db.collection('clubs').findOne(function (err,row) {
				test.ok(true);
				test.ok(row.members.length > 0);
				if (row.members.length == 0) return test.done();
				db.collection('users').findOne({_id:row.members[0]},function (err,userRow) {
					test.ok(true);
					club.Club.getClubById(row._id,function (err,clubobj) {
						test.ok(true);
						clubobj.setSuspended(true,userRow._id,function () {
							test.ok(true);
							clubobj.setSuspended(false,userRow._id,function () {
								db.close();
								mdb.close();
								test.done();
							});
						});
					});
				});
			});
		});
	}
};
process.on('uncaughtException',function (err) {
	console.log(err);
	console.log(err.stack);
	process.exit(1);
});
