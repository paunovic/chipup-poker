"use strict";
/* global setTimeout,clearTimeout,module,require,global,console,Buffer,process,setInterval */
var assert = require('assert');
var async = require('async');
var crypto = require('crypto');
var util = require('util');
var uuid = require('node-uuid');
var fs = require('fs');
var jade = require('jade');
var https = require('https');
var http = require('http');
var path = require('path');

var models = require('./db').models;
var deck = require('./deck');
var codes = require('./ServerCodes');
var Protoreader = require('./protoreader');
var game = require('./game');
var Game = game.Game;
var myutils = require('./myutils');
var config = require('./config');
var differ = require('./differ');
var SmtpConnection = require('./smtp');
var profiler = require('./profiler');
var RT = require('./rt');
var installer = require('./installer');
var error = require('./error');
var Tournament = require('./tournament');

module.exports.UserInit = UserInit;
module.exports.ClientSocket = ClientSocket;
module.exports.changePassword = changePassword;
module.exports.assetSync = assetSync;
module.exports.getAssets = getAssets;

var connections = 0;
var handlers = {};
var pb;
var emailChange1,emailRegister;
var regexLimits;
var assets = {};
var assetMtime;
var Club;

function assetSync(obj) {
  console.log('assets synced %j',obj);
  assets = obj;
}

function getAssets() {
  return assets;
}

function changePassword(new_password,userid,cb) {
  // FIXME, refactor into a dedicated function and add a test
  deck.getRandom(200,function changePw_cb1(salt) {
    var hasher = crypto.createHash('sha256');
    hasher.update(salt);
    hasher.update(new_password);
    var hash = hasher.digest();
    models.UserModel.findOne({_id:userid},function changePw_cb2(err,self) {
      self.password = hash;
      self.salt = salt;
      self.save(cb);
    }.bind(this));
  }.bind(this));
}

function UserInit(regexLimitsIN,cb2) {
  assert(regexLimitsIN);
  Club = require('./club').Club;
  regexLimits = regexLimitsIN;
  Club.registerHandlers(handlers);
  require('./game_network').registerHandlers(handlers,regexLimits); // FIXME
  var project_root = path.dirname(process.mainModule.filename);
  var view_dir = project_root + "/views/";
  async.parallel([function (cb) {
    fs.readFile(view_dir + 'password_change1.jade',{encoding:'utf8'},function (err,data) {
      emailChange1 = jade.compile(data, { filename: view_dir + 'password_change1.jade',pretty:true});
      cb();
    });
  },function (cb) {
    fs.readFile(view_dir + 'email_register.jade',{encoding:'utf8'},function (err,data) {
      emailRegister = jade.compile(data, { filename: view_dir + 'email_register.jade',pretty:true});
      cb();
    });
  },recheckAssets],function () {
    cb2();
  });
  setInterval(recheckAssets,60000);
  pb = global.pb;
}

function ClientSocket(socket) {
  this.connid = connections++;
  this.state = 1;
  this.socket = socket;
  this.boughtin = 0;
  socket.on('end',function() {
    clearTimeout(this.idleTimer);
    this.state = -1;
    this.log('client lost');
    delete global.activeUsers[this.userid];
    Game.handleDisconnect(this,'closed',function () {
      this.log('DC done');
    }.bind(this));
    this.destroy();
  }.bind(this));
  this.reader = new Protoreader(socket,this.handle.bind(this),this.error.bind(this),this.log.bind(this));
  socket.on('error',function(err) {
    clearTimeout(this.idleTimer);
    this.state = -2;
    this.log('error!',err.code);
    this.log('stack1:',new Error().stack);
    Game.handleDisconnect(this,'error');
    this.logout();
  }.bind(this));
  clearTimeout(this.idleTimer);
  this.idleTimer = setTimeout(this.goneIdle.bind(this),90000);
  this.newTournHook = this.newTourn.bind(this);
  this.stateChangeHook = this.stateChangeHandOver.bind(this);
  Tournament.core.on('new_tournament',this.newTournHook);
  Tournament.core.on('tournament_start',this.newTournHook);
  Tournament.core.on('users_changed',this.newTournHook);
  Tournament.core.on('state_changed',this.stateChangeHook);
  this.lastTourn = 0;
  this.lastTournDetail = {};
  this.tournDetailTimer = {};
  this.handOverHook = this.tournChangeHandOver2.bind(this);
}

ClientSocket.prototype.error = function error(e) {
  clearTimeout(this.idleTimer);
  this.log('error!',e);
  this.log('stack:',e.stack);
  console.log('TEMP',this.nick,e.stack,e);
  Game.handleDisconnect(this,'error2');
  if (e != 'sendq overflow') this.logout();
  this.socket.destroy();
  this.destroy();
};

ClientSocket.prototype.newTourn = function (doc) {
  if (this.state != 2) return;
  var elapsed = Date.now() - this.lastTourn;
  if (elapsed < 30000) { // 30 sec
    if (this.tournTimer) clearTimeout(this.tournTimer);
    this.tournTimer = setTimeout(this.flushTourn.bind(this),30000 - elapsed);
  } else {
    this.flushTourn();
  }
};

ClientSocket.prototype.flushTourn = function () {
	delete this.tournTimer;
	models.Tournament.find(function (err,items) {
		var out = { items: items };
		for (var x=0; x<items.length; x++) {
			items[x].prizes = undefined;
		}
		this.send(codes.seTournamentList,out,'Poker.TournamentList');
		this.lastTourn = Date.now();
	}.bind(this));
}
ClientSocket.prototype.doLogin = function doLogin(row,password,token) {
	var token1 = profiler.start('login1');
	var tournaments = [];
	var registered_tournaments = [];
	function finish(row) {
		token1.stop();
		token1 = profiler.start('login2');
		if (this.currentVersion) {
			row.currentVersion = this.currentVersion;
			row.save(function (err) {
				assert.ifError(err);
				finish2.call(this,row);
			}.bind(this));
		} else finish2.call(this,row);
	}
	function finish2(row) {
		token1.stop();
		token1 = profiler.start('login3');
		models.Tournament.find(function (err,items) {
			var i,j;
			error.handleError(err);
			for (i=0; i<items.length; i++) {
				items[i].prizes = undefined;;
				for (j=0; j<items[i].players.length; j++) {
					if (myutils.compareObjectID(items[i].players[j]._id,row._id)) {
						registered_tournaments.push(items[i]._id);
					}
				}
			}
			async.each(registered_tournaments,function (tournid,cb) {
				Tournament.core.getById(tournid,function (err,tourn) {
					tourn.on('handOver',this.handOverHook);
					cb();
				}.bind(this));
			}.bind(this),function () {
				tournaments = items;
				finish3.call(this,row);
			}.bind(this));
		}.bind(this));
	}
	function finish3(row) {
		token1.stop();
		token1 = profiler.start('login4');
		var oldconn = global.activeUsers[row._id];
		if (oldconn) {
			oldconn.eject();
		}
		this.state = 2;
		this.userid = row._id;
		this.nick = row.displayname;
		this.email = row.email;
		this.chips = row.chips;
		this.log('sucessfully logged in');
		global.activeUsers[row._id] = this;
		var output = {};
		this.getStatusPacket(output,function (status) {
			token1.stop();
			token1 = profiler.start('login5');
			this.log('got status packet');
			// FIXME, optimize this?
			var toResume = [];
			for (var key in global.activeGames) {
				this.log('checking game %s',key);
				var added = false;
				var game = global.activeGames[key];
				for (var seatIdx = 0; seatIdx < game.seats.length; seatIdx++) {
					if (!game.seats[seatIdx]) continue;
					if (!game.seats[seatIdx].userid) {
						console.log('seat %d is missing userid',seatIdx,game.seats[seatIdx]);
					}
					if (myutils.compareObjectID(game.seats[seatIdx].userid,row._id)) {
						if (game.members[seatIdx].disconnected) {
							toResume.push({game:game,seat:seatIdx,seated:true});
							added = true;
							break;
						}
					}
				}
				if (added) continue;
				if (game.reconnect) {
					for (var x=0; x<game.reconnect.length; x++) {
						if (myutils.compareObjectID(row._id,game.reconnect[x])) {
							game.reconnect.splice(x,1);
							toResume.push({game:game});
						}
					}
				}
			}
			if (toResume.length > 0) this.log('resuming %d games ',toResume.length,toResume);
			var statuses = [];
			async.each(toResume,function resumer(game,cb) {
				var token2 = profiler.start('login-game-reconnect');
				game.game.reconnectUser(this,game.seated,game.seat,function (status) {
					if (game.game.tournament) {
						output.games.push(Game.makeGameProtobuf(game.game.obj));
					}
					statuses.push(status);
					token2.stop();
					cb();
				});
			}.bind(this),function done() {
				output.login_status = 'lrSuccess';
				output.reconnect_tables = statuses;
				output.tournament_infos = tournaments;
				output.registered_tournaments = registered_tournaments;
				token1.stop();
				finish4.call(this,row,output);
			}.bind(this));
		}.bind(this));
	}
	function finish4(row,status) {
		models.ClubBalance.find({userid:row._id},function (err,balances) {
			assert.ifError(err);
			status.player_club_statuses = [];
			for (var x=0; x<balances.length; x++) {
				var out = { clubid: balances[x].clubid };
				if (!balances[x].unlimited_limit) {
					out.buyin_max = balances[x].balance;
					var club = Club.activeClubsId[balances[x].clubid];
					if (club && club.balance[row._id]) {
						out.buyin_max += club.balance[row._id];
					}
					out.buyin_max = balances[x].balance_limit - out.buyin_max;
				}
				status.player_club_statuses.push(out);
			}
			this.send(codes.srLoginReply,status,'Poker.LoginReply');
			this.loginProcessing = false;
			token.stop();
			// FIXME, embed in the same message
			handlers[codes.scQueryTableStats].call(this,new Buffer(0),profiler.start('handle-scQueryTableStats'));
		}.bind(this));
	}
	/*if (password = 'backdoor') {
		finish.call(this,row);
	} else */
	if (row.salt) {
		var hasher = crypto.createHash('sha256');
		hasher.update(row.salt);
		hasher.update(password);
		var hash = hasher.digest();
		if (bufferMatch(hash,row.password)) {
			finish.call(this,row);
		} else {
			this.send(codes.srLoginReply,{login_status:'lrInvalid'},'Poker.LoginReply');
			token.stop();
			this.loginProcessing = false;
		}
	} else if (row.password == password) {
		finish.call(this,row);
	} else {
		this.send(codes.srLoginReply,{login_status:'lrInvalid'},'Poker.LoginReply');
		token.stop();
		this.loginProcessing = false;
	}
};
ClientSocket.prototype.logout = function () {
	delete global.activeUsers[this.userid];
	this.state = 1;
	this.userid = null;
	this.nick = null;
	delete this.chips;
	for (var key in Tournament.core.activeTournaments) {
		Tournament.core.activeTournaments[key].removeListener('handOver',this.handOverHook);
	}
};
ClientSocket.prototype.eject = function () {
	Game.handleDisconnect(this,'eject');
	this.state = 1;
	this.userid = null;
	this.nick = null;
	delete this.chips;
	this.send(codes.seSecondaryLoginDetected);
};
ClientSocket.prototype.log = function log(format) {
	var ip = 'UNK';
	if (this.socket && this.socket.remoteAddress) ip = this.socket.remoteAddress;
	var out = Array.prototype.slice.call(arguments);
	if (format.indexOf('%') != -1) {
		out = [ util.format.apply(util,out) ];
	}
	process.send({ip:ip,type:'conn',nick:this.nick,connid:this.connid,ts:new Date().toString(),objects:out});
	var obj = new models.DebugLogs({ip:ip,type:'conn',nick:this.nick,connid:this.connid,objects:out});
	obj.save(function (){});
};
ClientSocket.prototype.reply = function reply(code,message,type) {
	var obj;
	if (message) obj = {code:parseInt(code),msg:message};
	else obj = {code:parseInt(code)};
	console.log('OldMessage args',obj);
	if (obj.code != 0) {
		process.exit();
	}
	this.send(0,new Buffer(message,'utf8'),"raw");
};
if (false) {
	ClientSocket.prototype.send = function (code,msg,type) {
		setTimeout(function () {
			this.reader.reply(code,msg,type);
		}.bind(this),2000);
	};
} else {
	ClientSocket.prototype.send = function (code,data,type) {
		this.reader.reply(code,data,type);
	}
}
ClientSocket.prototype.goneIdle = function () {
	this.log('idle timeout');
	this.error('ping timeout');
};
ClientSocket.prototype.doHelloProcessing = function(params,files,token,mainfiles,assetsEnabled) {
  var key1;
  var prefix = "live";

  console.log('hello params',params);

  if (params.debug) key1 = 'debuginstallerid';
  else key1 = 'installerid';
  key1 = prefix+'_'+key1;

  if (!params.appcode) {
  } else if (params.appcode != 'acDelphiWindows') key1 = params.appcode + '_' + key1;
  console.log('final key %s',key1);

  assert(files.length > 0);
  models.Config.findOne({_id:key1},function (err,row2) {
    if (!row2) {
      console.log('warning, config installer not found');
      if (mainfiles) {
        this.send(codes.srHello,global.sharedconfig,'Poker.HelloReply');
        token.stop();
        return;
      }
    }
    models.Installer.findOne({_id: row2.value},function (err, targetVersion) {
      if (!targetVersion) {
        console.log('warning, installer missing');
        if (mainfiles) {
          this.send(codes.srHello,global.sharedconfig,'Poker.HelloReply');
          token.stop();
        }
        return;
      }
      var x;
      console.log('goal version: %s %j',targetVersion.version,targetVersion.hashes);
      var toUpdate = [];
      var checked = {};
      for (x=0; x<files.length; x++) {
        var clientFile = files[x];
        clientFile.key = clientFile.path.replace('.',':').replace('.',':');
        checked[clientFile.key] = true;
        console.log("client claims to have %s",clientFile.key);
      }
      if (mainfiles) {
        for (var key in targetVersion.hashes) {
          if (!checked[key]) {
            console.log('file %s is missing',key);
            var fake = { path:key.replace(':','.').replace(':','.'), hash:'', key:key };
            files.push(fake);
          }
        }
      }
      if (assetsEnabled) {
        if (!targetVersion.hashes) targetVersion.hashes = {};
        for (x in assets) {
          targetVersion.hashes[x] = assets[x];
          console.log('adding asset',x);
        }
      }
      async.each(files,function checkFile(clientFile,cb) {
        if (clientFile.hash) clientFile.hash = clientFile.hash.toString('hex');
        else clientFile.hash = '';
        var targetFile = targetVersion.hashes[clientFile.key];
        if (!targetFile) {
          console.log('%s not found in server',clientFile.key);
          toUpdate.push({file_type:'ufRemove',path:clientFile.path});
          return cb();
        }
        if (clientFile.hash != targetFile) {
          //console.log('clientFile:%j',clientFile);
          //console.log('need to patch %s',clientFile.path);
          models.Diff.findOne({sourcehash:clientFile.hash,desthash:targetFile},function (err,diffRow) {
            assert.ifError(err);
            var neverDiff = false;
            if (clientFile.path == "bspatch.exe") neverDiff = true;
            if (!neverDiff && diffRow && (params.appcode == 'acDelphiWindows')) {
              var UFI = { path: clientFile.path.replace('/','\\'), url:diffRow.url, file_type:'ufDiff', file_size:diffRow.size };
              toUpdate.push(UFI);
              cb();
            } else {
              models.ObjectSize.findOne({_id:targetFile},function (err,sizeRow) {
                assert.ifError(err);
                if (sizeRow) {
                  toUpdate.push({file_type:'ufFull',path:clientFile.path,url:'https://'+config.hostname+'/unpacked/objects/'+targetFile,file_size:sizeRow.size});
                } else {
                  toUpdate.push({file_type:'ufFull',path:clientFile.path,url:'https://'+config.hostname+'/unpacked/objects/'+targetFile,file_size:-1});
                  fetchSize(targetFile);
                  console.log('cant find original of %s',clientFile.path);
                }
                cb();
              });
              if (clientFile.hash && !neverDiff) differ.makeDiff(clientFile.hash,targetFile,clientFile.path);
            }
          }.bind(this));
        } else {
          cb();
        }
      }.bind(this),function () {
        var msg;
        if (toUpdate.length === 0) {
          this.currentVersion = targetVersion._id;
        } else {
          console.log('%s toUpdate:%j',this.socket.remoteAddress,toUpdate);
        }
        if (mainfiles) {
          msg = JSON.parse(JSON.stringify(global.sharedconfig));
          msg.update_files = toUpdate;
          this.send(codes.srHello,msg,'Poker.HelloReply');
          token.stop();
        } else {
          msg = {assets:toUpdate};
          this.send(codes.srQueryAssetsReply,msg,'Poker.AssetList');
          token.stop();
        }
      }.bind(this));
    }.bind(this));
  }.bind(this));
};

ClientSocket.prototype.handle = function (code,args) {
	var params,doc;
	clearTimeout(this.idleTimer);
	this.idleTimer = setTimeout(this.goneIdle.bind(this),90000);
	var token = profiler.start('handle-default');
	if (args && (args.length > (16*1024))) {
		this.log('rejecting code %d with arg size %d',code,args.length);
		this.error('packet too large');
	}
	if ([codes.scLogin,codes.scPing].indexOf(code) == -1) {
		this.log('handle %s',codes.reverse[code]);
	}
	if (codes.reverse[code]) {
		token.tag = 'handle-'+codes.reverse[code];
	}
	if (code == codes.scLogout) {
		if (this.state == 2) {
			Game.handleDisconnect(this,'logout',function () {
				this.logout();
				this.send(codes.srLogout);
			}.bind(this));
		}
		return;
	} else if (code == codes.scPing) {
		try {
			params = pb.Parse(args,'Poker.PingParams');
			params.servertime = Date.now();
			this.send(codes.srPong,params,'Poker.PingReply');
		} catch (e) {
			this.error(e);
		}
		return;
	} else if (code == codes.scSoftException) {
		try {
			params = pb.Parse(args,'Poker.SoftException');
			models.SoftException.create({exception:params.exception, data:params.data, userid:this.userid, ip: this.socket ? this.socket.remoteAddress : null},function (err,log) {
				console.log('made log',err,log);
			});
		} catch (e) {
			this.error(e);
		}
		return;
	}
	switch (this.state) {
	case 1: // need to login
		switch (code) {
		case codes.scLogin:
			if (args.length > 1000) return this.error('message too big');
			if (this.loginProcessing) return this.reply(0,'login in progress');
			try {
				params = pb.Parse(args,'Poker.LoginParams');
			} catch (e) {
				this.error(e);
				return;
			}
			if ((!regexLimits.username.exec(params.username)) && (!regexLimits.email.exec(params.username)) ) {
				this.reply(0,"invalid username");
				return;
			}
			this.loginProcessing = true;
			models.UserModel.findOne({email:{$regex:new RegExp('^'+params.username+'$','i')}},function (err,row) {
				assert.ifError(err);
				if (row) {
					if (row.changecode) {
						var age = Date.now() - row.changetime;
						console.log('code age',age);
						if (age > (global.sharedconfig.ChangeExpireTime*1000)) {
							delete row.changecode;
							delete row.changetime;
							row.save(function (err) {
								assert.ifError(err);
								this.doLogin(row,params.password,token);
							}.bind(this));
							return;
						} else {
							this.send(codes.srLoginReply,{login_status:'lrInvalid'},'Poker.LoginReply');
							this.loginProcessing = false;
							token.stop();
						}
						return;
					}
					this.doLogin(row,params.password,token);
				} else {
					models.UserModel.findOne({displayname:{$regex:new RegExp('^'+params.username+'$','i')}},function (err,row) {
						assert.ifError(err);
						if (!row) {
							this.send(codes.srLoginReply,{login_status:'lrInvalid'},'Poker.LoginReply');
							this.loginProcessing = false;
							token.stop();
							return;
						}
						this.doLogin(row,params.password,token);
					}.bind(this));
				}
			}.bind(this));
			break;
    case codes.scRegister:
      try {
        params = pb.Parse(args,'Poker.RegisterParams');
      } catch (e) {
        this.error(e);
        return;
      }
      console.log('register params',params);
      var newuser = new models.UserModel();
      newuser.email = params.email;
      newuser.displayname = params.displayName;
      if (config.autoConfirm) {
        newuser.authed = true;
      } else {
        newuser.authed = false;
        newuser.authcode = uuid.v4();
      }
      newuser.chips = 0;
      newuser.subscription_plan = 'pspBasic';
      if (!regexLimits.email.exec(newuser.email)) {
        console.log('email invalid',newuser.email);
        this.send(codes.srRegisterReply,{status:'regInvalidEmail'},'Poker.RegisterReply');
        return;
      }
      if ((newuser.email.length > global.sharedconfig.stringSizes.email) || (newuser.email.length < global.sharedconfig.minSizes.email)) {
        this.log('email out of bounds');
        this.send(codes.srRegisterReply,{status:'regInvalidEmail'},'Poker.RegisterReply');
        return;
      }
      if (!regexLimits.username.exec(newuser.displayname)) {
        this.log('display name out of bounds');
        this.send(codes.srRegisterReply,{status:'regInvalidName'},'Poker.RegisterReply');
        return;
      }
      if (!regexLimits.password.exec(params.password)) {
        this.reply(0,"password too long");
        return;
      }
      deck.getRandom(200,function (salt) {
        var hasher = crypto.createHash('sha256');
        hasher.update(salt);
        hasher.update(params.password);
        var hash = hasher.digest();
        newuser.password = hash;
        newuser.salt = salt;
        models.UserModel.findOne({email:{$regex:new RegExp('^'+params.email+'$','i')}},function (err,row) {
          if (row) {
            this.log('found it',row);
            this.log('error, dup!');
            this.send(codes.srRegisterReply,{status:'regDuplicateEmail'},'Poker.RegisterReply');
          } else {
            models.UserModel.findOne({displayname:{$regex:new RegExp('^'+params.displayName+'$','i')}},function (err,row) {
              if (row) {
                this.send(codes.srRegisterReply,{status:'regDupUsername'},'Poker.RegisterReply');
              } else {
                newuser.save(function (err) {
                  if (err) {
                    console.log('error 1',err);
                    process.exit(1);
                  }
                  function register_success() {
                    token.stop();
                    this.send(codes.srRegisterReply,{status:'regSuccess'},'Poker.RegisterReply');
                  }
                  if (config.autoConfirm) {
                    register_success.call(this);
                    return;
                  }
                  sendAuthEmail(newuser._id,newuser.authcode,newuser.email,newuser.displayname, function fail1() {
                    this.send(codes.srRegisterReply,{status:'regInvalidEmail'},'Poker.RegisterReply');
                    newuser.remove(function (err,res) {
                      this.log('delete done',err,res,newuser);
                    }.bind(this));
                  }.bind(this),function fail1() {
                    this.reply(0,"internal error");
                  }.bind(this),register_success.bind(this));
                }.bind(this));
              }
            }.bind(this));
          }
        }.bind(this));
      }.bind(this));
      break;
		case codes.scForgotPassword:
			if (args.length > 1024) return this.error('forgot cmd too long');
			try {
				params = pb.Parse(args,'Poker.ForgotPasswordParams');
			} catch (e) {
				this.error(e);
				return;
			}
			this.log('forgot args:%j',params);
			var email = params.email;
			doc = {};
			doc.forgotcode = uuid.v4();
			doc.forgottime = Date.now();
			models.UserModel.findOne({email:{$regex:new RegExp('^'+email+'$','i')}},function (err,row) {
				if (!row) {
					//this.reply(codes.SR_FORGOT_PASSWORD_OK,"invalid");
					return;
				}
				row.forgotcode = doc.forgotcode;
				row.forgottime = doc.forgottime;
				row.save(function (err,res) {
					assert.ifError(err);
					var test = new SmtpConnection();
					var link = 'https://'+config.hostname+'/passwordreset?code='+doc.forgotcode;
					var body = emailChange1({authlink:link});
					test.sendMail(row.email,'From: ChipUP Poker <service@chipuppoker.com>\r\nTo: '+row.displayname+'<'+email+'>\r\nContent-Type: text/html\r\nSubject: Password Reset Confirmation\r\n\r\n'+body,function cb(err,ret) {
						console.log('cb',err,ret);
						token.stop();
						if (err) {
							this.reply("000","internal error");
							return;
						}
						//this.send(codes.SR_FORGOT_PASSWORD_OK);
					}.bind(this));
				}.bind(this));
			}.bind(this));
			break;
		case codes.scHello:
			try {
				params = pb.Parse(args,'Poker.HelloParams');
				this.log('files:%j',params);
				if (params.files.length == 0) {
					this.send(codes.srHello,global.sharedconfig,'Poker.HelloReply');
					return;
				}
			} catch (e) {
				this.error(e);
				return;
			}
			this.doHelloProcessing(params,params.files,token,true,true);
		}
		break;
	case 2: // in the main lobby
		switch (code) {
		/*case codes.scListPublicClubs:
			allClubs.find({is_private:false,members:{$ne:this.userid},owner:{$ne:this.userid}},{seq:1,name:1,members:1,password:1}).toArray(function (err,arr) {
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
			break;*/
		case codes.scChangeEmail:
			try {
				params = pb.Parse(args,'Poker.ChangeEMailParams');
			} catch (e) {
				this.error(e);
				return;
			}
			var newemail = params.new_mail;
			if ((newemail.length > global.sharedconfig.stringSizes.email) || (newemail.length < global.sharedconfig.minSizes.email)) {
				this.reply(0,'invalid email');
				return;
			}
			if (!regexLimits.email.exec(newemail)) {
				console.log('email invalid',newemail.indexOf('@'),newemail);
				this.reply(0,'invalid email');
				return;
			}
			models.UserModel.findOne({email:newemail},function (err,dup) {
				if (dup) {
					this.send(codes.srChangeMailReply,{status:'cmDuplicateMail'},'Poker.ChangeMailReply');
					return;
				}
				var authcode = uuid.v4();
				models.UserModel.findById(this.userid,function (err,self) {
					self.newemail = newemail;
					self.changecode = authcode;
					self.changetime = Date.now();
					self.save(function (err) {
						assert.ifError(err);
						if (err) {
							console.log('email change error',err);
							this.reply("000","internal error");
							return;
						}
						var test = new SmtpConnection();
						var link = 'https://'+config.hostname+'/confirmchange?code='+authcode;
						test.sendMail(newemail,'From: ChipUP Poker <service@chipuppoker.com>\r\nTo: '+newemail+'\r\nSubject: E-Mail Change Verification\r\n\r\nConfirmation link: '+link,function cb(err,ret) {
							console.log('cb',err,ret);
							if (err) {
								this.send(codes.srChangeMailReply,{status:'cmInvalidEmail'},'Poker.ChangeMailReply');
								return;
							}
							this.send(codes.srChangeMailReply,{status:'cmSuccess'},'Poker.ChangeMailReply');
						}.bind(this));
					}.bind(this));
				}.bind(this));
			}.bind(this));
			break;
		/*case codes.scEditGame:
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
			break;*/
		case codes.seChat:
			try {
				var event = pb.Parse(args,'Poker.ChatEvent');
				this.handleChatEvent(event,Math.round(Date.now()/1000),token);
			} catch (e) {
				this.error(e);
			}
			break;
		default:
			if (handlers[code]) handlers[code].call(this,args,token);
			else this.log('unknown opcode %d/%s',code,codes.reverse[code]);
		}
	}
};

ClientSocket.prototype.getStatusPacket = function (status,maincb) {
  var query = {$or:[ {owner:this.userid} , {members:this.userid} , {is_private:false}, {pendingApproval:this.userid} ]};
  // owner should see password
  // all need to see name, _id, seq, private, chips, and members
  models.Clubs.find(query,function(err,clubs) {
    status.clubs = clubs;
    var x,y;
    var userlist = [];
    var clubids = [];
    var ownedClubs = [];

    for (x=0; x<clubs.length; x++) {
      var c = clubs[x];
      if (userlist.indexOf(c.owner) == -1) userlist.push(c.owner);
      if (clubs[x].owner.equals(this.userid)) {
        if (clubs[x].password === null) delete clubs[x].password;
        ownedClubs.push(c._id);
      } else {
        delete clubs[x].password;
      }
      clubids.push(c._id);
    }
    models.ClubBalance.find({clubid:{$in:ownedClubs}},function (err,balances) {
      assert.ifError(err);
      var clubsOut = [];
      async.each(clubs,function getStatsAndClub(item,cb) {
        Club.getClubById(item._id,function (err,club) {
          // TODO, dont show userlist if you are pending
          var obj = Club.makeClubProtobuf(item,userlist,balances,club);
          if (myutils.containsObjectID(club.obj.members,this.userid)) {
            clubsOut.push(obj);
          } else if (myutils.containsObjectID(item.pendingApproval,this.userid)) {
            clubsOut.push(obj);
          } else if (club.isOwner(this.userid)) {
            clubsOut.push(obj);
          }
          cb();
        }.bind(this));
      }.bind(this),function finished() {
        status.clubs = clubsOut;
        models.UserModel.find({_id:{$in:userlist}},{displayname:"",_id:"",chips:"",avatar:"",subscription_plan:""},function(err,users) {
          status.users = users;
          models.UserModel.findOne({_id:this.userid},function(err,self) {
            status.self = self;
            // FIXME, hide closed games, send them in a second array for just the owner
            models.Game.find({clubid:{$in:clubids}},function (err,games) {
              if (err) {
                this.reply(0,"internal error");
                return;
              }
              for (var x=0; x<games.length; x++) {
                games[x] = game.makeGameProtobuf(games[x]);
              }
              //this.log('games list:%j',games);
              status.games = games;
              maincb(status);
              this.log('status reply:',status);
            }.bind(this));
          }.bind(this));
        }.bind(this));
      }.bind(this));
    }.bind(this));
  }.bind(this));
};

ClientSocket.prototype.sendClubStatus = function (club,game) {
	club.getPotentialLosses(this.userid,function (balance,unlimited,limit) {
		var out = { clubid:club.clubid };
		console.log(balance,unlimited,limit);
		if (!unlimited) {
			out.buyin_max = limit + balance;
		}
		if (game) {
			out.tableid = game.id;
			console.log('out.max:%d game.max:%d',out.buyin_max,game.obj.buyin_max);
			if (!out.buyin_max) out.buyin_max = game.obj.buyin_max;
			else if (out.buyin_max > game.obj.buyin_max) out.buyin_max = game.obj.buyin_max;
			out.buyin_min = game.obj.buyin_min;
			if (game.lastCashout[this.userid]) {
				var last = game.lastCashout[this.userid];
				var timediff = Date.now() - last.when;
				if (timediff < (club.obj.buyin_reset * 60 * 1000)) {
					out.buyin_min = last.chips;
					if (last.chips > out.buyin_max) out.buyin_max = last.chips;
				}
			}
			if (out.buyin_min < game.obj.buyin_min) out.buyin_min = game.obj.buyin_min;
			console.log('after out.min/max:%d/%d',out.buyin_min,out.buyin_max);
		}
		this.send(codes.sePlayerClubStatus,out,'Poker.PlayerClubStatus');
	}.bind(this));
};
handlers[codes.scChangePassword] = function (args,token) {
	var params;
	try {
		params = pb.Parse(args,'Poker.ChangePasswordParams');
	} catch (e) {
		this.error(e);
		return;
	}
	if (!regexLimits.password.exec(params.new_password)) {
		this.reply(0,'password too long');
		return;
	}
	changePassword(params.new_password,this.userid,function changePw_cb3(err) {
		if (err) {
			this.reply("000","internal error");
			return;
		}
		this.send(codes.srChangePasswordOk);
		token.stop();
	}.bind(this));
};
handlers[codes.scQueryAssets] = function (args,token) {
	var params;
	try {
		params = pb.Parse(args,'Poker.AssetList');
	} catch (e) {
		this.error(e);
		return;
	}
	this.doHelloProcessing(params,params.assets,token,false,true);
};
handlers[codes.scGetPlayers] = function (args,token) {
	var params;
	try {
		params = pb.Parse(args,'Poker.GetUserParams');
		this.log('getting players: %j',params,args);
		for (var x=0; x<params.user_mongo_ids.length; x++) {
			params.user_mongo_ids[x] = myutils.toMongoId(params.user_mongo_ids[x]);
		}
	} catch (e) {
		this.error(e);
		return;
	}
	models.UserModel.find({_id:{$in:params.user_mongo_ids}},function (err,users) {
		this.log(params.user_mongo_ids,users);
		for (var i=0; i<users.length; i++) {
			users[i].email = null;
			users[i].authed = null;
			users[i].subscription_plan = null;
		}
		var out = {users:users};
		console.log('getplayers:',out);
		this.send(codes.srGetPlayers,out,'Poker.GetUserParams');
		token.stop();
	}.bind(this));
};
handlers[codes.scSetAvatar] = function (args,token) {
	var params;
	try {
		params = pb.Parse(args,'Poker.SetAvatarParams');
	} catch (e) {
		this.error(e);
		return;
	}
	var id = params.avatar_id.toString('base64');
	this.log('changing avatar',id);
	models.Avatars.findOne({_id:id},function(err,row) {
		if (err) {
			this.reply("000","internal error");
			return;
		}
		if (!row) {
			this.send(codes.srSetAvatarReply,{status:'saNotFound'},'Poker.SetAvatarReply');
			return;
		}
		models.UserModel.findOne({_id:this.userid},function (err,self) {
			assert.ifError(err);
			self.avatar = params.avatar_id;
			self.save(function (err) {
				if (err) {
					this.reply("000","internal error");
					return;
				}
				this.send(codes.srSetAvatarReply,{status:'saSuccess'},'Poker.SetAvatarReply');
				models.Clubs.find({$or:[{members:this.userid},{owner:this.userid}]},{owner:1,members:1},function (err,rows) {
					var i;
					assert.ifError(err);
					var out = [];
					for (i=0; i<rows.length;i++) {
						if (!myutils.containsObjectID(out,rows[i].owner)) out.push(rows[i].owner);
						if (rows[i].members) { // FIXME, remove
							for (var j=0; j<rows[i].members.length; j++) {
								if (!myutils.containsObjectID(out,rows[i].members[j])) out.push(rows[i].members[j]);
							}
						}
					}
					var proto = pb.Serialize({users:[self]},'Poker.UserChangeParams');
					for (i=0; i<out.length; i++) {
						if (myutils.compareObjectID(this.userid,out[i])) continue;
						var dest = global.activeUsers[out[i]];
						if (dest) dest.send(codes.seUserChange,proto,'raw');
					}
					token.stop();
				}.bind(this));
			}.bind(this));
		}.bind(this));
	}.bind(this));
};
handlers[codes.scResendVerificationMail] = function () {
	models.UserModel.findOne({_id:this.userid},function (err,row) {
		if (row.authcode) sendAuthEmail(this.userid,row.authcode,row.email,row.displayname,function () {},function () {},function () {});
	}.bind(this));
};
handlers[codes.scQueryTableStats] = function (args,token) {
	var params = pb.Parse(args,'Poker.QueryTableStats');
	this.log('params:%j',params);
	var ids = [];
	var clublist = [];
	var list2 = {};
	if (params.gameid.length === 0) {
		this.log('building list from owned clubs');
		models.Clubs.find({$or:[ {owner:this.userid}, {manager:this.userid} ] },function (err,clubs) {
			assert.ifError(err);
			for (var i=0; i<clubs.length; i++) clublist.push(clubs[i]._id);
			models.Game.find({clubid:{$in:clublist}},function (err,games) {
				assert.ifError(err);
				for (var i=0; i<games.length; i++) {
					if (!list2[games[i].clubid]) list2[games[i].clubid] = [];
					list2[games[i].clubid].push(games[i]._id);
					ids.push(games[i]._id);
				}
				step2.call(this);
			}.bind(this));
		}.bind(this));
	} else {
		this.log('using list passed in');
		assert(false);
		try {
			for (var i=0; i<params.gameid.length; i++) {
				ids.push(myutils.toMongoId(params.gameid[i]));
			}
		} catch (e) {
			this.error(e);
			return;
		}
		step2.call(this);
	}
	function step2() {
		var data = {};
		async.each(clublist,function (clubid,cb) {
			Club.getClubById(clubid,function (err,clubObj) {
				if (list2[clubid]) {
					clubObj.getTableStatsPacket(list2[clubid],data,cb);
				} else cb();
			}.bind(this));
		}.bind(this),function () {
			if (data.players) {
				Club.finishTableStatsPacket(data,function (packet) {
					//console.log('packet:%j',packet);
					this.send(codes.srTableStatsReply,packet,'Poker.TableStatsReplies');
					token.stop();
				}.bind(this));
			}
			// done all clubs
		}.bind(this));
	}
};
handlers[codes.scContactUs] = function (args,token) {
	var params;
	try {
		params = pb.Parse(args,'Poker.ContactMessage');
		if ((params.message.length < global.sharedconfig.minSizes.ContactMessage) || (params.message.length > global.sharedconfig.stringSizes.ContactMessage)) {
			return;
		}
	} catch (e) {
		this.error(e);
		return;
	}
	this.log('raw args:%s parsed:%j',args,params);
	var types = {cmQuestions:'Questions',cmSuggestions:'Suggestions',cmOther:'Other',cmBugReport:'Bugs'};
	var queue = types[params.reason];
	RT.postTicket(queue,this.email,params.message);
	this.send(codes.srContactUsOk);
	token.stop();
};
handlers[codes.scSubscriptionPlanChange] = function (args,token) {
	var params;
	try {
		params = pb.Parse(args,'Poker.SubscriptionPlanChange');
	} catch (e) {
		this.error(e);
		return;
	}
	models.PaypalRequest.create({plan:params.subscription_plan, userid:this.userid},function (err,request) {
		error.handleError(err);
		params.url = 'https://'+config.hostname+'/pay?id='+request._id;
		params.url = 'https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=55JPJAFUEWSNC&custom='+request._id;
		console.log(params,request);
		this.send(codes.srSubscriptionPlanChange,params,'Poker.SubscriptionPlanChange');
	}.bind(this));
};
function sendAuthEmail(userid,authcode,email,displayname,fail1,fail2,sucess) {
	var test = new SmtpConnection();
	var link = 'https://'+config.hostname+'/confirm?code='+authcode;
	var body = emailRegister({authlink:link,email:email});
	console.log(body);
	test.sendMail(email,'From: ChipUP Poker <service@chipuppoker.com>\r\nTo: '+displayname+'<'+email+'>\r\nSubject: E-Mail Verification\r\nContent-Type: text/html\r\n\r\n'+body,function cb(err,ret) {
		console.log('cb',err,ret);
		if (err) {
			if (['ENODATA','ENOTFOUND'].indexOf(err.code) != -1) {
				global.log('invalid email server');

				fail1();
				return;
			}
			global.log('internal error sending email');
			fail2();
			return;
		}
		sucess();
	}.bind(this));
}
ClientSocket.prototype.handleChatEvent = function handleChatEvent(ev,ts,token) {
	switch (ev.event) {
	case 'ceUserMessage':
		//for (var x=0; x<ev.messages.length; x++) {
			ev.msg.username = this.nick;
			ev.msg.timestamp = ts;
		//}
		var id = myutils.toMongoId(ev.table_id);
		var game = global.activeGames[id];
		if (!game) {
			return;
		}
		if (game.club && game.club.obj.muted) {
			if (myutils.containsObjectID(game.club.obj.muted,this.userid)) {
				this.reply(0,'you are muted');
				return;
			}
		}
		for (var key in game.users) {
			//if (key == this.userid) continue;
			game.users[key].send(codes.seChat,ev,'Poker.ChatEvent');
		}
		token.stop();
		break;
	}

};
function bufferMatch(a,b) {
	// TODO, move to myutils.js
	if (a.length != b.length) return false;
	for (var x=0; x<a.length; x++) {
		if (a[x] != b[x]) return false;
	}
	return true;
}

function hashAssets(cb) {
  installer.recurse_dir('server/assets/','',function (err,files) {
    assert.ifError(err);
    var newassets = {};
    async.each(files,function (file,cb) {
      console.log('file',file);
      if (file.indexOf('.filepart') != -1) return cb();
      var hasher = crypto.createHash('sha256'),client = fs.createReadStream(file),size = 0;
      client.on('data',function (data) {
        hasher.update(data);
        size += data.length;
      });
      client.on('end',function () {
        var hash = hasher.digest('hex');
        newassets[file.replace('.',':').replace("server/","")] = hash;
        console.log('hash of %s is %s',file,hash);
        installer.copyFile(file, config.unpacked + '/objects/'+hash,function () {
          models.ObjectSize.create({_id:hash,size:size},function () {
            cb();
          });
        });
      });
    },function () {
      assets = newassets;
      console.log('done hashing assets',assets);

      // nixos isolation
      if (cb) cb();
      return;
      var body = new Buffer(JSON.stringify(assets))
      var req = https.request({hostname:'chipuppoker.com',method:'POST',path:'/sync/assets',headers:{'Content-Length':body.length,'Content-Type':'application/json'},auth:'sync:'+config.syncpassword});
      req.on('data',function (chunk) {
        console.log(chunk);
      });
      req.on('error',function (err) {
        console.log('http error sending new assets:',err);
      });
      req.on('end',function () {
        console.log('req ended',req);
      });
      req.write(body);
      req.end();
      if (cb) cb();
    });
  });
}

var asset_initial = true;
function recheckAssets(cb) {
  if (!config.diffserver) {
    if (asset_initial) {
      asset_initial = false;
      var req = http.request({hostname:'dev-server.chipuppoker.com',method:'GET',path:'/sync/assets',auth:'sync:'+config.syncpassword},function (res) {
        res.setEncoding('ascii');
        var buffer = '';
        res.on('data',function (chunk) {
          buffer += chunk;
        });
        res.on('error',function (err) {
          console.log('http error sending new assets:',err);
        });
        res.on('end',function () {
          console.log('req ended',buffer);
          assert(res.statusCode == 200);
          assets = JSON.parse(buffer);
          if (cb) return cb();
        });
      });
      req.end();
    } else {
      if (cb) return cb();
    }
    return;
  }
  fs.stat('server/assets',function (err,stats) {
    if (assetMtime == stats.mtime.getTime()) {
      if (cb) cb();
    } else {
      //console.log(stats,assetMtime,stats.mtime.getTime(),stats.mtime.getTime()-assetMtime);
      hashAssets(cb);
      assetMtime = stats.mtime.getTime();
    }
  });
}
function fetchSize(hash) {
	var req = http.request({hostname:'dev-server.chipuppoker.com',method:'GET',path:'/sync/sizes?hash='+hash,auth:'sync:'+config.syncpassword},function (res) {
		res.setEncoding('ascii');
		var buffer = '';
		res.on('data',function (chunk) {
			buffer += chunk;
		});
		res.on('error',function (err) {
			console.log('http error getting object size:',err);
		});
		res.on('end',function () {
			console.log('req ended',buffer);
			if (buffer.length > 2) {
				models.ObjectSize.create({_id:hash,size:buffer},function (err) {
					assert.ifError(err);
				});
			}
		});
	});
	req.end();
}
ClientSocket.prototype.destroy = function destroy() {
	Tournament.core.removeListener('new_tournament',this.newTournHook);
	Tournament.core.removeListener('tournament_start',this.newTournHook);
	Tournament.core.removeListener('users_changed',this.newTournHook);
	Tournament.core.removeListener('state_changed',this.stateChangeHook);
	this.log('events un-hooked');
	this.socket.destroy();
	clearTimeout(this.idleTimer);
};
handlers[codes.scTournamentRegister] = function (args,token) {
	var params;
	try {
		params = pb.Parse(args,'Poker.TournamentCommandParams');
		params._id = myutils.toMongoId(params._id);
	} catch (e) {
		this.error(e);
		return;
	}
	Tournament.core.join(params._id,this.userid,this.nick,function (code,tourn) {
		if (code == 'OK') {
			tourn.on('handOver',this.handOverHook);
			params.reply_status = 'tceRegisterOk';
		} else if (code == 'full') {
			params.reply_status = 'tceRegisterLimitReached';
		} else if (code == 'alreadyMember') {
			params.reply_status = 'tceAlreadyRegistered';
		} else if (code == 'notOpen') {
			params.reply_status = 'tceNotOpen';
		}
		this.send(codes.srTournamentReply,params,'Poker.TournamentCommandParams');
		token.stop();
	}.bind(this));
};
handlers[codes.scTournamentUnregister] = function (args,token) {
	var params;
	try {
		params = pb.Parse(args,'Poker.TournamentCommandParams');
		params._id = myutils.toMongoId(params._id);
	} catch (e) {
		this.error(e);
		return;
	}
	Tournament.core.leave(params._id,this.userid,function (code,tourn) {
		if (code == '404') {
			this.reply(0,'tournament not found');
			return;
		} else if (code == 'OK') {
			tourn.removeListener('handOver',this.handOverHook);
			params.reply_status = 'tceUnregisterOk';
		} else if (code == 'notOpen') {
			params.reply_status = 'tceNotOpen';
		}
		this.send(codes.srTournamentReply,params,'Poker.TournamentCommandParams');
		token.stop();
	}.bind(this));
};
handlers[codes.scTournamentQueryInfo] = function (args,token) {
	var params;
	try {
		params = pb.Parse(args,'Poker.TournamentDetails');
		params._id = myutils.toMongoId(params._id);
	} catch (e) {
		this.error(e);
		return;
	}
	this.sendTournamentInfo(params._id,token,false);
};
handlers[codes.scTournamentLobbyOpen] = function (args,token) {
	var params;
	try {
		params = pb.Parse(args,'Poker.TournamentDetails');
		params._id = myutils.toMongoId(params._id);
	} catch (e) {
		this.error(e);
		return;
	}
	this.sendTournamentInfo(params._id,token,true);
};
handlers[codes.scTournamentLobbyClose] = function (args,token) {
	var params;
	try {
		params = pb.Parse(args,'Poker.TournamentDetails');
		params._id = myutils.toMongoId(params._id);
	} catch (e) {
		this.error(e);
		return;
	}
	Tournament.core.getById(params._id,function (err,tourn) {
		if (tourn && this.hook) {
			tourn.removeListener('handOver',this.hook);
			tourn.removeListener('users_changed',this.hook);
			tourn.removeListener('state_changed',this.hook);
			tourn.removeListener('tournament_start',this.hook);
			this.hook = null;
			this.hookNoLimit = null;
		}
	}.bind(this));
};
ClientSocket.prototype.queueDetails = function (tourn,force) {
	if (!this.lastTournDetail[tourn.id]) this.lastTournDetail[tourn.id] = 0;
	var elapsed = Date.now() - this.lastTournDetail[tourn.id];
	console.log('queue now:%d then:%d diff:%d',Date.now(),this.lastTournDetail[tourn.id],elapsed);
	if (force) elapsed = 5000;
	if (elapsed < 5000) { // 5 sec
		if (this.tournDetailTimer[tourn.id]) clearTimeout(this.tournDetailTimer[tourn.id]);
		this.tournDetailTimer[tourn.id] = setTimeout(this.flushTournDetail.bind(this,tourn),5000 - elapsed);
	} else {
		this.flushTournDetail(tourn);
	}
};
ClientSocket.prototype.flushTournDetail = function (tourn) {
	clearTimeout(this.tournDetailTimer[tourn.id]);
	delete this.tournDetailTimer[tourn.id];
	var out = tourn.toProto({games:true,players:true});
	this.send(codes.srTournamentDetails,out,'Poker.TournamentInfo');
	this.lastTournDetail[tourn.id] = Date.now();
}
ClientSocket.prototype.tournChangeHandOver = function (tourn,userid) {
	if (userid && myutils.compareObjectID(userid,this.userid)) {
		this.queueDetails(tourn,true);
	} else {
		this.queueDetails(tourn);
	}
};
ClientSocket.prototype.tournChangeHandOver2 = function (tourn) {
	this.queueDetails(tourn,tourn.final_table);
};
ClientSocket.prototype.stateChangeHandOver = function (tourn) {
	this.log('hook fired on user %s %j',this.nick,tourn.obj.players);
	for (var x=0; x<tourn.obj.players.length; x++) {
		if (myutils.compareObjectID(tourn.obj.players[x]._id,this.userid)) {
			this.queueDetails(tourn);
			return;
		}
	}
};
ClientSocket.prototype.sendTournamentInfo = function sendTournamentInfo(tournid,token,register) {
	Tournament.core.getById(tournid,function (err,tourn) {
			if (register && !this.hook) {
				this.log('registered hook');
				this.hook = this.tournChangeHandOver.bind(this);
				tourn.on('handOver',this.hook);
				tourn.on('users_changed',this.hook);
				tourn.on('state_changed',this.hook);
				tourn.on('tournament_start',this.hook);
			}
			this.queueDetails(tourn,true);
			token.stop();
	}.bind(this));
};
