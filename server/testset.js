var Core = require('./core');
var async = require('async');
var http = require('http');
var MongoClient = require('mongodb').MongoClient;

var mdb = require('./db');


exports.fuzzerLoop = function (test) {
	var originalMsg = Core.pb.Serialize({debug:true},'Poker.HelloParams');
	function testByte(byteOffset,value,cb) {
		var copy = new Buffer(originalMsg);
		copy[byteOffset] = value;
		var root = new Core(function (method,args) {
			//root.debugHandle(method,args);
			if (method == root.codes.srHello) {
				test.ok(true);
				root.socket.destroy();
				cb();
			}
		});
		root.reply(root.codes.scHello,copy,'raw');
		root.socket.on('end',function () {
			test.ok(true);
			cb();
		});
	}
	var jobs = [];
	for (var x=0; x<originalMsg.length; x++) {
		for (var y=0; y<256; y++) {
			jobs.push([x,y]);
		}
	}
	test.expect(jobs.length);
	async.eachLimit(jobs,10,function (job,cb) {
		testByte(job[0],job[1],cb);
	},function () {
		test.done();
	});
}
exports.ping_timeout1 = function (test) {
	test.expect(2);
	var root = new Core(function (method,args) {
		//root.debugHandle(method,args);
		if (method == root.codes.srHello) test.ok(true,'got scHello');
	});
	//root.reply(root.codes.scHello,{debug:false},'Poker.HelloParams');
	var timer = setTimeout(fail,110000);
	function fail() {
		console.log('FAIL!');
		root.socket.destroy();
		console.log('calling done');
		test.ok(false,"ping timeout didnt work");
		test.done();
	}
	root.socket.on('end',function() {
		clearTimeout(timer);
		console.log('socket closed');
		root.socket.destroy();
		test.ok(true,'ping timeout worked');
		test.done();
	});
}
exports.testRegisterLong = function (test) {
	var name = "unittest"+Math.random();
	var root = new Core(function (method,args) {
		var obj = root.debugHandle(method,args);
		if (method == root.codes.srHello) {
			root.reply(root.codes.scRegister,{email:name+'@server.com',password:'password',displayName:name},'Poker.RegisterParams');
		} else if (method == root.codes.srRegisterReply) {
			test.equal(obj.status,'regInvalidName');
			root.socket.destroy();
			test.done();
		}
	});
	root.socket.on('end',function () {
		test.ok(false);
		test.done();
	});
	root.reply(root.codes.scHello,{debug:false},'Poker.HelloParams');
}
var username = this.name = "unittest"+Math.random();
username = username.substr(0,20);
exports.testRegisterAndLogin = {
	testRegister: function (test) {
		var name = username;
		var root = new Core(function (method,args) {
			var obj = root.debugHandle(method,args);
			if (method == root.codes.srHello) {
				root.reply(root.codes.scRegister,{email:name+'@server.com',password:'password',displayName:name},'Poker.RegisterParams');
			} else if (method == root.codes.srRegisterReply) {
				test.equal(obj.status,'regSuccess');
				root.socket.destroy();
				test.done();
			}
		});
		root.socket.on('end',function () {
			test.ok(false);
			test.done();
		});
		root.reply(root.codes.scHello,{debug:false},'Poker.HelloParams');
	},
	testLogin: function (test) {
		var name = username;
		var root = new Core(function (method,args) {
			var obj = root.debugHandle(method,args);
			if (method == root.codes.srHello) {
				root.reply(root.codes.scLogin,{username:name+'@server.com',password:'password'},'Poker.LoginParams');
			} else if (method == root.codes.srLoginReply) {
				test.equal(obj.login_status,'lrSuccess');
				root.socket.destroy();
				test.done();
			}
		});
		root.reply(root.codes.scHello,{debug:false},'Poker.HelloParams');
	}
}
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
