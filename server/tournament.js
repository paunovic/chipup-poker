var models = require('./db').models,
	util = require('util'),
	assert = require('assert'),
	EventEmitter = require('events').EventEmitter,
	myutils = require('./myutils');

var error = require('./error'),
	Game = require('./game').Game,
	deck = require('./deck'),
	Hand = deck.Hand,
	codes = require('./ServerCodes'),
	ReadWriteLock = require('./lock');

var lazy = {};
lazy.__defineGetter__('user',function () {
	return require('./user');
});
lazy.__defineGetter__('ClientSocket',function () {
	return lazy.user.ClientSocket;
});

var async = require('async');

module.exports = Tournament;

function Tournament() {
	this.tables = [];
}

Tournament.create = function (obj,cb) {
	models.Tournament.create(obj,function (err,doc) {
		if (err) {
			if (err.name == 'ValidationError') return cb(err);
			if (err.name == 'CastError') return cb(err);
		}
		error.handleError(err);
		console.log('doc is',doc);
		core.emit('new_tournament',doc);
		this.commonLock.writeLock(function (release) {
			core.resetTimer(function () {
				release();
				cb();
			});
		});
	}.bind(this));
}
function TournamentCore() {
	this.commonLock = new ReadWriteLock();
}
util.inherits(TournamentCore,EventEmitter);
util.inherits(Tournament,EventEmitter);
Tournament.prototype.startGames = function () {
	async.each(this.tables,function (tbl,cb1) {
		tbl.Lock.writeLock(function (release) {
			var events = [];
			tbl.stateMachine(function (events) {
				console.log('events:%j',events);
				tbl.broadcastStatus(null,true,events);
				release();
				cb1();
			},null,{silent:true},events,0);
		});
	});
}
TournamentCore.prototype.join = function (tournid,userid,nick,cb) {
	models.Tournament.findById(tournid,function (err,doc) {
		console.log(err,userid,doc);
		var dup = false;
		for (var i=0; i<doc.players.length; i++) {
			if (myutils.compareObjectID(doc.players[i]._id,userid)) {
				dup = true;
			}
		}
		if (dup) {
			// error, already a member
			return cb('alreadyMember');
		} else if (doc.registered_players >= doc.maxplayers) {
			return cb('full');
		} else {
			doc.players.push({_id:userid,displayname:nick,chips:doc.startingchips*100});
			doc.registered_players = doc.players.length;
			doc.save(function (err) {
				console.log('saved -  join',arguments,doc);
				cb('OK');
			});
		}
	});
}
TournamentCore.prototype.leave = function (tournid,userid,cb) {
	models.Tournament.findById(tournid,function (err,doc) {
		if (!doc) return cb('404');
		for (var i=0; i<doc.players.length; i++) {
			if (myutils.compareObjectID(doc.players[i]._id,userid)) {
				doc.players.splice(i,1);
			}
		}
		doc.registered_players = doc.players.length;
		doc.save(function (err) {
			error.handleError(err);
			cb('OK');
		});
	});
}
TournamentCore.prototype.resetTimer = function (cb) {
	assert.equal(this.commonLock.readers,-1);
	if (this.timer) clearTimeout(this.timer);
	delete this.timer;
	models.Tournament.find({state:'tnsOpen'},{name:1,start_time:1,state:1}).sort({start_time:1}).limit(1).exec(function (err,rows) {
		if (rows.length != 1) {
			console.log('none found');
			return cb(); // dont start a timer, there is nothing to wait for
		}
		var row = rows[0];
		console.log('row0 is %j',row);
		var now = Date.now() / 1000;
		var timeleft = row.start_time - now;
		if (timeleft < 0) this.checkTournaments(cb);
		else {
			console.log('found',err,rows,timeleft);
			console.log('%d now',now);
			console.log('%d goal',row.start_time);
			this.timer = setTimeout(function () {
				this.commonLock.writeLock(function (release) {
					this.checkTournaments(function () {
						release();
					});
				}.bind(this));
			}.bind(this),(timeleft+60)*1000);
			if (cb) cb();
		}
	}.bind(this));
}
TournamentCore.prototype.checkTournaments = function (cb) {
	models.Tournament.find({state:'tnsOpen'}).sort({name:1,start_time:1}).limit(1).exec(function (err,rows) {
		if (rows.length != 1) return cb(); // nothing found
		var row = rows[0];
		var now = Date.now() / 1000;
		var timeleft = row.start_time - now;
		if (timeleft > 0) {
			this.resetTimer(cb);
			return;
		}
		if (row.registered_players < row.minplayers) {
			console.log('not enough people online');
			row.state = 'tnsCancelled';
			row.save(function () {
				core.emit('tournament_start',row);
				this.resetTimer(cb);
			}.bind(this));
			return;
		}
		this.startTournament(row,function () {
			this.resetTimer(cb);
		}.bind(this));
	}.bind(this));
}
TournamentCore.prototype.startTournament = function (row,cb) {
	row.state = 'tnsInProgress';
	var table_count = row.registered_players / row.seats_per_table;
	console.log('need %d tables',table_count);
	var todo = [];
	for (var i=0; i<table_count; i++) {
		var doc = {game_type:row.gametype, blinds:'gb5x10', seats:row.seats_per_table, gamename:'Tournament '+row.name+' table#'+(i+1), game_limit:row.limit, buyin_min: 10, buyin_max:20, rake:0, rotation:0, hands:0, tournament:row._id};
		todo.push(doc);
	}
	var tourn = new Tournament(row);
	async.each(todo,function (doc,cb) {
		models.Game.create(doc,function (err,game) {
			console.log('made %j',game);
			Game.getGame(game._id,function (err,gameout) {
				console.log('got game');
				tourn.tables.push(gameout);
				cb();
			});
		});
	},function () {
		var tableindex = 0;
		function forceSitDown(user,cb) {
			if (tableindex >= tourn.tables.length) tableindex = 0;
			var tbl = tourn.tables[tableindex];
			tbl.Lock.writeLock(function (release) {
				var userOnline = false;
				if (global.activeUsers[user._id]) userOnline = true;
				var freeSeat = 0;
				while (tbl.members[freeSeat]) freeSeat++;
				console.log('found seat %d in table "%s"',freeSeat,tbl.obj.gamename);
				tbl.members[freeSeat] = { hand: new Hand(), status:'psOutOfHand', chips:user.chips, seat:freeSeat, sitOutNextRound:false, sittingOutRoundsCount:0, handsPlayed:0, muck:false };
				tbl.seats[freeSeat] = { userid: user._id };
				if (userOnline) {
					var conn = global.activeUsers[user._id];
					tbl.users[user._id] = conn;
					tbl.seats[freeSeat].conn = conn;
					conn.send(codes.srTournamentOpenTable,{game:tbl.obj,table_status:tbl.getTableStatus(conn,true,[])},'Poker.TournamentTableStart'); // FIXME, add a sit event?
				} else {
					tbl.reconnect.push(user._id);
					tbl.members[freeSeat].disconnected = true;
					tbl.seats[freeSeat].conn = {log:lazy.ClientSocket.prototype.log, userid:user._id, nick:user.displayname};
				}
				tableindex++;
				tbl.broadcastStatus(null,true,[]);
				release();
				cb();
			});
		}
		// force all users to sit, even if they are disconnected
		var online = [];
		var offline = [];
		for (var x=0; x<row.players.length; x++) {
			if (global.activeUsers[row.players[x]._id]) online.push(row.players[x]);
			else offline.push(row.players[x]);
		}
		console.log('online:%j\noffline:%j',online,offline);
		//var offlinepertable = Math.ceil(offline.length / tourn.tables.length);
		//var userspertable = Math.ceil(row.players.length / tourn.tables.length);
		//console.log('max users per table: %d\noffline per table: %d',userspertable,offlinepertable);
		async.eachSeries(online,forceSitDown,function (err) {
			async.eachSeries(offline,forceSitDown,function (err) {
				setTimeout(tourn.startGames.bind(tourn),30000);
				row.save(function () {
					this.emit('tournament_start',row);
					cb();
				}.bind(this));
			}.bind(this));
		}.bind(this));
	}.bind(this));
}
var core = new TournamentCore();
Tournament.core = core;
