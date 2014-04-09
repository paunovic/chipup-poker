var allClubs,activeUsers,allStats,allUsers,allGames;

var assert = require('assert');


module.exports = Club;
function Club(obj) {
	if (!(this instanceof Club)) return new Club(clubid);
	this.clubid = obj._id;
	this.obj = obj
}
Club.activeClubsSeq = [];
Club.getClubBySeq = function (seq,cb) {
	if (!Club.activeClubsSeq[seq]) {
		allClubs.findOne({seq:seq},function (err,obj) {
			Club.activeClubsSeq[seq] = new Club(obj);
			cb(null,Club.activeClubsSeq[seq]);
		}.bind(this));
	} else {
		cb(null,Club.activeClubsSeq[seq]);
	}
}
Club.prototype.isOwner = function (user) {
	return this.obj.owner.equals(user);
}
Club.prototype.handOver = function (gameObj,cb) {
	if (activeUsers[this.obj.owner]) {
		console.log('owner is online');
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
				stats[i].userid = fromMongoId(stats[i].userid);
				games[gameidhex].playerstats.push(stats[i]);
			}
			allUsers.find({_id:{$in:players}},{displayname:1}).toArray(function (err,playersOut) {
				for (var i=0; i<playersOut.length; i++) {
					playersOut[i]._id = fromMongoId(playersOut[i]._id);
				}
				var gameidhex = gameObj.id.toString();
				games[gameidhex].clubid = fromMongoId(this.clubid);
				activeUsers[this.obj.owner].send(codes.srTableStatsReply,{reply:out, players:playersOut},'Poker.TableStatsReplies');
				cb();
			}.bind(this));
		}.bind(this));
	} else {
		console.log('owner offline');
		cb();
	}
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
