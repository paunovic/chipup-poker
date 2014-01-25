#!/usr/bin/node
// http://docs.mongodb.org/manual/reference/operator/update/positional/
var net = require('net');
var tls = require('tls');
var fs = require('fs');
var MongoClient = require('mongodb').MongoClient;
var ObjectID = require('mongodb').ObjectID
var SmtpConnection = require('./smtp');
//var Reader = require('./reader').reader;
var express = require('express');
var uuid = require('node-uuid');
var generatePassword = require('password-generator');
var codes = require('./ServerCodes');
var crypto = require('crypto');
var p = require("node-protobuf").Protobuf;
var deck = require('./deck');
var Deck = deck.Deck;
var Hand = deck.Hand;
var https = require('https');

var pb = new p(fs.readFileSync("../message.desc"));
var protoreader = require('./protoreader');
protoreader.init(pb);

var domain = "http://chipuppoker.com/";
var sharedconfig = {stringSizes:{}};
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
			// FIXME, inform the user if they are connected
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
// FIXME if upload dir doesnt exist, this fails hard
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
app.get("/test",function (req,res) {
	res.send("<form method='post' action='/image_upload' enctype='multipart/form-data'><input type='file' name='avatar'><input type='submit'></form>");
});
app.get("/getavatar",function (req,res) {
	var id = req.query.id;
	console.log('getting avatar',req.query,id.length);
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
app.listen(3000);

var conn,allUsers,allClubs,allCounters,avatars,allGames;
MongoClient.connect('mongodb://localhost:27017/poker',function (err,db) {
	if (err) {
		console.log(err);
		process.exit(1);
	}
	conn = db;
	console.log('connected');
	db.collection('users',function (err,collection) {
		if (err) {
			console.log(err);
			process.exit(1);
		}
		allUsers = collection;
		console.log('got user list');
		allUsers.createIndex("email",{unique:true}, function (err,res) {
		});
		allUsers.createIndex("displayname",{unique:true}, function (err,res) {
		});
	})
	db.collection('clubs',function (err,list) {
		allClubs = list;
		allClubs.createIndex("name",{unique:true},function (err,res) {
		});
	});
	db.collection('counters',function(err,list) {
		allCounters = list;
		list.insert({_id:"club",seq:1},function (err,res) {});
	});
	avatars = db.collection('avatars');
	allGames = db.collection('games');
});
function getNextSequence(name,cb) {
	allCounters.findAndModify({_id:name},[],
		{ $inc:{seq:1}},
	function (err,res) {
		console.log('seq',name,err,res);
		cb(res.seq);
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
secureServer.listen(12346);
var activeUsers = {};
var activeGames = {};
function ClientSocket(socket) {
	this.state = 1;
	this.socket = socket;
	socket.on('end',function() {
		this.log('client lost');
		delete activeUsers[this.userid];
		Game.handleDisconnect(this);
	}.bind(this));
	//this.socket.write("abc\ndef\nghi\n");
	this.send(codes.srHello,sharedconfig,'Poker.HelloReply');
	this.reader = new protoreader(socket,this);
	socket.on('error',function() {
		this.log('error!',arguments);
		this.logout();
	}.bind(this));
	this.log('new socket setup');
}
ClientSocket.prototype.error = function error(e) {
	this.log('error!',e);
	this.log(e.stack);
	this.logout();
	this.socket.destroy();
	Game.handleDisconnect(this);
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
		this.log(row);
		hasher.update(row.salt.buffer);
		hasher.update(password);
		var hash = hasher.digest();
		this.log('passwords',hash,row.password);
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
	this.state = 1;
	this.userid = null;
	this.nick = null;
	this.send(codes.seSecondaryLoginDetected);
	// FIXME, handle activeGames
}
ClientSocket.prototype.log = function log() {
	var out = Array.prototype.slice.call(arguments);
	out.unshift(new Date().toString()+' '+this.nick+":");
	console.log.apply(this,out);
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
ClientSocket.prototype.send = protoreader.reply;
ClientSocket.prototype.spendTokens = function spendTokens(tokens,failcode,callback) {
	allUsers.findOne({_id:this.userid},function (err,res) {
		if (res.tokens < tokens) {
			this.send(failcode);
			return;
		}
		allUsers.update({_id:this.userid},{$inc:{tokens:-tokens}},function (err,res) {
			if (err) {
				this.log('shouldnt happen 012 1',err);
				this.reply(0,"error updating user");
				return;
			}
			callback();
		}.bind(this));
	}.bind(this));
}
function toMongoId(buf) {
	return new ObjectID(buf.toString('hex'));
}
ClientSocket.prototype.handle = function (code,args) {
	console.log('handle',codes.reverse[code],args);
	if (code == codes.scLogout) {
		this.logout();
		this.send(codes.srLogout);
		return;
	} else if (code == codes.scPing) {
		this.send(codes.srPong,args,'raw');
		return;
	}
	switch (this.state) {
	case 1: // need to login
		switch (code) {
		case codes.scLogin:
			var params = pb.Parse(args,'Poker.LoginParams');
			this.log(params);
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
			// FIXME, give a better default
			doc.avatar = "2vjw2PHZKtTC1oAiXpF8dnqKh++XT5biqzainRgOcuo=";
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
				this.log('salt',salt);
				var hasher = crypto.createHash('sha256');
				hasher.update(salt);
				hasher.update(params.password);
				var hash = hasher.digest();
				this.log('pw hash is',hash);
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
									console.log('registered',result);
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
						users[x].avatar = new Buffer(users[x].avatar,'base64');
						users[x]._id = new Buffer(users[x]._id.toString(),'hex');
					}
					status.users = users;
					allUsers.findOne({_id:this.userid},{tokens:"",displayname:"",email:"",authed:"", avatar:""},function(err,self) {
						self.avatar = new Buffer(self.avatar,'base64');
						self._id = new Buffer(self._id.toString(),'hex');
						status.self = self;
						// FIXME hide some fields in games
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
			// FIXME, limit which columns go out
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
				var doc = {is_private:priv,password:pass,name:clubname, owner:this.userid, chips:100000};
				// FIXME, switch to spendTokens
				allUsers.findOne({_id:this.userid},function (err,res) {
					if (res.tokens < sharedconfig.tokenPrices.club_creation) {
						this.send(codes.srCreateClubNoTokens);
						return;
					}
					allUsers.update({_id:this.userid},{$inc:{tokens:-sharedconfig.tokenPrices.club_creation}},function (err,res) {
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
					this.send(codes.srOwnershipGiveAwayInvalidClubId);
					return;
				}
				if (club.owner.equals(this.userid)) {
					if (club.members && club.members.indexOf(newowner)) {
						this.log('adding self to members',this.userid);
						allClubs.update({_id:club._id},
							{$addToSet:{members:this.userid}},function (err,res) {
								this.log('result 2',err,res);
								allClubs.update({_id:club._id},{
								 $set:{owner:newowner},
								 $pull:{members:newowner}
								},function (err,res) {
									this.log(err,res);
									allClubs.findOne({_id:club._id},function cb(err,row) {
										var out = makeClubProtobuf(row);
										this.send(codes.srOwnershipGiveAwayOk,out,'Poker.Club');
									}.bind(this));
								}.bind(this));
						}.bind(this));
					} else {
						this.send(codes.srOwnershipGiveAwayInvalidPlayerId);
					}
				} else {
					this.send(codes.srOwnershipGiveAwayNotOwner);
				}
			}.bind(this));
			break;
		case codes.scChangeClubDetails:
			var params = pb.Parse(args,'Poker.Club');
			var clubseq = params.seq;
			allClubs.findOne({seq:clubseq},function (err,club) {
				if (!club) {
					this.reply("000","club not found");
					return;
				}
				if (!club.owner.equals(this.userid)) {
					this.reply("000","your not owner");
					return;
				}
				var mods = {$set:{}};
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
					that.spendTokens(sharedconfig.tokenPrices.club_change_details,codes.srClubDetailsChangeNoTokens,function () {
						allClubs.update({_id:club._id},mods,function (err,ret) {
							this.log('detail update',clubseq,params,mods,err,ret);
							if (err) {
								this.reply(codes.srChangeClubDetailsReply,{status:'csNameExists'},'Poker.ClubCommandReply');
							} else {
								// FIXME club
								allClubs.findOne({_id:club._id},function cb(err,row) {
									var userlist = [ ];
									var out = makeClubProtobuf(row,userlist);
									this.send(codes.srChangeClubDetailsReply,{status:'csSuccess',club:out},'Poker.ClubCommandReply');
									this.log('userlist to inform:',userlist);
									for (var x=0; x<userlist.length; x++) {
										var user = activeUsers[userlist[x]];
										if (user) user.send(codes.seClubChange,out,'Poker.Club');
									}
								}.bind(this));
							}
						}.bind(that));
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
			var clubseq = params.club_seq;
			var userid = toMongoId(params.player_mongo_id);
			var chips = params.chip_amount;
			this.log('transfering chips',clubseq,userid,chips);
			allClubs.findOne({seq:clubseq},function (err,club) {
				if (!club) {
					this.reply("000","no such club");
					return;
				}
				if (!club.owner.equals(this.userid)) {
					this.reply("000","your not owner");
					this.log('attempted to transfer while not owner');
					return;
				}
				if (club.chips < chips) {
					this.send(codes.srClubTransferChipsInvalidAmount);
					return;
				}
				// FIXME, enforce limit per player
				if (chips > 2000) {
					this.send(codes.srClubTransferChipsInvalidAmount);
					return;
				}
				if (chips < 1) {
					this.send(codes.srClubTransferChipsInvalidAmount);
					return;
				}
				allUsers.update({_id:userid},
					{ $inc:{chips:chips}},
					function (err,res) {
						this.log('step 1',err,res);
						allClubs.update({_id:club._id},
						{ $inc:{chips:-chips}},
						function (err,res) {
							this.log('step 2',err,res);
							allClubs.findOne({_id:club._id},function cb(err,row) {
								var out = makeClubProtobuf(row);
								this.send(codes.srClubTransferChipsOk,out,'Poker.Club');
							}.bind(this));
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
							this.reply("000","internal error");
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
			this.log('changing avatar',params);
			var id = params.avatar_id.toString('base64');
			this.log('id is',id);
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
			if (checkGameParams(small_blind,big_blind,gamename,seats,game_type,game_limit)) {
				this.reply(0,"invalid params");
				return;
			}
			var doc = {game_type:game_type, small_blind:small_blind, big_blind:big_blind, seats:seats, creator_mongo_id:this.userid, clubseq:clubseq, gamename:gamename, game_limit:game_limit};
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
			if (checkGameParams(small_blind,big_blind,gamename,seats,game_type,game_limit)) {
				this.reply(0,"invalid params");
				return;
			}
			// FIXME, run game.preedit
			var doc = {$set:{game_type:game_type, small_blind:small_blind, big_blind:big_blind, seats:seats, gamename:gamename, game_limit:game_limit }};
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
			this.log('table join',params);
			var id = new toMongoId(params._id);
			Game.getGame(id,function (err,game) {
				this.log('game info',game.obj.clubid);
				allClubs.findOne({_id:game.obj.clubid},function (err,club) {
					this.log(club);
					if (club.suspended) {
						for (var x=0; x<club.suspended.length; x++) {
							console.log(club.suspended[x],this.userid);
							if (club.suspended[x].toString() == this.userid.toString()) {
								this.reply(0,'your suspended in that club');
								return;
							}
						}
					}
					if (game.join(this)) this.send(codes.srTableStatus,game.getTableStatus(),'Poker.TableStatus');
				}.bind(this));
			}.bind(this));
			break;
		case codes.scTableLeave:
			var params = pb.Parse(args,'Poker.Game');
			this.log('table leave',params);
			var id = new toMongoId(params._id);
			Game.getGame(id,function (err,game) {
				game.leave(this);
			}.bind(this));
			break;
		case codes.scTableSit:
			var params = pb.Parse(args,'Poker.TableSit');
			var id = new toMongoId(params.game_id);
			Game.getGame(id,function (err,game) {
				game.sitDown(this,params);
			}.bind(this));
			break;
		case codes.scTableStandUp:
			var params = pb.Parse(args,'Poker.Game');
			var id = toMongoId(params._id);
			Game.getGame(id,function (err,game) {
				if (game.standUp(this)) this.send(codes.srTableStandUpOk,game.getTableStatus(),'Poker.TableStatus');
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
function Game(obj) {
	this.users = {};
	this.members = [];
	this.obj = obj;
	this.id = obj._id;
	activeGames[this.id] = this;
	this.state = 'idle';
}
Game.prototype.edited = function edited(params) {
	// FIXME, more fields, also now acts as a cache for seGameChange/seGameDelete
	this.obj.seats = params.seats;
}
Game.prototype.join = function join(conn) {
	this.users[conn.userid] = conn;
	return true;
}
Game.prototype.sitDown = function (conn,params) {
	// FIXME, handle chips
	conn.log('sitting down',params);
	if ((params.seat_index < 0) || (params.seat_index >= this.obj.seats)) {
		conn.reply(0,'invalid seat index');
		return;
	}
	if (this.members[params.seat_index]) {
		conn.send(codes.srTableSitSeatTaken,this.getTableStatus(),'Poker.TableStatus');
	} else {
		this.members[params.seat_index] = { conn:conn, hand: new Hand(), inhand:false };
		if (this.state == 'idle') {
			if (this.sittingCount() > 1) {
				for (var x=0; x<this.members.length; x++) {
					if (!this.members[x]) continue;
					this.deck.draw(2,this.members[x].hand);
					this.members[x].inhand = true;
				}
				this.state = 'preflop';
			}
		}
		var status = this.getTableStatus();
		console.log('sending table status to all');
		conn.send(codes.srTableSitOk,status,'Poker.TableStatus');
		for (var key in this.users) {
			if (this.users[key] == conn) continue;
			this.users[key].send(codes.srTableStatus,status,'Poker.TableStatus');
		}
		// FIXME json performance hack
		allClubs.findOne({_id:this.obj.clubid},function (err,club) {
			var g = makeGameProtobuf(JSON.parse(JSON.stringify(this.obj)));
			for (var x=0; x<club.members.length; x++) {
				var conn2 = activeUsers[club.members[x]];
				if (!conn2) continue;
				if (conn2 === conn) continue;
				conn2.send(codes.seGameChange,g,'Poker.Game');
			}
		}.bind(this));
	}
}
Game.prototype.fold = function fold(seat) {
	switch (this.state) {
	case 'idle':
		break;
	case 'preflop': // most states go here
		if (this.inHandCount() == 1) {
			var seat;
			for (var x=0; x<this.members.length; x++) {
				if (!this.members[x]) continue;
				if (!this.members[x].inhand) continue;
				seat = x;
			}
			console.log('remaining guy wins everything',seat);
			this.state = 'winnning';
			setTimeout(function () {
				this.deck = new Deck();
				this.deck.shuffle(function () {
					for (var x=0; x<this.members.length; x++) {
						if (!this.members[x]) continue;
						this.members[x].inhand = false;
						this.members[x].hand = new Hand();
					}
					this.state = 'idle';
					console.log('reset');
					this.broadcastStatus(null);
				}.bind(this))
			}.bind(this),2000);
		}
		break;
	}
}
Game.prototype.broadcastStatus = function (conn) {
	var status = this.getTableStatus();
	console.log('sending table status to all');
	for (var key in this.users) {
		if (this.users[key] == conn) continue;
		this.users[key].send(codes.srTableStatus,status,'Poker.TableStatus');
	}
}
Game.prototype.getTableStatus = function getTableStatus() {
	var tableStatus = {table_mongo_id:new Buffer(this.id.toString(),'hex'),seats:[], state:this.state};
	for (var x=0; x<this.members.length; x++) {
		if (!this.members[x]) continue;
		var seat = this.members[x];
		//console.log('table debug',x,seat.conn.userid,seat.hand.prettyPrint());
		var obj = {seat:x, player_mongo_id:new Buffer(seat.conn.userid.toString(),'hex'), chips:666, inhand:seat.inhand}
		obj.cards = seat.hand.prettyPrint();
		obj.card_count = obj.cards.length / 2;
		tableStatus.seats.push(obj);
	}
	console.log(tableStatus);
	return tableStatus;
}
Game.prototype.sittingCount = function () {
	var count = 0;
	for (var x=0; x<this.members.length; x++) {
		if (!this.members[x]) continue;
		count++;
	}
	return count;
}
Game.prototype.inHandCount = function () {
	var count = 0;
	for (var x=0; x<this.members.length; x++) {
		if (!this.members[x]) continue;
		if (!this.members[x].inhand) continue;
		count++;
	}
	return count;
}
Game.prototype.standUp = function (conn) {
	for (var x=0; x<this.members.length; x++) {
		if ((this.members[x]) && (this.members[x].conn == conn)) {
			// FIXME, do something with his cards
			var seating = this.members[x];
			this.members[x] = null;
			if (seating.inhand) this.fold(x,seating);
			var status = this.getTableStatus();
			for (var key in this.users) {
				console.log('interator',key,this.users[key].userid,conn.userid);
				if (this.users[key] == conn) continue;
				this.users[key].send(codes.srTableStatus,status,'Poker.TableStatus');
			}
			// FIXME json performance hack
			allClubs.findOne({_id:this.obj.clubid},function (err,club) {
				var g = makeGameProtobuf(JSON.parse(JSON.stringify(this.obj)));
				for (var x=0; x<club.members.length; x++) {
					var conn2 = activeUsers[club.members[x]];
					if (!conn2) continue;
					if (conn2 === conn) continue;
					conn2.send(codes.seGameChange,g,'Poker.Game');
				}
			}.bind(this));
			return true;
		}
	}
	return false;
}
Game.prototype.leave = function leave(conn) {
	// FIXME, inform other members
	delete this.users[conn.userid];
	this.standUp(conn);
}
Game.handleDisconnect = function handleDisconnect(conn) {
	// FIXME
	for (key in activeGames) {
		var game = activeGames[key];
		if (game.users[conn.userid]) game.leave(conn);
	}
}
Game.getGame = function getgame(id,cb) {
	if (!activeGames[id]) {
		allGames.findOne({_id:id},function (err,obj) {
			var game = new Game(obj);
			game.deck = new Deck();
			game.deck.shuffle(function shuffled(){
				console.log(game.deck.prettyPrint());
				//this.send(codes.SR_DECKREPLY,{deck:deck.prettyPrint()},'Poker.GetDeckReply');
				cb(null,game);
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
		this.log('found game channel!',ev);
		for (key in game.users) {
			//if (key == this.userid) continue;
			game.users[key].send(codes.seChat,ev,'Poker.ChatEvent');
		}
		break;
	}

}
function checkGameParams(smallblind,bigblind,gamename,seats,game_type,game_limit) {
	if (smallblind < 1) return true;
	if (smallblind > bigblind) return true;
	if (gamename.length < 3) return true;
	if (gamename.length >= sharedconfig.stringSizes.gamename) return true;
	if ([2,6,9,10].indexOf(seats) == -1) return true;
	if ([0,1].indexOf(game_type) == -1) return true;
	if ([0,1,2].indexOf(game_limit) == -1) return true;
	return false;
}
ClientSocket.prototype.destroy = function destroy() {
	this.socket.destroy();
}
server.listen(12345);
