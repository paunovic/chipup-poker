"use strict";
/* global require,setTimeout,clearTimeout,module,Buffer,global,console */
var assert = require('assert');
var util = require('util');

var myutils = require('./myutils');
var Game = require('./game').Game;
var Club = require('./club').Club;
var codes = require('./ServerCodes');
var profiler = require('./profiler');
var models = require('./db').models;
var makeGameProtobuf = require('./game').makeGameProtobuf;
var pb = global.pb; // FIXME, hack?

function checkGameParams(gamename,seats,game_type,game_limit,buyin_min,buyin_max,blinds,regexLimits) {
	assert(regexLimits);
	if (!blinds) {
		global.log('invalid blinds');
		return true;
	}
	if (!game_type) {
		global.log('invalid game type');
		return true;
	}
	if (!game_limit) {
		global.log('missing game limit');
		return true;
	}
	if (!regexLimits.gamename.exec(gamename)) {
		global.log('invalid gamename');
		return true;
	}
	if ([2,3,4,5,6,7,8,9,10].indexOf(seats) == -1) {
		global.log('invalid seat count');
		return true;
	}
	var blind_levels = Game.decodeBlinds(blinds);
	if ((5 * blind_levels.big_blind) > buyin_min) {
		global.log('min too low',buyin_min);
		return true;
	}
	if (buyin_max < buyin_min) {
		global.log('max too low');
		return true;
	}
	if ((10*blind_levels.big_blind) > buyin_max) {
		global.log('max too low',buyin_max);
		return true;
	}
	return false;
}

module.exports.registerHandlers = function (handlers,regexLimits) {
	assert(regexLimits);
handlers[codes.scCloseGame] = function (args,token) {
	var params,id;
	try {
		params = pb.Parse(args,'Poker.CloseGameData');
		id = myutils.toMongoId(params.gameid);
		switch (params.timestamp) {
		case 'cgtCurrentHand':
			params.timestamp = 0;
			break;
		case 'cgtFiveMinutes':
			params.timestamp = 5*60;
			break;
		case 'cgtFifteenMinutes':
			params.timestamp = 15*60;
			break;
		default:
			throw 'invalid timestamp';
		}
	} catch (e) {
		this.error(e);
		return;
	}
	this.log('closing game: %j',params);
	models.Game.findOne({_id:id},function (err,gamerow) {
		if (err) {
			this.reply(0,"internal error");
			return;
		}
		if (!gamerow) {
			this.reply(0,"game not found");
			return;
		}
		Game.getGame(id,function (err,game) {
			if (!game.club.isOwner(this.userid)) {
				this.reply(0,'you dont own that club!');
				return;
			}
			game.obj = gamerow; // FIXME
			game.Lock.writeLock(function (release) {
				if (params.timestamp > 0) {
					game.setMessage({message:'tmtClosing',duration:params.timestamp});
					game.closeTimer = setTimeout(function () {
						game.Lock.writeLock(function (release2) {
							game.doClose(this,release2,gamerow);
						}.bind(this));
					}.bind(this),params.timestamp * 1000);
					game.closeTime = Date.now() + (params.timestamp * 1000);
					game.state2 = 'gsClosing';
					Game.clubBroadcastGameState(game,release);
				} else {
					game.closeTime = 0;
					game.doClose(this,release,gamerow);
				}
			}.bind(this));
		}.bind(this));
	}.bind(this));
};
handlers[codes.scCreateGame] = function (args,token) {
	var game_type,blinds,seats,clubid,gamename,params,game_limit;
	try {
		params = pb.Parse(args,'Poker.Game');
		clubid = myutils.toMongoId(params.club_mongoid);
		game_type = params.game_type;
		game_limit = params.game_limit;
		blinds = params.blinds;
		seats = params.seats;
		gamename = params.gamename;
		if (checkGameParams(gamename,seats,game_type,game_limit,params.buyin_min,params.buyin_max,blinds,regexLimits)) {
			this.log('invalid create game:%j',params);
			this.reply(0,"invalid params");
			return;
		}
	} catch (e) {
		this.error(e);
		return;
	}
	Club.getClubById(clubid,function (err,club) {
		if (err == 'not found') {
			this.reply(0,"club not found");
			return;
		}
		if (err) {
			this.reply(0,"internal error");
			return;
		}
		var doc = {game_type:game_type, blinds:blinds, seats:seats, clubseq:club.obj.seq, gamename:gamename, game_limit:game_limit, buyin_min:params.buyin_min, buyin_max:params.buyin_max,rake:0, rotation:0, hands:0};
		if (!club.isOwner(this.userid)) {
			this.reply(0,'your not owner');
			return;
		}
		doc.clubid = club.clubid;
		if (params.max_rake_per_hand) doc.max_rake_per_hand = params.max_rake_per_hand;
		models.Game.create(doc,function (err,game) {
			var x,key;
			if (err) {
				this.reply(0,"internal error");
				return;
			}
			this.log('inserted',game);
			var g = makeGameProtobuf(game);
			this.send(codes.srCreateGameOk,g,'Poker.Game');
			if (club.obj.is_private) {
				if (!club.obj.members) {
					token.tag += '-empty';
					token.stop();
					return;
				}
				token.tag += '-private';
				for (x=0; x<club.obj.members.length; x++) {
					var conn = global.activeUsers[club.obj.members[x]];
					if (!conn) continue;
					conn.send(codes.seGameCreate,g,'Poker.Game');
				}
				token.stop();
			} else {
				token.tag += '-public';
				for (key in global.activeUsers) {
					if (key === this) continue;
					global.activeUsers[key].send(codes.seGameCreate,g,'Poker.Game');
				}
				token.stop();
			}
		}.bind(this));
	}.bind(this));
};
handlers[codes.scFold] = function (args,token) {
	var token2 = profiler.start('fold-inner4'),id;
	try {
		var params = pb.Parse(args,'Poker.Game');
		id = myutils.toMongoId(params._id);
	} catch (e) {
		this.error(e);
		return;
	}
	Game.getGame(id,function (err,game) {
		if (!game) return;
		game.Lock.writeLock(function (release) {
			var x = game.findSeat(this);
			var seating = game.members[x];
			if (x != game.current_seat) {
				this.reply(0,'fold while not active player');
				console.log('fold fail 2');
				release();
				return;
			} else if (seating && seating.status == 'psInHand') {
				token2.stop(); // 3ms avg
				var token1 = profiler.start('fold-inner1');
				game.fold(x,function (events,offset) { // 36ms avg
					token1.stop();
					var token3 = profiler.start('fold-inner5');
					assert(events);
					if (game.current_seat >= 0) {
						game.startTimer(game.current_seat,offset);
					}
					game.broadcastStatus(null,true,events);
					token3.stop(); // 17ms avg
					token.stop(); // 61ms avg
					release();
				}.bind(this));
			} else {
				this.log('fold error',util.inspect(seating));
				release();
			}
		}.bind(this));
	}.bind(this));
};
handlers[codes.scTableSitOutNextHand] = function (args,token) {
	var params,id;
	try {
		params = pb.Parse(args,'Poker.TableBoolFlag');
		id = myutils.toMongoId(params.table_mongo_id);
	} catch (e) {
		this.error(e);
		return;
	}
	Game.getGame(id,function (err,game) {
		if (!game) return;
		game.Lock.writeLock(function (release) {
			var seatIdx = game.findSeat(this);
			if (seatIdx === -1) {
				this.send(codes.srNotSitting,{_id:game.obj._id},'Poker.Game');
				release();
				return;
			}
			if (['psInHand','psAllIn','psFolded','psOutOfHand'].indexOf(game.members[seatIdx].status) == -1) {
				this.reply(0,'you cant sitout if your out of play');
				release();
				return;
			}
			this.log('flag is %j, status:%s state:%s',params,game.members[seatIdx].status);
			if ((game.state == 'tsIdle') && (['psInHand','psOutOfHand'].indexOf(game.members[seatIdx].status) != -1) && params.flag && game.club) {
				this.log('going out of play');
				game.members[seatIdx].status = 'psOutOfPlay';
				game.clearDealTimer(); // FIXME, it may stop dealing when others are waiting?
				game.members[seatIdx].sitOutNextRound = false;
				game.members[seatIdx].sitOutBB = false;
				game.updateMongoState({members:true},function () {
					game.broadcastStatus(null,true,[]);
				});
			} else if (game.tourn && (game.state == 'tsIdle') && params.flag) {
				game.members[seatIdx].autoplay = true;
				game.broadcastStatus(null,true,[]);
			} else if (('psOutOfHand' == game.members[seatIdx].status) && params.flag && game.club) {
				game.members[seatIdx].status = 'psOutOfPlay';
				game.broadcastStatus(null,true,[]);
			} else {
				game.members[seatIdx].sitOutNextRound = params.flag;
			}
			token.stop();
			release();
		}.bind(this));
	}.bind(this));
};
handlers[codes.scPutChips] = function (args,token) {
	var params,id;
	try {
		params = pb.Parse(args,'Poker.PutChips');
		id = myutils.toMongoId(params.table_mongo_id);
	} catch (e) {
		this.error(e);
		return;
	}
	delete params.table_mongo_id;
	this.log('putChips %j',params);
	var token2 = profiler.start('putChips-inner3');
	var token6 = profiler.start('putChips-inner6'); // includes writeLock callback if its unlocked
	Game.getGame(id,function (err,game) {
		if (!game) return;
		game.Lock.writeLock(function (release) {
			token2.stop();
			if (params.current_state != game.state) {
				this.reply(0,'state mismatch');
				release();
				return;
			}
			var token5 = profiler.start('putChips-inner5');
			var seat = game.findSeat(this);
			if (seat != game.current_seat) {
				this.reply(0,'putchips while not active player');
				console.log('putChips fail 2 %d %d',seat,game.current_seat);
				release();
				return;
			}
			game.putChips(this,params.chip_amount,function (events,offset){
				assert(game.members[seat].chips >= 0);
				if (['tsWinning'].indexOf(game.state) == -1) {
					game.startTimer(game.current_seat,offset);
				}
				var token4 = profiler.start('putChips-inner4-2');
				game.broadcastStatus(null,true,events);
				token4.stop();
				token.stop();
				release();
				game.checkDelayedLeave();
			}.bind(this));
			token5.stop();
		}.bind(this));
	}.bind(this));
	token6.stop();
};
handlers[codes.scTableSitOutNextBB] = function (args) {
	var params,id;
	try {
		params = pb.Parse(args,'Poker.TableBoolFlag');
		id = myutils.toMongoId(params.table_mongo_id);
	} catch (e) {
		this.error(e);
		return;
	}
	Game.getGame(id,function (err,game) {
		if (!game) return;
		var seatIdx = game.findSeat(this);
		if (seatIdx === undefined) {
			this.send(codes.srNotSitting,{_id:game.obj._id},'Poker.Game');
			return;
		}
		if (['psInHand','psAllIn','psFolded','psOutOfHand'].indexOf(game.members[seatIdx].status) == -1) {
			this.reply(0,'you cant sitout if your out of play');
			return;
		}
		game.members[seatIdx].sitOutBB = params.flag;
	}.bind(this));
};
handlers[codes.scTablePlayNow] = function (args,token) {
	var id;
	try {
		var params = pb.Parse(args,'Poker.Game');
		id = myutils.toMongoId(params._id);
	} catch (e) {
		this.error(e);
		return;
	}
	Game.getGame(id,function (err,game) {
		if (!game) return;
		if (game.state2 == 'gsClosed') return;
		game.Lock.writeLock(function (release) {
			function finish(events) { // teDeal
				game.updateMongoState({members:true},function () {
					game.broadcastStatus(null,true,events);
					token.stop();
					release();
				});
			}
			var seatIdx = game.findSeat(this);
			if (seatIdx === -1) {
				this.send(codes.srNotSitting,{_id:game.obj._id},'Poker.Game');
				release();
				return;
			}
			if (game.members[seatIdx].chips === 0) {
				this.reply(0,'you dont have enough chips');
				release();
				return;
			}
			game.members[seatIdx].sitOutNextRound = false;
			game.members[seatIdx].sitOutBB = false;
			game.members[seatIdx].autoplay = false;
			if (game.members[seatIdx].status != 'psOutOfPlay') {
				finish([]);
				return;
			}
			if (game.club && game.club.isSuspended(this.userid)) {
				game.standUp(this,function (folded,events2,offset) {
					game.broadcastStatus(null,true,events2);
					release();
				}.bind(this));
				return;
			}
			game.members[seatIdx].status = 'psOutOfHand';
			//game.members[seatIdx].sitTime = Date.now();
			if (game.state == 'tsIdle') {
				if (!game.dealTimer) {
					game.dealTimer = setTimeout(function () {
						game.dealTimer = null;
						game.Lock.writeLock(function (release) {
							game.stateMachine(function (events) {
								game.broadcastStatus(null,true,events);
								release();
							}.bind(this),null,{silent:true},[],0);
						}.bind(this));
					}.bind(this),5000);
					finish([]);
				} else {
					game.log('waiting for deal timer');
					finish([]);
				}
			} else finish([]);
		}.bind(this));
	}.bind(this));
};
handlers[codes.scShowCards] = function (args,token) {
	var id;
	try {
		var params = pb.Parse(args,'Poker.Game');
		id = myutils.toMongoId(params._id);
	} catch (e) {
		this.error(e);
		return;
	}
	Game.getGame(id,function (err,game) {
		if (!game) return;
		game.Lock.writeLock(function (release) {
			if (game.state != 'tsWinning') {
				this.reply(0,'the game isnt over yet '+game.state);
				this.log('state was %s',game.state);
				release();
				return;
			}
			var seatIdx = game.findSeat(this);
			if (seatIdx === undefined) {
				this.send(codes.srNotSitting,{_id:game.obj._id},'Poker.Game');
				release();
				return;
			}
			if (game.members[seatIdx].can_show) {
				game.members[seatIdx].muck = false;
				game.history.players[seatIdx].muck = false;
				game.broadcastStatus(this,true,[]);
				game.members[seatIdx].can_show = false;
				game.cardsShown = true;
			} else {
				this.reply(0,'you cant show');
			}
			token.stop();
			release();
		}.bind(this));
	}.bind(this));
};
	handlers[codes.scTableJoin] = function (args,token) {
		var params = pb.Parse(args,'Poker.Game'),id;
		try {
			id = new myutils.toMongoId(params._id);
		} catch (e) {
			this.error(e);
			return;
		}
		this.log('table join',id);
		Game.getGame(id,function (err,game) {
			assert.ifError(err);
			if (!game) {
				this.reply(0,'invalid gameid');
				return;
			}
			if (game.state2 == 'gsClosed') return;
			game.Lock.writeLock(function (release) {
				var x;
				function dojoin() {
					game.join(this,function () {
						var events = [];
						if (['tsFlop','tsTurn','tsRiver'].indexOf(game.state) != -1) {
							var cards0 = game.flops[0].cards;
							var cards1;
							if (game.flops[1]) cards1 = this.flops[1].cards;
							if (['tsTurn','tsRiver'].indexOf(game.state) != -1) {
								cards0 = cards0.concat(game.turns[0].cards);
								if (game.turns[1]) cards1 = cards1.concat(game.turns[1].cards);
							}
							if (game.state == 'tsRiver') {
								cards0 = cards0.concat(game.rivers[0].cards);
								if (game.rivers[1]) cards1 = cards1.concat(game.rivers[1].cards);
							}
							var ev = {cards:[new Buffer(cards0)]};
							if (cards1) ev.cards[1] = new Buffer(cards1);
							events.push(game.makeEvent('teExistingCards',ev));
						}
						var status = game.getTableStatus(this,true,events);
						this.send(codes.seTableStatus,status,'Poker.TableStatus');
						release();
						token.stop();
					}.bind(this));
				}
				if (game.club) {
					this.log('game info',game.obj.clubid);
					var club = game.club.obj; // FIXME
					if (club.suspended) {
						for (x=0; x<club.suspended.length; x++) {
							if (myutils.compareObjectID(club.suspended[x],this.userid)) {
								this.reply(0,'your suspended in that club'); // FIXME
								release();
								return;
							}
						}
					}
					if (!myutils.compareObjectID(this.userid,club.owner) && (!club.members || !myutils.containsObjectID(club.members,this.userid)) && club.is_private) {
						this.log('i am not a member');
						this.reply(0,'your not a member of that club'); // FIXME, bots rely on this error
						release();
					} else {
						dojoin.call(this);
					}
				} else if (game.tournament) {
					dojoin.call(this);
				} else {
					assert(false);
				}
			}.bind(this));
		}.bind(this));
	};
	handlers[codes.scTableLeave] = function (args,token) {
		var params = pb.Parse(args,'Poker.Game'),id;
		try {
			id = new myutils.toMongoId(params._id);
		} catch (e) {
			return;
		}
		delete params._id;
		Game.getGame(id,function (err,game) {
			assert.ifError(err);
			if (!game) {
				this.reply(0,'invalid gameid');
			} else {
				if (!game.users[this.userid]) {
					this.reply(0,'your not at the table');
					return;
				}
				if (game.tournament) {
					var seatIdx = game.findSeat(this);
					if (seatIdx == -1) {
						game.leave(this,'protocol',function () {
							token.stop();
						});
					} else {
						this.reply(0,'you cant run away!');
						token.stop();
					}
				} else {
					game.leave(this,'protocol',function () {
						token.stop();
					});
				}
			}
		}.bind(this));
	};
	handlers[codes.scTableSit] = function (args,token) {
		var params,id;
		try {
			params = pb.Parse(args,'Poker.TableSit');
			id = new myutils.toMongoId(params.game_id);
		} catch (e) {
			this.log('params where %j',params);
			this.error(e);
			return;
		}
		delete params.game_id;
		Game.getGame(id,function (err,game) {
			assert.ifError(err);
			if (!game) {
				this.reply(0,'invalid gameid');
				return;
			}
			if (game.state2 == 'gsClosed') return;
			if (game.tournament) {
				this.reply(0,'no sitting here!');
				return;
			}
			if (params.seat_index === undefined) {
				this.reply(0,'seat index missing');
				return;
			}
			if (game.club.isSuspended(this.userid)) return;
			var temp = this.userid;
			game.Lock.writeLock(function (release) {
				if (temp != this.userid) {
					this.reply(0,'sit error 1');
					release();
					return;
				}
				if (this.state != 2) {
					this.log('sit error 2');
					release();
					return;
				}
				if (game.state2 == 'gsClosed') {
					release();
					return;
				}
				if (!game.users[this.userid]) {
					this.reply(0,'your not at the table');
					release();
					return;
				}
				var seatIdx = game.findSeat(this);
				if (seatIdx != -1) {
					this.reply(0,'your already sitting');
					token.stop();
					release();
					return;
				}
				game.sitDown(this,params,function (sucess,events) {
					if (sucess) {
						game.broadcastStatus(this,true,events); // sendEvent
						var status = game.getTableStatus(this,true,events);
						this.send(codes.srTableSitOk,status,'Poker.TableStatus');
						this.sendClubStatus(game.club,game);
					}
					token.stop();
					release();
				}.bind(this));
			}.bind(this));
		}.bind(this));
	};
	handlers[codes.scTableStandUp] = function (args,token) {
		var params = pb.Parse(args,'Poker.Game'),once=true,id;
		try {
			id = myutils.toMongoId(params._id);
		} catch (e) {
			global.log('params to scTableStandUp where %j',params);
			//this.error(e);
			return;
		}
		Game.getGame(id,function (err,game) {
			assert.ifError(err);
			if (!game) return;
			game.Lock.writeLock(function (release) {
				var x = game.findSeat(this),token2,seating = game.members[x];
				var queue_position = game.sitQueue.indexOf(this.userid);
				if ((x == -1) && (queue_position != -1)) {
					game.sitQueue.splice(queue_position,1);
					this.send(codes.seTableStatus,game.getTableStatus(this,null,[]),'Poker.TableStatus');
					release();
					return;
				}
				if (!seating) {
					this.log('standup error %d',x);
					release();
					return;
				}
				if (game.tournament) {
					this.reply(0,'you cant quit!');
					release();
					return;
				}
				token2 = profiler.start('stand-inner1');
				game.standUp(this,function (folded,events,offset) {
					var x,havechips=0;
					assert(once);
					once = false;
					this.log('2events are %j',events);
					if (folded && (game.current_seat >= 0)) {
						game.startTimer(game.current_seat,offset);
					}
					this.send(codes.srTableStandUpOk,game.getTableStatus(this,true,events),'Poker.TableStatus');
					for (x=0; x<game.members.length; x++) {
						if (!game.members[x]) {
							continue;
						}
						if (game.members[x].status == 'psOutOfPlay') continue;
						if (game.members[x].disconnected) continue;
						if (game.members[x].chips > 0) {
							game.log('standup found one %d %s %d',x,game.members[x].status,game.members[x].chips);
							havechips++;
						}
					}
					if (havechips < 2) {
						clearTimeout(game.dealTimer);
						game.dealTimer = null;
						game.log('cleared deal timer');
					}
					game.broadcastStatus(this,true,events);
					token.stop();
					token2.stop();
					release();
				}.bind(this));
			}.bind(this));
		}.bind(this));
	};
	handlers[codes.scTableAddOn] = function (args,token) {
		var params,id;
		try {
			params = pb.Parse(args,'Poker.TableSit');
			if (params.chips < 1) {
				this.reply(0,'you cant buyout');
				return;
			}
			id = new myutils.toMongoId(params.game_id);
		} catch (e) {
			this.error(e);
			return;
		}
		delete params.game_id;
		Game.getGame(id,function (err,game) {
			game.Lock.writeLock(function (release) {
				var seatIdx = game.findSeat(this);
				if (seatIdx === -1) {
					this.send(codes.srNotSitting,{_id:game.obj._id},'Poker.Game');
					release();
					return;
				}
				if (['psOutOfPlay','psFolded','psOutOfHand'].indexOf(game.members[seatIdx].status) === -1) {
					this.reply(0,'your not out of play!');
					release();
					return;
				}
				if ((params.chips + game.members[seatIdx].chips) > game.obj.buyin_max) {
					this.send(codes.srTableAddonOverLimit,game.getTableStatus(this,false,[]),'Poker.TableStatus');
					release();
					return;
				}
				if (game.club) {
					assert.equal(this.state,2);
					game.club.getPotentialLosses(this.userid,function (maxLosses,unlimited,limit) {
						console.log(arguments);
						if (unlimited) game.AddOn(this,params.chips);
						else {
							if ((params.chips + (maxLosses*-1)) > limit) {
								this.send(codes.srTableAddonOverLimit,game.getTableStatus(this,false,[]),'Poker.TableStatus');
							} else game.AddOn(this,params.chips);
						}
						token.stop();
						release();
					}.bind(this));
				} else {
					this.reply(0,'trying to cheat eh?');
					token.stop();
					release();
				}
			}.bind(this));
		}.bind(this));
	};
	handlers[codes.scTableSitOpen] = function (args,token) {
		var params,id;
		try {
			params = pb.Parse(args,'Poker.Game');
			id = myutils.toMongoId(params._id);
		} catch (e) {
			this.error(e);
			return;
		}
		Game.getGame(id,function (err,game) {
			assert.ifError(err);
			this.sendClubStatus(game.club,game);
		}.bind(this));
	};
	handlers[codes.scTableSitClose] = function (args,token) {
		var params,id;
		try {
			params = pb.Parse(args,'Poker.Game');
			id = myutils.toMongoId(params._id);
		} catch (e) {
			this.error(e);
			return;
		}
		Game.getGame(id,function (err,game) {
			assert.ifError(err);
			game.tableSitClose(this);
		}.bind(this));
	};
	handlers[codes.scSplitTableCards] = function (args,token) {
		var id,params;
		try {
			params = pb.Parse(args,'Poker.TableBoolFlag');
			id = myutils.toMongoId(params.table_mongo_id);
		} catch (e) {
			this.error(e);
			return;
		}
		Game.getGame(id,function (err,game) {
			if (!game) return;
			game.Lock.writeLock(function (release) {
				var seatIdx = game.findSeat(this);
				if (seatIdx === undefined) {
					this.reply(0,'your not sitting');
					release();
					return;
				}
				game.members[seatIdx].want_split = params.flag;
				console.log("seat %d setting split to %j",seatIdx,params.flag);
				token.stop();
				release();
			}.bind(this));
		}.bind(this));
	};
};
