#!/usr/bin/node
// http://docs.mongodb.org/manual/reference/operator/update/positional/
var net = require('net');
var tls = require('tls');
var fs = require('fs');
var MongoClient = require('mongodb').MongoClient;
var ObjectID = require('mongodb').ObjectID
//var Reader = require('./reader').reader;
var express = require('express');
var uuid = require('node-uuid');
var generatePassword = require('password-generator');
var crypto = require('crypto');
var p = require("node-protobuf").Protobuf;
var https = require('https');
var assert = require('assert');
var util = require('util');
var async = require('async');
var child_process = require('child_process');

var SmtpConnection = require('./smtp');
var ReadWriteLock = require('./lock'); // FIXME, send them a PR?, fork it?, it came from the rwlock npm package
var deck = require('./deck');
var codes = require('./ServerCodes');
var dag = require('./dag/build/Release/dag');
var bugsView = require('./bugs');

var Deck = deck.Deck;
var Hand = deck.Hand;

var pb = new p(fs.readFileSync("../message.desc"));
var protoreader = require('./protoreader');
protoreader.init(pb,codes,[codes.seTableStatus,codes.seTableEvent]);

dag.init();

// stats
var hands = 0;

var domain = "http://chipuppoker.com/";
var sharedconfig = {stringSizes:{},max_play_time:20,max_timebank:60};
sharedconfig.stringSizes.email = 200
sharedconfig.stringSizes.password = 32
sharedconfig.stringSizes.clubname = 64
sharedconfig.stringSizes.invcode = 32
sharedconfig.stringSizes.username = 20;
sharedconfig.stringSizes.gamename = 32;
sharedconfig.ChangeExpireTime = 3600 * 24;
sharedconfig.ForgotExpireTime = 3600;

var app = express();
app.configure(function () {
	assert(fs.statSync('./upload'));
	app.use(express.bodyParser({uploadDir:'./upload'}));
});
app.get('/confirm',function (req,res) {
	if (!req.query.code) {
		res.send("error, code missing");
		return;
	}
	if (req.query.code.length != 36) {
		res.send("error, code not long enough");
		return;
	}
	allUsers.findOne({authcode:req.query.code},function (err,user) {
		if (!user) {
			res.send("error, auth code used or invalid");
			return;
		}
		allUsers.update({_id:user._id},{$set:{authed:true},$unset:{authcode:""}},function (err,result) {
			console.log('email confirm time',user);
			res.send("account activated");
			var conn = activeUsers[user._id];
			if (!conn) return;
			conn.send(codes.seAccountConfirmed);
		});
	});
});
app.get('/confirmchange',function (req,res) {
	if (!req.query.code) {
		res.send("error, code missing");
		return;
	}
	if (req.query.code.length != 36) {
		res.send("error, code not long enough");
		return;
	}
	allUsers.findOne({changecode:req.query.code},function (err,user) {
		if (!user) {
			res.send("error, auth code used or invalid");
			return;
		}
		var age = Date.now() - user.changetime;
		console.log('code age',age);
		if (age > (sharedconfig.ChangeExpireTime*1000)) {
			allUsers.update({_id:user._id},{$unset:{changecode:"",changetime:""}},function (err,updated) {
				res.send("error, change code expired");
			}.bind(this));
			return;
		}
		allUsers.update({_id:user._id},{$set:{email:user.newemail},$unset:{newemail:"",changecode:""}},function (err,result) {
			console.log('email change time',user);
			// FIXME, inform the user if they are connected
			res.send("email address changed");
			var conn = activeUsers[user._id];
			if (!conn) return;
			//conn.send(codes.seAccountConfirmed);
		});
	});
});
app.get("/passwordreset",function (req,res) {
	if (!req.query.code) {
		res.send("error, code missing");
		return;
	}
	if (req.query.code.length != 36) {
		res.send("error, code not long enough");
		return;
	}
	allUsers.findOne({forgotcode:req.query.code},function (err,user) {
		if (!user) {
			res.send("error, auth code used or invalid");
			return;
		}
		var age = Date.now() - user.forgottime;
		console.log('reset code age',age);
		if (age > (sharedconfig.ForgotExpireTime*1000)) {
			allUsers.update({_id:user._id},{$unset:{forgotcode:"",forgottime:""}},function (err,updated) {
				res.send("error, change code expired");
			}.bind(this));
			return;
		}
		var newpassword = generatePassword();
		deck.getRandom(16,function (salt) {
			var hasher = crypto.createHash('sha256');
			hasher.update(salt);
			hasher.update(newpassword);
			var hash = hasher.digest();
			allUsers.update({_id:user._id},{$set:{password:hash,salt:salt},$unset:{forgotcode:"",forgottime:""}},function (err,result) {
				console.log('password change time',user);
				res.send("password changed, new password sent to your email");
				var test = new SmtpConnection();
				var message = 'your new password is: '+newpassword;
				test.sendMail(user.email,'From: clever@angeldsis.com\r\nSubject: test\r\n\r\n'+message,function cb(err,ret) {
					console.log('cb',err,ret);
					if (err) {
						console.log('password reset email error',err);
						return;
					}
				});
			});
		});
	});
});
app.post("/uploadAvatar",function (req,res) {
	console.log('files',req.headers);
	console.log('version',req.httpVersionMajor,req.httpVersionMinor);
	fs.readFile(req.files.avatar.path,function (err,data) {
		var extension = req.files.avatar.originalFilename.split('.').pop();
		var hasher = crypto.createHash('sha256');
		hasher.update(data);
		var hash = hasher.digest('base64');
		avatars.findOne({_id:hash},function (err,row) {
			if (err) {
				console.log('error',err);
				res.send(JSON.stringify({error:err}));
				return;
			}
			if (row) {
				var out = new Buffer(hash,'base64');
				console.log('sending dup id',out);
				res.send(200,out);
			} else {
				avatars.insert({_id:hash,image:data,size:data.length,created:Date.now(),ext:extension},function (err,row) {
					if (err) {
						console.log('error',err);
						res.send(JSON.stringify(err));
						return;
					}
					var out = new Buffer(row[0]._id,'base64');
					console.log('sending unique id',out);
					res.send(200,out);
					fs.unlink(req.files.avatar.path);
				});
			}
		});
	});
});
app.post('/paypal_callback',function (req,res) {
	if (req.body.test_ipn) var host = 'www.sandbox.paypal.com';
	else var host = 'www.paypal.com';
	var raw_post = [];
	for (key in req.body) {
		raw_post.push(key+'='+escape(req.body[key]));
	}
	raw_post.push('cmd=_notify-validate');
	raw_post = raw_post.join('&');
	var req2 = https.request({
		hostname:host,
		port:443,
		path:'/cgi-bin/webscr',
		method:'POST',
		headers:{
			'Content-length':raw_post.length
		}},function (res2) {
			res2.setEncoding('utf8');
			var buffer = '';
			res2.on('data',function (chunk) {
				buffer += chunk;
			});
			res2.on('end',function () {
				if ((res2.statusCode == 200) && (buffer.trim() == 'VERIFIED')) {
					res.send(200,'');
					console.log('all good');
					console.log(req.body);
				} else {
					res.send(500,'problem verifying data');
					console.log('error, reply:',buffer);
					console.log(res2.statusCode,res2.headers);
				}
			});
		});
	req2.write(raw_post);
	req2.end();
});
app.post('/error_upload',function (req,res) {
	// fields are req.body.MailFrom MailSubject MailBody
	var body = req.body;
	var doc = { MailFrom:body.MailFrom, MailSubject:body.MailSubject, MailBody:body.MailBody };
	async.parallel([function (cb1) {
		fs.readFile(req.files.ScreenShot.path,function (err,data) {
			doc.ScreenShot = data;
			fs.unlink(req.files.ScreenShot.path);
			cb1();
		});
		},function (cb2) {
		fs.readFile(req.files.BugReport.path,{encoding:'utf8'},function (err,data) {
			doc.BugReport = data;
			fs.unlink(req.files.BugReport.path);
			cb2();
		});
		}],function done() {
			bugs.insert(doc,function (err,result) {
				console.log(result);
				res.send(200);
			});
		});
});
app.get("/test",function (req,res) {
	res.send("<form method='post' action='/image_upload' enctype='multipart/form-data'><input type='file' name='avatar'><input type='submit'></form>");
});
app.get("/getavatar",function (req,res) {
	var id = req.query.id;
	log('getting avatar %j %d %s',req.query,id.length,id);
	if (id == 'default') {
		fs.readFile('../client/design/avatar/Default Avatar.jpg',function (err,data) {
			if (err) throw err;
			res.send(data);
		});
		return;
	}
	var raw = new Buffer(id,'hex');
	var base64 = raw.toString('base64');
	avatars.findOne({_id:base64},function (err,row) {
		if (!row) {
			res.send(404);
			return;
		}
		var filename = req.query.id+"."+row.ext;
		console.log(filename);
		res.set({"Content-Disposition":'attachment; filename="'+filename+'"'});
		res.send(row.image.buffer);
	});
});
app.get("/install_chipuppoker.exe",function (req,res) {
	res.sendfile('/home/buildbotcheckout/release/install_chipuppoker.exe');
});
app.get('/game',function (req,res) {
	var start = Date.now();
	handHistory.find({gameid:new ObjectID(req.query.id)}).toArray(function (err,hands) {
		Game.getGame(new ObjectID(req.query.id),function (err,game) {
			game.Lock.writeLock(function (release) {
				res.render('game',{game:game,hands:hands,start:start});
				release();
			});
		});
	});
});
app.post('/eval',function (req,res) {
	var state = req.body;
	console.log(state);
	console.log(state.cards1);
	var fakegame = { flop:{cards:state.flop}, turn:{cards:state.turn}, river:{cards:state.river}};
	var fakeusers = [{seat:0,hand:state.cards1},{seat:1,hand:state.cards2}];
	var result = dag.rankHands(fakegame,fakeusers);
	res.send(JSON.stringify(result));
});
app.use(express.static('files'));
function goOnline() {
	app.listen(3000);
	secureServer.listen(12346);
	server.listen(12345);
	cactiServer.listen(1246);
}

var conn,allUsers,allClubs,allCounters,avatars,allGames,bugs,handHistory;
MongoClient.connect('mongodb://localhost:27017/poker',function (err,db) {
	if (err) {
		console.log(err);
		process.exit(1);
	}
	conn = db;
	process.on('uncaughtException',function (err) {
		console.log(err);
		db.collection('serverErrors').insert({error:err.toString(),trace:err.stack.split('\n').slice(1).join('\n').trim()},function (err) {
			if (err) console.log(err);
			process.exit(-1);
		});
	});
	process.send({msg:'connected'});

	allUsers = db.collection('users');
	allClubs = db.collection('clubs');
	avatars = db.collection('avatars');
	allGames = db.collection('games');
	allCounters = db.collection('counters');
	bugs = db.collection('bugs');
	handHistory = db.collection('handHistory');

	bugsView.setup(app,bugs,allUsers,db);

	allUsers.createIndex("email",{unique:true}, function (err,res) {});
	allUsers.createIndex("displayname",{unique:true}, function (err,res) {});

	allClubs.createIndex("name",{unique:true},function (err,res) {});
	handHistory.ensureIndex({seq:1},function (err,res){});
	handHistory.ensureIndex({gameid:1},function (err,res){});

	allCounters.insert({_id:"club",seq:1},function (err,res) {});
	allGames.find({gameState:{$exists:true}}).toArray(function (err,badgames) { // FIXME, check state
		console.log(badgames);
		if (badgames.length > 0) {
			log('%d bad games found, recovering',badgames.length);
			async.each(badgames,function (game,cb) {
				allGames.update({_id:game._id},{$unset:{gameState:0}},cb)
			},checkCorruptChips);
		} else {
			checkCorruptChips();
		}
	});
	function checkCorruptChips() {
		allUsers.find({chips:NaN}).toArray(function (err,badUsers) { // should never find any
			if (badUsers.length > 0) {
				console.log(badUsers);
				process.send({type:'control',cmd:'autooff'});
				process.exit(0);
			} else checkCorruptRake();
		});
	}
	function checkCorruptRake() {
		allGames.find({rake:NaN}).toArray(function (err,badGames) { // should never find any
			if (badGames.length > 0) {
				console.log(badGames);
				process.send({type:'control',cmd:'autooff'});
				process.exit(0);
			} else initHands();
		});
	}
	function initHands() {
		allCounters.findOne({_id:'handHistory'},function (err,row) {
			if (!row) {
				getNextSequence('handHistory',function(seq) {
					hands = seq;
					goOnline();
				});
			} else {
				hands = row.seq;
				goOnline();
			}
		});
	}
});
function log(format) {
	var out = Array.prototype.slice.call(arguments);
	if (format.indexOf('%') != -1) {
		out = [ util.format.apply(util,out) ]
	}
	process.send({type:'global',ts:new Date().toString(),msg:out.join(' ')});
}
function getNextSequence(name,cb) {
	allCounters.findAndModify({_id:name},[],
		{ $inc:{seq:1}},
	function (err,res) {
		console.log('seq',name,err,res);
		if (res) {
			cb(res.seq);
		} else {
			allCounters.insert({_id:name,seq:0},function (err,row) {
				cb(1);
			});
		}
	});
}
var server = net.createServer(function listener(socket) {
	var handler = new ClientSocket(socket);
});
var options = {
	key: fs.readFileSync('key.pem'),
	cert: fs.readFileSync('cert.pem')
};

var secureServer = tls.createServer(options,function listener(socket) {
	var handler = new ClientSocket(socket);
});
var cactiServer = require('net').createServer(stats_server);


var activeUsers = {};
var activeGames = {};
function ClientSocket(socket) {
	this.state = 1;
	this.socket = socket;
	this.boughtin = 0;
	socket.on('end',function() {
		this.state = -1;
		this.log('client lost');
		delete activeUsers[this.userid];
		Game.handleDisconnect(this,'closed');
	}.bind(this));
	//this.socket.write("abc\ndef\nghi\n");
	this.send(codes.srHello,sharedconfig,'Poker.HelloReply');
	this.reader = new protoreader(socket,this);
	socket.on('error',function(err) {
		this.state = -2;
		this.log('error!',err.code);
		Game.handleDisconnect(this,'error');
		this.logout();
	}.bind(this));
}
ClientSocket.prototype.error = function error(e) {
	this.log('error!',e);
	this.log('stack:',e.stack);
	console.log('TEMP',e.stack,e);
	Game.handleDisconnect(this,'error2');
	this.logout();
	this.socket.destroy();
}
function bufferMatch(a,b) {
	if (a.length != b.length) return false;
	for (var x=0; x<a.length; x++) {
		if (a[x] != b[x]) return false;
	}
	return true;
}
ClientSocket.prototype.doLogin = function doLogin(row,password) {
	if (row.salt) {
		var hasher = crypto.createHash('sha256');
		hasher.update(row.salt.buffer);
		hasher.update(password);
		var hash = hasher.digest();
		if (bufferMatch(hash,row.password.buffer)) {
			var oldconn = activeUsers[row._id];
			if (oldconn) {
				oldconn.eject();
			}
			this.state = 2;
			this.userid = row._id;
			this.nick = row.displayname;
			this.send(codes.srLoginReply,{status:'lrSuccess'},'Poker.LoginReply');
			this.log('sucessfully logged in with salt');
			activeUsers[row._id] = this;
		} else {
			this.send(codes.srLoginReply,{status:'lrInvalid'},'Poker.LoginReply');
		}
	} else if (row.password == password) {
		var oldconn = activeUsers[row._id];
		if (oldconn) {
			oldconn.eject();
		}
		this.state = 2;
		this.userid = row._id;
		this.nick = row.displayname;
		this.send(codes.srLoginReply,{status:'lrSuccess'},'Poker.LoginReply');
		this.log('sucessfully logged in');
		activeUsers[row._id] = this;
	} else {
		this.send(codes.srLoginReply,{status:'lrInvalid'},'Poker.LoginReply');
	}
}
ClientSocket.prototype.logout = function () {
	delete activeUsers[this.userid];
	this.state = 1;
	this.userid = null;
	this.nick = null;
}
ClientSocket.prototype.eject = function () {
	Game.handleDisconnect(this,'eject');
	this.state = 1;
	this.userid = null;
	this.nick = null;
	this.send(codes.seSecondaryLoginDetected);
}
ClientSocket.prototype.log = function log(format) {
	var out = Array.prototype.slice.call(arguments);
	if (format.indexOf('%') != -1) {
		out = [ util.format.apply(util,out) ]
	}
	process.send({type:'conn',nick:this.nick,ts:new Date().toString(),objects:out});
}
ClientSocket.prototype.reply = function reply(code,message,type) {
	var obj;
	if (message) obj = {code:parseInt(code),msg:message};
	else obj = {code:parseInt(code)};
	console.log('OldMessage args',obj);
	if (obj.code != 0) {
		process.exit();
	}
	this.send(0,new Buffer(message,'utf8'),"raw");
}
if (false) {
	ClientSocket.prototype.send = function (code,msg,type) {
		setTimeout(function () {
			protoreader.reply.call(this,code,msg,type);
		}.bind(this),2000);
	}
} else {
	ClientSocket.prototype.send = protoreader.reply;
}
function toMongoId(buf) {
	return new ObjectID(buf.toString('hex'));
}
function compareObjectID(a,b) {
	if (!b) return false;
	return a.toString() == b.toString();
}
function containsObjectID(list,id) {
	for (var x=0; x<list.length; x++) {
		if (compareObjectID(id,list[x])) return true;
	}
	return false;
}
ClientSocket.prototype.handle = function (code,args) {
	if ([codes.scLogin].indexOf(code) == -1) this.log('handle %s',codes.reverse[code]);
	if (code == codes.scLogout) {
		Game.handleDisconnect(this,'logout');
		this.logout();
		this.send(codes.srLogout);
		return;
	} else if (code == codes.scPing) {
		var params = pb.Parse(args,'Poker.PingParams');
		params.servertime = Date.now();
		this.send(codes.srPong,params,'Poker.PingReply');
		return;
	}
	switch (this.state) {
	case 1: // need to login
		switch (code) {
		case codes.scLogin:
			var params = pb.Parse(args,'Poker.LoginParams');
			allUsers.findOne({email:params.username},function (err,row) {
				if (row) {
					if (row.changecode) {
						var age = Date.now() - row.changetime;
						console.log('code age',age);
						if (age > (sharedconfig.changeexpire*1000)) {
							allUsers.update({_id:row._id},{$unset:{changecode:"",changetime:""}},function (err,updated) {
								this.doLogin(row,params.password);
							}.bind(this));
							return;
						} else {
							this.send(codes.srLoginReply,{status:'lrInvalid'},'Poker.LoginReply');
						}
						return;
					}
					this.doLogin(row,params.password);
				} else {
					allUsers.findOne({displayname:params.username},function (err,row) {
						if (!row) {
							this.send(codes.srLoginReply,{status:'lrInvalid'},'Poker.LoginReply');
							return;
						}
						this.doLogin(row,params.password);
					}.bind(this));
				}
			}.bind(this));
			break;
		case codes.scRegister:
			var params = pb.Parse(args,'Poker.RegisterParams');
			console.log('register params',params);
			var doc = {email:params.email, displayname:params.displayName, tokens:100, authed:false };
			doc.authcode = uuid.v4();
			if (doc.email.indexOf('@') < 1) {
				console.log('email invalid',doc.email.indexOf('@'),doc.email);
				this.send(codes.srRegisterReply,{status:'regInvalidEmail'},'Poker.RegisterReply');
				return;
			}
			if (doc.email.length > sharedconfig.stringSizes.email) {
				this.send(codes.srRegisterReply,{status:'regInvalidEmail'},'Poker.RegisterReply');
				return;
			}
			if (doc.displayname.length > sharedconfig.stringSizes.username) {
				this.send(codes.srRegisterReply,{status:'regInvalidName'},'Poker.RegisterReply');
				return;
			}
			if (params.password.length > sharedconfig.stringSizes.password) {
				this.reply(0,"password too long");
				return;
			}
			deck.getRandom(16,function (salt) {
				var hasher = crypto.createHash('sha256');
				hasher.update(salt);
				hasher.update(params.password);
				var hash = hasher.digest();
				doc.password = hash;
				doc.salt = salt;
				// FIXME, case insensitive
				allUsers.findOne({email:params.email},function (err,row) {
					if (row) {
						console.log('found it',row);
						console.log('error, dup!');
						this.send(codes.srRegisterReply,{status:'regDuplicateEmail'},'Poker.RegisterReply');
					} else {
						allUsers.findOne({displayname:params.displayName},function (err,row) {
							if (row) {
							this.send(codes.srRegisterReply,{status:'regDupUsername'},'Poker.RegisterReply');
							} else {
								allUsers.insert(doc,function(err,result) {
									if (err) {
										console.log('error 1',err);
										process.exit(1);
									}
									var test = new SmtpConnection();
									var link = domain+'confirm?code='+doc.authcode;
									test.sendMail(doc.email,'From: clever@angeldsis.com\r\nSubject: test\r\n\r\nConfirmation link: '+link,function cb(err,ret) {
										console.log('cb',err,ret);
										if (err) {
											if (['ENODATA','ENOTFOUND'].indexOf(err.code) != -1) {
												this.log('invalid email server');
												this.send(codes.srRegisterReply,{status:'regInvalidEmail'},'Poker.RegisterReply');
												allUsers.remove({_id:result[0]._id},function (err,res) {
													this.log('delete done',err,res,result);
												}.bind(this));
												return;
											}
											this.log('internal error sending email');
											this.reply(0,"internal error");
											return;
										}
										this.send(codes.srRegisterReply,{status:'regSuccess'},'Poker.RegisterReply');
									}.bind(this));
								}.bind(this));
							}
						}.bind(this));
					}
				}.bind(this));
			}.bind(this));
			break;
		case codes.scForgotPassword:
			var params = pb.Parse(args,'Poker.ForgotPasswordParams');
			console.log('forgot args',params);
			var email = params.email;
			var doc = {};
			doc.forgotcode = uuid.v4();
			doc.forgottime = Date.now();
			allUsers.findOne({email:email},function (err,row) {
				if (!row) {
					//this.reply(codes.SR_FORGOT_PASSWORD_OK,"invalid");
				}
				allUsers.update({_id:row._id},{$set:doc},function (err,res) {
					var test = new SmtpConnection();
					var link = domain+'passwordreset?code='+doc.forgotcode;
					test.sendMail(row.email,'From: clever@angeldsis.com\r\nSubject: test\r\n\r\nClick here to reset your password: '+link,function cb(err,ret) {
						console.log('cb',err,ret);
						if (err) {
							this.reply("000","internal error");
							return;
						}
						//this.send(codes.SR_FORGOT_PASSWORD_OK);
					}.bind(this));
				}.bind(this));
			}.bind(this));
			break;
		}
		break;
	case 2: // in the main lobby
		switch (code) {
		case codes.scStatus:
			var query = {$or:[{owner:this.userid},{members:this.userid}]};
			// owner should see password
			// all need to see name, _id, seq, private, chips, and members
			allClubs.find(query).toArray(function(err,clubs) {
				var status = {};
				status.clubs = clubs;
				var x,y;
				var userlist = [];
				var clubids = [];
				for (x=0; x<clubs.length; x++) {
					var c = clubs[x];
					if (userlist.indexOf(c.owner) == -1) userlist.push(c.owner);
					if (clubs[x].owner.equals(this.userid)) {
						if (clubs[x].password == null) delete clubs[x].password;
					} else {
						delete clubs[x].password;
					}
					clubids.push(c._id);
					clubs[x] = makeClubProtobuf(clubs[x],userlist);
				}
				allUsers.find({_id:{$in:userlist}},{displayname:"",_id:"",chips:"",avatar:""}).toArray(function(err,users) {
					for (var x=0; x<users.length; x++) {
						users[x] = makeUserProtobuf(users[x]);
					}
					status.users = users;
					allUsers.findOne({_id:this.userid},function(err,self) {
						status.self = makeUserProtobuf(self);
						allGames.find({clubid:{$in:clubids}}).toArray(function (err,games) {
							if (err) {
								this.reply(0,"internal error");
								return;
							}
							for (var x=0; x<games.length; x++) {
								games[x] = makeGameProtobuf(games[x]);
							}
							//this.log('games list',games);
							status.games = games;
							//this.reply(codes.SR_STATUS,JSON.stringify(status));
							this.send(codes.srStatus,status,'Poker.StatusReply');
							//this.log('status reply:',status);
						}.bind(this));
					}.bind(this));
				}.bind(this));
			}.bind(this));
			break;
		/*case codes.CMD_GETDECK:
			console.log(args);
			var deck = new Deck();
			deck.shuffle(function shuffled(){
				console.log(deck);
				console.log(deck.prettyPrint());
				this.send(codes.SR_DECKREPLY,{deck:deck.prettyPrint()},'Poker.GetDeckReply');
			}.bind(this));
			break;*/
		case codes.scListPublicClubs:
			allClubs.find({is_private:false},{seq:1,name:1,members:1,password:1}).toArray(function (err,arr) {
				for (var x=0; x<arr.length; x++) {
					if (arr[x].members) {
						arr[x].member_count = arr[x].members.length + 1;
						delete arr[x].members;
					} else arr[x].member_count = 1;
					arr[x]._id = new Buffer(arr[x]._id.toString(),'hex');
					if (arr[x].password && (arr[x].password.length > 0)) arr[x].has_password = true;
					else arr[x].has_password = false;
					delete arr[x].password;
				}
				this.send(codes.srListClubs,{clubs:arr},'Poker.ListClubsReply');
				//this.reply(codes.SR_LIST_CLUBS,JSON.stringify(arr));
			}.bind(this));
			break;
		case codes.scCreateClub:
			var params = pb.Parse(args,'Poker.Club');
			//if (parts.length < 3) {
			//	this.reply(codes.SR_JOINCLUB_OK,"missing arguments");
			//	return;
			//}
			var priv = params.is_private;
			var pass = params.password;
			var clubname = params.name;
			if (clubname.length > sharedconfig.stringSizes.clubname) {
				this.send(codes.srCreateClubReply,{status:'csInvalidName'},'Poker.ClubCommandReply');
				return;
			}
			if (pass && (pass.length > sharedconfig.stringSizes.invcode)) {
				this.send(codes.srCreateClubReply,{status:'csInvalidPassword'},'Poker.ClubCommandReply');
				return;
			}
			// FIXME, dont allow a blank pw on priv clubs
			allClubs.findOne({name:{$regex:new RegExp('^'+clubname+'$','i')}},function (err,row) {
				if (row) {
					this.log('SR_CREATECLUB_NAME_EXISTS',err);
					this.send(codes.srCreateClubReply,{status:'csNameExists'},'Poker.ClubCommandReply');
					return;
				}
				var doc = {is_private:priv,password:pass,name:clubname, owner:this.userid, chips:100000,rake:params.rake};
				allUsers.findOne({_id:this.userid},function (err,res) {
					if (res.clubCreateTokens < 1) {
						this.send(codes.srCreateClubNoTokens);
						return;
					}
					allUsers.update({_id:this.userid},{$inc:{clubCreateTokens:-1}},function (err,res) {
						if (err) {
							this.log('shouldnt happen 012 1',err);
							this.send(codes.srCreateClubReply,{status:'csNameExists'},'Poker.ClubCommandReply');
							return;
						}
						this.log('dropped tokens',err,res);
						getNextSequence('club',function (seq) {
							doc.seq = seq;
							allClubs.insert(doc,function(err,result) {
								if (err) {
									this.log('shouldnt happen 012',err);
									this.send(codes.srCreateClubReply,{status:'csNameExists'},'Poker.ClubCommandReply');
									return;
								}
								var out = makeClubProtobuf(result[0]);
								this.send(codes.srCreateClubReply,{status:'csSuccess',club:out},'Poker.ClubCommandReply');
							}.bind(this));
						}.bind(this));
					}.bind(this));
				}.bind(this));
			}.bind(this));
			break;
		case codes.scJoinClub:
			var params = pb.Parse(args,'Poker.Club');
			var clubseq = params.seq;
			var pw = params.password;
			this.log('join1',clubseq,pw);
			allClubs.findOne({seq:clubseq},function (err,item) {
				if (!item) {
					this.send(codes.srJoinClubReply,{status:'csInvalidClubId'},'Poker.ClubCommandReply');
					return;
				}
				if (item.owner.equals(this.userid)) {
					this.send(codes.srJoinClubReply,{status:'csAlreadyMember'},'Poker.ClubCommandReply');
					return;
				}
				if (item.members) {
					for (var x=0; x<item.members.length; x++) {
						if (item.members[x].equals(this.userid)) {
							this.log('already a member');
							this.send(codes.srJoinClubReply,{status:'csAlreadyMember'},'Poker.ClubCommandReply');
							return;
						}
					}
				}
				if (item.is_private && (pw != item.password)) {
					this.send(codes.srJoinClubReply,{status:'csBadPassword'},'Poker.ClubCommandReply');
					return;
				}
				allClubs.update({_id:item._id},
					{ $addToSet: { members: this.userid} },
					function (err,res) {
						// FIXME club
						this.log('join2',err,res);
						allClubs.findOne({_id:item._id},function cb(err,row) {
							allGames.find({clubid:item._id}).toArray(function (err,games) {
								for (var x=0; x<games.length; x++) {
									games[x] = makeGameProtobuf(games[x]);
								}
								var userlist = [ row.owner ];
								var clubinfo = makeClubProtobuf(row,userlist);
								var joininfo = {status:'csSuccess',club:clubinfo,games:games};
								this.send(codes.srJoinClubReply,joininfo,'Poker.ClubCommandReply');
								this.log('userlist to inform:',userlist);
								// FIXME, dont send to current user
								for (var x=0; x<userlist.length; x++) {
									var user = activeUsers[userlist[x]];
									if (user == this) continue;
									if (user) user.send(codes.seClubChange,clubinfo,'Poker.Club');
								}
							}.bind(this));
						}.bind(this));
					}.bind(this));
				this.log('join3',err,item,this.userid);
			}.bind(this));
			break;
		case codes.scKickPlayer:
			var params = pb.Parse(args,'Poker.KickPlayerParams');
			var clubid = params.club_seq;
			var userid = toMongoId(params.player_mongo_id);
			this.log('kicking',clubid,userid);
			// FIXME, code 023 kicking somebody not in the club
			allClubs.findOne({seq:clubid},function (err,club) {
				if (!club.owner.equals(this.userid)) {
					this.reply("000","your not owner");
					this.log('attempted to kick while not owner');
					return;
				}
				allClubs.update({seq:clubid},
					{ $pull:{members:userid}},
					function (err,res) {
						if (res == 0) {
							this.send(codes.srKickPlayerReply,{status:'csInvalidClubId'},'Poker.ClubCommandReply');
							return;
						}
						allClubs.findOne({_id:club._id},function cb(err,row) {
							var userlist = [ userid ];
							var out = makeClubProtobuf(row,userlist);
							this.send(codes.srKickPlayerReply,{status:'csSuccess',club:out},'Poker.ClubCommandReply');
							this.log('userlist to inform:',userlist);
							for (var x=0; x<userlist.length; x++) {
								var user = activeUsers[userlist[x]];
								if (user) user.send(codes.seClubChange,out,'Poker.Club');
							}
						}.bind(this));
					}.bind(this));
			}.bind(this));
			break;
		case codes.scLeaveClub:
			var params = pb.Parse(args,'Poker.Club');
			var clubid = params.seq;
			// FIXME, check for owner leaving
			allClubs.update({seq:clubid},
				{ $pull:{members:this.userid}},
				function (err,res) {
					if (res == 0) this.send(codes.srLeaveClubReply,{status:'csInvalidClubId'},'Poker.ClubCommandReply');
					else {
						// FIXME club
						allClubs.findOne({seq:clubid},function cb(err,row) {
							var userlist = [ ];
							var out = makeClubProtobuf(row,userlist);
							this.send(codes.srLeaveClubReply,{status:'csSuccess',club:out},'Poker.ClubCommandReply');
							this.log('userlist to inform:',userlist);
							for (var x=0; x<userlist.length; x++) {
								var user = activeUsers[userlist[x]];
								if (user) user.send(codes.seClubChange,out,'Poker.Club');
							}
						}.bind(this));
					}
				}.bind(this));
			break;
		case codes.scGiveClubOwnership:
			var params = pb.Parse(args,'Poker.GiveClubOwnershipParams');
			var clubseq = params.club_seq;
			var newowner = toMongoId(params.player_mongo_id);
			this.log('giving ownership away',clubseq,newowner);
			allClubs.findOne({seq:clubseq},function (err,club) {
				if (!club) {
					this.send(codes.srOwnershipGiveAwayInvalidClubId,makeClubProtobuf(club),'Poker.Club');
					return;
				}
				if (club.owner.equals(this.userid)) {
					if (containsObjectID(club.members,newowner)) {
						this.log('adding self to members',this.userid);
						allClubs.update({_id:club._id},
							{$addToSet:{members:this.userid}},function (err,res) {
								this.log('result 2',err,res);
								allClubs.update({_id:club._id},{
								 $set:{owner:newowner},
								 $pull:{members:newowner}
								},function (err,res) {
									this.log('err:%j res:%d',err,res);
									allClubs.findOne({_id:club._id},function cb(err,row) {
										var userlist = [ row.owner ];
										var out = makeClubProtobuf(row,userlist);
										this.send(codes.srOwnershipGiveAwayOk,out,'Poker.Club');
										this.log('i am %s, target is %s',this.userid,newowner);
										this.log('userlist to inform:',userlist);
										for (var x=0; x<userlist.length; x++) {
											var user = activeUsers[userlist[x]];
											if (user === this) continue;
											if (user) user.send(codes.seClubChange,out,'Poker.Club');
										}
									}.bind(this));
								}.bind(this));
						}.bind(this));
					} else {
						this.send(codes.srOwnershipGiveAwayInvalidPlayerId,makeClubProtobuf(club),'Poker.Club');
					}
				} else {
					this.send(codes.srOwnershipGiveAwayNotOwner,makeClubProtobuf(club),'Poker.Club');
				}
			}.bind(this));
			break;
		case codes.scChangeClubDetails:
			var params = pb.Parse(args,'Poker.Club');
			var clubseq = params.seq;
			this.log('change club details %j',params);
			allClubs.findOne({seq:clubseq},function (err,club) {
				if (!club) {
					this.reply("000","club not found");
					return;
				}
				if (!club.owner.equals(this.userid)) {
					this.reply("000","your not owner");
					return;
				}
				var mods = {$set:{rake:params.rake}};
				var doit = false;
				var autofinish = true;
				if (club.name == params.name) delete params.name;
				if (params.name) {
					doit = true;
					mods.$set.name = params.name;
					if (params.name.length > sharedconfig.stringSizes.clubname) {
						this.reply("000","name too long");
						return;
					}
					allClubs.findOne({name:{$regex:new RegExp('^'+params.name+'$','i')}},function (err,row) {
						if (row) {
							this.send(codes.srChangeClubDetailsReply,{status:'csNameExists'},'Poker.ClubCommandReply');
						} else finish();
					}.bind(this));
					autofinish = false;
				}
				if ((params.password) || (params.password == '')) {
					doit = true;
					mods.$set.password = params.password;
				}
				if ((params.is_private == 1) || (params.is_private == 0)) {
					mods.$set.is_private = params.is_private == 1;
					doit = true;
				}
				if (!doit) {
					this.log(params);
					this.reply("000","no changes found");
					return;
				}
				var that = this;
				function finish() {
					allClubs.update({_id:club._id},mods,function (err,ret) {
						this.log('detail update',clubseq,params,mods,err,ret);
						if (err) {
							this.reply(codes.srChangeClubDetailsReply,{status:'csNameExists'},'Poker.ClubCommandReply');
						} else {
							// FIXME club
							allClubs.findOne({_id:club._id},function cb(err,row) {
								var userlist = [ ];
								allGames.find({clubid:row._id}).toArray(function (err,games) {
									var out = makeClubProtobuf(row,userlist);
									for (var x=0; x<games.length; x++) {
										games[x] = makeGameProtobuf(games[x]);
									}
									
									this.send(codes.srChangeClubDetailsReply,{status:'csSuccess',club:out,games:games},'Poker.ClubCommandReply');
									this.log('userlist to inform:',userlist);
									for (var x=0; x<userlist.length; x++) {
										var user = activeUsers[userlist[x]];
										if (user) user.send(codes.seClubChange,out,'Poker.Club');
									}
								}.bind(this));
							}.bind(this));
						}
					}.bind(that));
				}
				if (autofinish) finish();
			}.bind(this));
			break;
		case codes.scDeleteClub:
			var params = pb.Parse(args,'Poker.Club');
			var clubseq = params.seq;
			this.log('deleting club',params);
			allClubs.findOne({seq:clubseq},function (err,club) {
				if (!club) {
					this.log('club not found');
					this.reply("000","club not found");
					return;
				}
				if (!club.owner.equals(this.userid)) {
					this.log('not owner');
					this.reply("000","your not owner");
					return;
				}
				allClubs.remove({_id:club._id},function (err,res) {
					this.log('delete worked',err,res);
					// FIXME, force end games in this club?
					
					var userlist = [];
					var out = makeClubProtobuf(club,userlist);
					this.send(codes.srClubDisbandOk,out,'Poker.Club');
					this.log('userlist to inform:',userlist);
					for (var x=0; x<userlist.length; x++) {
						var user = activeUsers[userlist[x]];
						if (user) user.send(codes.seClubDeleted,out,'Poker.Club');
					}
				}.bind(this));
			}.bind(this));
			break;
		case codes.scTransferChips:
			var params = pb.Parse(args,'Poker.TransferChipsParams');
			var userid = toMongoId(params.player_mongo_id);
			var chips = params.chip_amount;
			this.log('transfering chips',userid,chips);
			allUsers.findOne({_id:this.userid},function (err,self) {
				if (!self) {
					this.reply("000","self not found");
					return;
				}
				if (self.chips < chips) {
					this.send(codes.srTransferChipsInvalidAmount);
					return;
				}
				/*/ FIXME, enforce limit per player
				if (chips > 2000) {
					this.send(codes.srClubTransferChipsInvalidAmount);
					return;
				}*/
				if (chips < 1) {
					this.reply(codes.srTransferChipsInvalidAmount);
					return;
				}
				allUsers.update({_id:userid},
					{ $inc:{chips:chips}},
					function (err,res) {
						this.log('step 1',err,res);
						allUsers.update({_id:this.userid},
						{ $inc:{chips:-chips}},
						function (err,res) {
							this.log('step 2',err,res);
							this.send(codes.srTransferChipsOk,args,'raw');
							var dest = activeUsers[userid];
							if (dest) dest.send(codes.seTransferChips,{chip_amount:chips,player_mongo_id:new Buffer(this.userid.toString(),'hex')},'Poker.TransferChipsParams');
							// FIXME, inform other club members
						}.bind(this));
					}.bind(this));
			}.bind(this));
			break;
		case codes.scChangeEmail:
			var params = pb.Parse(args,'Poker.ChangeEMailParams');
			var newemail = params.new_mail;
			// FIXME return 037 if email already exists
			if (newemail.indexOf('@') < 1) {
				console.log('email invalid',doc.email.indexOf('@'),doc.email);
				this.reply(0,'invalid email');
				return;
			}
			allUsers.findOne({email:newemail},function (err,dup) {
				if (dup) {
					this.send(codes.srChangeMailReply,{status:'cmDuplicateMail'},'Poker.ChangeMailReply');
					return;
				}
				var authcode = uuid.v4();
				allUsers.update({_id:this.userid},{$set:{newemail:newemail, changecode:authcode, changetime: Date.now()}},function (err,res) {
					if (err) {
						console.log('email change error',err);
						this.reply("000","internal error");
						return;
					}
					var test = new SmtpConnection();
					var link = domain+'confirmchange?code='+authcode;
					test.sendMail(newemail,'Subject: test\r\n\r\nConfirmation link: '+link,function cb(err,ret) {
						console.log('cb',err,ret);
						if (err) {
							this.send(codes.srChangeMailReply,{status:'cmInvalidEmail'},'Poker.ChangeMailReply');
							return;
						}
						this.send(codes.srChangeMailReply,{status:'cmSuccess'},'Poker.ChangeMailReply');
					}.bind(this));
				}.bind(this));
			}.bind(this));
			break;
		case codes.scChangePassword:
			var params = pb.Parse(args,'Poker.ChangePasswordParams');
			if (params.new_password.length > sharedconfig.stringSizes.password) {
				this.reply(0,'password too long');
				return;
			}
			deck.getRandom(16,function (salt) {
				this.log('salt',salt);
				var hasher = crypto.createHash('sha256');
				hasher.update(salt);
				hasher.update(params.new_password);
				var hash = hasher.digest();
				this.log('pw hash is',hash);
				allUsers.update({_id:this.userid},{$set:{password:hash,salt:salt}},function (err,res) {
					if (err) {
						this.reply("000","internal error");
						return;
					}
					this.send(codes.srChangePasswordOk);
				}.bind(this));
			}.bind(this));
			break;
		case codes.scSetAvatar:
			var params = pb.Parse(args,'Poker.SetAvatarParams');
			var id = params.avatar_id.toString('base64');
			delete params.avatar_id;
			this.log('changing avatar',id);
			avatars.findOne({_id:id},function(err,row) {
				if (err) {
					this.reply("000","internal error");
					return;
				}
				if (!row) {
					this.send(codes.srSetAvatarReply,{status:'saNotFound'},'Poker.SetAvatarReply');
					return;
				}
				allUsers.update({_id:this.userid},{$set:{avatar:id}},function (err,res) {
					if (err) {
						this.reply("000","internal error");
						return;
					}
					// FIXME, inform other users
					this.send(codes.srSetAvatarReply,{status:'saSuccess'},'Poker.SetAvatarReply');
				}.bind(this));
			}.bind(this));
			break;
		case codes.scCreateGame:
			var params = pb.Parse(args,'Poker.Game');
			var clubseq = params.clubseq;
			var game_type = params.game_type;
			var game_limit = params.game_limit;
			var small_blind = params.small_blind;
			var big_blind = params.big_blind;
			var seats = params.seats;
			var gamename = params.gamename;
			if (checkGameParams(small_blind,big_blind,gamename,seats,game_type,game_limit,params.buyin_min,params.buyin_max)) {
				this.log('invalid create game:%j',params);
				this.reply(0,"invalid params");
				return;
			}
			var doc = {game_type:game_type, small_blind:small_blind, big_blind:big_blind, seats:seats, creator_mongo_id:this.userid, clubseq:clubseq, gamename:gamename, game_limit:game_limit, buyin_min:params.buyin_min, buyin_max:params.buyin_max,rake:0};
			allClubs.findOne({seq:clubseq},function (err,club) {
				if (err) {
					this.reply(0,"internal error");
					return;
				}
				if (!club) {
					this.reply(0,"club not found");
					return;
				}
				doc.clubid = club._id;
				allGames.insert(doc,function (err,game) {
					if (err) {
						this.reply(0,"internal error");
						return;
					}
					this.log('inserted',game[0]);
					var g = makeGameProtobuf(game[0]);
					this.send(codes.srCreateGameOk,g,'Poker.Game');
					if (!club.members) return;
					for (var x=0; x<club.members.length; x++) {
						var conn = activeUsers[club.members[x]];
						if (!conn) continue;
						conn.send(codes.seGameCreate,g,'Poker.Game');
					}
				}.bind(this));
			}.bind(this));
			break;
		case codes.scDeleteGame:
			var params = pb.Parse(args,'Poker.Game');
			var id = new toMongoId(params._id);
			allGames.findOne({_id:id},function (err,game) {
				if (err) {
					this.reply(0,"internal error");
					return;
				}
				if (!game) {
					this.reply(0,"game not found");
					return;
				}
				// FIXME, move finished games to another list
				allGames.remove({_id:id},function (err,ret) {
					if (err) {
						this.reply(0,"internal error");
						return;
					}
					this.log('removed',err,ret);
					// FIXME, remove Game object
					allClubs.findOne({_id:game.clubid},function (err,club) {
						var g = makeGameProtobuf(game);
						this.send(codes.srDeleteGameOk,g,'Poker.Game');
						for (var x=0; x<club.members.length; x++) {
							var conn = activeUsers[club.members[x]];
							if (!conn) continue;
							conn.send(codes.seGameDelete,g,'Poker.Game');
						}
					}.bind(this));
				}.bind(this));
			}.bind(this));
			break;
		case codes.scEditGame:
			var params = pb.Parse(args,'Poker.Game');
			this.log('edit game',params);
			var id = new toMongoId(params._id);
			this.log('id is',id);
			var game_type = params.game_type;
			var game_limit = params.game_limit;
			var small_blind = params.small_blind;
			var big_blind = params.big_blind;
			var seats = params.seats;
			var gamename = params.gamename;
			if (checkGameParams(small_blind,big_blind,gamename,seats,game_type,game_limit,params.buyin_min,params.buyin_max)) {
				this.log('invalid create game:%j',params);
				this.reply(0,"invalid params");
				return;
			}
			// FIXME, run game.preedit
			var doc = {$set:{game_type:game_type, small_blind:small_blind, big_blind:big_blind, seats:seats, gamename:gamename, game_limit:game_limit, buyin_min:params.buyin_min, buyin_max:params.buyin_max }};
			allGames.update({_id:id},doc,function (err,res) {
				if (err) {
					this.reply(0,"internal error");
					return;
				}
				this.log('edit game',res);
				if (activeGames[id]) activeGames[id].edited(params);
				// FIXME performance?
				allGames.findOne({_id:id},function (err,game) {
					allClubs.findOne({_id:game.clubid},function (err,club) {
						var g = makeGameProtobuf(game);
						this.send(codes.srEditGameOk,g,'Poker.Game');
						for (var x=0; x<club.members.length; x++) {
							var conn = activeUsers[club.members[x]];
							if (!conn) continue;
							conn.send(codes.seGameChange,g,'Poker.Game');
						}
					}.bind(this));
				}.bind(this));
			}.bind(this));
			break;
		case codes.seChat:
			var event = pb.Parse(args,'Poker.ChatEvent');
			this.handleChatEvent(event,Date.now());
			break;
		case codes.scTableJoin:
			var params = pb.Parse(args,'Poker.Game');
			var id = new toMongoId(params._id);
			this.log('table join',id);
			Game.getGame(id,function (err,game) {
				this.log('game info',game.obj.clubid);
				allClubs.findOne({_id:game.obj.clubid},function (err,club) {
					if (club.suspended) {
						for (var x=0; x<club.suspended.length; x++) {
							console.log(club.suspended[x],this.userid);
							if (compareObjectID(club.suspended[x],this.userid)) {
								this.reply(0,'your suspended in that club'); // FIXME
								return;
							}
						}
					}
					if (!compareObjectID(this.userid,club.owner) && (!club.members || !containsObjectID(club.members,this.userid))) {
						this.log('i am not a member');
						this.reply(0,'your not a member of that club'); // FIXME
					} else if (game.join(this)) this.send(codes.seTableStatus,game.getTableStatus(this,false,[]),'Poker.TableStatus');
				}.bind(this));
			}.bind(this));
			break;
		case codes.scTableLeave:
			var params = pb.Parse(args,'Poker.Game');
			var id = new toMongoId(params._id);
			delete params._id;
			Game.getGame(id,function (err,game) {
				game.leave(this,'protocol');
			}.bind(this));
			break;
		case codes.scTableSit:
			var params = pb.Parse(args,'Poker.TableSit');
			var id = new toMongoId(params.game_id);
			delete params.game_id;
			Game.getGame(id,function (err,game) {
				var min = game.obj.buyin_min * game.obj.big_blind;
				var max = game.obj.buyin_max * game.obj.big_blind;
				if ((params.chips > max) || (params.chips < min)) {
					this.reply(0,'buyin out of range');
					this.log('buyin:%d min:%d max:%d',params.chips,min,max);
					return;
				}
				this.log('getting lock %s',this.userid);
				var temp = this.userid;
				game.Lock.writeLock(function (release) {
					this.log('got lock %s',temp);
					game.sitDown(this,params,function (sucess,events) {
						if (sucess) {
							var status = game.getTableStatus(this,true,events);
							this.send(codes.srTableSitOk,status,'Poker.TableStatus');
							game.broadcastStatus(this,true,events); // sendEvent
						}
						this.log('releasing lock');
						release();
					}.bind(this));
				}.bind(this));
			}.bind(this));
			break;
		case codes.scTableStandUp:
			var params = pb.Parse(args,'Poker.Game');
			var id = toMongoId(params._id);
			Game.getGame(id,function (err,game) {
				game.Lock.writeLock(function (release) {
					var x = game.findSeat(this);
					var seating = game.members[x];
					if (!seating) {
						this.log('standup error');
						release();
						return;
					}
					game.standUp(this,function (folded,events) {
						this.log('events are %j',events);
						if (folded && (game.current_seat >= 0)) game.startTimer(game.current_seat);
						this.send(codes.srTableStandUpOk,game.getTableStatus(this,true,events),'Poker.TableStatus');
						game.broadcastStatus(this,true,events);
						release();
					}.bind(this));
				}.bind(this));
			}.bind(this));
			break;
		case codes.scSuspendPlayer:
			var params = pb.Parse(args,'Poker.ChangeSuspendState');
			this.log(params);
			var clubid = toMongoId(params.club_mongo_id);
			var playerid = toMongoId(params.player_mongo_id);
			var broadcast = function broadcast(code) {
				// FIXME club
				allClubs.findOne({_id:clubid},function cb(err,row) {
					var userlist = [ ];
					var out = makeClubProtobuf(row,userlist);
					this.send(code,out,'Poker.Club');
					this.log('userlist to inform:',userlist);
					for (var x=0; x<userlist.length; x++) {
						var user = activeUsers[userlist[x]];
						if (user) user.send(codes.seClubChange,out,'Poker.Club');
					}
				}.bind(this));
			}.bind(this);
			if (params.suspended) {
				allClubs.update({_id:clubid},
					{ $addToSet: { suspended: playerid} },
					function (err,res) {
						this.log('suspend push',err,res);
						broadcast(codes.srSuspendPlayerOk);
					}.bind(this)
				);
			} else {
				allClubs.update({_id:clubid},
					{ $pull:{suspended:playerid}},
					function (err,res) {
						this.log('suspend pull',err,res);
						broadcast(codes.srReinstatePlayerOk);
					}.bind(this)
				);
			}
			break;
		case codes.scGetPlayers:
			var params = pb.Parse(args,'Poker.GetUserParams');
			this.log('getting players: %j',params);
			for (var x=0; x<params.user_mongo_ids.length; x++) {
				params.user_mongo_ids[x] = toMongoId(params.user_mongo_ids[x]);
			}
			allUsers.find({_id:{$in:params.user_mongo_ids}}).toArray(function (err,users) {
				this.log(params.user_mongo_ids,users);
				var out = {users:[]};
				for (var x=0; x<users.length; x++) {
					out.users[x] = makeUserProtobuf(users[x]);
				}
				this.send(codes.srGetPlayers,out,'Poker.GetUserParams');
			}.bind(this));
			break;
		case codes.scFold:
			var params = pb.Parse(args,'Poker.Game');
			var id = toMongoId(params._id);
			Game.getGame(id,function (err,game) {
				game.Lock.writeLock(function (release) {
					var x = game.findSeat(this);
					// FIXME, do something with his cards
					var seating = game.members[x];
					if (x != game.current_seat) {
						// FIXME, fail
						this.reply(0,'fold while not active player');
						console.log('fold fail 2');
						release();
						return;
					} else if (seating && seating.status == 'psInHand') {
						game.fold(x,function (events) {
							game.broadcastStatus(null,true,events);
							if (game.current_seat >= 0) game.startTimer(game.current_seat);
							release();
						}.bind(this));
					} else {
						this.log('fold error',util.inspect(seating));
						release();
					}
				}.bind(this));
			}.bind(this));
			break;
		case codes.scPutChips:
			var params = pb.Parse(args,'Poker.PutChips');
			var id = toMongoId(params.table_mongo_id);
			delete params.table_mongo_id;
			this.log('putChips %j',params);
			Game.getGame(id,function (err,game) {
				this.log('getting lock');
				game.Lock.writeLock(function (release) {
					var seat = game.findSeat(this);
					if (seat != game.current_seat) {
						// FIXME, fail
						this.reply(0,'putchips while not active player');
						console.log('putChips fail 2');
						release();
						return;
					}
					game.putChips(this,params.chip_amount,function (events){
						assert(game.members[seat].chips >= 0);
						if (['tsWinning'].indexOf(game.state) == -1) game.startTimer(game.current_seat);
						game.broadcastStatus(null,true,events);
						release();
						this.log('unlocked');
						game.checkDelayedLeave();
					}.bind(this));
				}.bind(this));
			}.bind(this));
			break;
		case codes.scTableAddOn:
			var params = pb.Parse(args,'Poker.TableSit');
			if (params.chips < 1) {
				this.reply(0,'you cant buyout');
				return;
			}
			var id = new toMongoId(params.game_id);
			delete params.game_id;
			Game.getGame(id,function (err,game) {
				var seatIdx = game.findSeat(this);
				if (seatIdx === undefined) {
					this.reply(0,'your not sitting');
					return;
				}
				if (['psOutOfPlay','psFolded','psOutOfHand'].indexOf(game.members[seatIdx].status) == -1) {
					this.reply(0,'your not out of play!');
					return;
				}
				if ((params.chips + game.members[seatIdx].chips) > (game.obj.buyin_max * game.obj.big_blind)) {
					this.send(codes.srTableAddonOverLimit,game.getTableStatus(this),'Poker.TableStatus');
					return;
				}
				game.AddOn(this,params.chips);
			}.bind(this));
			break;
		case codes.scTablePlayNow:
			var params = pb.Parse(args,'Poker.Game');
			var id = toMongoId(params._id);
			Game.getGame(id,function (err,game) {
				game.Lock.writeLock(function (release) {
					var seatIdx = game.findSeat(this);
					if (seatIdx === undefined) {
						this.reply(0,'your not sitting');
						release();
						return;
					}
					if (game.members[seatIdx].chips == 0) {
						this.reply(0,'you dont have enough chips');
						release();
						return;
					}
					if (game.members[seatIdx].status != 'psOutOfPlay') {
						game.members[seatIdx].sitOutNextRound = false;
						release();
						return;
					}
					game.members[seatIdx].status = 'psOutOfHand';
					if (game.state == 'tsIdle') game.stateMachine(finish,null,{silent:true},[]);
					else finish([]);
					function finish(events) { // teDeal
						game.broadcastStatus(null,true,events); // FIXME spam?
						release();
						if (game.state == 'tsPreFlop') {
							// FIXME game.startTimer(game.current_seat);
						}
					}
				}.bind(this));
			}.bind(this));
			break;
		case codes.scTableSitOutNextHand:
			var params = pb.Parse(args,'Poker.TableBoolFlag');
			var id = toMongoId(params.table_mongo_id);
			Game.getGame(id,function (err,game) {
				var seatIdx = game.findSeat(this);
				if (seatIdx === undefined) {
					this.reply(0,'your not sitting');
					return;
				}
				if (['psInHand','psAllIn','psFolded','psOutOfHand'].indexOf(game.members[seatIdx].status) == -1) {
					this.reply(0,'you cant sitout if your out of play');
					return;
				}
				game.members[seatIdx].sitOutNextRound = params.flag;
			}.bind(this));
			break;
		case codes.scTableSitOutNextBB:
			var params = pb.Parse(args,'Poker.TableBoolFlag');
			var id = toMongoId(params.table_mongo_id);
			Game.getGame(id,function (err,game) {
				var seatIdx = game.findSeat(this);
				if (seatIdx === undefined) {
					this.reply(0,'your not sitting');
					return;
				}
				if (['psInHand','psAllIn','psFolded','psOutOfHand'].indexOf(game.members[seatIdx].status) == -1) {
					this.reply(0,'you cant sitout if your out of play');
					return;
				}
				game.members[seatIdx].sitOutBB = params.flag;
			}.bind(this));
		}
	}
}
function makeClubProtobuf(c,userlist) {
	// FIXME club
	if (c.members) {
		for (y=0; y<c.members.length; y++) {
			if (userlist && (userlist.indexOf(c.members[y]) == -1)) userlist.push(c.members[y]);
			c.members[y] = new Buffer(c.members[y].toString(),'hex');
		}
	}
	if (c.suspended) {
		c.suspended_members = [];
		for (y=0; y<c.suspended.length; y++) {
			c.suspended_members[y] = new Buffer(c.suspended[y].toString(),'hex');
		}
		delete c.suspended;
	}
	c._id = new Buffer(c._id.toString(),'hex');
	c.owner = new Buffer(c.owner.toString(),'hex');
	return c;
}
function makeGameProtobuf(g) {
	// FIXME game, include number of people sitting
	var gameobj = activeGames[g._id];
	if (gameobj) g.sitting = gameobj.sittingCount();
	g._id = new Buffer(g._id.toString(),'hex');
	g.creator_mongo_id = new Buffer(g.creator_mongo_id.toString(),'hex');
	return g;
}
function makeUserProtobuf(u) {
	if (u.avatar) u.avatar = new Buffer(u.avatar,'base64');
	u._id = new Buffer(u._id.toString(),'hex');
	return u;
}
function Pot(game) {
	this.value = 0;
	this.members = []
	this.trueMembers = []
}
Pot.prototype.add = function (bet,seat,game) {
	this.value += bet;

	if (this.trueMembers.indexOf(seat) == -1) this.trueMembers.push(seat);

	if (this.members.indexOf(seat) != -1) return;
	var pub = game.members[seat];
	if (!pub) return; // he stood up
	if (pub.status == 'psFolded') return;
	this.members.push(seat);
}
function Game(obj) {
	this.users = {}; // all users, even not sitting
	this.members = []; // all users, as seen by the users
	this.seats = []; // internal data for seats
	this.timebanks = {}; // timebank data for all users who have visited the table
	this.obj = obj;
	this.id = obj._id;
	activeGames[this.id] = this;
	this.state = 'tsIdle';
	this.dealer = -1;
	this.current_seat = -1;
	this.bets = [];
	this.pots = [ new Pot(this) ];
	this.minBet = 0;
	this.log('pots initialized to zero');
	this.Lock = new ReadWriteLock();
	this.omaha = this.obj.game_type == 'gtOmaha';
	this.lastplayer = [];
}
Game.prototype.getLimit = function (seat) {
	if (typeof this.bets[seat] != 'number') this.bets[seat] = 0;
	var oldbet = this.bets[seat];
	if (this.obj.game_limit == 'glNoLimit') {
		return oldbet + this.members[seat].chips;
	}

	var pot = 0;
	for (var x=0; x<this.pots.length; x++) {
		pot += this.pots[x].value;
	}
	for (var x=0; x<this.bets.length; x++) {
		if (typeof this.bets[x] != 'number') this.bets[x] = 0;
		pot += this.bets[x];
	}
	var pottotal = pot + (this.minBet - oldbet);
	var maxbet = pottotal + this.minBet;
	//this.log('pot:%d pottotal:%d maxbet:%d oldbet:%d',pot,pottotal,maxbet,oldbet);
	return maxbet;
}
Game.prototype.log = function log(format) {
	var out = Array.prototype.slice.call(arguments);
	if (format.indexOf('%') != -1) {
		out = [ util.format.apply(util,out) ]
	}
	out.unshift(this.handid);
	process.send({type:'game',name:this.obj.gamename,ts:new Date().toString(),objects:out});
}
Game.prototype.AddOn = function AddOn(conn,chips) {
	var seat = this.findSeat(conn);
	allUsers.findOne({_id:conn.userid},function (err,self) {
		if ((conn.boughtin + chips) > self.chips) {
			conn.send(codes.srTableSitNoChips,this.getTableStatus(conn),'Poker.TableStatus');
			return;
		}
		conn.boughtin += chips;
		this.members[seat].chips += chips;
		var status = this.getTableStatus(conn);
		conn.send(codes.srTableAddonOk,status,'Poker.TableStatus');
		this.broadcastStatus(conn);
	}.bind(this));
}
Game.prototype.edited = function edited(params) {
	// FIXME, more fields, also now acts as a cache for seGameChange/seGameDelete
	this.obj.seats = params.seats;
	this.obj.small_blind = params.small_blind
	this.obj.big_blind = params.big_blind;
	this.obj.buyin_min = params.buyin_min;
	this.obj.buyin_max = params.buyin_max;
	this.obj.game_limit = params.game_limit;
	this.obj.game_type = params.game_type;
	this.omaha = this.obj.game_type == 'gtOmaha';
}
Game.prototype.join = function join(conn) {
	this.users[conn.userid] = conn;
	return true;
}
Game.prototype.sitDown = function (conn,params,cb) {
	assert.equal(this.Lock.readers,-1);
	assert(conn.userid);
	var events = [];
	conn.log('sitting down',params);
	if ((params.seat_index < 0) || (params.seat_index >= this.obj.seats)) {
		conn.reply(0,'invalid seat index');
		cb(false,events);
		return;
	}
	if (this.seats[params.seat_index]) {
		conn.log('seat taken by',util.inspect(this.members[params.seat_index]),util.inspect(this.seats[params.seat_index]));
		conn.send(codes.srTableSitSeatTaken,this.getTableStatus(conn,null,[]),'Poker.TableStatus');
		cb(false,events);
	} else {
		allUsers.findOne({_id:conn.userid},function (err,userinfo) {
			conn.log('state:%d %s',conn.state,conn.userid);
			conn.log('self:',userinfo,'boughtin:',conn.boughtin,'chips:',userinfo.chips);
			if ((userinfo.chips === undefined) || (params.chips > (userinfo.chips - conn.boughtin))) {
				conn.send(codes.srTableSitNoChips,this.getTableStatus(conn,null,[]),'Poker.TableStatus');
				cb(false,events);
				return;
			}
			this.members[params.seat_index] = { hand: new Hand(), status:'psOutOfPlay', chips:params.chips, seat:params.seat_index, sitOutNextRound:false };
			if (!this.timebanks[conn.userid]) this.timebanks[conn.userid] = sharedconfig.max_timebank * 1000;
			this.seats[params.seat_index] = { conn:conn, userid:conn.userid };
			conn.boughtin += params.chips;
			// FIXME, should always be 0?
			if (this.bets[params.seat_index] == undefined) this.bets[params.seat_index] = 0;
			events.push(this.makeEvent('teSit',params.seat_index));
			finish.call(this);
		}.bind(this));
		function finish() {
			//this.broadcastStatus(conn);
			// FIXME json performance hack
			allClubs.findOne({_id:this.obj.clubid},function (err,club) {
				var g = makeGameProtobuf(JSON.parse(JSON.stringify(this.obj)));
				if (!club.members) return cb(true,events);
				for (var x=0; x<club.members.length; x++) {
					var conn2 = activeUsers[club.members[x]];
					if (!conn2) continue;
					if (conn2 === conn) continue;
					conn2.send(codes.seGameChange,g,'Poker.Game');
				}
				cb(true,events);
			}.bind(this));
		}
	}
}
Game.prototype.deal = function deal(cb,config) {
	getNextSequence('handHistory',function (seq) {
		this.handid = seq;
		this.history = {moves:[],players:[],cards:[]};
		hands = seq;
		if (this.dealer == -1) this.nextDealer();
		this.bets = [];
		for (var x=0; x<this.members.length; x++) {
			if (!this.members[x]) continue;
			if (this.members[x].status == 'psOutOfPlay') continue;
			if (this.members[x].chips == 0) {
				this.members[x].status = 'psOutOfPlay';
				this.lastplayer[x] = this.seats[x].userid;
				continue;
			}
			if (this.omaha) this.deck.draw(4,this.members[x].hand);
			else this.deck.draw(2,this.members[x].hand);
			this.bets[x] = 0;
			if (this.members[x].status == 'psOutOfHand') {
				this.seats[x].conn.log('moving into hand %s %s %j',this.seats[x].userid,this.lastplayer[x],config);
				if (!compareObjectID(this.seats[x].userid,this.lastplayer[x])) {
					if (this.members[x].chips <= this.obj.big_blind) {
						this.addHistory({seat:x,bet:this.members[x].chips,code:['forced','BB','AllIn']});
						this.setBet(x,this.members[x].chips);
						this.members[x].status = 'psAllIn';
					} else {
						this.setBet(x,this.obj.big_blind);
						this.addHistory({seat:x,bet:this.obj.big_blind,code:['forced','BB']});
					}
				}
			}
			this.members[x].status = 'psInHand';
			this.history.players[x] = this.seats[x].userid;
			this.history.cards[x+3] = this.members[x].hand.prettyPrint();
		}

		this.pots = [ new Pot(this) ];
		this.log('pots reset to zero');
		this.current_seat = this.dealer;

		this.small_blind = this.current_seat = this.getNextSeat(this.current_seat);
		if (this.headsup) this.small_blind = this.current_seat = this.getNextSeat(this.current_seat);
		if (this.bets[this.current_seat] == 0) {
			if (this.members[this.current_seat].chips <= this.obj.small_blind) {
				this.addHistory({seat:this.current_seat,bet:this.members[this.current_seat].chips,code:['SB','AllIn']});
				this.setBet(this.current_seat,this.members[this.current_seat].chips);
				this.members[this.current_seat].status = 'psAllIn';
			} else {
				this.setBet(this.current_seat,this.obj.small_blind);
				this.addHistory({seat:this.current_seat,bet:this.obj.small_blind,code:['SB']});
			}
		}
		
		this.big_blind = this.current_seat = this.getNextSeat(this.current_seat,null,true);
		if (this.bets[this.current_seat] == 0) {
			if (this.members[this.current_seat].chips <= this.obj.big_blind) {
				this.addHistory({seat:this.current_seat,bet:this.members[this.current_seat].chips,code:['BB','AllIn']});
				this.setBet(this.current_seat,this.members[this.current_seat].chips);
				this.members[this.current_seat].status = 'psAllIn';
			} else {
				this.setBet(this.current_seat,this.obj.big_blind);
				this.addHistory({seat:this.current_seat,bet:this.obj.big_blind,code:['BB']});
			}
		}
		this.current_seat = this.getNextSeat(this.current_seat);
		
		this.roundEnd();
		this.ranOut = false;
		this.flop = new Hand();
		this.turn = new Hand();
		this.river = new Hand();
		this.deck.draw(3,this.flop);
		this.deck.draw(1,this.turn);
		this.deck.draw(1,this.river);
		this.history.cards[0] = this.flop.prettyPrint();
		this.history.cards[1] = this.turn.prettyPrint();
		this.history.cards[2] = this.river.prettyPrint();
		this.state = 'tsPreFlop';
		this.log('bcast 2');
		
		handHistory.insert({seq:seq,gameid:this.obj._id,moves:this.history.moves,players:this.history.players,cards:this.history.cards,rake:this.rake},function (err,row) {
			this.log('hand made:%j',row);
			this.startTimer(this.current_seat); // FIXME, run this later
			//this.stateMachine(function () {
				cb([this.makeEvent('teDealing')]);
			//}.bind(this));
		}.bind(this));
	}.bind(this));
}
Game.prototype.addHistory = function (obj) {
	this.history.moves.push(obj);
}
Game.prototype.setBet = function (seat,bet) {
	var oldbet = this.bets[seat];
	this.bets[seat] = bet;
	this.members[seat].chips -= (bet - oldbet);
	if (bet > this.minBet) this.minBet = bet;
}
Game.prototype.eatChips = function (seat,chips,cb) {
	this.pots[0].value += chips;
	allUsers.update({_id:this.members[seat].conn.userid},
		{ $inc:{chips:-chips}},function (err,res) {
			this.members[seat].conn.log('lost chips',err,res,chips);
			allGames.update({_id:this.obj._id},
				{$inc:{pot:chips}},function (err,res) {
					assert(res == 1);
					this.members[seat].conn.log('pot for game went up to ',this.pots);
					cb();
				}.bind(this));
		}.bind(this));
}
Game.prototype.getNextSeat = function (current,validstates) {
	if (!validstates) validstates = ['psInHand','psAllIn'];
	var limit = 100;
	function getNextSatIn(x) {
		x++;
		while (!this.members[x]) {
			if (limit-- < 0) {
				this.log('giving up');
				return -1;
			}
			x++;
			this.log('trying seat',x,limit);
			if (x >= this.obj.seats) x = 0;
			this.lastplayer[x] = null;
		}
		return x;
	}
	current = getNextSatIn.call(this,current);
	if (current < 0) return -1;
	while (validstates.indexOf(this.members[current].status) == -1) {
		current = getNextSatIn.call(this,current);
		if (current < 0) return -1;
		if (limit-- < 0) return -1;
	}
	return current;
}
Game.prototype.getPrevSeat = function (current) {
	var limit = 100;
	function getPrevSatIn(x) {
		x--;
		if (x < 0) x = this.obj.seats;
		while (!this.members[x]) {
			if (limit-- < 0) {
				this.log('giving up');
				return -1;
			}
			x--;
			this.log('trying seat',x,limit);
			if (x < 0) x = this.obj.seats;
		}
		return x;
	}
	current = getPrevSatIn.call(this,current);
	if (current < 0) return -1;
	while (['psInHand','psAllIn'].indexOf(this.members[current].status) == -1) {
		current = getPrevSatIn.call(this,current);
		if (current < 0) return -1;
		if (limit-- < 0) return -1;
	}
	return current;
}
Game.prototype.fold = function fold(seat,cb1) {
	assert.equal(this.Lock.readers,-1);
	this.stopTimer(seat);
	var seatObj = this.members[seat];
	var priv = this.seats[seat];
	this.log('fold',seat,this.state);
	function finish2(events) {
		this.saveHistory(cb1.bind(this,events));
	}
	switch (this.state) {
	default:
	case 'tsIdle':
		priv.conn.log('fallback');
		cb1();
		break;
	case 'tsPreFlop': // most states go here
	case 'tsFlop':
	case 'tsTurn':
	case 'tsRiver':
		priv.conn.log('normal fold state');
		for (var x=0; x<this.pots.length; x++) {
			//priv.conn.log('folding seat %d, pots:%j',seat,this.pots[x].members);
			var idx = this.pots[x].members.indexOf(seat);
			if (idx != -1) {
				priv.conn.log(this.pots,idx,seat);
				this.pots[x].members.splice(idx,1);
			}
		}
		if (seatObj) seatObj.status = 'psFolded';
		this.addHistory({seat:seat,code:['teFold'],trace:new Error().stack});
		if (this.inHandCount() == 0) {
			priv.conn.log('wut now??');
			finish2.call(this);
		} else if (this.inHandCount() == 1) {
			priv.conn.log('d');
			var lastseat;
			for (var x=0; x<this.members.length; x++) {
				if (!this.members[x]) continue;
				if (['psInHand','psAllIn'].indexOf(this.members[x].status) == -1) continue;
				lastseat = x;
			}
			priv.conn.log('remaining guy wins everything',lastseat);
				this.moveToPot('fold1',function () {
					priv.conn.log('done moving to pot 2');
					//this.doWin([lastseat],cb1);
					this.calcWinners(finish2.bind(this),[this.makeEvent('teFold',seat)]);
					//this.sendEvent('teWinning',[lastseat]);
					//this.log('MOVE WIN DEFAULT '+this.seats[seat].conn.nick+' '+this.seats[seat].userid);
					//assert(0);
				}.bind(this));
		} else {
			priv.conn.log('fold with more then 1 person remaining',this.inHandCount());
			this.keycount--;
			if (seat == this.current_seat) {
				priv.conn.log('and i was active');
				this.stateMachine(finish.bind(this),null,null,[this.makeEvent('teFold',seat)]);
			} else finish.call(this);
			function finish() {
				var events = [this.makeEvent('teFold',seat)];
				this.broadcastStatus(null,null,events); // FIXME spam?
				finish2.call(this,events);
			}
		}
		break;
	}
}
Game.prototype.doWin = function (cb) {
	var totalrake = 0;
	assert.equal(this.Lock.readers,-1);
	this.state = 'tsWinning';
	function finish() {
		this.log('cleared seat');
		this.current_seat = -1;
		this.log('main cb');
		cb();

		setTimeout(function () {
			this.Lock.writeLock(function (release) {
				this.deck = new Deck();
				this.deck.shuffle(function () {
					// SPLIT this.deck.cards = [1,40,17,41,29,51,48,20,9,25,13,19,46,42,10,8,16,47,0,11,18,14,31,4,2,24,32,33,6,15,12,39,21,37,30,26,34,7,22,3,35,27,44,5,36,50,49,28,23,43,38,45];
					// failed 3 way omaha split this.deck.cards = [44,8,10,11, 40,12,14,15, 36,20,22,23, 48,0,4,17,30, 47,42,41,18,46,31,29,2,24,32,33,6,25,51,39,21,37,16,26,34,7,13,3,35,27,1,5,9,50,49,28,19,43,38,45];
					this.log('doWin reset, shuffled deck is',JSON.stringify(this.deck.cards));
					//if (this.inHandCount() > 1) var nextstate = 'psInHand';
					for (var x=0; x<this.members.length; x++) {
						if (!this.members[x]) continue;
						if (this.members[x].status == 'psOutOfPlay') continue;
						if (this.members[x].status == 'psStandingUp') {
							this.log('found a slow guy');
							this.members[x] = null;
							continue;
						}
						this.members[x].hand = new Hand();
						if (this.members[x].sitOutNextRound) {
							this.members[x].sitOutNextRound = false;
							this.members[x].status = 'psOutOfPlay';
							this.lastplayer[x] = this.seats[x].userid;
						} else {
							if (this.members[x].status != 'psOutOfHand') {
								this.members[x].status = 'psInHand';
								this.seats[x].conn.log('moving into psInHand');
							}
						}
					}
					this.state = 'tsWinning2';
					//this.broadcastStatus(null);
					this.stateMachine(function (events) {
						this.log('bcast 1');
						this.broadcastStatus(null,true,events); // teDeal
						release();
					}.bind(this),null,{cont:true},[]);
				}.bind(this));
			}.bind(this))
		}.bind(this),2000);
	}
	var winnerObjects = [];
	var winnerids = [];
	var wins = []; // array of how much each seat wins
	function addWin(seat,chips) {
		if (wins[seat]) wins[seat] += chips;
		else wins[seat] = chips;
	}
	for (var y=0; y<this.pots.length; y++) {
		var pot = this.pots[y];
		if (pot.value == 0) continue;
		var rake = pot.value * (this.rake / 100);
		this.log('splitting pot#%d',y)
		var split = Math.round((pot.value-rake) / pot.winners.length);
		totalrake += pot.value - (split * pot.winners.length);
		for (var x=0; x<pot.winners.length; x++) {
			var priv = this.seats[pot.winners[x]];
			if (winnerObjects.indexOf(this.members[pot.winners[x]]) == -1) {
				winnerObjects.push(this.members[pot.winners[x]]);
				winnerids.push(priv.userid);
			}
			//console.log('winner debug',winnerObjects[x],pot.winners[x]);
			assert(priv,'winner must be seated'); // FIXME
			addWin(pot.winners[x],split);
		}
		this.log('pot#%d initialrake:%d totalrake:%d',y,rake,totalrake);
	}
	this.log('initialrake:%d totalrake:%d',rake,totalrake);
	assert.equal(typeof totalrake,'number');
	this.log('wins',wins,winnerids);
	var stack = new Error().stack;

	//assert.equal(wins[0],15);
	console.log('doWin',this.pots,this.members);
	this.pots = [ new Pot(this) ];
	async.eachSeries(winnerObjects,function (winnerObj,cb2) {
		var seat = winnerObj.seat;
		var userid = this.seats[seat].userid;
		var gain = wins[seat];
		allUsers.update({_id:userid},{$inc:{chips:gain}},function (err,res) {
				assert(!err,err);
				assert.equal(res,1);
				this.log('seat #'+seat+' gained '+gain);
				this.seats[seat].conn.boughtin += gain;
				if (winnerObj) winnerObj.chips += gain;
				cb2();
			}.bind(this));
		}.bind(this),function done() {
			allGames.update({_id:this.obj._id},{$unset:{gameState:0},$inc:{rake:totalrake}},function (err,res) {
				assert(!err,err);
				this.obj.rake += totalrake;
				assert.equal(res,1);
				finish.call(this);
			}.bind(this));
		}.bind(this));
}
Game.prototype.checkRoundPass = function (cb,events) {
	assert.equal(this.Lock.readers,-1);
	assert(events);
	this.log('key seat count is:'+this.keycount+' current:'+this.current_seat);
	if (this.keycount <= 0) {
		var min = -1;
		var max = 0;
		for (var x=0; x<this.members.length; x++) {
			if (!this.members[x]) continue;
			if (['psInHand','psAllIn','psStandingUp'].indexOf(this.members[x].status) == -1) continue;
			if (this.bets[x] > max) max = this.bets[x];
			if (['psAllIn','psStandingUp'].indexOf(this.members[x].status) != -1) continue;
			if (min == -1) min = this.bets[x];
			if (this.bets[x] < min) min = this.bets[x];
		}
		this.log('bet ranges min:'+min+' max:'+max+' all bets:'+JSON.stringify(this.bets));
		if (min == -1) min = max;
		if (min == max) {
			if (this.state == 'tsPreFlop') {
				this.log('flopping');
				//this.broadcastStatus();
				this.state = 'tsFlop';
				this.addHistory({code:['flop']});
				this.moveToPot('preflop',cb.bind(this,events));
				this.roundEnd();
			} else if (this.state == 'tsFlop') {
				this.log('turning');
				//this.broadcastStatus();
				this.state = 'tsTurn';
				this.addHistory({code:['turn']});
				this.moveToPot('turn',cb.bind(this,events));
				this.roundEnd();
			} else if (this.state == 'tsTurn') {
				this.log('river time');
				//this.broadcastStatus();
				this.state = 'tsRiver';
				this.addHistory({code:['river']});
				this.moveToPot('river',cb.bind(this,events));
				this.roundEnd();
			} else {
				//this.broadcastStatus(null);
				this.moveToPot('post-river',function () {
					this.log('events callback FIXME %s',new Error().stack);
					this.calcWinners(cb,events);
				}.bind(this));
			}
		} else cb(events);
	} else cb(events);
}
Game.prototype.calcWinners = function (cb,events) {
	var potdata = [];
	var logmsg = [];
	if (this.omaha) {
		// loop over each pot and figure out which batches of hands to eval
		var pots = [];
		var tbl = this.flop.prettyPrint(true)+' '+this.turn.prettyPrint(true)+' '+this.river.prettyPrint(true);
		for (var x=0; x<this.pots.length; x++) {
			if (this.pots[x].value == 0) continue;
			var hands = [];
			var cards = [];
			this.log('x%d',x);
			for (var y=0; y<this.pots[x].members.length; y++) {
				var z = this.pots[x].members[y];
				this.log('x%d y%d z%d',x,y,z);
				if (!this.members[z]) continue;
				if (['psInHand','psAllIn'].indexOf(this.members[z].status) == -1) continue;
				hands.push({seat:z,hand:this.members.hand.cards});
				cards.push(this.members[z].hand.prettyPrint(true));
			}
			this.log('pot in:%j',this.pots[x]);
			assert(hands.length);
			var cmd = "./pokenum -o -t "+cards.join(' - ')+' -- '+tbl;
			pots[x] = { hands:hands,cmd:cmd };
		}
		this.log(pots);
		if ((pots.length == 1) && (pots[0].hands.length == 1)) {
			forcewin = pots[0].hands[0].seat;
			for (var x=0; x<this.pots.length; x++) {
				var pot = this.pots[x];
				var winners = [ forcewin ];
				if (pot.value == 0) continue;
				potdata[x] = { sum:pot.value, seats:pot.members, WinnerData:[] };
				this.log('this pot',x,pot);
				
				logmsg.push(this.seats[forcewin].conn.nick+' '+this.seats[forcewin].userid);
				potdata[x].WinnerData.push({seat:forcewin,msg:'default'});
				
				this.log('winners of pot #'+potid,winners);
				pot.winners = winners;
			}
			finish1.call(this);
		} else {
			var potid = 0;
			async.eachSeries(pots,function evalPot(pot,cb2){
				this.log('need to eval:%j',pot);
				if (false) {
				var pokenum = child_process.exec(pot.cmd,{cwd:'./poker-eval-138.0/examples'},function (error,stdout,stderr) {
					var winners = [];
					this.log('cmd:'+pot.cmd);
					this.log('reply:'+stdout);
					var parts = stdout.trim().split(' ');
					assert(parts.length > 0);
					parts.splice(0,2);
					this.log(parts);
					for (var x=0; x<parts.length; x++) {
						if (parts[x] == '1.000000') {
							winners.push(pot.hands[x].seat);
						} else if (parts[x] == '0.500000') {
							winners.push(pot.hands[x].seat);
						} else if (parts[x] == '0.000000') {
						} else assert(0);
					}
					potdata[potid] = { sum:pot.value, seats:pot.members, WinnerData:[] };
					logmsg.push(this.seats[winners[0]].conn.nick+' '+this.seats[winners[0]].userid);
					potdata[potid].WinnerData.push({seat:winners[0],msg:'omaha way'});
					this.log('winners of pot #'+potid,winners);
					this.pots[potid].winners = winners;
					potid++;
					cb2();
				}.bind(this));
				} else {
				for (var x=0; x<pots.length; x++) {
					var output = omaha.rankHands(this,pots[x].hands);
					this.log('pot %j resulted in %j',pots[x],output);
				}
				assert(0);
				}
			}.bind(this),function done() {
				finish1.call(this);
			}.bind(this));
		}
	} else {
		var potid = 0;
		var hands = [];
		for (var x=0; x<this.members.length; x++) {
			if (!this.members[x]) continue;
			if (['psInHand','psAllIn'].indexOf(this.members[x].status) == -1) continue;
			hands.push({seat:x,hand:this.members[x].hand.cards});
		}
		this.log('hands: %j',hands[0]);
		var forcewin = -1;
		if (hands.length > 1) {
			var result = dag.rankHands(this,hands);
			this.log('dag results:',result);
		} else {
			forcewin = hands[0].seat;
		}
	// FIXME< just use a for loop?
	async.eachSeries(this.pots,function (pot,cb1) {
		var lowestid = -1;
		var winningindex = -1;
		var winner;
		var winners = [];
		var data = [];
		if (pot.value == 0) return cb1();
		potdata[potid] = { sum:pot.value, seats:pot.members };
		this.log('this pot',potid,pot);

		if (forcewin >= 0) {
			winners = [ forcewin ];
			logmsg.push(this.seats[forcewin].conn.nick+' '+this.seats[forcewin].userid);
			data.push({seat:forcewin,msg:'default'});
		} else {
			this.log('results',result);
			for (var x=0; x<result.outputs.length; x++) {
				if (pot.members.indexOf(result.outputs[x].seat) == -1) continue;
				if (lowestid == -1) {
					lowestid = result.outputs[x].id;
					winningindex = x;
					winner =  result.outputs[x];
				}
				if (result.outputs[x].id < lowestid) {
					lowestid = result.outputs[x].id;
					winningindex = x;
					winner =  result.outputs[x];
				}
			}
			// split pot has the same .id on multiple people
			for (var x=0; x<result.outputs.length; x++) {
				if (pot.members.indexOf(result.outputs[x].seat) == -1) continue;
				if (result.outputs[x].id == lowestid) {
					winners.push(result.outputs[x].seat);
					this.log('output: %j',result.outputs[x]);
					logmsg.push(this.seats[result.outputs[x].seat].conn.nick+' '+this.seats[result.outputs[x].seat].userid);
					data.push({seat:result.outputs[x].seat,msg:result.outputs[x].desc});
				}
			}
		}
		potdata[potid].WinnerData = data;
		this.log('winners of pot #'+potid,winners);
		potid++;
		pot.winners = winners;
		cb1();
	}.bind(this));
		finish1.call(this);
	}
	
	function finish1() {
		events.push(this.makeEvent('teWinning',null,potdata));
		this.addHistory({code:['win1'],potdata:potdata});
		this.doWin(function () {
			this.saveHistory(function () {
				cb(events);
			});
		}.bind(this));
		this.log('MOVE WIN END '+logmsg.join(','));
	}
}
Game.prototype.moveToPot = function (reason,cb1) {
	this.log('state: %s bets: %j pots: %j reason:%s',this.state,this.bets,this.pots,reason);
	var increase;
	var min;
	var max;
	var betsToRemove = [];
	function removeBet(seat,bet) {
		if (betsToRemove[seat] === undefined) betsToRemove[seat] = bet;
		else betsToRemove[seat] += bet;
	}
	function calcRanges() {
		min = -1;
		max = 0;
		for (var x=0; x<this.bets.length; x++) {
			if (this.bets[x] === undefined) this.bets[x] = 0
			if (this.bets[x] == 0) continue;
			if (this.bets[x] > max) max = this.bets[x];
			if (min == -1) min = this.bets[x];
			if (this.bets[x] < min) min = this.bets[x];
		}
		if (min == -1) min = 0;
		this.log('SIDE',min,max);
	}
	do {
		calcRanges.call(this);
		increase = 0;
		if (max == 0) break;
		for (var x=0; x<this.bets.length; x++) {
			if (this.bets[x] >= min) {
				increase += min;
				this.bets[x] -= min;
				removeBet(x,min);
				this.pots[this.pots.length-1].add(min,x,this);
				this.log('adding %d to pot from seat %d %s',min,x,this.members[x] ? this.members[x].status : 'member null');
			}
		}
		if (this.pots[this.pots.length-1].value) {
			var p = this.pots[this.pots.length-1];
			if ((p.members.length == 0) && (p.trueMembers.length == 1)) {
				p.members.push(p.trueMembers[0]);
			}
		}
		this.log('increase:'+increase+' '+min+'x'+(increase/min));
		this.log('SIDE1',this.pots,this.bets,betsToRemove);
		if (this.pots[this.pots.length-1].value) {
			assert(this.pots[this.pots.length-1].members.length)
		}
		this.pots.push(new Pot());
	} while (min != max);
	for (var x=0; x<(this.pots.length-1); x++) {
		// safety
		if (this.pots[x].value) assert(this.pots[x].members.length);

		var set1 = this.pots[x].members.join(',');
		var set2 = this.pots[x+1].members.join(',');
		this.log(set1,set2);
		if (set1 == set2) {
			this.pots[x].value += this.pots[x+1].value;
			this.pots.splice(x+1,1);
			this.log(this.pots);
			if (x >= 0) x--;
		}
	}
	this.log('post merge: %j',this.pots);
	//if (this.pots.length > 1 && this.pots[1].members.length > 1) assert(this.pots.length < 3);
	for (var potid=0; potid<this.pots.length; potid++) {
		if (this.pots[potid].trueMembers.length == 1) {
			var returnseat = this.pots[potid].members[0];
			removeBet(returnseat,-(this.pots[potid].value));
			if (this.members[returnseat]) {
				this.seats[returnseat].conn.log('CHECK returning',this.members[returnseat].chips);
				this.members[returnseat].chips += this.pots[potid].value;
				this.seats[returnseat].conn.log('CHECK returned',this.pots[potid].value,this.members[returnseat].chips);
			}
			this.pots.splice(potid,1);
		}
	}

	// FIXME, remove this check later?
	for (var x=0; x<this.seats.length; x++) if (this.seats[x]) assert(this.seats[x].userid);

	async.parallel([
		function (cb) {
			this.updateMongoState(function () {
				this.log('pot for game updated');
				cb();
			}.bind(this));
		}.bind(this),
		function (cb2) {
			// FIXME< use async.each
			var idx = 0;
			function repeat() {
				if (idx > this.obj.seats) return finish.call(this);
				var priv = this.seats[idx];
				if (!this.seats[idx]) {
					idx++;
					repeat.call(this);
					return;
				}
				var item = this.members[idx];
				if (item) {
					if (['psOutOfHand','psOutOfPlay'].indexOf(item.status) != -1) {
						idx++;
						return repeat.call(this);
					}
				}
				if (betsToRemove[idx] === undefined) betsToRemove[idx] = 0;
				priv.conn.log('removing chips userid:%s idx:%d bets:%j',priv.userid,idx,betsToRemove);
				assert(priv.userid);
				assert.equal(typeof betsToRemove[idx],'number');
				allUsers.update({_id:priv.userid},
					{ $inc:{chips:-betsToRemove[idx]}},function (err,res) {
						assert(!err);
						assert(res == 1);
						priv.conn.log('lost chips',idx,betsToRemove[idx]);
						priv.conn.boughtin -= betsToRemove[idx];
						betsToRemove[idx] = 0;
						idx++;
						// debug to detect desync
						// usage: set buyin on a table with EVERYTHING on every user
						//allUsers.findOne({_id:priv.userid},function (err,check) {
							//priv.conn.log('CHECK global:',check.chips,'table:',item.chips,'boughtin:',priv.conn.boughtin);
							//assert.equal(check.chips,item.chips);
							//assert.equal(check.chips,priv.conn.boughtin);
							repeat.call(this);
						//}.bind(this));
					}.bind(this));
			}
			function finish() {
				//this.log('remove chips done',betsToRemove);
				cb2();
			}
			repeat.call(this);
		}.bind(this)],function () {
			this.log('done moving to pot 1');
			this.minBet = 0;
			cb1();
		}.bind(this));
}
Game.prototype.updateMongoState = function (cb) {
	allGames.update({_id:this.obj._id}, {$set:{gameState:{pots:this.pots}}},function (err,res) {
		assert(res == 1);
		cb();
	}.bind(this));
}
Game.prototype.putChips = function (conn,chips,cb) {
	assert.equal(this.Lock.readers,-1);
	var seat = this.findSeat(conn);
	this.stopTimer(seat);
	if (['tsPreFlop','tsFlop','tsTurn','tsRiver'].indexOf(this.state) == -1) {
		// FIXME, fail
		this.log('putChips fail 1');
		cb();
		return;
	}
	
	var increase = chips - this.bets[seat];
	var event;
	var oldbet = this.bets[seat];
	var maxbet = this.getLimit(seat);

	if (chips > maxbet) { // cheater!
		conn.error('cheater, going over pot limit '+chips+' '+maxbet);
		conn.destroy();
		cb();
		return;
	} else if (chips < oldbet) { // cheater!
		conn.error('cheater detected, lowering bet '+chips+','+oldbet);
		conn.destroy();
		cb([]);
		return;
	} else if (this.members[seat].chips == increase) {
		this.members[seat].status = 'psAllIn';
		event = 'teAllIn';
	} else if (chips < this.minBet) { // cheater!
		conn.error('cheater detected, betting low '+chips+','+this.minBet);
		conn.destroy();
		cb([]);
		return;
	} else if (chips > this.minBet) {
		event = 'teRaise';
	} else if (this.bets[seat] == chips) { // check
		event = 'teCheck';
	} else if (chips == this.minBet) {
		event = 'teCall';
	}
	this.log('MOVE '+event+' '+this.seats[seat].conn.nick+' '+this.seats[seat].userid);
	this.addHistory({seat:seat,bet:chips,code:[event],trace: new Error().stack});
	this.keycount--;

	if (increase > this.members[seat].chips) {
		conn.error('cheater detected, overbetting '+chips+','+increase+','+this.members[seat].chips);
		conn.destroy();
		cb();
		return;
	}
	conn.log('eating bets:'+JSON.stringify(this.bets)+' increase:'+increase+' chips:'+chips+' seat:'+seat);
	this.setBet(seat,chips);
	
	this.saveHistory(function () {
		this.stateMachine(function (events) {
			cb(events);
		}.bind(this),null,null,[this.makeEvent(event,seat)]);
	}.bind(this));
}
Game.prototype.saveHistory = function (cb) {
	handHistory.update({seq:this.handid},{$set:{moves:this.history.moves}},function (err,res) {
		assert.equal(res,1);
		cb();
	});
}
Game.prototype.findSeat = function (conn) {
	for (var x=0; x<this.seats.length; x++) {
		if ((this.seats[x]) && (this.seats[x].conn == conn)) {
			return x;
		}
	}
}
Game.prototype.nextDealer = function () {
	var limit = 100;
	this.dealer++;
	while (limit-- > 0) { // FIXME
		this.log('dealer loop',limit,this.dealer);
		if (limit-- < 0) break;
		if (this.dealer >= this.obj.seats) this.dealer = 0;
		if (!this.members[this.dealer]) { this.dealer++; continue; }
		if (this.members[this.dealer].status == 'psOutOfPlay') { this.dealer++; continue; }
		if (this.members[this.dealer].chips > 0) break;
		this.dealer++;
	}
	if (limit < 10) { // FIXME
		this.dealer = -1;
	}
}
Game.prototype.checkDelayedLeave = function () {
	if ((this.state == 'tsIdle') || (this.Lock.readers == 0)) {
		for (var x=0; x<this.seats.length; x++) {
			var priv = this.seats[x];
			if (!priv) continue;
			var pub = this.members[x];
			if (!pub) {
				if (priv.delayed) {
					this.log('finishing delayed leave');
					this.seats[x] = null;
				}
			}
		}
	}
}
Game.prototype.stateMachine = function stateMachine(cb,conn,config,events) {
	assert.equal(this.Lock.readers,-1);
	assert(events);
	this.log('state machine: %s events:%j',this.state,events);
	this.checkDelayedLeave();
	switch (this.state) {
	case 'tsWinning':
		cb(); // FIXME
		break;
	case 'tsWinning2':
		var havechips = 0;
		for (var x=0; x<this.members.length; x++) if (this.members[x] && (this.members[x].chips > 0)) havechips++;
		if (havechips == 0) {
			this.log('nobody has chips');
			this.dealer = -1;
			this.current_seat = -1;
		} else if (havechips < 2) {
			this.log('only one guy has chips');
			this.nextDealer();
		}
		this.state = 'tsIdle';
		this.checkDelayedLeave();
		this.current_seat = -1;
		this.nextDealer();
	case 'tsIdle':
		var havechips = 0;
		for (var x=0; x<this.members.length; x++) {
			if (!this.members[x]) continue;
			if (this.members[x].status == 'psOutOfPlay') continue;
			if (this.members[x].chips > 0) {
				this.log('sm found one',x,this.members[x].status,this.members[x].chips);
				havechips++;
			}
		}
		if (this.dealer == -1) this.nextDealer();
		if (havechips > 1) {
			this.log('enough are sitting, checking sitOutBB');
			var dealerbackup = this.dealer;
			if (this.dealer == -1) this.nextDealer();
			var pos = this.dealer;
			if (havechips == 2) {
				this.headsup = true;
				pos = this.getNextSeat(pos,['psInHand','psAllIn','psOutOfHand']);
			} else this.headsup = false;
			var small_blind = this.getNextSeat(pos,['psInHand','psAllIn','psOutOfHand']);
			var big_blind = this.getNextSeat(small_blind,['psInHand','psAllIn','psOutOfHand']);
			this.log('future dealer:%d, sb:%d, bb:%d',this.dealer,small_blind,big_blind);
			this.dealer = dealerbackup;
			if (this.members[big_blind].sitOutBB) {
				this.members[big_blind].status = 'psOutOfPlay';
				this.members[big_blind].sitOutBB = false;
				this.stateMachine(cb,null,config,events);
				return;
			}
			this.deal(cb,config);
		} else finish1.call(this);
		function finish1() {
			if (config && config.silent) {
			} else this.broadcastStatus(conn,null,events);
			cb(events);
		}
		break;
	case 'tsPreFlop':
	case 'tsFlop':
	case 'tsTurn':
	case 'tsRiver':
		//this.log('normal state',this.state,this.current_seat);
		//if (this.members[this.current_seat]) this.log('chips:',this.members[this.current_seat].chips);
		var cantplay = 0;
		var canplay = 0;
		var cancheck = 0;
		for (var x=0; x<this.members.length; x++) {
			if (!this.members[x]) continue;
			if (this.members[x].status == 'psInHand') {
				canplay++;
				if (this.canCheck(x)) cancheck++;
			} else if (this.members[x].status == 'psAllIn') cantplay++;
		}
		this.log('cantplay:'+cantplay+' canplay:'+canplay+' cancheck:'+cancheck);
		var skip = false;
		// FIXME, improve logic for more players
		if ((cantplay == 1) && (canplay == 1) && (cancheck == 1)) skip = true;
		if ((cantplay == 2) && (canplay == 1) && (cancheck == 1)) skip = true;
		if ((cantplay == 3) && (canplay == 1) && (cancheck == 1)) skip = true;
		if ((canplay == 0) && (cancheck == 0)) {
			skip = true;
			this.keycount = -1;
		}
		if (skip) {
			this.log('skipping a player');
			this.keycount--;
			var last = this.current_seat;
			this.current_seat = this.getNextSeat(this.current_seat);
			this.checkRoundPass(function (events) {
				this.log('player '+last+' skipped, doing state again, FIXME %j',events);
				return this.stateMachine(cb,null,null,events);
			}.bind(this),events);
			return;
		}
		this.checkRoundPass(finish.bind(this),events);
		function finish(events) {
			assert(events);
			this.log('sm finish %j %s',events,new Error().stack);
			if (this.state != 'tsWinning') {
				this.current_seat = this.getNextSeat(this.current_seat);
				if (this.members[this.current_seat].chips == 0) {
					this.ranOut = true;
					this.log('skipping');
					return this.stateMachine(cb);
				}
				if (this.ranOut && (this.inHandCount() == 2)) {
					this.log('somebody ran out, auto finishing');
					return this.stateMachine(cb);
				}
			}
			//this.broadcastStatus(null);
			cb(events);
		}
	}
}
Game.prototype.canCheck = function (seatIdx) {
	// find the highest bet
	var max = 0;
	for (var x=0; x<this.members.length; x++) {
		if (!this.members[x]) continue;
		if (['psInHand','psAllIn'].indexOf(this.members[x].status) == -1) continue;
		if (this.bets[x] > max) max = this.bets[x];
	}
	if (this.bets[seatIdx] == max) return true;
	return false;
}
Game.prototype.makeEvent = function (event,seat,data) {
	var obj = {event:event};
	if (data) obj.pots = data;
	if (typeof seat == 'number') obj.seat = seat;
	return obj;
}
Game.prototype.broadcastStatus = function (conn,forceunlock,events) {
	assert(events);
	this.log('sending table status to all 2',this.state);
	for (var key in this.users) {
		if (this.users[key] == conn) continue;
		if (!this.users[key]) continue;
		var status = this.getTableStatus(this.users[key],forceunlock,events);
		this.users[key].send(codes.seTableStatus,status,'Poker.TableStatus');
	}
}
var counter = 0;
Game.prototype.getTableStatus = function getTableStatus(self,forceunlock,events) {
	assert(self);
	assert(events);
	assert(self.nick);
	var tableStatus = {table_mongo_id:new Buffer(this.id.toString(),'hex'),seats:[], state:this.state, bets:this.bets, pots:[], locked:this.Lock.readers == -1, seq:counter++, minimum_bet:this.minBet,small_blind:this.small_blind, big_blind:this.big_blind, events:events};
	if (forceunlock) tableStatus.locked = false;
	if (this.handid) tableStatus.handid = this.handid;
	if (this.pots) {
		for (var x=0; x<this.pots.length; x++) {
			if ((x == (this.pots.length-1)) && (this.pots[x].value == 0)) continue;
			tableStatus.pots.push(this.pots[x].value);
		}
	}
	if (this.timer && this.timer.time) tableStatus.time = this.timer.time;
	for (var x=0; x<this.members.length; x++) {
		if (!this.members[x]) continue;
		var seat = this.members[x];
		var priv = this.seats[x];
		//console.log('table debug',x,seat.conn.userid,seat.hand.prettyPrint());
		if (!this.timebanks[priv.userid]) this.timebanks[priv.userid] = sharedconfig.max_timebank * 1000;
		var timebank = this.timebanks[priv.userid];
		if (timebank < 0) timebank = 0;
		var obj = {seat:x, player_mongo_id:new Buffer(priv.userid.toString(),'hex'), chips:seat.chips, status:seat.status, timebank:timebank}
		if (this.testmode || (['tsWinning','tsWinning2'].indexOf(this.state) != -1) || (priv.conn === self)) {
			obj.cards = new Buffer(seat.hand.cards);
		}
		if (priv.conn == self) tableStatus.maximum_limit = this.getLimit(x);
		obj.card_count = seat.hand.cards.length;
		tableStatus.seats.push(obj);
	}
	tableStatus.dealer = this.dealer;
	tableStatus.current_seat = this.current_seat;
	if (['tsFlop','tsTurn','tsRiver'].indexOf(this.state) != -1) tableStatus.flop = new Buffer(this.flop.cards);
	if (['tsTurn','tsRiver'].indexOf(this.state) != -1) tableStatus.turn = new Buffer(this.turn.cards);
	if (this.state == 'tsRiver') tableStatus.river = new Buffer(this.river.cards);
	this.log('made status:%d %s %j',counter-1,self ? 'for '+self.nick: '',tableStatus);
	return tableStatus;
}
Game.prototype.sittingCount = function () {
	var count = 0;
	for (var x=0; x<this.members.length; x++) {
		if (!this.members[x]) continue;
		if (this.members[x].chips <= 0) continue;
		count++;
	}
	return count;
}
Game.prototype.inHandCount = function () {
	var count = 0;
	for (var x=0; x<this.members.length; x++) {
		if (!this.members[x]) continue;
		if (['psInHand','psAllIn'].indexOf(this.members[x].status) == -1) continue;
		count++;
	}
	return count;
}
Game.prototype.roundEnd = function () {
	var havechips = 0;
	for (var x=0; x<this.members.length; x++) {
		if (!this.members[x]) continue;
		if (this.members[x].status == 'psOutOfHand') continue;
		if (this.members[x].status == 'psOutOfPlay') continue;
		if (this.members[x].status == 'psFolded') continue;
		if (this.members[x].status == 'psAllIn') continue;
		if (this.members[x].chips > 0) {
			this.log('roundend found one',x,this.members[x].status,this.members[x].chips);
			havechips++;
		}
	}
	this.keycount = havechips;
}
Game.prototype.standUp = function (conn,cb1) {
	assert.equal(this.Lock.readers,-1);
	var seatIdx = this.findSeat(conn);
	var seatObj = this.members[seatIdx];
	var folded = false;
	conn.log('standing up seat:%d bet:%d status:%j locked:%d',seatIdx,this.bets[seatIdx],seatObj,this.Lock.readers);
	conn.boughtin -= seatObj.chips;
	// FIXME, do something with his cards
	
	this.members[seatIdx] = null;
	this.lastplayer[seatIdx] = conn.userid;
	conn.log('nulled out seat',seatIdx);
	
	if ((['tsIdle','tsWinning'].indexOf(this.state) == -1) && (['psInHand','psAllIn'].indexOf(seatObj.status) != -1)) {
		this.fold(seatIdx,finish1.bind(this));
		folded = true;
	} else {
		this.keycount--;
		finish1.call(this,[]);
	}
	function finish1(events) {
		this.log('events are %j',events);
		assert.equal(this.Lock.readers,-1);
		conn.log('standing up seat:',seatIdx,'bet:',this.bets[seatIdx],'status:',seatObj.status);
		var priv = this.seats[seatIdx];
		priv.conn.log('instant leave');
		//this.broadcastStatus();
		if (this.bets[seatIdx] === undefined) this.bets[seatIdx] = 0;
		this.log('bets:',this.bets);
		assert.equal(typeof this.bets[seatIdx],'number');
		var increase = this.bets[seatIdx];
		conn.log('increase is',increase);
		assert(priv);
		if (['tsIdle','tsWinning'].indexOf(this.state) != -1) {
			assert.equal(increase,0);
			this.seats[seatIdx] = null;
			this.log('nulled out internal seat');
			//this.broadcastStatus();
			finish2.call(this);
		} else {
			this.pots[0].value += increase;
			async.parallel([
			function (cb) {
					allGames.update({_id:this.obj._id},
					{$inc:{pot:increase}},function (err,res) {
						this.log('error updating game: %j',err);
						assert.equal(err,null);
						assert.equal(res,1);
						this.log('pot for game went up by ',increase);
						cb();
					}.bind(this));
			}.bind(this),function (cb) {
				allUsers.update({_id:priv.userid},
					{ $inc:{chips:-this.bets[seatObj.seat]}},function (err,res) {
						assert(!err);
						assert(res == 1);
						priv.conn.log('lost chips',increase,this.bets[seatIdx],seatIdx);
						priv.conn.boughtin -= this.bets[seatIdx];
						this.bets[seatIdx] = 0;
						cb();
					}.bind(this));
			}.bind(this)],function (err) {
				assert(!err);
				this.seats[seatIdx] = null;
				this.log('nulled out internal seat');
				//this.broadcastStatus();
				finish2.call(this);
			}.bind(this));
		}
		function finish2() {
			conn.log('in standup finish2');
			//var status = this.getTableStatus();
			events.push(this.makeEvent('teStandUp',seatIdx));
			if (this.sittingCount() == 0) {
				this.dealer = -1;
				this.current_seat = -1;
			}
			//this.broadcastStatus(conn);
			conn.log('a');
			// FIXME json performance hack
			allClubs.findOne({_id:this.obj.clubid},function (err,club) {
				conn.log('b');
				if (!club.members) return cb1(folded,events);
				conn.log('c');
				var g = makeGameProtobuf(JSON.parse(JSON.stringify(this.obj)));
				for (var x=0; x<club.members.length; x++) {
					var conn2 = activeUsers[club.members[x]];
					if (!conn2) continue;
					if (conn2 === conn) continue;
					conn2.send(codes.seGameChange,g,'Poker.Game');
				}
				conn.log('d');
				cb1(folded,events);
			}.bind(this));
			// FIXME, run state machine if not locked
		}
	}
}
Game.prototype.leave = function leave(conn,reason) {
	conn.log('getting lock:%s',this.Lock.trace);
	this.Lock.writeLock(function (release) {
		conn.log('got lock',this.Lock.readers);
		delete this.users[conn.userid];
		var seatIdx = this.findSeat(conn);
		conn.log('leave idx %d %s',seatIdx,reason);
		if (seatIdx != undefined) {
			this.standUp(conn,function (folded,events) {
					conn.log('releasing lock events:%j');
					this.broadcastStatus(null,true,events);
					release();
				}.bind(this));
		} else release();
	}.bind(this));
}
Game.prototype.startTimer = function startTimer(seat) {
	//return;
	this.stopTimer(seat);
	this.log('starting timer for seat %d in state %s',seat,this.state);
	this.log('public: %j',this.members[seat]);
	this.log('private: %s',util.inspect(this.seats[seat]));
	assert(this.members[seat]);
	this.timer = { time: (sharedconfig.max_play_time*1000) + Date.now(), seat:seat };
	var priv = this.seats[seat];
	if (!this.timebanks[priv.userid]) this.timebanks[priv.userid] = sharedconfig.max_timebank * 1000;
	this.timer.timerid = setTimeout(function () {
		this.log('DING!');
		this.Lock.writeLock(function (release) {
			assert.equal(this.timer.seat,seat);
			this.stopTimer(seat);
			this.log('folding');
			this.fold(seat,function (events) {
				this.log('folded %j',events);
				this.broadcastStatus(null,true,events);
				release();
				if (this.current_seat >= 0) this.startTimer(this.current_seat);
			}.bind(this));
		}.bind(this));
	}.bind(this),(sharedconfig.max_play_time*1000) + this.timebanks[this.seats[seat].userid]);
}
Game.prototype.stopTimer = function stopTimer(seat) {
	if (this.timer) {
		var spent = Date.now() - this.timer.time;
		var priv = this.seats[seat];
		if (!this.timebanks[priv.userid]) this.timebanks[priv.userid] = sharedconfig.max_timebank * 1000;
		if (spent > 0) this.timebanks[this.seats[seat].userid] -= spent;
		if (this.timebanks[this.seats[seat].userid] < -1) this.timebanks[this.seats[seat].userid] = -1;
		this.log('removed %d from timebank, %d remains',spent,this.timebanks[this.seats[seat].userid]);
		clearTimeout(this.timer.timerid);
	}
	this.timer = null;
}
Game.handleDisconnect = function handleDisconnect(conn,reason) {
	// FIXME
	conn.log('handling disconnect:%s',reason);
	for (key in activeGames) {
		var game = activeGames[key];
		if (game.users[conn.userid]) game.leave(conn,'disconnect');
	}
}
Game.getGame = function getgame(id,cb) {
	if (!activeGames[id]) {
		allGames.findOne({_id:id},function (err,obj) {
			var game = new Game(obj);
			game.deck = new Deck();
			game.deck.shuffle(function shuffled(){
				//this.send(codes.SR_DECKREPLY,{deck:deck.prettyPrint()},'Poker.GetDeckReply');
				allClubs.findOne({_id:obj.clubid},function (err,club) {
					game.rake = club.rake;
					if (!game.rake) game.rake = 5;
					game.testmode = club.testmode;
					cb(null,game);
				});
			}.bind(this));
		}.bind(this));
	} else cb(null,activeGames[id]);
}
ClientSocket.prototype.handleChatEvent = function handleChatEvent(ev,ts) {
	switch (ev.event) {
	case 'ceUserMessage':
		//for (var x=0; x<ev.messages.length; x++) {
			ev.msg.username = this.nick;
			ev.msg.timestamp = ts;
		//}
		var id = new toMongoId(ev.table_id);
		var game = activeGames[id];
		if (!game) {
			// FIXME, game doesnt exist server side
			return;
		}
		for (key in game.users) {
			//if (key == this.userid) continue;
			game.users[key].send(codes.seChat,ev,'Poker.ChatEvent');
		}
		break;
	}

}
var timebanktimer;
function setTimebankTimer() {
	var now = new Date();
	now.setMinutes(0);
	now.setSeconds(0);
	now.setMilliseconds(0);
	now.setHours(now.getHours()+1);
	var now2 = new Date();
	clearTimeout(timebanktimer);
	var target = now - now2;
	setTimeout(function () {
		log('DING, timebanks');
		for (key in activeGames) {
			var game = activeGames[key];
			log('clearing timebank %s %j',key,game.timebanks);
			game.timebanks = {};
		}
		setTimebankTimer();
	},target);
}
setTimebankTimer();
function checkGameParams(smallblind,bigblind,gamename,seats,game_type,game_limit,buyin_min,buyin_max) {
	if (smallblind < 1) return true;
	if (smallblind > bigblind) return true;
	if (gamename.length < 3) return true;
	if (gamename.length >= sharedconfig.stringSizes.gamename) return true;
	if ([2,3,4,5,6,7,8,9,10].indexOf(seats) == -1) return true;
	if (5 > buyin_min) {
		log('min too low',buyin_min);
		return true;
	}
	if (10 > buyin_max) {
		log('max too low',buyin_max);
		return true;
	}
	return false;
}
ClientSocket.prototype.destroy = function destroy() {
	this.socket.destroy();
}
function cactiStats() {
	var mem = process.memoryUsage();
	var data = { hands:hands };
	var msg = []
	for (x in data) {
		msg.push(x+':'+data[x]);
	}
	for (x in mem) {
		msg.push(x+':'+mem[x]);
	}
	return msg.join(' ');
}
function stats_server(c) {
	c.write(cactiStats());
	c.end();
}
