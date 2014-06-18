var Core = require('./core');
var async = require('async');
var http = require('http');
var MongoClient = require('mongodb').MongoClient;

var mdb = require('./db');
var myutils = require('./myutils');

var clubid;

exports.club = {
	makeanddelete: function (test) {
		var activeUsers = {};
		var activeGames = {};
		var club = require('./club');
		test.expect(3);
		mdb.open();
		MongoClient.connect('mongodb://localhost:27017/poker',function (err,db) {
			club.init(db,activeUsers,activeGames,Core.pb);
			myutils.init(db);
			db.collection('users').findOne(function (err,user) {
				test.ok(user);
				club.Club.createClub('clubname','password',user._id,5,function (worked,clubObj) {
					clubid = clubObj.obj.seq;
					test.ok(worked);
					club.Club.dupCheck('clubname',function (dup) {
						test.ok(dup);
						db.close();
						mdb.close();
						test.done();
					});
				});
			});
		});
	},
	joinClub: function (test) {
		var activeUsers = {};
		var activeGames = {};
		var club = require('./club');
		mdb.open();
		MongoClient.connect('mongodb://localhost:27017/poker',function (err,db) {
			club.init(db,activeUsers,activeGames,Core.pb);
			myutils.init(db);
			db.collection('users').find().limit(2).toArray(function (err,users) {
				club.getClubBySeq(clubid,function (err,clubObj) {
					console.log('spot 1',err);
					test.ok(clubObj);
					var user2 = users[0];
					if (clubObj.isOwner(user2._id)) user2 = users[1];
					clubObj.joinClub(user2._id,function () {
						console.log(clubObj.obj);
						db.close();
						mdb.close();
						test.done();
					});
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
		test.expect(6);
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
	},
	kick: function (test) {
		var activeUsers = {};
		var activeGames = {};
		var club = require('./club');
		mdb.open();
		MongoClient.connect('mongodb://localhost:27017/poker',function (err,db) {
			club.init(db,activeUsers,activeGames,Core.pb);
			myutils.init(db);
			club.getClubBySeq(clubid,function (err,clubObj) {
				test.ok(clubObj);
				clubObj.KickMember(clubObj.obj.members[0],function () {
					test.ok(true);
					db.close();
					mdb.close();
					test.done();
				});
			});
		});
	},
	deleteClub: function (test) {
		var activeUsers = {};
		var activeGames = {};
		var club = require('./club');
		mdb.open();
		test.expect(1);
		MongoClient.connect('mongodb://localhost:27017/poker',function (err,db) {
			club.init(db,activeUsers,activeGames,Core.pb);
			myutils.init(db);
			club.getClubBySeq(clubid,function (err,clubObj) {
				test.ok(clubObj);
				console.log(clubObj);
				clubObj.deleteClub(function () {
					db.close();
					mdb.close();
					test.done();
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
