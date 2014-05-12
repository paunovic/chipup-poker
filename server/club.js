var allClubs,activeUsers,allStats,allUsers,allGames;

var assert = require('assert');

var makeGameProtobuf = require('./game').makeGameProtobuf;
var profiler = require('./profiler');


module.exports = Club;
function Club(obj) {
	if (!(this instanceof Club)) return new Club(clubid);
	this.clubid = obj._id;
	this.obj = obj
}
Club.activeClubsSeq = [];
Club.activeClubsId = {};
Club.getClubBySeq = function (seq,cb) {
	if (!Club.activeClubsSeq[seq]) {
		allClubs.findOne({seq:seq},function (err,obj) {
			Club.activeClubsSeq[seq] = new Club(obj);
			Club.activeClubsId[obj._id] = Club.activeClubsSeq[seq];
			cb(null,Club.activeClubsSeq[seq]);
		}.bind(this));
	} else {
		cb(null,Club.activeClubsSeq[seq]);
	}
}
Club.getClubById = function (id,cb) {
	if (!Club.activeClubsId[id]) {
		allClubs.findOne({_id:id},function (err,obj) {
			Club.activeClubsSeq[obj.seq] = new Club(obj);
			Club.activeClubsId[obj._id] = Club.activeClubsSeq[obj.seq];
			cb(null,Club.activeClubsSeq[obj.seq]);
		}.bind(this));
	} else {
		cb(null,Club.activeClubsId[id]);
	}
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
		console.log('owner offline');
		cb();
	}
}
Club.prototype.seGameChanged = function (gamerow,cb,exclude) {
	var token = profiler.start('seGameChanged');
	// FIXME, cache object
	// FIXME, cache the protobuf
	allClubs.findOne({_id:this.clubid},function (err,club) {
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
Club.init = function (db,activeUsersIn) {
	allClubs = db.collection('clubs');
	activeUsers = activeUsersIn;
	allStats = db.collection('allStats');
	allUsers = db.collection('users');
	allGames = db.collection('games');
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
Club.makeClubProtobuf = function makeClubProtobuf(c,userlist) {
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
