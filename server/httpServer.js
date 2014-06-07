var express = require('express');
var fs = require('fs');
var assert = require('assert');
var ObjectID = require('mongodb').ObjectID;
var util = require('util');
var crypto = require('crypto');

var config = require('./config');
var MongoStore = require('./mongoStore');

var Game = require('./game').Game;
var deck = require('./deck');

module.exports.initHttpServer = initHttpServer;

function initHttpServer(db,app,activeUsers) {
	var server = new Server(db,app,activeUsers);
	return server;
}

function Server(db,app,activeUsersIN) {
	this.activeUsers = activeUsersIN;
	var PokerProfile = db.collection('PokerProfile');
	this.bugs = db.collection('bugs');
	this.serverErrors = db.collection('serverErrors');
	this.users = db.collection('users');
	this.clubs = db.collection('clubs');
	this.games = db.collection('games');
	this.handHistory = db.collection('handHistory');
	this.admin = db.collection('admin');

	this.sessionStore = new MongoStore(db,'sessions');
	app.use(express.cookieParser());
	app.use(express.session({secret:'ahQu6eey',key:'poker',store:this.sessionStore}));
	app.configure(function () {
		assert(fs.statSync('./upload'));
		app.use(express.bodyParser({uploadDir:'./upload'}));
	});
	app.use('/sync/',express.basicAuth('sync',config.syncpassword));
	app.use('/secure/',function (req,res,next) {
		if (req.session.authed) return next();
		if (req.url == '/login') {
			return next(); // allow the login page
		} else {
			req.session.lastUrl = req.originalUrl;
			res.writeHead(302,{Location:'/secure/login'});
			res.end('you must first login');
		}
	});
	app.set('view engine','jade');
	app.get('/secure/',this.secureIndex.bind(this));

	app.get('/secure/login',this.secureLogin.bind(this));
	app.get('/secure/logout',this.secureLogout.bind(this));
	app.get('/secure/changePassword',this.changePassword.bind(this));
	app.post('/secure/login',this.secureLoginPost.bind(this));
	app.post('/secure/changePassword',this.secureChangePasswordPost.bind(this));

	app.get('/secure/bugs',this.bugList.bind(this));
	app.get('/secure/bug',this.getBug.bind(this));
	app.get('/secure/screenshot',this.getScreenshot.bind(this));
	app.get('/secure/serverBugs',this.ServerBugsList.bind(this));
	app.get('/secure/users',this.userList.bind(this));
	app.get('/secure/user',this.getUser.bind(this));
	app.get('/secure/clubs',this.getClubs.bind(this));
	app.get('/secure/club',this.getClub.bind(this));
	app.get('/secure/game',this.getGame.bind(this));
	app.get('/secure/hand',this.getHand.bind(this));
}
Server.prototype.getHand = function (req,res) {
	var start = Date.now();
	this.handHistory.findOne({_id:new ObjectID(req.query.id)},function (err,hand) {
		res.render('hand',{hand:hand,start:start});
	});
}
Server.prototype.secureChangePasswordPost = function (req,res) {
	console.log(req.body);
	if (req.body.password != req.body.repeatPassword) {
		res.end('passwords dont match');
		return;
	}
	deck.getRandom(16,function (salt) {
		var hasher = crypto.createHash('sha256');
		hasher.update(salt);
		hasher.update(req.body.password);
		var hash = hasher.digest();
		this.admin.update({username:req.session.username},{$set:{password:hash, salt:salt }},function (err,rows) {
			assert.ifError(err);
			if (req.session.lastUrl) {
				res.writeHead(302,{Location:req.session.lastUrl});
			} else {
				res.writeHead(302,{Location:'/secure/'});
			}
			res.end('done');
		});
	}.bind(this));
}
Server.prototype.secureLoginPost = function (req,res) {
	var username = req.body.username;
	var password = req.body.password;
	console.log('checking auth %s/%s',username,password);
	this.admin.findOne({username:username},function (err,adminRow) {
		console.log('adminRow:%j',adminRow);
		if (adminRow) {
			if (!adminRow.salt) {
				if (adminRow.password == password) {
					req.session.authed = true;
					req.session.username = adminRow.username;
					res.writeHead(302,{Location:'/secure/changePassword'});
					res.end('sucess');
					return;
				}
			} else {
				var hasher = crypto.createHash('sha256');
				hasher.update(adminRow.salt.buffer);
				hasher.update(password);
				var hash = hasher.digest();
				if (hash.toString('hex') == adminRow.password.buffer.toString('hex')) {
					req.session.authed = true;
					req.session.username = adminRow.username;
					if (req.session.lastUrl) {
						res.writeHead(302,{Location:req.session.lastUrl});
					} else {
						res.writeHead(302,{Location:'/secure/'});
					}
					res.end('sucess');
					return;
				} else {
					res.end('no match');
					return;
				}
			}
		}
		res.end('fail');
	});
}
Server.prototype.getGame = function (req,res) {
	var start = Date.now();
	this.handHistory.find({gameid:new ObjectID(req.query.id)}).limit(1000).sort({_id:-1}).toArray(function (err,hands) {
		Game.getGame(new ObjectID(req.query.id),function (err,game) {
			game.Lock.writeLock(function (release) {
				res.render('game',{game:game,hands:hands,start:start,util:util});
				release();
			});
		});
	});
}
Server.prototype.getClub = function (req,res) {
	var start = Date.now();
	this.clubs.findOne({_id:new ObjectID(req.query.id)},function (err,club) {
		var userids = [ club.owner ];
		if (club.members) {
			for (var x=0; x<club.members.length; x++) {
				userids.push(club.members[x]);
			}
		}
		this.games.find({clubid:new ObjectID(req.query.id)}).toArray(function (err,games) {
			this.users.find({_id:{$in:userids}}).toArray(function (err,users) {
				var usermap = {};
				for (var x=0; x<users.length; x++) {
					usermap[users[x]._id] = users[x];
				}
				res.render('club',{club:club,games:games,start:start,users:usermap});
			});
		}.bind(this));
	}.bind(this));
}
Server.prototype.getClubs = function (req,res) {
	var start = Date.now();
	this.clubs.find({}).toArray(function (err,data) {
		res.render('clubs',{clubs:data,start:start});
	});
}
Server.prototype.changePassword = function (req,res) {
	res.render('changePassword');
}
Server.prototype.getBug = function (req,res) {
	var start = Date.now();
	this.bugs.findOne({_id:new ObjectID(req.query.id)},function (err,row) {
		res.render('bug',{bug:row,start:start});
	});
}
Server.prototype.getScreenshot = function (req,res) {
	this.bugs.findOne({_id:new ObjectID(req.query.id)},function (err,row) {
		res.set({"Content-Disposition":'filename="'+row._id+'.png"','Content-Type':'image/png'});
		res.send(row.ScreenShot.buffer);
	});
}
Server.prototype.secureIndex = function (req,res) {
	res.render('secure_index');
}
Server.prototype.secureLogin = function (req,res) {
	res.render('secure_login');
}
Server.prototype.secureLogout = function (req,res) {
	req.session.destroy(function (err) {
		res.writeHead(302,{Location:'/secure/login'});
		res.end('sucess');
	});
}
Server.prototype.bugList = function (req,res) {
	var start = Date.now();
	this.bugs.find({}).toArray(function (err,data) {
		res.render('bugs',{bugs:data,start:start});
	});
}
Server.prototype.ServerBugsList = function (req,res) {
	var start = Date.now();
	if (req.query.delete) {
		this.serverErrors.remove({_id:new ObjectID(req.query.delete)},function () {});
	}
	this.serverErrors.find().sort({_id:-1}).toArray(function (err,data) {
		res.render('serverErrors',{rows:data,start:start});
	});
}
Server.prototype.userList = function (req,res) {
	var start = Date.now();
	this.users.find({}).toArray(function (err,data) {
		var sum = 0;
		for (var x=0; x<data.length; x++) {
			if (data[x].chips) sum += data[x].chips;
		}
		res.render('users',{users:data,start:start,sum:sum});
	});
}
Server.prototype.getUser = function (req,res) {
	var start = Date.now();
	this.users.findOne({_id:new ObjectID(req.query.id)},function (err,row) {
		this.clubs.find({$or:[ {members:new ObjectID(req.query.id)}, {owner:new ObjectID(req.query.id)} ]}).toArray(function (err,clubs) {
			var self = this.activeUsers[row._id];
			var obj = {user:row,clubs:clubs,start:start,online:self,util:util}
			res.render('user',obj);
		}.bind(this));
	}.bind(this));
}
