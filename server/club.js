"use strict";
var allClubs,activeUsers,allStats,allUsers,allGames,clubBalances;

var assert = require('assert');
var ObjectID = require('mongodb').ObjectID;

var makeGameProtobuf = require('./game').makeGameProtobuf;
var profiler = require('./profiler');
var ReadWriteLock = require('./lock');

var getLock = new ReadWriteLock();

module.exports = Club;
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
Club.getClubBySeq = function (seq,cb) {
	getLock.writeLock(function (release) {
		if (!Club.activeClubsSeq[seq]) {
			allClubs.findOne({seq:seq},function (err,obj) {
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
			allClubs.findOne({_id:id},function (err,obj) {
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
Club.prototype.handOver = function (gameObj,cb) {
	if (activeUsers[this.obj.owner]) {
		console.log('owner is online');
		// FIXME, add hands
		allStats.find({gameid:gameObj.id}).toArray(function (err,stats) {
			assert.ifError(err);
			var games = {};
			var out = [];
			var players = [];
			for (var i=0; i<stats.length; i++) {
				var gameidhex = stats[i].gameid.toString();
				if (!games[gameidhex]) {
					games[gameidhex] = {gameid: fromMongoId(stats[i].gameid), playerstats:[]};
					out.push(games[gameidhex]);
				}
				if (!containsObjectID(players,stats[i].userid)) players.push(stats[i].userid);
				if (activeUsers[stats[i].userid]) {
					var conn = activeUsers[stats[i].userid];
					var seatIdx = gameObj.findSeat(conn);
					if (typeof seatIdx == 'number') {
						stats[i].chipsinplay = gameObj.members[seatIdx].chips;
					}
				}
				stats[i].userid = fromMongoId(stats[i].userid);
				games[gameidhex].playerstats.push(stats[i]);
			}
			allUsers.find({_id:{$in:players}},{displayname:1}).toArray(function (err,playersOut) {
				for (var i=0; i<playersOut.length; i++) {
					playersOut[i]._id = fromMongoId(playersOut[i]._id);
				}
				var gameidhex = gameObj.id.toString();
				games[gameidhex].clubid = fromMongoId(this.clubid);
				if (activeUsers[this.obj.owner]) {
					activeUsers[this.obj.owner].send(codes.srTableStatsReply,{reply:out, players:playersOut},'Poker.TableStatsReplies');
				} else {
					console.log('owner disconnected while fetching stats');
				}
				cb();
			}.bind(this));
		}.bind(this));
	} else {
		cb();
	}
}
Club.prototype.seGameChanged = function (gamerow,cb,exclude) {
	var token = profiler.start('seGameChanged');
	// FIXME, cache object
	// FIXME, cache the protobuf
	allClubs.findOne({_id:this.clubid},function (err,club) {
		assert.ifError(err);
		assert(club);
		var g = makeGameProtobuf(gamerow);
		if (club.is_private) {
			token.tag += 'a';
			var conn = activeUsers[club.owner];
			if (conn) conn.send(codes.seGameChange,g,'Poker.Game');
			if (club.members) {
				var count = 0;
				for (var x=0; x<club.members.length; x++) {
					conn = activeUsers[club.members[x]];
					if (!conn) continue;
					if (conn === exclude) continue;
					conn.send(codes.seGameChange,g,'Poker.Game');
					count++;
				}
				token.tag += '.'+count;
			}
		} else {
			token.tag += 'b';
			var count = 0;
			for (var x in activeUsers) {
				activeUsers[x].send(codes.seGameChange,g,'Poker.Game');
				count++;
			}
			token.tag += '.'+count;
		}
		token.stop();
		cb();
	}.bind(this));
}
Club.prototype.goPublic = function (cb) {
	allClubs.update({_id:this.clubid},{$set:{is_private:false}},function (err) {
		assert.ifError(err);
		allClubs.findOne({_id:this.clubid},function (err,clubObj) {
			assert.ifError(err);
			var c = Club.makeClubProtobuf(JSON.parse(JSON.stringify(clubObj)));
			this.obj = clubObj;
			allGames.find({clubid:this.clubid}).toArray(function (err,games) {
				assert.ifError(err);
				for (var x=0; x<games.length; x++) {
					games[x] = makeGameProtobuf(games[x]);
				}
				var joininfo = {status:'csSuccess',club:c,games:games};
				for (var key in activeUsers) {
					activeUsers[key].send(codes.srJoinClubReply,joininfo,'Poker.ClubCommandReply');
				}
			}.bind(this));
		}.bind(this));
	}.bind(this));
	cb('dummy');
}
Club.prototype.updateLimitPostWin = function (change,userid,callback) {
	clubBalances.update({clubid:this.clubid, userid:userid},{$inc:{balance:change}},function (err,rows) {
		if (rows == 1) return callback();
		clubBalances.insert({clubid:this.clubid, userid:userid, balance:change, balance_limit:this.obj.default_balance_limit},callback);
	}.bind(this));
}
Club.prototype.buyin = function (userid,chips) {
	if (!this.balance[userid]) this.balance[userid] = -chips;
	else this.balance[userid] -= chips;
	console.log(this.balance);
}
Club.prototype.cashout = function (userid,chips) {
	this.balance[userid] += chips;
	console.log(this.balance);
}
Club.prototype.getPotentialLosses = function (userid,cb) {
	clubBalances.findOne({clubid:this.clubid, userid:userid},function (err,row) {
		assert.ifError(err);
		if (!row && !this.balance[userid]) return cb(0);
		if (!this.balance[userid]) return cb(row.balance);
		cb(this.balance[userid] + row.balance);
	}.bind(this));
}
Club.init = function (db,activeUsersIn) {
	allClubs = db.collection('clubs');
	activeUsers = activeUsersIn;
	allStats = db.collection('allStats');
	allUsers = db.collection('users');
	allGames = db.collection('games');
	clubBalances = db.collection('clubBalances');
}
// FIXME, their own file
function toMongoId(buf) {
	return new ObjectID(buf.toString('hex'));
}
function fromMongoId(id) {
	return new Buffer(id.id,'binary');
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
Club.makeClubProtobuf = function makeClubProtobuf(c,userlist,stats,self) {
	assert(stats);
	if (stats.length > 1) assert(self);
	if (!c.members) c.members = [];
	c.members.push(c.owner);
	var out = [];
	for (var y=0; y<c.members.length; y++) {
		if (userlist && (userlist.indexOf(c.members[y]) == -1)) userlist.push(c.members[y]);
		var suspended = false;
		if (c.suspended) {
			if (containsObjectID(c.suspended,c.members[y])) suspended = true;
		}
		var obj = {_id:fromMongoId(c.members[y]), suspended:suspended, balance_limit:0, club_balance: 0};
		for (var a=0; a<stats.length; a++) {
			if (compareObjectID(stats[a].clubid,c._id)) {
				if (compareObjectID(stats[a].userid,c.members[y])) {
					obj.club_balance = stats[a].balance;
					if (self.balance[c.members[y]]) obj.club_balance += self.balance[c.members[y]];
					obj.balance_limit = stats[a].balance_limit;
				}
			}
		}
		out.push(obj);
	}
	c.members = out;
	delete c.suspended;
	c._id = new Buffer(c._id.toString(),'hex');
	c.owner = new Buffer(c.owner.toString(),'hex');
	return c;
}
