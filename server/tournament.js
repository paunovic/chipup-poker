var models = require('./db').models,
	util = require('util'),
	colors = require('colors');
	assert = require('assert'),
	EventEmitter = require('events').EventEmitter,
	myutils = require('./myutils'),
	profiler = require('profiler');

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
	this.obj.blind_schedule.LevelLength = parseInt(this.obj.blind_schedule.LevelLength);
	assert.equal(typeof this.obj.blind_schedule.LevelLength,'number');
	this.breakmin = 55;
	this.Lock = new ReadWriteLock();
	this.id = this.obj._id;
	this.bustQueue = {};
	this.final_table = false;
}

Tournament.create = function (obj,cb) {
	models.Tournament.create(obj,function (err,doc) {
		if (err) {
			if (err.name == 'ValidationError') return cb(err);
			if (err.name == 'CastError') return cb(err);
		}
		error.handleError(err);
		doc.blind_schedule = PrintBlindStructure(doc.sb, doc.bb, doc.startingchips, doc.timeperlevel, doc.length);
		doc.save(function () {
			error.handleError(err);
			core.emit('new_tournament',doc);
			core.commonLock.writeLock(function (release) {
				core.resetTimer(function () {
					release();
					cb(null,doc);
				});
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
	console.log('%s dealing cards',new Date());
	this.startTime = Date.now();
	this.currentLevel = 0; // FIXME, improve nextLevel handling
	this.onBreak = false;
	async.each(this.tables,function (tbl,cb1) {
		tbl.Lock.writeLock(function (release) {
			tbl.clearMessage('tmtTournamentStart');
			var events = [];
			tbl.stateMachine(function (events) {
				console.log('events:%j',events);
				tbl.broadcastStatus(null,true,events);
				release();
				cb1();
			},null,{silent:true},events,0);
		});
	},function () {
		this.obj.state = 'tnsInProgress';
		this.obj.save(function (err) {
			error.handleError(err);
			this.emit('state_changed',this);
			core.emit('state_changed',this);
			this.emit('tournament_start',this);
			this.currentLevel = -1;
			this.nextLevel();
		}.bind(this));
	}.bind(this));
};
Tournament.prototype.toProto = function (config) {
	var out = { _id:this.obj._id, name:this.obj.name, description:this.obj.description, gametype:this.obj.gametype, limit:this.obj.limit, seats_per_table:this.obj.seats_per_table, minplayers:this.obj.minplayers, maxplayers:this.obj.maxplayers, startingchips:this.obj.startingchips, timeperlevel:this.obj.timeperlevel, registered_players:this.obj.registered_players, start_time:this.obj.start_time, state:this.obj.state, prizes:this.obj.prizes };
	if (config) {
		if (config.games) {
			out.games = [];
			var result = this.countPlayersPerTable();
			for (var x=0; x<this.tables.length; x++) {
				if (result.counts[x].count > 0) out.games[x] = Game.makeGameProtobuf(this.tables[x].obj);
			}
		}
		if (config.players) {
			//var sum = 0;
			out.players = [];
			for (var x=0; x<this.obj.players.length; x++) {
				//sum += this.obj.players[x].chips;
				out.players[x] = this.obj.players[x];
				out.players[x].position = x;
				var t = this.user_table_xref[this.obj.players[x]._id];
				if (t) {
					out.players[x].gameid = t.table;
					out.players[x].seat_index = t.seat;
				} else {
					out.players[x].gameid = null;
					out.players[x].seat_index = null;
				}
				//console.log('chips:%j',out.players[x])
			}
			//console.log('sum:%d',sum);
			//assert.equal(sum,330000);
		}
	}
	out.blind_structure = this.blind_schedule.blinds;
	if (['tnsStarting','tnsInProgress','tnsOnBreak'].indexOf(this.obj.state) != -1) {
		out.current_blind_level = this.currentLevel;
		out.current_blind_level_end_time = this.level_end_time;
	}
	return out;
}
Tournament.prototype.register = function () {
	core.activeTournaments[this.obj._id] = this;
};
Tournament.prototype.getLevel = function () {
	return this.currentLevel;
};
Tournament.prototype.nextLevel = function () {
	assert.equal(typeof this.obj.blind_schedule.LevelLength,'number');
	var now = new Date();
	console.log('level tick prev:%d %s',this.currentLevel,now);
	if (this.obj.state == 'tnsFinished') {
		return;
	}
	if (this.currentLevel == (this.obj.blind_schedule.blinds.length - 1)) return;
	this.currentLevel++;
	this.levelTime = now.getTime();
	var minuteNow = now.getMinutes();
	var minuteEnd = minuteNow + this.obj.blind_schedule.LevelLength;
	console.log('now,end %d,%d',minuteNow,minuteEnd);

	var level_delay = this.obj.blind_schedule.LevelLength * 60;
	level_delay = level_delay - now.getSeconds();

	if ( ((minuteNow < (this.breakmin+1)) && (minuteEnd < (this.breakmin+1)))
		|| ( (minuteNow > (this.breakmin+5)) && (minuteEnd > (this.breakmin+5)) ) ) {
		setTimeout(this.nextLevel.bind(this),level_delay * 1000);
		this.level_end_time = Date.now() + (level_delay * 1000);
	} else {
		var nexthalf = minuteEnd - this.breakmin;
		this.nexthalf = nexthalf;
		var delay = (this.obj.blind_schedule.LevelLength-nexthalf) * 60;
		delay = delay - now.getSeconds();
		console.log('need to do a break nexthalf:%d delay:%d',nexthalf,delay);
		setTimeout(this.beginBreak.bind(this),(delay)*1000);
		this.level_end_time = Date.now() + (level_delay * 1000);
	}
	this.emit('state_changed',this);
	core.emit('state_changed',this);
}
Tournament.prototype.beginBreak = function () {
	if (this.obj.state == 'tnsFinished') {
		console.log('break canceled');
		return;
	}
	console.log('break starting %s',new Date());
	this.onBreak = true;
	var obj = { message:'tmtTournamentBreak', duration:300 };
	async.each(this.tables,function (tbl,cb) {
		tbl.Lock.writeLock(function (release) {
			tbl.setMessage(obj);
			release();
			cb();
		});
	}.bind(this),function () {
		console.log('break begining');
		this.obj.state = 'tnsOnBreak';
		this.obj.save(function (err) {
			error.handleError(err);
			this.emit('state_changed',this);
			core.emit('state_changed',this);
			setTimeout(this.break_over.bind(this),obj.duration*1000);
			this.level_end_time = Date.now() + (obj.duration * 1000);
		}.bind(this));
	}.bind(this));
}
Tournament.prototype.break_over = function () {
	console.log('%s break over, resuming games',new Date());
	this.onBreak = false;
	async.each(this.tables,function (tbl,cb1) {
		tbl.Lock.writeLock(function (release) {
			tbl.clearMessage('tmtTournamentBreak');
			if (tbl.state == 'tsIdle') {
				var events = [];
				tbl.stateMachine(function (events) {
					console.log('events:%j',events);
					tbl.broadcastStatus(null,true,events);
					release();
					cb1();
				},null,{silent:true},events,0);
			} else {
				release();
				cb1();
			}
		});
	},function () {
		this.obj.state = 'tnsInProgress';
		this.obj.save(function (err) {
			error.handleError(err);
			var now = new Date();
			var delay = (this.nexthalf * 60) - now.getSeconds();
			console.log('second level half delay: %d',delay);
			setTimeout(function () {
				console.log('%s level ends',new Date());
				this.nextLevel();
			}.bind(this),delay*1000);
			this.level_end_time = Date.now() + (delay * 1000);
			this.emit('state_changed',this);
			core.emit('state_changed',this);
		}.bind(this));
	}.bind(this));
}
Tournament.prototype.break_start = function (game,cb) {
	game.log('game hit break');
	cb();
};
Tournament.prototype.fixRank = function (oldpos,rise) {
	var looking = true;
	var pos = oldpos;
	var chips = this.obj.players[oldpos].chips;
	var direction = rise ? -1 : 1;
	var changed = false;
	while (looking) {
		var next = pos + direction;
		var currentchips = this.obj.players[pos].chips;
		if ((next >= this.obj.players.length) || (next < 0)) {
			return changed;
			//console.log('next:%d pos:%d nc:NAN cc:%d',next,pos,currentchips);
		} else {
			var nextchips = this.obj.players[next].chips;
			//console.log('next:%d pos:%d nc:%d cc:%d',next,pos,nextchips,currentchips);
			if ( ((nextchips > currentchips) && !rise) || ((nextchips < currentchips) && rise) ) {
				var self = this.obj.players.splice(pos,1)[0];
				this.obj.players.splice(next,0,self);
				//console.log('moved a player from %d->%d',pos,next);
				pos = next;
				changed = false;
			} else looking = false;
		}
	}
	return changed;
};
Tournament.prototype.rerebalance = function (game) {
	game.Lock.writeLock(function (release) {
		this.handOver(game,function () {
			release();
		}.bind(this));
	}.bind(this));
}
Tournament.prototype.handOver = function (game,cb) {
	var token1 = profiler.start('tournament.handOver');
	function saveChanges(release_tourn) {
		var result = this.countPlayersPerTable(game);
		if (result.active == 1) {
			if (result.players_at_this_table > 0) {
				console.log('final table enabled');
				game.final_table = true;
				this.final_table = true;
			} else {
				for (var x=0; x<result.counts.length; x++) {
					if (result.counts[x] > 0) {
						this.tables[x].final_table = true;
						this.final_table = true;
						console.log('final table 2');
					}
				}
			}
			//console.log(game);
			//console.log(this);
		}
		this.log.save(function (err) {
			this.obj.save(function (err) {
				if (this.obj.state == 'tnsFinished') {
					this.emit('state_changed',this);
					core.emit('state_changed',this);
				}
				this.emit('handOver',this);
				token1.stop();
				release_tourn();
				cb();
			}.bind(this));
		}.bind(this));
	}
	this.Lock.writeLock(function (release_tourn) {
		console.log('%s Tournament.handOver %d %s',new Date(),parseInt(game.obj.gamename)-1,game.id);
		// called after a hand ends in a game, updates tournament chip counts from game seats

		// do the queued busts
		var obj;
		if (this.bustQueue[game.id]) {
			while (obj = this.bustQueue[game.id].pop()) {
				this.doBust(obj.userid, obj.seat, obj.table);
			}
		}
		var players_remaining = 0;
		for (var x=0; x<this.obj.players.length; x++) {
			if (this.obj.players[x].chips > 0) players_remaining++;
		}
		for (var x=0; x<this.obj.players.length; x++) {
			for (var y=0; y<game.members.length; y++) {
				if (!game.members[y]) continue;
				if (myutils.compareObjectID(this.obj.players[x]._id,game.seats[y].userid)) {
					//console.log('match',x,y,this.obj.players[x],game.members[y]);
					if (this.obj.players[x].chips != game.members[y].chips) {
						//console.log('player %s(%d) changed chips %d->%d',this.obj.players[x].displayname,x,this.obj.players[x].chips/100,game.members[y].chips/100);
						var rise = game.members[y].chips > this.obj.players[x].chips;
						this.obj.players[x].chips = game.members[y].chips;
						if (this.fixRank(x,rise)) x = 0;
					}
				}
			}
		}
		// DEBUG
		var total2 = 0;
		for (var x=0; x<this.obj.players.length; x++) {
			total2 += this.obj.players[x].chips;
		}
		// debug
		var data = {};
		for (var x=0; x<this.obj.players.length; x++) {
			var p = this.obj.players[x];
			if (!data[p.gameid]) data[p.gameid] = {seats:[]};
			data[p.gameid].seats[p.seat_index] = p.chips/100;
		}
		for (var key in data) {
			var sum = 0;
			for (var x=0; x<data[key].seats.length; x++) if (data[key].seats[x]) sum += data[key].seats[x];
			//console.log('sum:%d key:%s seats:%j',sum,key,data[key].seats);
		}
		// debug2
		/*var total = 0;
		var seats = [];
		for (var y=0; y<game.members.length; y++) {
			if (!game.members[y]) continue;
			seats[y] = game.members[y].chips;
			total += game.members[y].chips;
		}
		console.log('sum:%d chips:%j',total,seats);
		if (total == 60000) {
		} else if (total == 50000) {
		} else assert(false);
		assert.equal(total2,330000);*/
		// /DEBUG
		if (players_remaining == 1) {
			console.log('on the final player');
			this.obj.state = 'tnsFinished';
			var winner = this.obj.players[0];
			var conn = global.activeUsers[winner._id];
			if (conn) {
				var obj = {tournament_id:this.id, player_id:winner._id, place:0, table_id:game.id }
				if (this.obj.prizes[0]) obj.prize = this.obj.prizes[0];
				conn.send(codes.seTournamentPlayerFinished,obj,'Poker.TournamentPlayerFinished');
			}
			console.log(winner);
			var winner_conn = false;
			for (var x=0; x<game.seats.length; x++) {
				if (!game.members[x]) continue;
				if (myutils.compareObjectID(winner._id,game.seats[x].userid)) {
					console.log(x,game.seats[x]);
					winner_conn = game.seats[x].conn;
				}
			}
			process.nextTick(function () {
				game.leave(winner_conn,'tournamentWinner',function () {
				}.bind(this));
			}.bind(this));
			assert.equal(winner.chips,this.obj.startingchips * 100 * this.obj.players.length);
			winner.chips = 0;
			saveChanges.call(this,release_tourn);
		} else {
			var result = this.countPlayersPerTable(game);
			var counts = result.counts;
			var total = result.total;
			var players_at_this_table = result.players_at_this_table;
			//console.log('counts:%j total:%d',counts,total);
			var minTables = Math.ceil(total/this.obj.seats_per_table);
			var remainder = total % this.obj.seats_per_table;
			var targetPlayers = Math.floor(total/minTables);
			//console.log('minTables:%d remainder:%d avg per table2:%d, this table:%d min:%d max:%d',minTables,remainder,targetPlayers,players_at_this_table,result.min,result.max);
			this.log.records.push({ type:'counts', counts:result, thisTable:parseInt(game.obj.gamename)-1 });

			if ((result.active > minTables) && (players_at_this_table == result.min)) {
				game.clearOut = true;
				console.log('begining destruction of table %s',parseInt(game.obj.gamename)-1);
			}
			if (game.clearOut) {
				var target = targetPlayers + 1;
				if (target > this.obj.seats_per_table) target = this.obj.seats_per_table;
				var table_dest = this.findEmptyTable(counts,target,game);
				if (table_dest) {
					console.log('too many tables A, found %s',parseInt(table_dest.obj.gamename)-1);
					this.log.records.push({type:'msg',msg:'too many tables A, attempting transfer'});
					this.doRebalance(game,table_dest,function () {
						var result = this.countPlayersPerTable(game);
						console.log('moved a player, re-counting:%j',result);
						if (result.players_at_this_table >= 1) {
							var table_dest = this.findEmptyTable(result.counts,target,game);
							if (table_dest) {
								this.log.records.push({type:'xfer1',msg:'too many tables C, attempting transfer', counts:result, thisTable:parseInt(game.obj.gamename)-1 });
								this.doRebalance(game,table_dest,function () {
									saveChanges.call(this,release_tourn);
									setTimeout(this.rerebalance.bind(this,game),1000);
								}.bind(this),true);
							} else {
								saveChanges.call(this,release_tourn);
								this.log.records.push({type:'msg',msg:'no table available to move final player, re-checking'});
								setTimeout(this.rerebalance.bind(this,game),1000);
							}
						} else saveChanges.call(this,release_tourn);
					}.bind(this),true);
					return;
				} else {
					console.log('too many tables A, none found',result);
					if (result.players_at_this_table == 1) {
						this.log.records.push({type:'msg',msg:'too many tables A, none found yet'});
						setTimeout(this.rerebalance.bind(this,game),1000);
					} else {
						this.log.records.push({type:'msg',msg:'too many tables A, none found'});
					}
				}
			} else if ((players_at_this_table > targetPlayers) && (result.min < targetPlayers)) /*|| ((players_at_this_table == result.max) && ((result.max-result.min) >= 2)))*/ {
				console.log('current table is too full');
				this.log.records.push({type:'msg',msg:'current table is too full'});
				var table_dest = this.findEmptyTable(counts,targetPlayers);
				if (table_dest) {
					this.doRebalance(game,table_dest,function () {
						saveChanges.call(this,release_tourn);
					}.bind(this),false);
					return;
				}
			} else if (result.max < targetPlayers) {
				console.log('too many tables B');
			} else if ((targetPlayers == players_at_this_table) && (result.min < targetPlayers) && (targetPlayers == this.obj.seats_per_table)) {
				console.log('this table is full, and should be drained');
			} else if ((players_at_this_table == result.max) && ((result.max-result.min) > 2)) {
				console.log('major imbalance, grabbing one from this table');
			}
			saveChanges.call(this,release_tourn);
		}
	}.bind(this));
};
Tournament.prototype.doRebalance = function (table_source,table_dest,cb,force) {
	table_dest.Lock.writeLock(function (release) {
		console.log('time to find a seat dealer:%d',table_dest.dealer);
		var holes = this.findHoles(table_dest);
		console.log('holes:%j',holes);
		var candidates = this.findCandidates(table_source,holes);
		console.log('candidates:%j',candidates);
		if ((candidates.length == 0) && force) {
			// no matching seats, but force mode is on, move anyways
			for (var y=0; y<table_source.obj.seats; y++) {
				if (table_source.members[y]) {
					for (var i=0; i<holes.length; i++) {
						candidates.unshift({seat_source:y, seat_destination:holes[i].seat, position:-1});
					}
				}
			}
			this.log.records.push({type:'msg', msg:'forcing a move since no matches found'});
			console.log('candidates:%j',candidates);
		}
		for (var y=0; y<candidates.length; y++) {
			var obj = candidates[y];
			if (!force && (obj.position < 2)) continue;
			var tseat = candidates[y].seat_destination;
			var oseat = candidates[y].seat_source;
			table_source.paused = true;

			table_dest.log('moving player %s into seat %d',table_source.seats[oseat].conn.nick,tseat);
			table_dest.members[tseat] = table_source.members[oseat];
			table_dest.seats[tseat] = table_source.seats[oseat];
			table_dest.members[tseat].status = 'psOutOfHand';
			table_dest.members[tseat].seat = tseat;
			table_dest.lastplayer[tseat] = table_dest.seats[tseat].userid;
			var event = table_dest.makeEvent('teSit',tseat);
			this.user_table_xref[table_dest.seats[tseat].userid] = {table:table_dest.obj._id, seat:tseat};

			var pub = table_dest.members[tseat];
			var userid = table_dest.seats[tseat].userid;

			if (pub.disconnected) {
				for (var x=0; x<table_source.reconnect.length; x++) {
					if (myutils.compareObjectID(userid,table_source.reconnect[x])) {
						table_source.reconnect.splice(x,1);
					}
				}
				table_dest.reconnect.push(userid);
			} else {
				table_dest.users[table_dest.seats[tseat].userid] = table_dest.seats[tseat].conn;
				delete table_source.users[table_dest.seats[tseat].userid];
			}
			table_source.log('moving player %s from seat %d out',table_source.seats[oseat].conn.nick,oseat);
			this.log.records.push({type:'move', oseat:oseat, tseat:tseat, otable:parseInt(table_source.obj.gamename)-1, ttable:parseInt(table_dest.obj.gamename)-1, thandid: table_dest.handid, position:obj.position });
			table_source.standUp(table_source.seats[oseat].conn,function (folded,events,offset) {
				//table_source.log('standup completed');
				var obj = { game_source:table_source.id, game_destination:table_dest.id, user_id:table_dest.seats[tseat].userid, seat_source:oseat, seat_destination:tseat };
				for (var key in table_source.users) {
					if (!table_source.users[key]) continue;
					table_source.users[key].send(codes.seTournamentPlayerTransfer,obj,'Poker.TournamentPlayerTransfer');
				}
				for (var key in table_dest.users) {
					if (!table_dest.users[key]) continue;
					table_dest.users[key].send(codes.seTournamentPlayerTransfer,obj,'Poker.TournamentPlayerTransfer');
				}
				table_source.broadcastStatus(null,true,events);
				table_dest.broadcastStatus(null,true,[event]);
				setTimeout(this.postTransfer.bind(this,table_source,table_dest,oseat,tseat),5000);
				release();
				cb();
			}.bind(this));
			return; // // dont call saveChanges yet
		}
		// no suitable seat found, release lock and do cb
		this.log.records.push({type:'no_candidate', msg:'no suitable matches found', holes:holes });
		release();
		cb();
	}.bind(this));
};
Tournament.prototype.findCandidates = function (game,holes) {
	var candidates = [];
	var pos = 0;
	var seat = game.dealer;
	for (var y=0; y<game.obj.seats; y++) {
		if (game.members[seat]) {
			for (var i=0; i<holes.length; i++) {
				if (pos == holes[i].position) {
					console.log('candidate, moving player %s from seat %d to %d, relative position %d',game.seats[seat].conn.nick,seat,holes[i].seat,pos);
					candidates.unshift({seat_source:seat, seat_destination:holes[i].seat, position:pos});
				}
			}
			pos++;
		}
		seat++;
		if (seat >= game.obj.seats) seat -= game.obj.seats;
	}
	return candidates;
};
Tournament.prototype.findHoles = function (table_dest) {
	var holes = [];
	var pos = 0;
	var seat = table_dest.dealer;
	for (var y=0; y<table_dest.obj.seats; y++) {
		//console.log('seat:%d pos:%d y:%d ',seat,pos,y,table_dest.members[seat]);
		if (table_dest.members[seat]) {
			pos++;
		} else {
			holes.push({seat:seat,position:pos});
		}
		seat++;
		if (seat >= table_dest.obj.seats) seat -= table_dest.obj.seats;
	}
	return holes;
};
Tournament.prototype.findEmptyTable = function (counts,targetPlayers,skip) {
	for (var x=0; x<counts.length; x++) {
		if (counts[x].count < targetPlayers) {
			if (this.tables[x] == skip) continue;
			if (this.tables[x].clearOut) continue;
			console.log('table %d %j is too empty',x,counts[x]);
			if (this.tables[x].Lock.readers != 0) {
				console.log('but its locked, waiting');
				continue;
			}
			return this.tables[x];
		} else console.log('table %d %d is good',x,counts[x].count);
	}
};
Tournament.prototype.countPlayersPerTable = function (this_table) {
	var counts = [];
	var total = 0;
	var players_at_this_table = 0;
	var max = 0;
	var min = 100;
	var active = 0;
	for (var x=0; x<this.tables.length; x++) {
		var players = this.countPlayers(this.tables[x]);
		//console.log('table %d has %d players',x,players);
		if (this.tables[x] == this_table) {
			players_at_this_table = players;
		}
		counts[x] = {count:players,id:this.tables[x].id};
		total += players;
		if (players > max) max = players;
		if ((players < min) && (players > 0)) min = players;
		if (players > 0) active++;
	}
	return {counts:counts, total:total, players_at_this_table:players_at_this_table, max:max, min:min, active:active };
};
Tournament.prototype.bust = function (userid,seat,table) {
	if (!this.bustQueue[table.id]) this.bustQueue[table.id] = [];
	this.bustQueue[table.id].push({userid:userid, seat:seat, table:table});
}
Tournament.prototype.doBust = function (userid,seat,table) {
	this.log.records.push({type:'bust', userid:userid, table:parseInt(table.obj.gamename)-1, seat:seat });
	this.user_table_xref[userid] = null;
	console.log('user %s busted',userid);
	for (var x=0; x<this.obj.players.length; x++) {
		if (myutils.compareObjectID(this.obj.players[x]._id,userid)) {
			//console.log('match',x,y,this.obj.players[x],game.members[y]);
			//console.log('player %s(%d) changed chips %d->%d',this.obj.players[x].displayname,x,this.obj.players[x].chips,game.members[y].chips);
			this.obj.players[x].chips = 0;
			this.fixRank(x,false);
			break;
		}
	}
	for (var x=0; x<this.obj.players.length; x++) {
		if (myutils.compareObjectID(this.obj.players[x]._id,userid)) {
			var conn = global.activeUsers[userid];
			if (conn) {
				var obj = {tournament_id:this.id, player_id:userid, place:x, table_id:table.id }
				if (this.obj.prizes[x]) obj.prize = this.obj.prizes[x];
				console.log(this.obj.prizes,x,obj);
				conn.send(codes.seTournamentPlayerFinished,obj,'Poker.TournamentPlayerFinished');
			}
			break;
		}
	}
};
Tournament.prototype.postTransfer = function (table_source,table_dest,oseat,tseat) {
	function finish() {
		table_dest.Lock.writeLock(function (release) {
			if (table_dest.state == 'tsIdle') {
				var events = [];
				table_dest.stateMachine(function (events) {
					console.log('events:%j',events);
					table_dest.broadcastStatus(null,true,events);
					release();
				},null,{silent:true},events,0);
			} else {
				release();
			}
		});
	}
	table_source.Lock.writeLock(function (release) {
		table_source.paused = false;
		if (table_source.state == 'tsIdle') {
			var events = [];
			table_source.stateMachine(function (events) {
				console.log('events:%j',events);
				table_source.broadcastStatus(null,true,events);
				release();
				finish();
			},null,{silent:true},events,0);
		} else {
			release();
			finish();
		}
	}.bind(this));
};
Tournament.prototype.countPlayers = function (tbl) {
	var count = 0;
	for (var x=0; x<tbl.members.length; x++) {
		if (!tbl.members[x]) continue;
		count++;
	}
	return count;
};
TournamentCore.prototype.join = function (tournid,userid,nick,cb) {
	this.commonLock.writeLock(function (release) {
		this.getByIdUnlocked(tournid,function (err,tourn) {
			if (tourn.obj.state != 'tnsOpen') {
				return cb('notOpen');
			}
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
				tourn.obj.save(function (err,doc,rows) {
					//console.log('%s saved - join',new Date());
					release();
					tourn.emit('users_changed',tourn,userid);
					core.emit('users_changed',tourn);
					cb('OK',tourn);
				}.bind(this));
			}
		}.bind(this));
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
			if (tourn.obj.state != 'tnsOpen') {
				return cb('notOpen');
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
				tourn.emit('users_changed',tourn,userid);
				core.emit('users_changed',tourn);
				cb('OK',tourn);
			}.bind(this));
		}.bind(this));
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
		var now = Date.now() / 1000;
		var timeleft = row.start_time - now - 30;
		//console.log('row0 is %d %j',timeleft,row);
		if (timeleft < 0) this.checkTournaments(cb);
		else {
			//console.log('%d now',now);
			//console.log('%d goal',row.start_time);
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
	assert.equal(this.commonLock.readers,-1);
	models.Tournament.find({state:'tnsOpen'},{state:1}).sort({start_time:1}).limit(1).exec(function (err,rows) {
		if (rows.length != 1) return cb(); // nothing found
		this.getByIdUnlocked(rows[0]._id,function (err,tourn) {
			var row = tourn.obj; // FIXME, replace references
			var now = Date.now() / 1000;
			var timeleft = row.start_time - now - 30;
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
	}.bind(this));
}
TournamentCore.prototype.startTournament = function (row,cb) {
	console.log('%s starting tournament',new Date());
	assert.equal(this.commonLock.readers,-1);
	this.getByIdUnlocked(row._id,function (err,tourn) {
		models.TournamentLog.create({tournament_id:tourn.obj._id},function (err,doc) {
			tourn.log = doc;
		});
		tourn.startTime = Date.now();
		tourn.final_table = false;
		assert.equal(typeof tourn.obj.blind_schedule.LevelLength,'number');
		var table_count = tourn.obj.registered_players / tourn.obj.seats_per_table;
		console.log('need %d tables',table_count);
		var todo = [];
		myutils.shuffle(tourn.obj.players);
		tourn.obj.markModified("players");
		for (var i=0; i<table_count; i++) {
			var doc = {game_type:tourn.obj.gametype, blinds:'gb5x10', seats:tourn.obj.seats_per_table, gamename:''+(i+1), game_limit:tourn.obj.limit, buyin_min: 10, buyin_max:20, rake:0, rotation:0, hands:0, tournament:tourn.obj._id};
			todo.push(doc);
		}
		tourn.obj.state = 'tnsStarting';
		var tableids = [];
		async.eachSeries(todo,function (doc,cb) {
			models.Game.create(doc,function (err,game) {
				console.log('made %j',game);
				Game.getGame(game._id,function (err,gameout) {
					console.log('got game %s %s',gameout.id,gameout.nick);
					tourn.tables.push(gameout);
					tableids.push(gameout.id);
					cb();
				});
			});
		},function () {
			// FIXME, async race?
			tourn.log.records.push({ type:'tableids', tableids:tableids });
			var tableindex = 0;
			function forceSitDown(user,cb) {
				if (tableindex >= tourn.tables.length) tableindex = 0;
				var tbl = tourn.tables[tableindex];
				tbl.Lock.writeLock(function (release) {
					var userOnline = false;
					if (global.activeUsers[user._id]) userOnline = true;
					var freeSeat = 0;
					while (tbl.members[freeSeat]) freeSeat++;
					//console.log('found seat %d in table "%s"',freeSeat,tbl.obj.gamename);
					assert(freeSeat < tbl.obj.seats);
					tbl.members[freeSeat] = { hand: new Hand(), status:'psOutOfHand', chips:user.chips, seat:freeSeat, sitOutNextRound:false, sittingOutRoundsCount:0, handsPlayed:0, muck:false };
					tbl.seats[freeSeat] = { userid: user._id };
					tourn.user_table_xref[user._id] = {table:tbl.obj._id, seat:freeSeat };
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
					var obj = { message:'tmtTournamentStart', duration:30 };
					async.each(tourn.tables,function (tbl,cb) {
						tbl.Lock.writeLock(function (release) {
							tbl.setMessage(obj);
							release();
							cb();
						});
					}.bind(this),function () {
						setTimeout(tourn.startGames.bind(tourn),obj.duration*1000);
						tourn.obj.save(function (err) {
							if (err) return console.log(err.red);
							this.emit('tournament_start',tourn.obj);
							tourn.emit('tournament_start',tourn);
							cb();
						}.bind(this));
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
	assert.equal(typeof out.LevelLength,'number');

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
