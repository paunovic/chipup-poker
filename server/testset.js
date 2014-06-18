var Core = require('./core');
var async = require('async');
var http = require('http');
var MongoClient = require('mongodb').MongoClient;

var mdb = require('./db');


var globalCookies = {};
function parseCookies(reply) {
	var cookies = reply.headers['set-cookie'];
	if (!cookies) return;
	for (var x=0; x<cookies.length; x++) {
		var c = cookies[x].split(';')[0].split('=');
		globalCookies[c[0]] = c[1];
	}
	console.log(globalCookies);
}
function addCookies(headers) {
	for (var key in globalCookies) {
		headers.Cookie.push(key+'='+globalCookies[key]);
	}
}
exports.testSecure = {
	setUp: function (cb) {
		var raw_post = 'username=tester&password=tester'; // FIXME
		var req = http.request({hostname:'dev-server.chipuppoker.com',path:'/secure/login',method:'POST',headers:{'Content-length':raw_post.length,'Content-Type':'application/x-www-form-urlencoded'}},function (res) {
			parseCookies(res);
			var buffer = '';
			res.on('data',function (chunk) {
				buffer += chunk;
			});
			res.on('end',function () {
				console.log(buffer);
				cb();
			});
		});
		req.write(raw_post);
		req.end();
	},clubList: function (test) {
		var headers = {Cookie: []};
		addCookies(headers);
		var req = http.request({hostname:'dev-server.chipuppoker.com',path:'/secure/clubs',headers:headers},function (res) {
			parseCookies(res);
			var buffer = '';
			res.on('data',function (chunk) {
				buffer += chunk;
			});
			res.on('end',function () {
				console.log(buffer);
				test.done();
			});
		});
		req.end();
	},goPublic: function (test) {
		var body = 'clubid=53657ca0e21b108e10cbe4b9';
		var headers = {Cookie: [],'Content-Length':body.length,'Content-Type':'application/x-www-form-urlencoded'};
		addCookies(headers);
		var req = http.request({hostname:'dev-server.chipuppoker.com',path:'/secure/club_public',method:'POST',headers:headers},function (res) {
			parseCookies(res);
			var buffer = '';
			res.on('data',function (chunk) {
				buffer += chunk;
			});
			res.on('end',function () {
				console.log(buffer);
				test.done();
			});
		});
		req.write(body);
		req.end();
	}
};
exports.club = {
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
