"use strict";
var allClubs,activeUsers,allStats,allUsers,allGames,clubBalances,activeGames,handHistory,pb;

var assert = require('assert');
var ObjectID = require('mongodb').ObjectID;
var async = require('async');

var makeGameProtobuf = require('./game').makeGameProtobuf;
var profiler = require('./profiler');
var ReadWriteLock = require('./lock');
var myutils = require('./myutils');
var mdb = require('./db');

var getLock = new ReadWriteLock();

module.exports.Club = Club;
function Club(obj) {
	if (!(this instanceof Club)) return new Club(clubid);
	this.clubid = obj._id;
	this.obj = obj
	this.balance = {};
}
Club.prototype.refresh = function (obj) {
	assert(compareObjectID(this.clubid,obj._id));
	this.obj = obj;
}
Club.activeClubsSeq = [];
Club.activeClubsId = {};
module.exports.getClubBySeq = function (seq,cb) {
	getLock.writeLock(function (release) {
		if (!Club.activeClubsSeq[seq]) {
			mdb.models.Clubs.findOne({seq:seq},function (err,obj) {
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
}
Club.getClubById = function (id,cb) {
	getLock.writeLock(function (release) {
		if (!Club.activeClubsId[id]) {
			mdb.models.Clubs.findOne({_id:id},function (err,obj) {
				assert.ifError(err);
				if (!obj) return cb('not found');
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
}
Club.prototype.isOwner = function (user) {
	return this.obj.owner.equals(user);
}
Club.prototype.handOver = function (gameObj,cb,handid) {
	if (activeUsers[this.obj.owner]) {
		console.log('owner is online');
		var data = {};
		allGames.find({clubid:this.clubid},{_id:1}).toArray(function (err,games) {
			assert.ifError(err);
			var gamelist = [];
			for (var x=0; x<games.length; x++) gamelist.push(games[x]._id);
			this.getTableStatsPacket(gamelist,data,function () {
				Club.finishTableStatsPacket(data,function (packet) {
					if (activeUsers[this.obj.owner]) {
						activeUsers[this.obj.owner].send(codes.srTableStatsReply,packet,'Poker.TableStatsReplies');
					} else {
						console.log('owner disconnected while fetching stats');
					}
					cb();
				}.bind(this));
			}.bind(this));
		}.bind(this));
	} else cb();

		if (handid) {
			allGames.findOne({_id:gameObj.id},function (err,gameRow) {
				assert.ifError(err);
				handHistory.findOne({seq:handid},function (err,historyRow) {
					assert.ifError(err);
					var savedCards = [];
					var keyid = 0;
					async.each(historyRow.players,function (player,cb) {
						if (!player) return cb();
						allUsers.findOne({_id:player._id},function (err,playerRow) {
							player.keyid = keyid++;
							player.nick = playerRow.displayname;

							if (player.cards) {
								savedCards[player.keyid] = new Buffer(player.cards);
							}
							player.origid = player._id;
							player._id = myutils.fromMongoId(player._id);

							if (!player.muck && player.cards) player.cards = new Buffer(player.cards);
							else delete player.cards;
							cb();
						});
					},function () {
						historyRow._id = myutils.fromMongoId(historyRow._id);
						historyRow.cards = new Buffer(historyRow.cards);
						var obj = {clubid:myutils.fromMongoId(this.clubid), gameid:myutils.fromMongoId(gameObj.id), rows:[historyRow] };
					for (var x in gameObj.users) {
						for (var y=0; y<obj.rows[0].players.length; y++) {
							if (obj.rows[0].players[y]) {
								var key2 = obj.rows[0].players[y].keyid;
								if (obj.rows[0].players[y].rehide) {
									delete obj.rows[0].players[y].cards;
									obj.rows[0].players[y].rehide = false;
								}
								if (obj.rows[0].players[y].cards) continue;
								if (savedCards[key2]) {
									if (compareObjectID(obj.rows[0].players[y].origid,x)) {
										obj.rows[0].players[y].cards = savedCards[key2];
										obj.rows[0].players[y].rehide = true;
									}
								}
							}
						}
						gameObj.users[x].send(codes.srHandHistoryMsg,obj,'Poker.ClubHandHistoryReply');
					}
					}.bind(this));
				}.bind(this));
			}.bind(this));
		}
}
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
	allStats.find({gameid:{$in:gamelist}}).toArray(function (err,stats) {
		assert.ifError(err);
			for (var i=0; i<stats.length; i++) {
				var gameidhex = stats[i].gameid.toString();
				if (!games[gameidhex]) {
					games[gameidhex] = {gameid: myutils.fromMongoId(stats[i].gameid), playerstats:[]};
					out.push(games[gameidhex]);
				}
				if (!containsObjectID(players,stats[i].userid)) players.push(stats[i].userid);
				stats[i].chipsinplay = 0;
				if (activeGames[gameidhex]) {
					if (activeUsers[stats[i].userid]) {
						var conn = activeUsers[stats[i].userid];
						var seatIdx = activeGames[gameidhex].findSeat(conn);
						if (seatIdx >= 0) {
							stats[i].chipsinplay = activeGames[gameidhex].members[seatIdx].chips;
							if (!data.playerData[stats[i].userid]) data.playerData[stats[i].userid] = {chipsinplay:0}
							data.playerData[stats[i].userid].chipsinplay += activeGames[gameidhex].members[seatIdx].chips;
						}
					}
				}
				stats[i].club_balance = -1;
				stats[i].userid = myutils.fromMongoId(stats[i].userid);
				//console.log('stats i',stats[i]);
				games[gameidhex].playerstats.push(stats[i]);
			}
			cb();
	}.bind(this));
}
Club.finishTableStatsPacket = function (data,cb) {
	allUsers.find({_id:{$in:data.players}},{displayname:1}).toArray(function (err,playersOut) {
		assert.ifError(err);
		for (var i=0; i<playersOut.length; i++) {
			playersOut[i]._id = myutils.fromMongoId(playersOut[i]._id);
		}
		allGames.find({_id:{$in:data.gamelist}}).toArray(function (err,rawgames) {
			for (var i=0; i<rawgames.length; i++) {
				var gameidhex = rawgames[i]._id.toString();
				if (data.games[gameidhex]) {
					data.games[gameidhex].clubid = myutils.fromMongoId(rawgames[i].clubid);
					data.games[gameidhex].hands = rawgames[i].hands;
				} else data.out.push({ clubid:myutils.fromMongoId(rawgames[i].clubid), gameid:myutils.fromMongoId(rawgames[i]._id), hands:rawgames[i].hands });
			}
			var clubobj = {};
			var clubarr = [];
			//console.log('getting club balances %j',data.playerData);
			clubBalances.find({clubid:{$in:data.clubList}}).toArray(function (err,balances) {
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
						var club_balance = balances[j].balance - inplay
						if (!clubobj[balances[j].clubid]) {
							var obj = { clubid:myutils.fromMongoId(balances[j].clubid), player_stats:[] };
							clubobj[balances[j].clubid] = obj;
							clubarr.push(obj);
						}
						var player_obj = { userid:myutils.fromMongoId(balances[j].userid), club_balance: club_balance };
						clubobj[balances[j].clubid].player_stats.push(player_obj);
					//}
				}
				cb({reply:data.out, players:playersOut, club_stats:clubarr });
			}.bind(this));
		}.bind(this));
	}.bind(this));
}
Club.prototype.seGameChanged = function (gamerow,cb,exclude) {
	var token = profiler.start('seGameChanged');
	// FIXME, cache object
	mdb.models.Clubs.findOne({_id:this.clubid},function (err,club) { // FIXME, get it via a required refresh
		assert.ifError(err);
		if (!club) {
			cb();
			return;
		}
		this.refresh(club);
		var g = makeGameProtobuf(gamerow);
		if (club.is_private) {
			token.tag += 'a';
			var conn = activeUsers[club.owner];
			if (conn) conn.send(codes.seGameChange,g,'Poker.Game');
			if (club.members) {
				var count = 0;
				var rawmsg = pb.Serialize(g,'Poker.Game');
				for (var x=0; x<club.members.length; x++) {
					conn = activeUsers[club.members[x]];
					if (!conn) continue;
					if (conn === exclude) continue;
					conn.send(codes.seGameChange,rawmsg,'raw');
					count++;
				}
				token.tag += '.'+count;
			}
		} else {
			token.tag += 'b';
			var count = 0;
			var rawmsg = pb.Serialize(g,'Poker.Game');
			for (var x in activeUsers) {
				activeUsers[x].send(codes.seGameChange,rawmsg,'raw');
				count++;
			}
			token.tag += '.'+count;
		}
		token.stop();
		cb();
	}.bind(this));
}
Club.prototype.goPublic = function (cb) {
	this.obj.is_private = false;
	this.obj.save(function (err) {
		assert.ifError(err);
		clubBalances.find({clubid:this.clubid}).toArray(function (err,stats) {
			assert.ifError(err);
			var c = Club.makeClubProtobuf(this.obj,null,stats,this);
			allGames.find({clubid:this.clubid}).toArray(function (err,games) {
				assert.ifError(err);
				for (var x=0; x<games.length; x++) {
					games[x] = makeGameProtobuf(games[x]);
				}
				var joininfo = {status:'csSuccess',club:c,games:games};
				for (var key in activeUsers) {
					activeUsers[key].send(codes.srJoinClubReply,joininfo,'Poker.ClubCommandReply');
				}
				cb('dummy');
			}.bind(this));
		}.bind(this));
	}.bind(this));
}
Club.prototype.updateLimitPostWin = function (change,userid,callback) {
	clubBalances.update({clubid:this.clubid, userid:userid},{$inc:{balance:change}},function (err,rows) {
		if (rows == 1) return callback();
		clubBalances.insert({clubid:this.clubid, userid:userid, balance:change, balance_limit:this.obj.default_balance_limit, unlimited_limit:this.obj.unlimited_default_balance},callback);
	}.bind(this));
}
Club.prototype.buyin = function (userid,chips) {
	if (!this.balance[userid]) this.balance[userid] = -chips;
	else this.balance[userid] -= chips;
	//console.log('buyin balance',this.balance);
}
Club.prototype.cashout = function (userid,chips) {
	this.balance[userid] += chips;
	//console.log('cashout balance',this.balance);
}
Club.prototype.getPotentialLosses = function (userid,cb) {
	clubBalances.findOne({clubid:this.clubid, userid:userid},function (err,row) {
		assert.ifError(err);
		if (!row && !this.balance[userid]) return cb(0);
		if (!this.balance[userid]) return cb(row.balance,row.unlimited_limit,row.balance_limit);
		if (!row) return cb(this.balance[userid],this.obj.unlimited_default_balance,this.obj.default_balance_limit);
		//console.log('gpl row:%j',row);
		cb(this.balance[userid] + row.balance,row.unlimited_limit,row.balance_limit);
	}.bind(this));
}
Club.prototype.updateLimit = function (userid,limit,unlimited,cb) {
	clubBalances.update({clubid:this.clubid, userid:userid},{$set:{balance_limit:limit, unlimited_limit:unlimited}},function (err,rows) {
		assert.ifError(err);
		if (rows != 1) cb(false);
		else cb(true);
	}.bind(this));
}
Club.prototype.resetPlayerLimit = function (userid,cb) {
	clubBalances.update({clubid:this.clubid, userid:userid},{$set:{balance:0}},function (err,rows) {
		assert.ifError(err);
		if (rows != 1) cb(false);
		else cb(true);
	}.bind(this));
}
module.exports.init = function (db,activeUsersIn,activeGamesIn,pbIN) {
	allClubs = db.collection('clubs');
	activeUsers = activeUsersIn;
	activeGames = activeGamesIn;
	allStats = db.collection('allStats');
	allUsers = db.collection('users');
	allGames = db.collection('games');
	clubBalances = db.collection('clubBalances');
	handHistory = db.collection('handHistory');
	pb = pbIN;
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
		var obj = {_id:new Buffer(memberList[y],'hex'), suspended:suspended, balance_limit:0, club_balance: 0};
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
	c._id = new Buffer(input._id.toString(),'hex');
	c.owner = new Buffer(input.owner.toString(),'hex');
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
		for (var x=0; x<this.obj.members.length; x++) {
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
Club.registerHandlers = function (handlers,pb) {
handlers[codes.scSuspendPlayer] = function (args,token) {
	try {
		var params = pb.Parse(args,'Poker.ChangeSuspendState');
		this.log('params:%j',params);
		var clubid = myutils.toMongoId(params.club_mongo_id);
		var playerid = myutils.toMongoId(params.player_mongo_id);
	} catch (e) {
		this.error(e);
		return;
	}
	var broadcast = function broadcast(code) {
		Club.getClubById(clubid,function (err,clubObj) {
			clubBalances.find({clubid:clubObj.clubid}).toArray(function (err,stats) {
				var userlist = [ ];
				var out = Club.makeClubProtobuf(row,userlist,stats,clubObj);
				this.send(code,out,'Poker.Club');
				this.log('userlist to inform:',userlist);
				for (var x=0; x<userlist.length; x++) {
					var user = activeUsers[userlist[x]];
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
		if (!containsObjectID(this.obj.members,playerid)) {
			conn.reply(0,'player isnt a member');
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
	allClubs.findOne({seq:clubseq},function (err,item) {
		if (!item) {
			console.log('club not found');
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
			this.send(codes.srJoinClubReply,{status:'csInvalidPassword'},'Poker.ClubCommandReply');
			return;
		} else if (!item.is_private) {
			console.log('not private',item);
			this.send(codes.srJoinClubReply,{status:'csInvalidClubId'},'Poker.ClubCommandReply');
			return;
		}
		this.log('joining club %s',item._id);
		allClubs.update({_id:item._id},
			{ $addToSet: { members: this.userid} },
			function (err,res) {
				this.log('join2',err,res);
				allClubs.findOne({_id:item._id},function cb(err,row) {
					Club.getClubById(item._id,function (err,clubObj) {
						clubObj.refresh(row);
						clubObj.updateLimitPostWin(0,this.userid,function (){
							clubBalances.find({clubid:clubObj.clubid}).toArray(function (err,stats) {
								allGames.find({clubid:item._id}).toArray(function (err,games) {
									for (var x=0; x<games.length; x++) {
										games[x] = makeGameProtobuf(games[x]);
									}
									var userlist = [ row.owner ];
									var clubinfo = Club.makeClubProtobuf(row,userlist,stats,clubObj);
									var joininfo = {status:'csSuccess',club:clubinfo,games:games};
									this.send(codes.srJoinClubReply,joininfo,'Poker.ClubCommandReply');
									this.log('userlist to inform:',userlist);
									for (var x=0; x<userlist.length; x++) {
										var user = activeUsers[userlist[x]];
										if (user == this) continue;
										if (user) user.send(codes.seClubChange,clubinfo,'Poker.Club');
									}
								}.bind(this));
							}.bind(this));
						}.bind(this));
					}.bind(this));
				}.bind(this));
			}.bind(this));
		this.log('join3',err,item,this.userid);
	}.bind(this));
}
handlers[codes.scTransferChips] = function (args,token) {
	try {
		var params = pb.Parse(args,'Poker.TransferChipsParams');
		var userid = myutils.toMongoId(params.player_mongo_id);
	} catch (e) {
		this.error(e);
		return;
	}
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
		if (chips < 1) {
			this.reply(codes.srTransferChipsInvalidAmount);
			return;
		}
		allUsers.update({_id:userid},
			{ $inc:{chips:chips}},
			function (err,res) {
				assert.ifError(err);
				this.log('step 1',err,res);
				allUsers.update({_id:this.userid},
				{ $inc:{chips:-chips}},
				function (err,res) {
					assert.ifError(err);
					this.log('step 2',err,res);
					this.send(codes.srTransferChipsOk,args,'raw');
					var dest = activeUsers[userid];
					if (dest) {
						dest.send(codes.seTransferChips,{chip_amount:chips,player_mongo_id:new Buffer(this.userid.toString(),'hex')},'Poker.TransferChipsParams');
						dest.chips += chips;
					}
					this.chips -= chips;
					var list = [ userid, this.userid ];
					allClubs.find({$or:[{members:{$in:list}},{owner:{$in:list}}]},{owner:1,members:1}).toArray(function (err,rows) {
						assert.ifError(err);
						var out = [];
						for (var i=0; i<rows.length;i++) {
							if (!containsObjectID(out,rows[i].owner)) out.push(rows[i].owner);
							if (!rows[i].members) continue;
							for (var j=0; j<rows[i].members.length; j++) {
								if (!containsObjectID(out,rows[i].members[j])) out.push(rows[i].members[j]);
							}
						}
						allUsers.find({_id:{$in:[this.userid,userid]}}).toArray(function (err,rows) {
							assert.ifError(err);
							var proto = pb.Serialize({users:[makeUserProtobuf(rows[0]),makeUserProtobuf(rows[1])]},'Poker.UserChangeParams');
							for (var i=0; i<out.length; i++) {
								if (myutils.compareObjectID(this.userid,out[i])) continue;
								if (myutils.compareObjectID(userid,out[i])) continue;
								var dest = activeUsers[out[i]];
								if (dest) dest.send(codes.seUserChange,proto,'raw');
							}
						}.bind(this));
					}.bind(this));
				}.bind(this));
			}.bind(this));
	}.bind(this));
}
handlers[codes.scChangeClubDetails] = function (args,token) {
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
		if ((params.rake < 1) || (params.rake > 10) || (!params.rake)) {
			this.reply(0,"invalid rake");
			return;
		}
		if ((params.default_balance_limit < 1) || (!params.default_balance_limit)) return this.reply(0,'invalid default limit');
		var mods = {$set:{rake:params.rake,unlimited_default_balance:params.unlimited_default_balance}};
		var doit = false;
		var autofinish = true;
		if (club.name == params.name) delete params.name;
		if (params.name) {
			doit = true;
			mods.$set.name = params.name;
			if ((params.name.length > sharedconfig.stringSizes.clubname) || (params.name.length < sharedconfig.minSizes.clubname)) {
				this.reply("000","name too long");
				return;
			}
			allClubs.findOne({name:{$regex:new RegExp('^'+params.name+'$','i')}},function (err,row) {
				if (row) {
					this.send(codes.srChangeClubDetailsReply,{status:'csNameExists'},'Poker.ClubCommandReply');
				} else finish.call(this);
			}.bind(this));
			autofinish = false;
		}
		if (regexLimits.clubpassword.exec(params.password) || (params.password == '')) {
			doit = true;
			mods.$set.password = params.password;
		} else {
			this.reply(0,'invalid password');
			return;
		}
		if (params.default_balance_limit != club.default_balance_limit) mods.$set.default_balance_limit = params.default_balance_limit;
		if (!doit) {
			this.log('params:%j',params);
			this.reply("000","no changes found");
			return;
		}
		function finish() {
			allClubs.update({_id:club._id},mods,function (err,ret) {
				this.log('detail update',clubseq,params,mods,err,ret);
				if (err) {
					this.reply(codes.srChangeClubDetailsReply,{status:'csNameExists'},'Poker.ClubCommandReply');
				} else {
					allClubs.findOne({_id:club._id},function cb(err,row) {
						var userlist = [ ];
						allGames.find({clubid:row._id}).toArray(function (err,games) {
							clubBalances.find({clubid:row._id}).toArray(function (err,stats) {
								assert.ifError(err);
								Club.getClubById(row._id,function (err,clubObj) {
									assert.ifError(err);
									clubObj.refresh(row);
									var out = Club.makeClubProtobuf(row,userlist,stats,clubObj);
									for (var x=0; x<games.length; x++) {
										games[x] = makeGameProtobuf(games[x]);
									}

									this.send(codes.srChangeClubDetailsReply,{status:'csSuccess',club:out,games:games},'Poker.ClubCommandReply');
									this.log('userlist to inform:',userlist);
									for (var x=0; x<userlist.length; x++) {
										var user = activeUsers[userlist[x]];
										if (user) user.send(codes.seClubChange,out,'Poker.Club');
									}
									token.stop();
								}.bind(this));
							}.bind(this));
						}.bind(this));
					}.bind(this));
				}
			}.bind(this));
		}
		if (autofinish) finish.call(this);
	}.bind(this));
}
	handlers[codes.scLeaveClub] = function (args,token) {
		try {
			var params = pb.Parse(args,'Poker.Club');
			var clubid = params.seq;
			// FIXME, check for owner leaving
			allClubs.update({seq:clubid},
				{ $pull:{members:this.userid}},
				function (err,res) {
					if (res == 0) this.send(codes.srLeaveClubReply,{status:'csInvalidClubId'},'Poker.ClubCommandReply');
					else {
						allClubs.findOne({seq:clubid},function cb(err,row) {
							Club.getClubById(row._id,function (err,clubObj) {
								clubObj.refresh(row);
								clubBalances.find({clubid:clubObj.clubid}).toArray(function (err,stats) {
									var userlist = [ row.owner ]; // FIXME, send stats
									var out = Club.makeClubProtobuf(row,userlist,stats,clubObj);
									this.send(codes.srLeaveClubReply,{status:'csSuccess',club:out},'Poker.ClubCommandReply');
									this.log('userlist to inform:',userlist);
									for (var x=0; x<userlist.length; x++) {
										var user = activeUsers[userlist[x]];
										if (user) user.send(codes.seClubChange,out,'Poker.Club');
									}
								}.bind(this));
							}.bind(this));
						}.bind(this));
					}
				}.bind(this));
		} catch (e) {
			this.error(e);
		}
	}
}
