"use strict";
/* global require,module,global,Buffer,console,process */
var activeGames,pb,regexLimits;

var assert = require('assert');
var ObjectID = require('mongodb').ObjectID;
var async = require('async');
var util = require('util');

var codes = require('./ServerCodes');

function makeGameProtobuf() {
	var self = require('./game').makeGameProtobuf;
	return self.apply(this,arguments);
}
var profiler = require('profiler');
var ReadWriteLock = require('./lock');
var myutils = require('./myutils');
var user = require('./user');
var mdb = require('./db');
var models = mdb.models;

var getLock = new ReadWriteLock();

module.exports.Club = Club;
function Club(obj) {
	if (!(this instanceof Club)) return new Club(obj);
	this.clubid = obj._id;
	this.obj = obj;
	this.balance = {};
}
Club.prototype.refresh = function (obj) {
	assert(compareObjectID(this.clubid,obj._id));
	this.obj = obj;
};
Club.activeClubsSeq = [];
Club.activeClubsId = {};
Club.getClubBySeq = function (seq,cb) {
	getLock.writeLock(function (release) {
		if (!Club.activeClubsSeq[seq]) {
			mdb.models.Clubs.findOne({seq:seq},function (err,obj) {
				assert.ifError(err);
				if (!obj) {
					release();
					return cb('not found');
				}
				Club.activeClubsSeq[seq] = new Club(obj);
				Club.activeClubsId[obj._id] = Club.activeClubsSeq[seq];
				release();
				cb(null,Club.activeClubsSeq[seq]);
			}.bind(this));
		} else {
			release();
			cb(null,Club.activeClubsSeq[seq]);
		}
	}.bind(this));
};
Club.getClubById = function (id,cb) {
	getLock.writeLock(function (release) {
		if (!Club.activeClubsId[id]) {
			mdb.models.Clubs.findOne({_id:id},function (err,obj) {
				assert.ifError(err);
				if (!obj) {
					release();
					return cb('not found');
				}
				Club.activeClubsSeq[obj.seq] = new Club(obj);
				Club.activeClubsId[obj._id] = Club.activeClubsSeq[obj.seq];
				release();
				cb(null,Club.activeClubsSeq[obj.seq]);
			}.bind(this));
		} else {
			release();
			cb(null,Club.activeClubsId[id]);
		}
	}.bind(this));
};
Club.prototype.isOwner = function (user) {
	return this.obj.owner.equals(user);
};
Club.prototype.handOver = function (gameObj,cb,handid) {
	if (global.activeUsers[this.obj.owner]) {
		//console.log('owner is online');
		var data = {};
		models.Game.find({clubid:this.clubid},{_id:1},function (err,games) {
			assert.ifError(err);
			var gamelist = [];
			for (var x=0; x<games.length; x++) gamelist.push(games[x]._id);
			this.getTableStatsPacket(gamelist,data,function () {
				Club.finishTableStatsPacket(data,function (packet) {
					if (global.activeUsers[this.obj.owner]) {
						global.activeUsers[this.obj.owner].send(codes.srTableStatsReply,packet,'Poker.TableStatsReplies');
					} else {
						console.log('owner disconnected while fetching stats');
					}
					cb();
				}.bind(this));
			}.bind(this));
		}.bind(this));
	} else cb();

};
Club.prototype.getTableStatsPacket = function (gamelist,data,cb) {
	// FIXME, add hands
	if (!data.games) data.games = {};
	var games = data.games;
	if (!data.out) data.out = [];
	var out = data.out;
	if (!data.players) data.players = [];
	var players = data.players;
	if (!data.gamelist) data.gamelist = [];

	if (!data.clubdata) data.clubdata = {}; // key=clubid, obj=ClubStatsReply
	if (!data.playerData) data.playerData = {}; // key=userid, obj=internal stats
	if (!data.clubList) data.clubList = []; // array of clubid's
	data.clubList.push(this.clubid);
	for (var x=0; x<gamelist.length; x++) {
		if (!containsObjectID(data.gamelist,gamelist[x])) data.gamelist.push(gamelist[x]);
	}
	models.GameStats.find({gameid:{$in:gamelist}}).lean(true).exec(function (err,stats) {
		assert.ifError(err);
			for (var i=0; i<stats.length; i++) {
				//if (!stats[i].userid) console.log('FINDME',stats[i]);
				assert(stats[i].userid);
				var gameidhex = stats[i].gameid.toString();
				if (!games[gameidhex]) {
					games[gameidhex] = {gameid: stats[i].gameid, playerstats:[]};
					out.push(games[gameidhex]);
				}
				if (!containsObjectID(players,stats[i].userid)) players.push(stats[i].userid);
				stats[i].chipsinplay = 0;
				if (activeGames[gameidhex]) {
					if (global.activeUsers[stats[i].userid]) {
						var conn = global.activeUsers[stats[i].userid];
						var seatIdx = activeGames[gameidhex].findSeat(conn);
						if (seatIdx >= 0) {
							stats[i].chipsinplay = activeGames[gameidhex].members[seatIdx].chips;
							if (!data.playerData[stats[i].userid]) data.playerData[stats[i].userid] = {chipsinplay:0};
							data.playerData[stats[i].userid].chipsinplay += activeGames[gameidhex].members[seatIdx].chips;
						}
					}
				}
				stats[i].club_balance = -1;
				stats[i].userid = stats[i].userid;
				//console.log('stats i',stats[i]);
				games[gameidhex].playerstats.push(stats[i]);
			}
			cb();
	}.bind(this));
};
Club.finishTableStatsPacket = function (data,cb) {
	models.UserModel.find({_id:{$in:data.players}}).lean(true).exec(function (err,playersOut) {
		assert.ifError(err);
		for (var i=0; i<playersOut.length; i++) {
			playersOut[i]._id = playersOut[i]._id;
		}
		models.Game.find({_id:{$in:data.gamelist}},function (err,rawgames) {
			for (var i=0; i<rawgames.length; i++) {
				var gameidhex = rawgames[i]._id.toString();
				if (data.games[gameidhex]) {
					data.games[gameidhex].clubid = rawgames[i].clubid;
					data.games[gameidhex].hands = rawgames[i].hands;
				} else data.out.push({ clubid:rawgames[i].clubid, gameid:rawgames[i]._id, hands:rawgames[i].hands });
			}
			var clubobj = {};
			var clubarr = [];
			//console.log('getting club balances %j',data.playerData);
			models.ClubBalance.find({clubid:{$in:data.clubList}},function (err,balances) {
				assert.ifError(err);
				//console.log('current user:%s, all stats: %j',stats[i].userid,balances);
				for (var j=0; j<balances.length; j++) {
					if (!balances[j].userid) {
						console.log('wtf2',balances[j]);
						continue;
					}
					//if (compareObjectID(stats[i].userid,balances[j].userid)) {
						var inplay = 0;
						if (data.playerData[balances[j].userid]) inplay = data.playerData[balances[j].userid].chipsinplay;
						var club_balance = balances[j].balance - inplay;
						if (!clubobj[balances[j].clubid]) {
							var obj = { clubid:balances[j].clubid, player_stats:[] };
							clubobj[balances[j].clubid] = obj;
							clubarr.push(obj);
						}
						var player_obj = { userid:balances[j].userid, club_balance: club_balance };
						clubobj[balances[j].clubid].player_stats.push(player_obj);
					//}
				}
				cb({reply:data.out, players:playersOut, club_stats:clubarr });
			}.bind(this));
		}.bind(this));
	}.bind(this));
};
Club.prototype.seGameChanged = function (gameObj,cb,exclude) {
	var token = profiler.start('seGameChanged');
	// FIXME, cache object
	mdb.models.Clubs.findOne({_id:this.clubid},function (err,club) { // FIXME, get it via a required refresh
		var count,rawmsg,x;
		assert.ifError(err);
		if (!club) {
			cb();
			return;
		}
		this.refresh(club);
		var g = makeGameProtobuf(gameObj.obj);
		var serialized = pb.Serialize(g,'Poker.Game');
		myutils.throttle('seGameChange.'+gameObj.id,30,function () {
			if (club.is_private) {
				token.tag += 'a';
				var conn = global.activeUsers[club.owner];
				if (conn) conn.send(codes.seGameChange,g,'Poker.Game');
				if (club.members) {
					count = 0;
					rawmsg = pb.Serialize(g,'Poker.Game');
					for (x=0; x<club.members.length; x++) {
						conn = global.activeUsers[club.members[x]];
						if (!conn) continue;
						if (conn === exclude) continue;
						conn.send(codes.seGameChange,rawmsg,'raw');
						count++;
					}
					token.tag += '.'+count;
				}
			} else {
				token.tag += 'b';
				count = 0;
				rawmsg = pb.Serialize(g,'Poker.Game');
				for (x in global.activeUsers) {
					global.activeUsers[x].send(codes.seGameChange,rawmsg,'raw');
					count++;
				}
				token.tag += '.'+count;
			}
		});
		token.stop();
		cb();
	}.bind(this));
};
Club.prototype.goPublic = function (cb) {
	this.obj.is_private = false;
	this.obj.save(function (err) {
		assert.ifError(err);
		models.ClubBalance.find({clubid:this.clubid},function (err,stats) {
			assert.ifError(err);
			var c = Club.makeClubProtobuf(this.obj,null,stats,this);
			models.Game.find({clubid:this.clubid},function (err,games) {
				assert.ifError(err);
				for (var x=0; x<games.length; x++) {
					games[x] = makeGameProtobuf(games[x]);
				}
				var joininfo = {status:'csSuccess',club:c,games:games};
				for (var key in global.activeUsers) {
					global.activeUsers[key].send(codes.srJoinClubReply,joininfo,'Poker.ClubCommandReply');
				}
				cb('dummy');
			}.bind(this));
		}.bind(this));
	}.bind(this));
};
Club.prototype.updateLimitPostWin = function (change,userid,callback) {
	models.ClubBalance.findOneAndUpdate({clubid:this.clubid, userid:userid},{$inc:{balance:change}},function (err,row) {
		if (row) return callback();
		models.ClubBalance.create({clubid:this.clubid, userid:userid, balance:change, balance_limit:this.obj.default_balance_limit, unlimited_limit:this.obj.unlimited_default_balance},callback);
	}.bind(this));
};
Club.prototype.buyin = function (userid,chips) {
	if (!this.balance[userid]) this.balance[userid] = -chips;
	else this.balance[userid] -= chips;
	//console.log('buyin balance',this.balance);
};
Club.prototype.cashout = function (userid,chips) {
	this.balance[userid] += chips;
	//console.log('cashout balance',this.balance);
}
Club.prototype.getPotentialLosses = function (userid,cb) {
	models.ClubBalance.findOne({clubid:this.clubid, userid:userid},function (err,row) {
		assert.ifError(err);
		if (!row && !this.balance[userid]) return cb(0);
		if (!this.balance[userid]) return cb(row.balance,row.unlimited_limit,row.balance_limit);
		if (!row) return cb(this.balance[userid],this.obj.unlimited_default_balance,this.obj.default_balance_limit);
		//console.log('gpl row:%j',row);
		cb(this.balance[userid] + row.balance,row.unlimited_limit,row.balance_limit);
	}.bind(this));
}
Club.prototype.updateLimit = function (userid,limit,unlimited,cb) {
	models.ClubBalance.findOneAndUpdate({clubid:this.clubid, userid:userid},{$set:{balance_limit:limit, unlimited_limit:unlimited}},function (err,rows) {
		assert.ifError(err);
		if (rows) cb(true);
		else cb(false);
	}.bind(this));
}
Club.prototype.resetPlayerLimit = function (userid,cb) {
	models.ClubBalance.findOneAndUpdate({clubid:this.clubid, userid:userid},{$set:{balance:0}},function (err,row) {
		assert.ifError(err);
		if (row) cb(true);
		else cb(false);
	}.bind(this));
}
Club.init = function (activeGamesIn,regexLimitsIN) {
	activeGames = activeGamesIn;
	pb = global.pb;
	regexLimits = regexLimitsIN;
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
Club.makeClubProtobuf = function makeClubProtobuf(input,userlist,stats,self) {
	var c = JSON.parse(JSON.stringify(input));
	assert(stats);
	if (stats.length > 1) assert(self);
	var memberList = [input.owner];
	if (input.members) memberList = memberList.concat(input.members);
	var out = [];
	for (var y=0; y<memberList.length; y++) {
		if (userlist && (userlist.indexOf(memberList[y]) == -1)) userlist.push(memberList[y]);
		var suspended = false;
		if (input.suspended) {
			if (containsObjectID(input.suspended,memberList[y])) suspended = true;
		}
		var obj = {_id:new Buffer(memberList[y].toString(),'hex'), suspended:suspended, balance_limit:0, club_balance: 0};
		assert.equal(obj._id.length,12);
		for (var a=0; a<stats.length; a++) {
			if (compareObjectID(stats[a].clubid,input._id)) {
				if (stats[a].userid == null) {
					console.log('wtf1',stats[a]);
					continue;
				}
				if (compareObjectID(stats[a].userid,memberList[y])) {
					obj.club_balance = stats[a].balance;
					if (self.balance[memberList[y]]) obj.club_balance += self.balance[memberList[y]];
					obj.balance_limit = stats[a].balance_limit;
					obj.unlimited_limit = stats[a].unlimited_limit;
				}
			}
		}
		out.push(obj);
	}
	c.members = out;
	delete c.suspended;
	c._id = input._id.toProtobuf();
	c.owner = input.owner.toProtobuf();
	return c;
}
Club.prototype.log = function log(format) {
	var out = Array.prototype.slice.call(arguments);
	if (format.indexOf('%') != -1) {
		out = [ util.format.apply(util,out) ]
	}
	out.unshift(this.handid);
	process.send({type:'club',name:this.obj.gamename,ts:new Date().toString(),objects:out});
	var obj = new mdb.models.DebugLogs({type:'club',name:this.obj.gamename,objects:out});
	obj.clubid = this.obj.clubid;
	obj.save(function () {});
}
Club.prototype.setSuspended = function (suspended,playerid,cb) {
	if (!this.obj.suspended) this.obj.suspended = [];
	if (suspended) {
		if (!containsObjectID(this.obj.suspended,playerid)) {
			this.obj.suspended.push(playerid);
		}
	} else {
		for (var x=0; x<this.obj.suspended.length; x++) {
			if (compareObjectID(playerid,this.obj.suspended[x])) {
				this.obj.suspended.splice(x,1);
				break;
			}
		}
	}
	this.obj.save(function (err) {
		assert.ifError(err);
		cb(true);
	});
}
Club.prototype.isSuspended = function (userid) {
	for (var x=0; x<this.obj.suspended.length; x++) {
		if (compareObjectID(userid,this.obj.suspended[x])) {
			return true;
		}
	}
	return false;
}
Club.prototype.Leave = function (userid,cb) {
	this.obj.members.pull(userid);
	this.obj.save(function (err) {
		assert.ifError(err);
		cb();
	});
}
Club.prototype.joinClub = function (userid,cb) {
	this.obj.members.addToSet(userid);
	this.obj.save(function (err) {
		assert.ifError(err);
		cb();
	});
}
Club.prototype.deleteClub = function (cb) {
	this.obj.remove(function (err) {
		delete Club.activeClubsId[this.obj._id];
		delete Club.activeClubsSeq[this.obj.seq];
		assert.ifError(err);
		cb();
	}.bind(this));
}
Club.prototype.setOwner = function (newowner,cb) {
	this.joinClub(this.obj.owner,function () {
		this.obj.owner = newowner;
		this.Leave(newowner,function () {
			cb();
		});
	}.bind(this));
}
Club.dupCheck = function (name,cb) {
	mdb.models.Clubs.findOne({name:{$regex:new RegExp('^'+name+'$','i')}},function (err,row) {
		if (row) cb(true);
		else cb(false);
	});
}
Club.createClub = function (name,password,owner,rake,cb) {
	var doc = new mdb.models.Clubs({name:name, password:password, owner:owner, rake:rake, is_private:true, unlimited_default_balance:true, default_balance_limit:100000});
	myutils.getNextSequence('club',function (seq) {
		doc.seq = seq;
		doc.save(function (err) {
			assert.ifError(err);
			Club.getClubById(doc._id,function (err,clubObj) {
				assert.ifError(err);
				if (err) console.log(err);
				assert(clubObj);
				clubObj.updateLimitPostWin(0,owner,function (){
					cb(true,clubObj);
				});
			});
		});
	});
}
Club.registerHandlers = function (handlers) {
handlers[codes.scCreateClub] = function (args,token) {
	var params = pb.Parse(args,'Poker.Club');
	if (!regexLimits.clubname.exec(params.name)) {
		this.send(codes.srCreateClubReply,{status:'csInvalidName'},'Poker.ClubCommandReply');
		return;
	}
	if ((params.rake < 1) || (params.rake > 10) || (!params.rake)) {
		this.reply(0,"invalid rake");
		return;
	}
	if (!params.password) {
		this.send(codes.srCreateClubReply,{status:'csInvalidPassword'},'Poker.ClubCommandReply');
		return;
	} else if (!regexLimits.clubpassword.exec(params.password)) {
		this.send(codes.srCreateClubReply,{status:'csInvalidPassword'},'Poker.ClubCommandReply');
		return;
	}
	// FIXME, dont allow a blank pw on priv clubs
	Club.dupCheck(params.name,function (dup) {
		if (dup) {
			this.log('SR_CREATECLUB_NAME_EXISTS');
			this.send(codes.srCreateClubReply,{status:'csNameExists'},'Poker.ClubCommandReply');
			return;
		}
		Club.createClub(params.name,params.password,this.userid,params.rake,function (worked,club) {
			if (worked) {
				var out = Club.makeClubProtobuf(club.obj,null,[]);
				this.send(codes.srCreateClubReply,{status:'csSuccess',club:out},'Poker.ClubCommandReply');
			}
		}.bind(this));
	}.bind(this));
}
handlers[codes.scDeleteClub] = function (args,token) {
	function deleteClub(clubObj) {
		clubObj.deleteClub(function (err) {
			this.log('delete worked',err);
			// FIXME, force end games in this club?
			models.ClubBalance.find({clubid:clubObj.clubid},function (err,stats) {
				var userlist = [];
				var out = Club.makeClubProtobuf(clubObj.obj,userlist,stats,clubObj);
				this.send(codes.srClubDisbandOk,out,'Poker.Club');
				this.log('userlist to inform:',userlist);
				for (var x=0; x<userlist.length; x++) {
					var user = global.activeUsers[userlist[x]];
					if (user) user.send(codes.seClubDeleted,out,'Poker.Club');
				}
			}.bind(this));
		}.bind(this));
	}
	var params = pb.Parse(args,'Poker.Club');
	var clubid = myutils.toMongoId(params._id);
	this.log('deleting club',params);
	Club.getClubById(clubid,function (err,clubObj) {
		if (err == 'not found') {
			this.log('club not found');
			this.reply("000","club not found");
			return;
		}
		if (!clubObj.isOwner(this.userid)) {
			this.log('not owner');
			this.reply("000","your not owner");
			return;
		}
		models.Game.find({clubid:clubObj.clubid},{state2:1},function (err,games) {
			for (var x=0; x<games.length; x++) {
				if (games[x].state2 != 'gsClosed') {
					this.reply(0,'not all games are closed');
					return;
				}
				if (activeGames[games[x]._id]) {
					//this.reply(0,'all spectators must leave all games before you can delete the club');
					//return;
				}
			}
			deleteClub.call(this,clubObj);
		}.bind(this));
	}.bind(this));
};
handlers[codes.scKickPlayer] = function (args,token) {
	function finishKick(club) {
		club.Leave(userid,function (res) {
			if (res == 0) {
				this.send(codes.srKickPlayerReply,{status:'csInvalidClubId'},'Poker.ClubCommandReply');
				return;
			}
			models.ClubBalance.find({clubid:club.clubid},function (err,stats) {
				var userlist = [ userid ];
				var out = Club.makeClubProtobuf(club.obj,userlist,stats,club);
				this.send(codes.srKickPlayerReply,{status:'csSuccess',club:out},'Poker.ClubCommandReply');
				this.log('userlist to inform:',userlist);
				this.log('out:%j',out);
				for (var x=0; x<userlist.length; x++) {
					var user = global.activeUsers[userlist[x]];
					if (user) user.send(codes.seClubChange,out,'Poker.Club');
				}
			}.bind(this));
		}.bind(this));
	}
	// FIXME, update Club object
	try {
		var params = pb.Parse(args,'Poker.KickPlayerParams');
		var userid = myutils.toMongoId(params.player_mongo_id);
		var clubid = myutils.toMongoId(params.club_mongo_id);
		this.log('kicking',userid);
		// FIXME, code 023 kicking somebody not in the club
		Club.getClubById(clubid,function (err,club) {
			if (!club.isOwner(this.userid)) {
				this.reply("000","your not owner");
				this.log('attempted to kick while not owner');
				return;
			}
			var target = global.activeUsers[userid];
			if (target) {
				models.Game.find({clubid:club.clubid},function (err,clubGames) {
					assert.ifError(err);
					async.each(clubGames,function checkGame(gameRow,cb) {
						var gameObj = activeGames[gameRow._id];
						if (gameObj) {
							this.log('found a game active');
							var seatIdx = gameObj.findSeat(target);
							if (seatIdx == -1) return cb();
							this.log('and target is in seat %d',seatIdx);
							gameObj.Lock.writeLock(function (release) {
								this.log('got lock');
								gameObj.standUp(target,function (folded,events,offset) {
									this.log('stood up');
									gameObj.broadcastStatus(null,true,events);
									release();
									cb();
								}.bind(this));
							}.bind(this));
						} else cb();
					}.bind(this),function () {
						finishKick.call(this,club);
					}.bind(this));
				}.bind(this));
			} else finishKick.call(this,club);
		}.bind(this));
	} catch (e) {
		this.error(e);
	}
}
handlers[codes.scSuspendPlayer] = function (args,token) {
	var clubid;
	try {
		var params = pb.Parse(args,'Poker.ChangeSuspendState');
		this.log('params:%j',params);
		clubid = myutils.toMongoId(params.club_mongo_id);
		var playerid = myutils.toMongoId(params.player_mongo_id);
	} catch (e) {
		this.error(e);
		return;
	}
	var broadcast = function broadcast(code) {
		Club.getClubById(clubid,function (err,clubObj) {
			models.ClubBalance.find({clubid:clubObj.clubid},function (err,stats) {
				var userlist = [ ];
				var out = Club.makeClubProtobuf(clubObj.obj,userlist,stats,clubObj);
				this.send(code,out,'Poker.Club');
				this.log('userlist to inform:',userlist);
				for (var x=0; x<userlist.length; x++) {
					var user = global.activeUsers[userlist[x]];
					if (user) user.send(codes.seClubChange,out,'Poker.Club');
				}
			}.bind(this));
		}.bind(this));
	}.bind(this);
	Club.getClubById(clubid,function (err,club) {
		if (!club) {
			this.reply(0,'club not found');
			return;
		}
		if (!club.isOwner(this.userid)) {
			this.log('your not owner');
			return;
		}
		// FIXME, make it a function on Club
		if (!containsObjectID(club.obj.members,playerid)) {
			this.reply(0,'player isnt a member');
			return;
		}
		club.setSuspended(params.suspended,playerid,function (worked) {
			if (worked) {
				if (params.suspend) broadcast(codes.srSuspendPlayerOk);
				else broadcast(codes.srReinstatePlayerOk);
			}
		});
	}.bind(this));
}
handlers[codes.scJoinClub] = function (args,token) {
	var params = pb.Parse(args,'Poker.Club');
	var clubseq = params.seq;
	var pw = params.password;
	this.log('join1',clubseq,pw);
	Club.getClubBySeq(clubseq,function (err,clubObj) {
		if (err == 'not found') {
			this.log('club not found');
			this.send(codes.srJoinClubReply,{status:'csInvalidClubId'},'Poker.ClubCommandReply');
			return;
		}
		if (clubObj.isOwner(this.userid)) {
			this.send(codes.srJoinClubReply,{status:'csAlreadyMember'},'Poker.ClubCommandReply');
			return;
		}
		if (clubObj.obj.members) { // FIXME, remove once mongoose conversion is done
			if (containsObjectID(clubObj.obj.members,this.userid)) {
				this.log('already a member');
				this.send(codes.srJoinClubReply,{status:'csAlreadyMember'},'Poker.ClubCommandReply');
				return;
			}
		}
		if (clubObj.obj.is_private && (pw != clubObj.obj.password)) {
			this.send(codes.srJoinClubReply,{status:'csInvalidPassword'},'Poker.ClubCommandReply');
			return;
		} else if (!clubObj.obj.is_private) {
			console.log('not private',clubObj);
			this.send(codes.srJoinClubReply,{status:'csInvalidClubId'},'Poker.ClubCommandReply');
			return;
		}
		this.log('joining club %s',clubObj.obj._id);
		clubObj.joinClub(this.userid,function () {
			this.log('join2');
			clubObj.updateLimitPostWin(0,this.userid,function (){
				models.ClubBalance.find({clubid:clubObj.clubid},function (err,stats) {
					models.Game.find({clubid:clubObj.obj._id},function (err,games) {
						for (var x=0; x<games.length; x++) {
							games[x] = makeGameProtobuf(games[x]);
						}
						var userlist = [ clubObj.obj.owner ];
						var clubinfo = Club.makeClubProtobuf(clubObj.obj,userlist,stats,clubObj);
						var joininfo = {status:'csSuccess',club:clubinfo,games:games};
						this.send(codes.srJoinClubReply,joininfo,'Poker.ClubCommandReply');
						this.log('userlist to inform:',userlist);
						for (var x=0; x<userlist.length; x++) {
							var user = global.activeUsers[userlist[x]];
							if (user == this) continue;
							if (user) user.send(codes.seClubChange,clubinfo,'Poker.Club');
						}
					}.bind(this));
				}.bind(this));
			}.bind(this));
		}.bind(this));
		this.log('join3',err,this.userid);
	}.bind(this));
}
handlers[codes.scSetPlayerLimit] = function (args,token) {
	var clubid;
	try {
		var params = pb.Parse(args,'Poker.PlayerLimitParams');
		clubid = myutils.toMongoId(params.clubid);
		var userid = myutils.toMongoId(params.userid);
		//this.log('params:%j',params);
		if (params.limit < 1) return this.reply(0,'limit too low');
	} catch (e) {
		this.error(e);
		return;
	}
	Club.getClubById(clubid,function (err,clubObj) {
		if (err == 'not found') {
			this.reply(0,'club not found');
			return;
		}
		assert.ifError(err);
		assert(clubObj);
		if (!clubObj.isOwner(this.userid)) {
			this.reply(0,'your not the owner');
			return;
		}
		clubObj.updateLimit(userid,params.limit,params.unlimited,function (result) {
			//clubObj.getTableStatsPacket([
			if (result) this.send(codes.srPlayerLimitOk,args,'raw');
			else this.reply(0,'player not found');
			token.stop();
		}.bind(this));
	}.bind(this));
}
handlers[codes.scResetPlayerBalance] = function (args,token) {
	var clubid;
	try {
		var params = pb.Parse(args,'Poker.PlayerLimitParams');
		clubid = myutils.toMongoId(params.clubid);
		var userid = myutils.toMongoId(params.userid);
		this.log('params:%j',params);
	} catch (e) {
		this.error(e);
		return;
	}
	Club.getClubById(clubid,function (err,clubObj) {
		if (err == 'not found') {
			this.reply(0,'club not found');
			return;
		}
		assert.ifError(err);
		assert(clubObj);
		if (!clubObj.isOwner(this.userid)) {
			this.reply(0,'your not the owner');
			return;
		}
		clubObj.resetPlayerLimit(userid,function (result) {
			if (result) this.send(codes.srResetPlayerBalanceOk,args,'raw');
			else this.reply(0,'player not found');
			token.stop();
		}.bind(this));
	}.bind(this));
}
handlers[codes.scChangeClubDetails] = function (args,token) {
	var params = pb.Parse(args,'Poker.Club');
	var clubid = myutils.toMongoId(params._id);
	this.log('change club details %j',params);
	Club.getClubById(clubid,function changeDetail_cb1(err,club) {
		if (err == 'not found') {
			this.reply("000","club not found");
			return;
		}
		if (!club.isOwner(this.userid)) {
			this.reply("000","your not owner");
			return;
		}
		if ((params.rake < 1) || (params.rake > 10) || (!params.rake)) {
			this.reply(0,"invalid rake");
			return;
		}
		if ((params.default_balance_limit < 1) || (!params.default_balance_limit)) return this.reply(0,'invalid default limit');
		var doit = false;
		var autofinish = true;
		if (club.obj.name == params.name) delete params.name;
		if (params.name) {
			if ((params.name.length > global.sharedconfig.stringSizes.clubname) || (params.name.length < global.sharedconfig.minSizes.clubname)) {
				this.reply("000","name too long");
				return;
			}
			Club.dupCheck(params.name,function (dup) {
				if (dup) {
					this.log('dup club name');
					this.send(codes.srChangeClubDetailsReply,{status:'csNameExists',club:Club.makeClubProtobuf(club.obj,null,[],club)},'Poker.ClubCommandReply');
				} else {
					club.obj.name = params.name;
					finish.call(this);
				}
			}.bind(this));
			doit = true;
			autofinish = false;
		}
		if (regexLimits.clubpassword.exec(params.password) || (params.password == '')) {
			doit = true;
			club.obj.password = params.password;
		} else {
			this.reply(0,'invalid password');
			return;
		}
		if (params.default_balance_limit != club.default_balance_limit) club.obj.default_balance_limit = params.default_balance_limit;
		if (!doit) {
			this.log('params:%j',params);
			this.reply("000","no changes found");
			return;
		}
		function finish() {
			club.obj.rake = params.rake;
			club.obj.unlimited_default_balance = params.unlimited_default_balance;
			club.obj.save(function changeDetail_cb2(err,ret) {
				this.log('detail update',clubid,params,err,ret);
				if (err) {
					this.log('name collision');
					this.reply(codes.srChangeClubDetailsReply,{status:'csNameExists',club:Club.makeClubProtobuf(club.obj,null,null,club)},'Poker.ClubCommandReply');
				} else {
					var userlist = [ ];
					models.Game.find({clubid:club.clubid},function changeDetail_cb3(err,games) {
						models.ClubBalance.find({clubid:club.clubid},function changeDetail_cb4(err,stats) {
							var x;
							assert.ifError(err);
							var out = Club.makeClubProtobuf(club.obj,userlist,stats,club);
							for (x=0; x<games.length; x++) {
								games[x] = makeGameProtobuf(games[x]);
							}

							this.send(codes.srChangeClubDetailsReply,{status:'csSuccess',club:out,games:games},'Poker.ClubCommandReply');
							this.log('userlist to inform:',userlist);
							for (x=0; x<userlist.length; x++) {
								var user = global.activeUsers[userlist[x]];
								if (user) user.send(codes.seClubChange,out,'Poker.Club');
							}
							token.stop();
						}.bind(this));
					}.bind(this));
				}
			}.bind(this));
		}
		if (autofinish) finish.call(this);
	}.bind(this));
};
	handlers[codes.scLeaveClub] = function (args,token) {
		try {
			var params = pb.Parse(args,'Poker.Club');
			var clubid = myutils.toMongoId(params._id);
			// FIXME, check for owner leaving
			Club.getClubById(clubid,function (err,clubObj) {
					if (err == 'not found') this.send(codes.srLeaveClubReply,{status:'csInvalidClubId'},'Poker.ClubCommandReply');
					else {
						clubObj.Leave(this.userid,function () {
							models.ClubBalance.find({clubid:clubObj.clubid},function (err,stats) {
								var userlist = [ clubObj.obj.owner ]; // FIXME, send stats
								var out = Club.makeClubProtobuf(clubObj.obj,userlist,stats,clubObj);
								this.send(codes.srLeaveClubReply,{status:'csSuccess',club:out},'Poker.ClubCommandReply');
								this.log('userlist to inform:',userlist);
								for (var x=0; x<userlist.length; x++) {
									var user = global.activeUsers[userlist[x]];
									if (user) user.send(codes.seClubChange,out,'Poker.Club');
								}
							}.bind(this));
						}.bind(this));
					}
				}.bind(this));
		} catch (e) {
			this.error(e);
		}
	};
	handlers[codes.scGiveClubOwnership] = function (args,token) {
		var clubid,newowner;
		try {
			var params = pb.Parse(args,'Poker.GiveClubOwnershipParams');
			clubid = myutils.toMongoId(params.club_mongo_id);
			newowner = myutils.toMongoId(params.player_mongo_id);
		} catch (e) {
			this.error(e);
			return;
		}
		this.log('giving ownership away',clubid,newowner);
		Club.getClubById(clubid,function (err,clubObj) {
			if (err == 'not found') {
				this.send(codes.srOwnershipGiveAwayInvalidClubId,Club.makeClubProtobuf(clubObj.obj,null,null,clubObj),'Poker.Club');
				return;
			}
			models.ClubBalance.find({clubid:clubObj.clubid},function (err,stats) {
				if (clubObj.isOwner(this.userid)) {
					if (containsObjectID(clubObj.obj.members,newowner)) {
						this.log('adding self to members',this.userid);
						clubObj.setOwner(newowner,function () {
							var userlist = [ clubObj.obj.owner ];
							var out = Club.makeClubProtobuf(clubObj.obj,userlist,stats,clubObj);
							this.send(codes.srOwnershipGiveAwayOk,out,'Poker.Club');
							this.log('i am %s, target is %s',this.userid,newowner);
							this.log('userlist to inform:',userlist);
							for (var x=0; x<userlist.length; x++) {
								var user = global.activeUsers[userlist[x]];
								if (user === this) continue;
								if (user) user.send(codes.seClubChange,out,'Poker.Club');
							}
						}.bind(this));
					} else {
						this.send(codes.srOwnershipGiveAwayInvalidPlayerId,Club.makeClubProtobuf(clubObj.obj,stats,clubObj),'Poker.Club');
					}
				} else {
					this.send(codes.srOwnershipGiveAwayNotOwner,Club.makeClubProtobuf(clubObj.obj,stats,clubObj),'Poker.Club');
				}
			}.bind(this));
		}.bind(this));
	};
};
