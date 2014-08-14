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
module.exports.PrintBlindStructure = PrintBlindStructure;

function Tournament(obj) {
	this.tables = [];
	this.obj = obj;
	this.user_table_xref = {};
	this.blind_schedule = obj.blind_schedule; // FIXME
	this.currentLevel = 0;
}

Tournament.create = function (obj,cb) {
	obj.blind_schedule = PrintBlindStructure(obj.sb, obj.bb, obj.startingchips, obj.timeperlevel, obj.length);
	models.Tournament.create(obj,function (err,doc) {
		if (err) {
			if (err.name == 'ValidationError') return cb(err);
			if (err.name == 'CastError') return cb(err);
		}
		error.handleError(err);
		core.emit('new_tournament',doc);
		core.commonLock.writeLock(function (release) {
			core.resetTimer(function () {
				release();
				cb(null,doc);
			});
		});
	});
}
function TournamentCore() {
	this.commonLock = new ReadWriteLock();
	this.activeTournaments = {};
}
util.inherits(TournamentCore,EventEmitter);
util.inherits(Tournament,EventEmitter);
Tournament.prototype.startGames = function () {
	this.startTime = Date.now();
	this.currentLevel = -1;
	this.onBreak = false;
	this.nextLevel();
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
};
Tournament.prototype.toProto = function (config) {
	var out = { _id:this.obj._id, name:this.obj.name, description:this.obj.description, gametype:this.obj.gametype, limit:this.obj.limit, seats_per_table:this.obj.seats_per_table, minplayers:this.obj.minplayers, maxplayers:this.obj.maxplayers, startingchips:this.obj.startingchips, timeperlevel:this.obj.timeperlevel, registered_players:this.obj.registered_players, start_time:this.obj.start_time, state:this.obj.state };
	if (config) {
		if (config.games) {
			out.games = [];
			for (var x=0; x<this.tables.length; x++) {
				out.games[x] = Game.makeGameProtobuf(this.tables[x].obj);
			}
		}
		if (config.players) {
			out.players = [];
			for (var x=0; x<this.obj.players.length; x++) {
				out.players[x] = this.obj.players[x];
				out.players[x].gameid = this.user_table_xref[this.obj.players[x]._id];
			}
		}
	}
	out.blind_structure = this.blind_schedule.blinds;
	return out;
}
Tournament.prototype.register = function () {
	core.activeTournaments[this.obj._id] = this;
};
Tournament.prototype.getLevel = function () {
	return this.currentLevel;
	var runtime = (Date.now() - this.startTime)/1000;
	return Math.floor(runtime / 60 / this.blind_schedule.LevelLength);
};
Tournament.prototype.nextLevel = function () {
	console.log('level tick prev:%d',this.currentLevel);
	if (this.currentLevel == (this.obj.blind_schedule.blinds.length - 1)) return;
	this.currentLevel++;
	var minuteNow = new Date().getMinutes();
	var minuteEnd = minuteNow + parseInt(this.obj.blind_schedule.LevelLength);
	console.log('now,end %d,%d',minuteNow,minuteEnd);
	var breakmin = 10;
	if ((minuteNow < (breakmin+1)) && (minuteEnd < (breakmin+1))) {
		setTimeout(this.nextLevel.bind(this),this.obj.blind_schedule.LevelLength * 60000);
	} else {
		var nexthalf = minuteEnd - breakmin
		var delay = (this.obj.blind_schedule.LevelLength-nexthalf) * 60
		delay = delay - (new Date().getSeconds());
		console.log('need to do a break nexthalf:%d delay:%d',nexthalf,delay);
		setTimeout(this.beginBreak.bind(this),(delay)*1000);
	}
}
Tournament.prototype.beginBreak = function () {
	console.log('break starting %s',new Date());
	this.onBreak = true;
	async.each(this.tables,function (tbl,cb) {
		tbl.Lock.writeLock(function (release) {
			var obj = { message:'tmtTournamentBreakAfterHand' };
			tbl.setMessage(obj);
			release();
			cb();
		});
	}.bind(this),function () {
		console.log('break begining');
	});
}
Tournament.prototype.breakStart = function (game,cb) {
	console.log('a game hit break');
	var allpaused = true;
	for (var x=0; x<this.tables.length; x++) {
		console.log('table %d state %s',x,this.tables[x].state);
		if (this.tables[x].state != 'tsIdle') {
			allpaused = false;
			break;
		}
	}
	if (allpaused) {
		console.log('break can begin');
		async.each(this.tables,function (tbl,cb1) {
			if (tbl === game) {
				var obj = { message:"tmtTournamentBreak", duration:300 };
				tbl.setMessage(obj);
				cb1();
				return;
			}
			console.log('getting lock');
			tbl.Lock.writeLock(function (release) {
				console.log('got lock');
				var obj = { message:"tmtTournamentBreak", duration:300 };
				tbl.setMessage(obj);
				release();
				cb1();
			}.bind(this));
		},cb);
	} else {
		async.each(this.tables,function (tbl,cb1) {
			if (tbl.state == 'tsIdle') {
				obj = { message:"tmtTournamentBreakWaitingTables" };
			} else {
				obj = { message:"tmtTournamentBreakAfterHand" };
			}
			if (tbl === game) {
				tbl.setMessage(obj);
				cb1();
				return;
			}
			tbl.Lock.writeLock(function (release) {
				var obj;
				tbl.setMessage(obj);
				release();
				cb1();
			}.bind(this));
		},cb);
	}
};
Tournament.prototype.handOver = function (game,cb) {
	// called after a hand ends in a game, updates tournament chip counts from game seats
	for (var x=0; x<this.obj.players.length; x++) {
		for (var y=0; y<game.members.length; y++) {
			if (!game.members[y]) continue;
			if (myutils.compareObjectID(this.obj.players[x]._id,game.seats[y].userid)) {
				//console.log('match',x,y,this.obj.players[x],game.members[y]);
				this.obj.players[x].chips = game.members[y].chips;
			}
		}
	}
	this.obj.save(function (err) {
		console.log('sending event');
		this.emit('handOver',this);
		console.log('post-save');
		cb();
	}.bind(this));
}
TournamentCore.prototype.join = function (tournid,userid,nick,cb) {
	this.commonLock.writeLock(function (release) {
		this.getByIdUnlocked(tournid,function (err,tourn) {
			console.log(err,userid,tourn);
			var dup = false;
			for (var i=0; i<tourn.obj.players.length; i++) {
				if (myutils.compareObjectID(tourn.obj.players[i]._id,userid)) {
					dup = true;
				}
			}
			if (dup) {
				// error, already a member
				release();
				return cb('alreadyMember');
			} else if (tourn.obj.registered_players >= tourn.obj.maxplayers) {
				release();
				return cb('full');
			} else {
				tourn.obj.players.push({_id:userid,displayname:nick,chips:tourn.obj.startingchips*100});
				tourn.obj.registered_players = tourn.obj.players.length;
				tourn.obj.save(function (err) {
					console.log('saved - join',arguments);
					release();
					cb('OK');
				});
			}
		});
	}.bind(this));
}
TournamentCore.prototype.getByIdUnlocked = function (id,cb) {
	if (this.activeTournaments[id]) {
		cb(null,this.activeTournaments[id]);
	} else {
		models.Tournament.findById(id,function (err,doc) {
			if (!doc) return cb('404');
			this.activeTournaments[id] = new Tournament(doc);
			this.activeTournaments[id].register();
			cb(null,this.activeTournaments[id]);
		}.bind(this));
	}
};
TournamentCore.prototype.getById = function (id,cb) {
	this.commonLock.writeLock(function (release) {
		this.getByIdUnlocked(id,function (err,tourn) {
			release();
			cb(err,tourn);
		});
	}.bind(this));
}
TournamentCore.prototype.leave = function (tournid,userid,cb) {
	this.commonLock.writeLock(function (release) {
		this.getByIdUnlocked(tournid,function (err,tourn) {
			if (err) {
				release();
				cb(err);
				return;
			}
			for (var i=0; i<tourn.obj.players.length; i++) {
				if (myutils.compareObjectID(tourn.obj.players[i]._id,userid)) {
					tourn.obj.players.splice(i,1);
				}
			}
			tourn.obj.registered_players = tourn.obj.players.length;
			tourn.obj.save(function (err) {
				error.handleError(err);
				release();
				cb('OK');
			});
		});
	}.bind(this))
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
		var timeleft = row.start_time - now - 60;
		if (timeleft < 0) this.checkTournaments(cb);
		else {
			console.log('found',err,rows,timeleft);
			console.log('%d now',now);
			console.log('%d goal',row.start_time);
			if (timeleft > 100000) {
				console.log('timeleft was %d years, trimming',timeleft/60/60/24/365);
				timeleft = 100000;
			}
			this.timer = setTimeout(function () {
				this.commonLock.writeLock(function (release) {
					this.checkTournaments(function () {
						release();
					});
				}.bind(this));
			}.bind(this),timeleft*1000);
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
	assert.equal(this.commonLock.readers,-1);
	this.getByIdUnlocked(row._id,function (err,tourn) {
		tourn.startTime = Date.now();
		var table_count = tourn.obj.registered_players / tourn.obj.seats_per_table;
		console.log('need %d tables',table_count);
		var todo = [];
		for (var i=0; i<table_count; i++) {
			var doc = {game_type:tourn.obj.gametype, blinds:'gb5x10', seats:tourn.obj.seats_per_table, gamename:''+(i+1), game_limit:tourn.obj.limit, buyin_min: 10, buyin_max:20, rake:0, rotation:0, hands:0, tournament:tourn.obj._id};
			todo.push(doc);
		}
		tourn.obj.state = 'tnsInProgress';
		async.each(todo,function (doc,cb) {
			models.Game.create(doc,function (err,game) {
				console.log('made %j',game);
				Game.getGame(game._id,function (err,gameout) {
					console.log('got game %s %s',gameout.id,gameout.nick);
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
					assert(freeSeat < tbl.obj.seats);
					tbl.members[freeSeat] = { hand: new Hand(), status:'psOutOfHand', chips:user.chips, seat:freeSeat, sitOutNextRound:false, sittingOutRoundsCount:0, handsPlayed:0, muck:false };
					tbl.seats[freeSeat] = { userid: user._id };
					tourn.user_table_xref[user._id] = tbl.obj._id;
					if (userOnline) {
						var conn = global.activeUsers[user._id];
						tbl.users[user._id] = conn;
						tbl.seats[freeSeat].conn = conn;
						conn.send(codes.srTournamentOpenTable,{game:tbl.obj,table_status:tbl.getTableStatus(conn,true,[])},'Poker.TournamentTableStart'); // FIXME, add a sit event?
					} else {
						tbl.reconnect.push(user._id);
						tbl.members[freeSeat].disconnected = true;
						tbl.members[freeSeat].autoplay = true;
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
			for (var x=0; x<tourn.obj.players.length; x++) {
				if (global.activeUsers[tourn.obj.players[x]._id]) online.push(tourn.obj.players[x]);
				else offline.push(tourn.obj.players[x]);
			}
			console.log('online:%j\noffline:%j',online,offline);
			//var offlinepertable = Math.ceil(offline.length / tourn.tables.length);
			//var userspertable = Math.ceil(row.players.length / tourn.tables.length);
			//console.log('max users per table: %d\noffline per table: %d',userspertable,offlinepertable);
			//console.log('game:',tourn.tables);
			async.eachSeries(online,forceSitDown,function (err) {
				async.eachSeries(offline,forceSitDown,function (err) {
					setTimeout(tourn.startGames.bind(tourn),30000);
					tourn.obj.save(function () {
						this.emit('tournament_start',tourn.obj);
						cb();
					}.bind(this));
				}.bind(this));
			}.bind(this));
		}.bind(this));
	}.bind(this))
}
var core = new TournamentCore();
Tournament.core = core;
function RoundBlind(ABlind, ARoundTo) {
	//console.log('rounding %d %d',ABlind,ARoundTo,Math.floor(ABlind/ARoundTo),Math.ceil(ABlind/ARoundTo)*ARoundTo);
	return Math.ceil(ABlind/ARoundTo)*ARoundTo;
}
function PrintBlindStructure(ASmallBlind,ABigBlind,AStartingChips,ALevelLength,ATournamentLength) {
	var EXTRA_LEVELS = 3;
	var EXTRA_LEVELS_MULTIPLIER = 1.25;
	var C1,levels,sb,bb,prev_sb,prev_bb,sb_rounded,bb_rounded,sb_bb_ratio,multiplier;

	levels = Math.floor((ATournamentLength * 60) / ALevelLength);
	sb_bb_ratio = ASmallBlind/ABigBlind;

	//console.log('Blinds: %d/%d; Chips: %d; L length: %dmin; T length: %dh',ASmallBlind, ABigBlind, AStartingChips, ALevelLength, ATournamentLength);
	//console.log('Total levels: %d, extra levels: %d',levels,EXTRA_LEVELS);
	//console.log('---------------------------------');
	var blinds = [];
	var out = { levels:levels, LevelLength:ALevelLength, blinds:blinds };

	sb = ASmallBlind;
	bb = ABigBlind;
	sb_rounded = RoundBlind(sb,1);
	bb_rounded = RoundBlind(bb,1);
	//console.log('L%d: %d/%d',1,sb_rounded,bb_rounded);
	blinds[0] = { sb:sb_rounded, bb:bb_rounded };

	prev_sb = sb_rounded;
	prev_bb = bb_rounded;
	for (C1 = 2; C1 <= levels; C1++) {
		multiplier = Math.pow(AStartingChips/ABigBlind,1/(levels-1));
		while ((sb_rounded == prev_sb) || (bb_rounded == prev_bb)) {
			bb = bb * multiplier;
			sb = bb * sb_bb_ratio;
			sb_rounded = RoundBlind(sb,5);
			bb_rounded = RoundBlind(bb,10);
		}
		prev_sb = sb_rounded;
		prev_bb = bb_rounded;

		//console.log('L%d: %d/%d',C1,sb_rounded,bb_rounded);
		blinds[C1-1] = { sb:sb_rounded, bb:bb_rounded };
	}
	for (C1 = 1; C1 <= EXTRA_LEVELS; C1++) {
		bb = bb * EXTRA_LEVELS_MULTIPLIER;
		sb = bb * sb_bb_ratio;
		sb_rounded = RoundBlind(sb,5);
		bb_rounded = RoundBlind(bb,10);
		//console.log('L%d: %d/%d',levels+C1,sb_rounded,bb_rounded);
		blinds[(levels+C1)-1] = { sb:sb_rounded, bb:bb_rounded };
	}
	return out;
}
