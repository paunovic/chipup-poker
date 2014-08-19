"use strict";

var assert = require('assert');
var util = require('util');
var async = require('async');

var activeGames,activeUsers,sharedconfig;

var ReadWriteLock = require('./lock'); // FIXME, send them a PR?, fork it?, it came from the rwlock npm package
var profiler = require('profiler');
var dag = require('./dag/build/Release/dag');
var omaha2 = require('./dag2/omaha');
dag.init();
var getGameLock = new ReadWriteLock();

module.exports.makeGameProtobuf = makeGameProtobuf;
module.exports.Game = Game;

var Pot = require('./pot').Pot;
var deck = require('./deck');
var Deck = deck.Deck;
var Hand = deck.Hand;
var Club;
var myutils = require('./myutils');
var mdb = require('./db');
var models = mdb.models;
var error = require('./error');
var Tournament = require('./tournament');

var lazy = {};
lazy.__defineGetter__('user',function () {
	return require('./user');
});
lazy.__defineGetter__('ClientSocket',function () {
	return lazy.user.ClientSocket;
});

function makeGameProtobuf(g) {
	// FIXME, remove this entirely?
	assert.equal(g._id.toString().length,24);
	var gameobj = activeGames[g._id];
	if (gameobj) {
		g.sitting = gameobj.sittingCount();
		g.state = gameobj.state2;
		if (g.state == 'gsClosing') g.closetime = gameobj.closeTime;
	} else if (g.state2) {
		g.state = g.state2;
	} else {
		g.state = 'gsEmpty';
	}
	g.club_mongoid = g.clubid; // FIXME, rename this somewhere
	switch (g.blinds) {
	case 'gb1x2':
		g.small_blind = 100;
		g.big_blind = 200;
		break;
	case 'gb5x5':
		g.small_blind = 500;
		g.big_blind = 500;
		break;
	case 'gb5x10':
		g.small_blind = 500;
		g.big_blind = 1000;
		break;
	case 'gb10x25':
		g.small_blind = 1000;
		g.big_blind = 2500;
		break;
	case 'gb25x50':
		g.small_blind = 2500;
		g.big_blind = 5000;
		break;
	case 'gb50x100':
		g.small_blind = 5000;
		g.big_blind = 10000;
		break;
	}
	return g;
}
function Game(obj) {
	this.gameinactive = false;
	this.users = {}; // all users, even not sitting
	this.members = []; // all users, as seen by the users
	this.seats = []; // internal data for seats
	this.reconnect = []; // array of ObjectId's for offline members
	this.timebanks = {}; // timebank data for all users who have visited the table
	this.obj = obj;
	this.id = obj._id;
	activeGames[this.id] = this;
	this.state = 'tsIdle';
	this.dealer = -1;
	this.current_seat = -1;
	this.bets = [];
	this.message = [];
	for (var x=0; x<this.obj.seats; x++) this.bets[x] = 0;
	this.pots = [ new Pot(this) ];
	this.minBet = 0;
	this.minimum_raise = 0;
	this.log('pots initialized to zero');
	this.Lock = new ReadWriteLock();
	this.omaha = this.obj.game_type == 'gtOmaha';
	this.lastplayer = [];
	this.autoDelete = false;
	this.ignoreOffline = true;
	this.rotation = this.obj.rotation;
	this.lastCashout = {};
	switch (this.obj.blinds) {
	case 'gb1x2':
		this.obj.small_blind = 100;
		this.obj.big_blind = 200;
		break;
	case 'gb5x5':
		this.obj.small_blind = 500;
		this.obj.big_blind = 500;
		break;
	case 'gb5x10':
		this.obj.small_blind = 500;
		this.obj.big_blind = 1000;
		break;
	case 'gb10x25':
		this.obj.small_blind = 1000;
		this.obj.big_blind = 2500;
		break;
	case 'gb25x50':
		this.obj.small_blind = 2500;
		this.obj.big_blind = 5000;
		break;
	case 'gb50x100':
		this.obj.small_blind = 5000;
		this.obj.big_blind = 10000;
		break;
	}

	if (this.obj.game_type == 'gtRotationNLHPLO') {
		this.omaha = this.rotation > this.obj.seats;
		if (this.omaha) {
			this.game_limit = 'glPotLimit';
		} else {
			this.game_limit = 'glNoLimit';
		}
	} else {
		this.game_limit = this.obj.game_limit;
	}

	if (obj.state2) this.state2 = obj.state2;
	else this.state2 = 'gsActive';
}
Game.init = function (input) {
	assert(input);
	activeGames = input;
	global.activeGames = activeGames; // FIXME, init this elsewhere
	global.util = require('util');
	activeUsers = global.activeUsers;
	sharedconfig = global.sharedconfig; // FIXME
	Club = require('./club').Club;
};
Game.makeGameProtobuf = makeGameProtobuf;
Game.hands = 0;
Game.prototype.doClose = function (conn,cb,gamerow) {
	if (this.state == 'tsIdle') this.close(this,cb);
	else {
		this.autoDelete = true;
		this.state2 = 'gsClosing';
		clubBroadcastGameState(gamerow.clubid,gamerow,cb);
	}
};
Game.prototype.clearDealTimer = function () {
	var havechips = 0;
	for (var x=0; x<this.members.length; x++) {
		if (!this.members[x]) {
			continue;
		}
		if (this.members[x].status == 'psOutOfPlay') continue;
		if (this.ignoreOffline && this.members[x].disconnected) continue;
		if (this.members[x].chips > 0) {
			this.log('standup found one %d %s %d',x,this.members[x].status,this.members[x].chips);
			havechips++;
		}
	}
	if (havechips < 2) {
		clearTimeout(this.dealTimer);
		this.dealTimer = null;
		this.log('cleared deal timer');
	}
};
function clubBroadcastGameState(game,cb) {
	game.club.seGameChanged(game,cb);
}
Game.clubBroadcastGameState = clubBroadcastGameState;
Game.prototype.close = function(conn,cb) {
	models.Game.findOneAndUpdate({_id:this.id},{$set:{state2:'gsClosed'}},function (err,ret) {
		error.handleError(err);
		if (err) {
			conn.reply(0,"internal error");
			return;
		}
		this.state2 = 'gsClosed';
		this.log('closed game %s %d',err,ret);
		
		var count = 0;
		for (var key in this.users) {
			count++;
			this.log('Game.close key:%s count:%d',key,count);
		}
		if (count == 0) {
			this.log('self-deleting');
			delete activeGames[this.id];
			this.doDelete();
		} else {
			this.deleteTimer = setTimeout(this.doDelete.bind(this),5 * 60 * 1000);
			this.club.seGameChanged(this,cb);
		}
	}.bind(this));
};
Game.prototype.getLimit = function (seat) {
	var x;
	//this.log('getLimit type %s %j',this.game_limit,this.bets);

	var canplay = 0;
	for (x=0; x<this.members.length; x++) {
		if (!this.members[x]) continue;
		if (this.members[x].status == 'psInHand') {
			canplay++;
		}
	}

	if (canplay == 1) return this.minBet;

	if (typeof this.bets[seat] != 'number') this.bets[seat] = 0;
	var oldbet = this.bets[seat];
	if (this.game_limit == 'glNoLimit') {
		return oldbet + this.members[seat].chips;
	}

	var pot = 0;
	for (x=0; x<this.pots.length; x++) {
		pot += this.pots[x].getPostRake(this.rake);
	}
	for (var x=0; x<this.bets.length; x++) {
		if (typeof this.bets[x] != 'number') this.bets[x] = 0;
		pot += this.bets[x];
	}
	var pottotal = pot + (this.minBet - oldbet);
	var maxbet = pottotal + this.minBet;
	this.log('pot:%d pottotal:%d maxbet:%d oldbet:%d',pot,pottotal,maxbet,oldbet);
	if (maxbet > this.members[seat].chips) return oldbet + this.members[seat].chips;
	return maxbet;
};
Game.prototype.log = function log(format) {
	var out = Array.prototype.slice.call(arguments);
	if (format.indexOf('%') != -1) {
		out = [ util.format.apply(util,out) ];
	}
	out.unshift(this.handid);
	process.send({type:'game',name:this.obj.gamename,ts:new Date().toString(),objects:out});
	var obj = new mdb.models.DebugLogs({type:'game',gameid:this.obj._id,name:this.obj.gamename,objects:out});
	if (this.club) obj.clubid = this.club.clubid;
	obj.save(function () {});
};
Game.prototype.AddOn = function AddOn(conn,chips) {
	var seat = this.findSeat(conn);
		conn.boughtin += chips;
		this.club.buyin(conn.userid,chips);
		this.logEvent('geCashin',conn.userid,chips);
		this.members[seat].chips += chips;
		this.updateBuyin(seat,chips,function () {
			var status = this.getTableStatus(conn,false,[]);
			conn.send(codes.srTableAddonOk,status,'Poker.TableStatus');
			this.broadcastStatus(conn,null,[]);
		}.bind(this));
};
Game.prototype.edited = function edited(params) {
	// FIXME, more fields, also now acts as a cache for seGameChange/seGameDelete
	this.obj.seats = params.seats;
	this.obj.small_blind = params.small_blind;
	this.obj.big_blind = params.big_blind; // FIXME
	this.obj.buyin_min = params.buyin_min;
	this.obj.buyin_max = params.buyin_max;
	this.obj.game_limit = params.game_limit;
	this.obj.game_type = params.game_type;
	this.omaha = this.obj.game_type == 'gtOmaha';
};
Game.prototype.join = function join(conn,cb) {
	assert.equal(this.Lock.readers,-1);
	this.users[conn.userid] = conn;
	this.updateMongoState({users:true},cb);
};
Game.prototype.sitDown = function (conn,params,cb) {
	function finish() {
		this.club.seGameChanged(this,function () {
			this.club.buyin(conn.userid,params.chips);
			this.updateMongoState({members:true},function () {
				cb(true,events);
			});
		}.bind(this),conn);
	}
	function doSit() {
		this.members[params.seat_index] = { hand: new Hand(), status:'psOutOfPlay', chips:params.chips, seat:params.seat_index, sitOutNextRound:false, SittingOutRoundsCount:0, handsPlayed:0 };
		this.logEvent('geCashin',conn.userid,params.chips);
		if (!this.timebanks[conn.userid]) this.timebanks[conn.userid] = sharedconfig.max_timebank * 1000;
		this.seats[params.seat_index] = { conn:conn, userid:conn.userid };
		conn.boughtin += params.chips;
		if (this.bets[params.seat_index] == undefined) this.bets[params.seat_index] = 0;
		events.push(this.makeEvent('teSit',params.seat_index));
		this.updateBuyin(params.seat_index,params.chips,function () {
			finish.call(this);
		}.bind(this));
	}
	assert.equal(this.Lock.readers,-1);
	assert(conn.userid);
	var events = [];
	conn.log('sitting down',params);
	if ((params.seat_index < 0) || (params.seat_index >= this.obj.seats)) {
		conn.reply(0,'invalid seat index');
		cb(false,events);
		return;
	}
	if (this.seats[params.seat_index]) {
		conn.log('seat taken by',util.inspect(this.members[params.seat_index]),util.inspect(this.seats[params.seat_index]));
		conn.send(codes.srTableSitSeatTaken,this.getTableStatus(conn,null,[]),'Poker.TableStatus');
		cb(false,events);
	} else {
			conn.log('state:%d %s',conn.state,conn.userid);
			this.club.getPotentialLosses(conn.userid,function (maxLosses,unlimited,limit) {
				if (unlimited) this.log('unlimited user');
				else {
					this.log('max potential losses for this user:%d/%d while buying in at %d',(-1*maxLosses)/100,limit/100,params.chips/100);
					if (((maxLosses*-1)+params.chips) > limit) {
						conn.send(codes.srClubBalanceReached,this.getTableStatus(conn,null,[]),'Poker.TableStatus');
						cb(false,events);
						return;
					}
				}
				var obeymax = true;
				var min = this.obj.buyin_min * this.obj.big_blind;
				var max = this.obj.buyin_max * this.obj.big_blind;
				var lastcashout = 0;
				if (this.lastCashout[conn.userid]) {
					var last = this.lastCashout[conn.userid];
					var timediff = Date.now() - last.when;
					conn.log('last cashout %d vs %d age:%d',last.chips,params.chips,timediff/1000);
					if (timediff < (30 * 60 * 1000)) {
						if (params.chips < last.chips) {
							conn.send(codes.srTableBuyinLessThanCashout,{game_id:this.id,last_cashout:last.chips},'Poker.BuyinError');
							cb(false,events);
							return;
						}
						if (last.chips == params.chips) obeymax = false;
						lastcashout = last.chips;
					}
				}
				if (obeymax) {
					conn.log('checking that %d is between %d and %d',params.chips,min,max);
					if ((params.chips > max) || (params.chips < min)) {
						conn.send(codes.srInvalidTableBuyin,{game_id:this.id,last_cashout:lastcashout},'Poker.BuyinError');
						conn.log('buyin:%d min:%d max:%d',params.chips,min,max);
						cb(false,events);
						return;
					}
				}
				doSit.call(this);
			}.bind(this));
	}
};
Game.prototype.updateBuyin = function (seatIdx,buyin,cb) {
	var doc = { gameid:this.obj._id,userid:this.seats[seatIdx].userid, buyins:[buyin], hands:0 };
	var mods = { $push:{buyins:{
		$each:[buyin],
		$slice:-50
	}}};
	var key = {gameid:this.obj._id,userid:this.seats[seatIdx].userid};
	models.GameStats.findOne(key,function (err,row) {
		error.handleError(err);
		if (!row) {
			global.log('inserting %j',doc);
			models.GameStats.create(doc,finish.bind(this));
		} else {
			models.GameStats.findOneAndUpdate({_id:row._id},mods,finish.bind(this));
		}
		function finish(err) {
			error.handleError(err);
			this.handOver(function () {
				cb();
			});
		}
	}.bind(this));
};
Game.prototype.handOver = function (cb,handid) {
	if (this.club) this.club.handOver(this,cb);
	else if (this.tourn) {
		this.tourn.handOver(this,cb);
	} else cb();
	if (handid) {
		var gameRow = this.obj; // FIXME
		models.HandHistory.findOne({seq:handid}).lean(true).exec(function (err,historyRow) {
			assert.ifError(err);
			var savedCards = [];
			var keyid = 0;
			async.each(historyRow.players,function (player,cb) {
				if (!player) return cb();
				models.UserModel.findOne({_id:player._id},function (err,playerRow) {
					player.keyid = keyid++;
					player.nick = playerRow.displayname;
						if (player.cards) {
						savedCards[player.keyid] = new Buffer(player.cards);
					}
					player.origid = player._id;

					if (!player.muck && player.cards) player.cards = new Buffer(player.cards);
					else delete player.cards;
					cb();
				});
			},function () {
				historyRow.cards = new Buffer(historyRow.cards);
				var obj = {gameid:this.id, rows:[historyRow] };
				if (this.tournament) obj.tournament_id = this.obj.tournament;
				if (this.clubid) obj.club_id = this.clubid;
				for (var x in this.users) {
					for (var y=0; y<obj.rows[0].players.length; y++) {
						if (obj.rows[0].players[y]) {
							var key2 = obj.rows[0].players[y].keyid;
							if (obj.rows[0].players[y].rehide) {
								delete obj.rows[0].players[y].cards;
								obj.rows[0].players[y].rehide = false;
							}
							if (obj.rows[0].players[y].cards) continue;
							if (savedCards[key2]) {
								if (myutils.compareObjectID(obj.rows[0].players[y].origid,x)) {
									obj.rows[0].players[y].cards = savedCards[key2];
									obj.rows[0].players[y].rehide = true;
								}
							}
						}
					}
					this.users[x].send(codes.srHandHistoryMsg,obj,'Poker.HandHistoryReply');
				}
			}.bind(this));
		}.bind(this));
	}
}
Game.prototype.updateLeaveStats = function (seatIdx,force,cb) {
	if (!this.members[seatIdx].sitTime) {
		if (cb) cb();
		return;
	}
	var time = (Date.now() - this.members[seatIdx].sitTime) / 1000;
	assert(time > 0.001);
	var doc = { gameid:this.obj._id,userid:this.seats[seatIdx].userid, secondsplayed:time };
	var mods = { $inc:{secondsplayed:time}};
	var key = {gameid:this.obj._id,userid:this.seats[seatIdx].userid};
	models.GameStats.findOne(key,function (err,row) {
		error.handleError(err);
		if (!row) {
			global.log('inserting %j',doc);
			models.GameStats.create(doc,finish);
		} else {
			models.GameStats.findOneAndUpdate({_id:row._id},mods,finish);
		}
		function finish(err) {
			error.handleError(err);
			if (cb) cb();
		}
	});
};
Game.prototype.deal = function deal(cb,config,emptyseat) {
	var players = 0;
	//this.log(' pre rotation:%d omaha:%s limit:%s',this.rotation,this.omaha,this.game_limit);
	if (this.obj.game_type == 'gtRotationNLHPLO') {
		if (this.rotation == this.obj.seats) {
			this.omaha = true;
		} else if (this.rotation == (this.obj.seats*2)) {
			this.omaha = false;
			this.rotation = 0;
		}
		if (this.omaha) {
			this.game_limit = 'glPotLimit';
		} else {
			this.game_limit = 'glNoLimit';
		}
	}
	this.rotation++;
	//this.log('post rotation:%d omaha:%s limit:%s',this.rotation,this.omaha,this.game_limit);
	myutils.getNextSequence('handHistory',function (seq) {
		var x;
		this.handid = seq;
		if (this.tourn) this.updateBlinds();
		models.Game.findOneAndUpdate({_id:this.id},{$set:{lasthandid:seq, rotation:this.rotation}},function (err,res){});
		this.history = {moves:[],players:[],cards:[]};
		Game.hands = seq;
		var oldDealer = this.dealer;
		this.nextDealer();
		this.bets = [];
		this.balance_changes = [];
		for (x=0; x<this.obj.seats; x++) {
			this.bets[x] = 0;
			this.balance_changes[x] = 0;
		}
		this.addHistory({code:['teDealing'],seat:-1});

		var todo = [];

		var canplay = 0;
		for (x=0; x<this.members.length; x++) {
			if (!this.members[x]) continue;
			if (['psInHand','psOutOfHand'].indexOf(this.members[x].status) != -1) canplay++;
		}

		var sb = this.getNextSeat(oldDealer);
		var bb = this.getNextSeat(sb);
		if (bb < oldDealer) bb += this.obj.seats;
		for (x=0; x<this.members.length; x++) {
			if (!this.members[x]) continue;
			if (this.members[x].status == 'psOutOfPlay') {
				if (!emptyseat) this.members[x].SittingOutRoundsCount++;
				else this.members[x].SittingOutRoundsCount = 0;
				this.log('seat %d has sat out %d rounds',x,this.members[x].SittingOutRoundsCount);
				this.history.players[x] = { _id:this.seats[x].userid, seat:x, chips:this.members[x].chips, status:this.members[x].status };
				continue;
			}
			if (this.ignoreOffline && this.members[x].disconnected) {
				this.members[x].status = 'psOutOfPlay';
				continue;
			}
			if (this.members[x].chips == 0) {
				this.members[x].status = 'psOutOfPlay';
				this.updateLeaveStats(x);
				this.lastplayer[x] = this.seats[x].userid;
				continue;
			}
			if (this.members[x].status == 'psOutOfHand') {
				this.seats[x].conn.log('moving into hand %s %s %j',this.seats[x].userid,this.lastplayer[x],config);
				if (myutils.compareObjectID(this.seats[x].userid,this.lastplayer[x])) {
					this.members[x].status = 'psInHand';
				}
			}
			if (canplay < 3) { // for 2 player games, just allow all
			} else if (bb == -1) { // initial round
			} else if (sb == -1) {
			} else if (this.members[x].status == 'psInHand') {
			} else if ((oldDealer < bb) && (bb < x)) { // you are after BB
				this.log('XXX %d is after bb:%d',x,bb);
			/*} else if (x == oldDealer) {
				this.log('XXX %d is dealer %d %d',x,sb,bb);
				this.nextDealer();
				sb = this.getNextSeat(this.dealer);
				bb = this.getNextSeat(sb);
				if (bb < this.dealer) bb += this.obj.seats;
				continue;*/
			} else if ((oldDealer < x) && (x < bb) && (bb > this.obj.seats)) {
				this.log('XXX %d is between %d-%d, but should still get cards',x,oldDealer,bb);
				if (x == this.dealer) {
					this.nextDealer();
					todo[x] = 'forcedBB';
				}
			} else if ((oldDealer < x) && (x < bb)) {
				this.log('XXX %d is between %d-%d',x,oldDealer,bb);
				if (x == this.dealer) {
					this.nextDealer();
				}
				continue;
			} else {
				this.log('XXX dealer:%d x:%d(%s) sb:%d bb:%d',oldDealer,x,this.members[x].status,sb,bb);
			}
			this.members[x].SittingOutRoundsCount = 0;
			if (this.omaha) {
				//players++;
				this.deck.draw(4,this.members[x].hand);
			} else this.deck.draw(2,this.members[x].hand);
			players++;
			this.bets[x] = 0;
			this.members[x].handsPlayed++;
			if (this.members[x].status == 'psOutOfHand') {
				this.seats[x].conn.log('moving into hand %s %s %j',this.seats[x].userid,this.lastplayer[x],config);
				if (!myutils.compareObjectID(this.seats[x].userid,this.lastplayer[x])) {
					if (!this.headsup) {
						todo[x] = 'forcedBB';
					}
				}
			}
			this.members[x].status = 'psInHand';
			this.history.players[x] = { _id:this.seats[x].userid, seat:x, cards:this.members[x].hand.cards, chips:this.members[x].chips, muck:true, status:this.members[x].status };
			this.members[x].can_show = true;
			this.members[x].muck = true;
			this.balance_changes[x] = 0;
		}
		assert(players > 1,util.format('gamename:%s players:%d canplay:%d',this.obj.gamename,players,canplay));

		this.pots = [ new Pot(this) ];
		this.log('pots reset to zero');
		this.current_seat = this.dealer;

		this.small_blind = this.current_seat = this.getNextSeat(this.current_seat);
		if (this.headsup) this.small_blind = this.current_seat = this.getNextSeat(this.current_seat);
		if (!todo[this.current_seat]) todo[this.current_seat] = 'SB';
		
		this.big_blind = this.current_seat = this.getNextSeat(this.current_seat,null,true);
		if (!todo[this.current_seat]) todo[this.current_seat] = 'BB';

		this.current_seat = this.getNextSeat(this.current_seat);

		for (var seat = this.dealer, passed=0; passed < this.obj.seats; seat++, passed++) {
			seat = seat % this.obj.seats;
			//console.log('seat:%d passed:%d todo:%s',seat,passed,todo[seat]);
			if (todo[seat] == 'forcedBB') {
				if (this.members[seat].chips <= this.obj.big_blind) {
					this.addHistory({seat:seat,bet:this.members[seat].chips,code:['teForced','teBB','teAllIn']});
					this.setBet(seat,this.members[seat].chips);
					this.members[seat].status = 'psAllIn';
				} else {
					this.setBet(seat,this.obj.big_blind);
					this.addHistory({seat:seat,bet:this.obj.big_blind,code:['teForced','teBB']});
				}
			} else if (todo[seat] == 'SB') {
				if (this.members[seat].chips <= this.obj.small_blind) {
					this.addHistory({seat:seat,bet:this.members[seat].chips,code:['teSB','teAllIn']});
					this.setBet(seat,this.members[seat].chips);
					this.members[seat].status = 'psAllIn';
				} else {
					this.setBet(seat,this.obj.small_blind);
					this.addHistory({seat:seat,bet:this.obj.small_blind,code:['teSB']});
				}
			} else if (todo[seat] == 'BB') {
				if (this.members[seat].chips <= this.obj.big_blind) {
					this.addHistory({seat:seat,bet:this.members[seat].chips,code:['teBB','teAllIn']});
					this.setBet(seat,this.members[seat].chips);
					this.members[seat].status = 'psAllIn';
				} else {
					this.setBet(seat,this.obj.big_blind);
					this.addHistory({seat:seat,bet:this.obj.big_blind,code:['teBB']});
				}
			}
		}
		
		// hack to stop memory leak?
		models.GameState.findOne({_id:this.id},function (err,row) {
			error.handleError(err);
			this.stateRow = row;
			this.stateRow.moveCounter = 0;
			// </hack>
			this.state = 'tsPreFlop';
			if (this.club) this.real_rake = this.club.obj.rake;
			this.rake = 0;
			this.minimum_raise = this.obj.big_blind * 2;
			this.roundEnd();
			this.stateRow.deck = this.deck.cards;
			this.ranOut = false;
			this.flop = new Hand();
			this.turn = new Hand();
			this.river = new Hand();
			this.log('bcast 2');
		
			models.HandHistory.create({seq:seq,gameid:this.obj._id,moves:this.history.moves,players:this.history.players,rake:this.rake,dealer:this.dealer,current_game:this.omaha ? 'gtOmaha' : 'gtHoldem'},function (err,row) {
				this.log('hand made:%j',row);
				//this.broadcastStatus(null,null,[this.makeEvent('teDealing')]);
				//setTimeout(function () {
				var cards;
				if (this.omaha) cards = 4;
				else cards = 2;
				this.startTimer(this.current_seat,1500 + (players*50*cards)); // FIXME, run this later
				//this.stateMachine(function () {

				this.updateMongoState({members:true},function () {
					var events = [this.makeEvent('teDealing')];
					if (this.members[this.current_seat].autoplay) {
						this.broadcastStatus(null,null,events);
						setTimeout(function () {
							this.fold(this.current_seat,function (events2) {
								cb(events2);
							});
						}.bind(this),1500);
					} else cb(events);
				}.bind(this));
				//}.bind(this),
				//players * 100);
			}.bind(this));
		}.bind(this));
	}.bind(this));
};
Game.prototype.clearCanShow = function () {
	for (var x=0; x<this.members.length; x++) {
		if (!this.members[x]) continue;
		if (this.members[x].status == 'psFolded') this.members[x].can_show = false;
	}
};
Game.prototype.addHistory = function (obj,winnercount) {
	if (obj.code[0] == 'teWinning') {
		this.history.WinnerPotData = obj.WinnerPotData;
		this.history.winnercount = winnercount;
	}
	this.history.moves.push(obj);
};
Game.prototype.setBet = function (seat,bet) {
	var oldbet = this.bets[seat];
	this.bets[seat] = bet;
	this.members[seat].chips -= (bet - oldbet);
	if (bet > this.minBet) {
		this.minimum_raise = bet - this.minBet;
		this.log('min raise A %d',this.minimum_raise);
		this.minBet = bet;
	}
};
Game.prototype.eatChips = function (seat,chips,cb) {
	this.pots[0].value += chips;
	models.UserModel.findOneAndUpdate({_id:this.members[seat].conn.userid},{ $inc:{chips:-chips}},function (err) {
		error.handleError(err);
		this.members[seat].conn.log('lost chips',err,res,chips);
		models.Game.findOneAndUpdate({_id:this.obj._id},{$inc:{pot:chips}},function (err,res) {
			assert(res == 1);
			this.members[seat].conn.log('pot for game went up to ',this.pots);
			cb();
		}.bind(this));
	}.bind(this));
};
Game.prototype.getNextSeat = function (current,validstates) {
	if (!validstates) validstates = ['psInHand','psAllIn'];
	var limit = 100;
	function getNextSatIn(x) {
		x++;
		while (!this.members[x]) {
			if (limit-- < 0) {
				this.log('giving up next');
				return -1;
			}
			x++;
			if (x >= this.obj.seats) x = 0;
			//this.lastplayer[x] = null;
		}
		return x;
	}
	current = getNextSatIn.call(this,current);
	if (current < 0) return -1;
	while (validstates.indexOf(this.members[current].status) == -1) {
		current = getNextSatIn.call(this,current);
		if (current < 0) return -1;
		if (limit-- < 0) return -1;
	}
	return current;
};
Game.prototype.getPrevSeat = function (current) {
	var limit = 100;
	function getPrevSatIn(x) {
		x--;
		if (x < 0) x = this.obj.seats;
		while (!this.members[x]) {
			if (limit-- < 0) {
				this.log('giving up prev');
				return -1;
			}
			x--;
			if (x < 0) x = this.obj.seats;
		}
		return x;
	}
	current = getPrevSatIn.call(this,current);
	if (current < 0) return -1;
	while (['psInHand','psAllIn'].indexOf(this.members[current].status) == -1) {
		current = getPrevSatIn.call(this,current);
		if (current < 0) return -1;
		if (limit-- < 0) return -1;
	}
	return current;
};
Game.prototype.fold = function fold(seat,cb1) {
	var token = profiler.start('fold-inner1.1');
	var x;
	assert.equal(this.Lock.readers,-1);
	this.stopTimer(seat);
	var seatObj = this.members[seat];
	var priv = this.seats[seat];
	this.log('fold',seat,this.state);
	this.clearCanShow();
	function finish(events,offset) {
		assert(events);
		assert.equal(typeof offset,'number');
		finish2.call(this,events,offset);
	}
	function finish2(events,offset) {
		assert.equal(typeof offset,'number');
		var token2 = profiler.start('fold-inner1.2');
		this.saveHistory(function () {
			token2.stop();
			// FIXME, update members like sitDown
			this.updateMongoState({},function () {
				cb1.call(this,events,offset);
			}.bind(this));
		}.bind(this));
	}
	switch (this.state) {
	default:
	case 'tsIdle':
		priv.conn.log('fallback');
		cb1();
		break;
	case 'tsPreFlop': // most states go here
	case 'tsFlop':
	case 'tsTurn':
	case 'tsRiver':
		priv.conn.log('normal fold state %s',this.state);
		for (x=0; x<this.pots.length; x++) {
			//priv.conn.log('folding seat %d, pots:%j',seat,this.pots[x].members);
			var idx = this.pots[x].members.indexOf(seat);
			if (idx != -1) {
				priv.conn.log('pots:%j idx:%d seat:%d',this.pots,idx,seat);
				this.pots[x].members.splice(idx,1);
			}
		}
		this.stateRow.moveCounter++;
		if (seatObj) seatObj.status = 'psFolded';
		this.history.players[seat].status = 'psFolded';
		this.addHistory({seat:seat,code:['teFold']});
		var inhandcount = this.inHandCount();
		if (inhandcount == 0) {
			priv.conn.log('wut now??');
			assert(false,'this should never happen:'+this.state);
			finish2.call(this);
		} else if (inhandcount == 1) {
			priv.conn.log('d');
			var lastseat;
			for (x=0; x<this.members.length; x++) {
				if (!this.members[x]) continue;
				if (['psInHand','psAllIn'].indexOf(this.members[x].status) == -1) continue;
				lastseat = x;
			}
			priv.conn.log('remaining guy wins everything',lastseat);
			this.moveToPot('fold1',function () {
				token.tag += 'a';
				token.stop();
				priv.conn.log('done moving to pot 2');
				this.calcWinners(finish2.bind(this),[this.makeEvent('teFold',seat)],0,null,false);
			}.bind(this));
		} else {
			priv.conn.log('fold with more then 1 person remaining',this.inHandCount());
			this.stateRow.keycount--;
			if (seat == this.current_seat) {
				priv.conn.log('and i was active');
				token.tag += 'b';
				token.stop();
				this.stateMachine(finish.bind(this),null,null,[this.makeEvent('teFold',seat)],0);
			} else {
				token.tag += 'c';
				token.stop();
				finish.call(this,[this.makeEvent('teFold',seat)],0);
			}
		}
		break;
	}
};
Game.prototype.removeSuspended = function () {
	if (!this.club) return;
	for (var x=0; x<this.members.length; x++) {
		if (!this.members[x]) continue;
		if (this.club.isSuspended(this.seats[x].userid)) this.members[x].status = 'psOutOfPlay';
	}
}
Game.prototype.doWin = function (cb,extradelay,cb3) {
	var x,y;
	var totalrake = 0;
	var rakestats = [];

	assert.equal(this.Lock.readers,-1);
	assert.equal(typeof extradelay,'number');
	this.state = 'tsWinning';
	var delay = 1500 + (this.pots.length * 500) + extradelay;
	this.log('delay is %d',delay);
	function finish() {
		this.log('cleared seat');
		this.current_seat = -1;
		this.log('main cb');
		cb(rakestats);

		setTimeout(function () {
			this.Lock.writeLock(function (release) {
				this.saveHistory(function () {
					if (cb3) cb3();
					if (this.gameinactive) return;
					this.deck = new Deck();
					this.deck.shuffle(function () {
						// SPLIT this.deck.cards = [1,40,17,41,29,51,48,20,9,25,13,19,46,42,10,8,16,47,0,11,18,14,31,4,2,24,32,33,6,15,12,39,21,37,30,26,34,7,22,3,35,27,44,5,36,50,49,28,23,43,38,45];
						// failed 3 way omaha split this.deck.cards = [44,8,10,11, 40,12,14,15, 36,20,22,23, 48,0,4,17,30, 47,42,41,18,46,31,29,2,24,32,33,6,25,51,39,21,37,16,26,34,7,13,3,35,27,1,5,9,50,49,28,19,43,38,45];
						this.log('doWin reset, shuffled deck is',JSON.stringify(this.deck.cards));
						//if (this.inHandCount() > 1) var nextstate = 'psInHand';
						for (var x=0; x<this.members.length; x++) {
							if (!this.members[x]) continue;
							if (this.members[x].status == 'psOutOfPlay') continue;
							this.members[x].hand = new Hand();
							if (this.ignoreOffline && this.members[x].disconnected) continue;
							if (this.members[x].sitOutNextRound) {
								this.members[x].sitOutNextRound = false;
								this.members[x].sitOutBB = false;
								if (this.tournament) {
									this.members[x].autoplay = true;
								} else {
									this.members[x].status = 'psOutOfPlay';
									this.updateLeaveStats(x);
									this.lastplayer[x] = this.seats[x].userid;
								}
							} else {
								if (this.members[x].status != 'psOutOfHand') {
									this.members[x].status = 'psInHand';
									this.seats[x].conn.log('moving into psInHand');
								}
							}
						}
						this.removeSuspended();
						this.state = 'tsWinning2';
						//this.broadcastStatus(null);
						this.log('a');
						this.stateMachine(function (events) {
							this.log('b');
							this.updateMongoState({members:true},function () {
								this.log('c');
								this.broadcastStatus(null,true,events); // teDeal
								release();
							}.bind(this));
						}.bind(this),null,{cont:true},[],0);
					}.bind(this));
				}.bind(this));
			}.bind(this));
		}.bind(this),delay);
	}
	var winnerObjects = [];
	var winnerids = [];
	var wins = []; // array of how much each seat wins
	function addWin(seat,chips) {
		if (wins[seat]) wins[seat] += chips;
		else wins[seat] = chips;
	}
	for (y=0; y<this.pots.length; y++) {
		var pot = this.pots[y];
		if (pot.value == 0) continue;

		// redo
		var rake = Math.round(pot.value * (this.rake / 100));
		if (pot.trueMembers.length == 0) console.log('pots are',this.pots);
		assert(pot.trueMembers.length > 0);
		var rakesplit = rake / pot.trueMembers.length;
		rake = rakesplit * pot.trueMembers.length;
		pot.rake = rake;
		this.history.WinnerPotData[y].rake = rake;
		var split = ((pot.value-rake)/pot.winners.length);
		// </redo>
		//var rake = pot.value * (this.rake / 100);
		this.log('splitting pot#%d',y);
		//var split = Math.round((pot.value-rake) / pot.winners.length);
		//rake = pot.value - (split * pot.winners.length);
		totalrake += rake;
		//var rakesplit = rake/pot.trueMembers.length;
		assert(!isNaN(rake));
		assert(!isNaN(rakesplit));
		assert(!isNaN(split));
		this.log('rake:%d/%d pot:%j split:%d',rake,rakesplit,pot,split);
		for (x=0; x<pot.trueMembers.length; x++) {
			if (rakestats[pot.trueMembers[x]]) rakestats[pot.trueMembers[x]].rake += rakesplit;
			else rakestats[pot.trueMembers[x]] = { rake:rakesplit, userid: pot.trueUsers[x] };
		}
		for (x=0; x<pot.winners.length; x++) {
			var priv = this.seats[pot.winners[x]];
			if (winnerObjects.indexOf(this.members[pot.winners[x]]) == -1) {
				winnerObjects.push(this.members[pot.winners[x]]);
				winnerids.push(priv.userid);
			}
			//console.log('winner debug',winnerObjects[x],pot.winners[x]);
			assert(priv,'winner must be seated');
			addWin(pot.winners[x],split);
		}
		this.log('pot#%d initialrake:%d totalrake:%d',y,rake,totalrake);
	}
	this.log('initialrake:%d totalrake:%d pots:%j',rake,totalrake,this.pots);
	assert.equal(typeof totalrake,'number');
	this.history.totalrake = totalrake;
	this.log('wins',wins,winnerids);
	var stack = new Error().stack;

	//assert.equal(wins[0],15);
	//this.log('doWin',this.pots,this.members); // the timer breaks JSON stringify
	this.pots = [ new Pot(this) ];
	async.eachSeries(winnerObjects,function (winnerObj,cb2) {
		var seat = winnerObj.seat;
		var userid = this.seats[seat].userid;
		var gain = wins[seat];
		this.balance_changes[seat] += gain;
		models.UserModel.findOneAndUpdate({_id:userid},{$inc:{chips:gain}},function (err) {
			error.handleError(err);
			this.log('seat #'+seat+' gained '+gain);
			if (this.seats[seat].conn) {
				this.seats[seat].conn.boughtin += gain;
				this.seats[seat].conn.chips += gain;
			}
			if (winnerObj) winnerObj.chips += gain;
			cb2();
		}.bind(this));
	}.bind(this),function done() {
		models.Game.findOneAndUpdate({_id:this.obj._id},{$unset:{gameState:0},$inc:{rake:totalrake}},function (err,res) {
			assert(!err,err);
			this.obj.rake += totalrake;
			assert(res);
			finish.call(this);
		}.bind(this));
	}.bind(this));
};
Game.prototype.checkRoundPass = function (cb,events,extradelay,cb3,autoending) {
	var token = profiler.start('checkRoundPass');
	assert.equal(this.Lock.readers,-1);
	assert(events);
	assert.equal(typeof extradelay,'number');
	this.log('key seat count is:'+this.stateRow.keycount+' current:'+this.current_seat);
	if (this.stateRow.keycount <= 0) {
		var min = -1;
		var max = 0;
		for (var x=0; x<this.members.length; x++) {
			if (!this.members[x]) continue;
			if (['psInHand','psAllIn'].indexOf(this.members[x].status) == -1) continue;
			if (this.bets[x] > max) max = this.bets[x];
			if (['psAllIn'].indexOf(this.members[x].status) != -1) continue;
			if (min == -1) min = this.bets[x];
			if (this.bets[x] < min) min = this.bets[x];
		}
		this.log('bet ranges min:'+min+' max:'+max+' all bets:'+JSON.stringify(this.bets));
		if (min == -1) min = max;
		if (min == max) {
			if (this.state == 'tsPreFlop') {
				this.rake = this.real_rake;
				this.log('flopping');
				this.deck.draw(3,this.flop);
				this.stateRow.flop = this.flop;
				this.history.cards = this.flop.cards;
				events.push(this.makeEvent('teFlop',{bets:this.bets.slice(),oldpots:this.pots,cards:new Buffer(this.flop.cards)}));
				this.current_seat = this.dealer;
				this.moveToPot('preflop',function () {
					this.updatePotRakes();
					this.addHistory({code:['teFlop'],seat:-1,pots:JSON.parse(JSON.stringify(this.pots))});
					this.state = 'tsFlop';
					this.log('flop adding to %d',extradelay);
					token.tag += 'c';
					token.stop();
					cb.call(this,events,1500+extradelay);
				}.bind(this));
				this.roundEnd();
			} else if (this.state == 'tsFlop') {
				this.log('turning');
				this.deck.draw(1,this.turn);
				this.stateRow.turn = this.turn;
				this.history.cards = this.history.cards.concat(this.turn.cards);
				events.push(this.makeEvent('teTurn',{bets:this.bets.slice(),oldpots:this.pots,cards:new Buffer(this.turn.cards)}));
				this.current_seat = this.dealer;
				this.moveToPot('turn',function () {
					this.updatePotRakes();
					this.addHistory({code:['teTurn'],seat:-1,pots:JSON.parse(JSON.stringify(this.pots))});
					this.state = 'tsTurn';
					this.log('turn adding to %d',extradelay);
					token.tag += 'd';
					token.stop();
					cb.call(this,events,1500+extradelay);
				}.bind(this));
				this.roundEnd();
			} else if (this.state == 'tsTurn') {
				this.log('river time');
				this.deck.draw(1,this.river);
				this.stateRow.river = this.river;
				this.history.cards = this.history.cards.concat(this.river.cards);
				events.push(this.makeEvent('teRiver',{bets:this.bets.slice(),oldpots:this.pots,cards:new Buffer(this.river.cards)}));
				this.current_seat = this.dealer;
				this.moveToPot('river',function () {
					this.updatePotRakes();
					this.addHistory({code:['teRiver'],seat:-1,pots:JSON.parse(JSON.stringify(this.pots))});
					this.state = 'tsRiver';
					this.log('river adding to %d',extradelay);
					token.tag += 'e';
					token.stop();
					cb.call(this,events,1500+extradelay);
				}.bind(this));
				this.roundEnd();
			} else {
				//this.broadcastStatus(null);
				events.push(this.makeEvent('tePostRiver',{bets:this.bets.slice()}));
				this.moveToPot('post-river',function () {
					this.updatePotRakes();
					//events.push(this.makeEvent('tePreWin',{pots:this.pots}));
					this.log('events callback FIXME %s',new Error().stack);
					token.tag += 'f';
					token.stop();
					this.calcWinners(cb,events,extradelay,cb3,autoending);
				}.bind(this));
			}
		} else {
			// cpu cost: ~0.8ms
			cb(events,0);
		}
	} else {
		cb(events,0);
	}
};
Game.prototype.postWinSaveStats = function (rakestats,cb) {
	var jobs = [];
	this.log('rake info: %j, balances:%j',rakestats,this.balance_changes);
	for (var x=0; x<this.balance_changes.length; x++) {
		if (!this.balance_changes[x]) continue;
		if (this.balance_changes[x] != 0) {
			if (!rakestats[x]) rakestats[x] = {rake:0};
			var mods = { $inc:{balance:this.balance_changes[x], rakecontrib:rakestats[x].rake, hands:1 }};
			var key = {gameid:this.obj._id,userid:rakestats[x].userid};
			var job = {mods:mods, key:key, change:this.balance_changes[x], userid:rakestats[x].userid};
			jobs.push(job);
		}
	}
	async.parallel([function a(cbA) {
		async.each(jobs,function hack(job,cb2) {
			global.log('updating stats %j',job);
			models.GameStats.findOneAndUpdate(job.key,job.mods,function (err) {
				error.handleError(err);
				if (this.club) this.club.updateLimitPostWin(job.change,job.userid,cb2);
				else cb2();
			}.bind(this));
		}.bind(this),cbA);
	}.bind(this),function b(cbB) {
		models.Game.findOneAndUpdate({_id:this.obj._id},{$inc:{hands:1}},function done(err,row) {
			assert(row);
			cbB();
		});
	}.bind(this)],function done() {
		cb();
	});
};
Game.prototype.calcWinners = function (cb,events,extradelay,cb3,autoending) {
	assert(events);
	assert.equal(typeof extradelay,'number');
	var WinnerPotData = [];
	var logmsg = [];
	var winnercount = 0;
	var potid = 0;
	var hands = [];
	var canplay = 0;
	var allinfound = false;
	for (var x=0; x<this.members.length; x++) {
		if (!this.members[x]) continue;
		if (['psInHand','psAllIn'].indexOf(this.members[x].status) == -1) continue;
		if (this.members[x].status == 'psInHand') {
			canplay++;
		}
		if (this.members[x].status == 'psAllIn') allinfound = true;
		hands.push({seat:x,hand:this.members[x].hand.cards});
	}
	if ((canplay == 1) && (allinfound) && autoending) {
		for (var x=0; x<this.members.length; x++) {
			if (!this.members[x]) continue;
			if (['psInHand','psAllIn'].indexOf(this.members[x].status) == -1) continue;
			this.members[x].muck = false;
			this.history.players[x].muck = false;
		}
	}
	this.log('hands: %j',hands[0]);
	var forcewin = -1;
	if (hands.length > 1) {
		if (this.omaha) {
			var result = omaha2.doEval(this.flop,this.turn,this.river,hands);
		} else {
			var result = dag.rankHands(this,hands);
		}
		this.lastResult = result;
		this.log('dag results:',result);
	} else {
		forcewin = hands[0].seat;
		this.lastResult = null;
	}
	// FIXME< just use a for loop?
	async.eachSeries(this.pots,function (pot,cb1) {
		var lowestid = -1;
		var winningindex = -1;
		var winner;
		var winners = [];
		var data = [];
		if (pot.value == 0) return cb1();
		WinnerPotData[potid] = { value:pot.value, members:pot.members };
		this.log('this pot',potid,pot);

		if (forcewin >= 0) {
			winners = [ forcewin ];
			if (winners.length > winnercount) winnercount = winners.length;
			if (this.seats[forcewin].conn) {
				logmsg.push(this.seats[forcewin].conn.nick+' '+this.seats[forcewin].userid);
			} else {
				logmsg.push("DC'd "+this.seats[forcewin].userid);
			}
			data.push({seat:forcewin,msg:'default'});
		} else {
			for (var x=0; x<result.outputs.length; x++) {
				if (pot.members.indexOf(result.outputs[x].seat) == -1) continue;
				if (lowestid == -1) {
					lowestid = result.outputs[x].id;
					winningindex = x;
					winner =  result.outputs[x];
				}
				if (result.outputs[x].id < lowestid) {
					lowestid = result.outputs[x].id;
					winningindex = x;
					winner =  result.outputs[x];
				}
			}
			// split pot has the same .id on multiple people
			for (var x=0; x<result.outputs.length; x++) {
				if (pot.members.indexOf(result.outputs[x].seat) == -1) continue;
				if (result.outputs[x].id == lowestid) {
					winners.push(result.outputs[x].seat);
					this.members[result.outputs[x].seat].muck = false;
					this.history.players[result.outputs[x].seat].muck = false;
					this.log('output: %j',result.outputs[x]);
					logmsg.push(this.seats[result.outputs[x].seat].conn.nick+' '+this.seats[result.outputs[x].seat].userid);
					data.push({seat:result.outputs[x].seat,msg:result.outputs[x].desc});
				}
			}
		}
		WinnerPotData[potid].WinnerData = data;
		this.log('winners of pot #'+potid,winners);
		if (winners.length > winnercount) winnercount = winners.length;
		potid++;
		pot.winners = winners;
		cb1();
	}.bind(this));
		finish1.call(this);
	
	function finish1() {
		events.push(this.makeEvent('teWinning',null,WinnerPotData));
		this.addHistory({code:['teWinning'],WinnerPotData:WinnerPotData,seat:-1},winnercount);
		this.doWin(function (rakestats) {
			this.postWinSaveStats(rakestats,function () {
				cb(events,0);
			}.bind(this));
		}.bind(this),extradelay,cb3);
		this.log('MOVE WIN END '+logmsg.join(','));
	}
}
Game.prototype.moveToPot = function (reason,cb1) {
	var token = profiler.start('moveToPot');
	var token1 = profiler.start('moveToPot-inner1');
	this.log('state: %s bets: %j pots: %j reason:%s',this.state,this.bets,this.pots,reason);
	var increase;
	var min;
	var max;
	var betsToRemove = [];
	function removeBet(seat,bet) {
		if (betsToRemove[seat] === undefined) betsToRemove[seat] = bet;
		else betsToRemove[seat] += bet;
	}
	function calcRanges() {
		min = -1;
		max = 0;
		for (var x=0; x<this.bets.length; x++) {
			if (this.bets[x] === undefined) this.bets[x] = 0
			if (this.bets[x] == null) this.bets[x] = 0;
			if (this.bets[x] == 0) continue;
			if (this.bets[x] > max) max = this.bets[x];
			if (min == -1) min = this.bets[x];
			if (this.bets[x] < min) min = this.bets[x];
		}
		if (min == -1) min = 0;
		this.log('SIDE',min,max);
	}
	do {
		calcRanges.call(this);
		increase = 0;
		if (max == 0) break;
		for (var x=0; x<this.bets.length; x++) {
			if (this.bets[x] >= min) {
				increase += min;
				this.bets[x] -= min;
				removeBet(x,min);
				this.log('adding %d to pot from seat %d %s',min,x,this.members[x] ? this.members[x].status : 'member null');
				this.pots[this.pots.length-1].add(min,x,this);
			}
		}
		if (this.pots[this.pots.length-1].value) {
			var p = this.pots[this.pots.length-1];
			if ((p.members.length == 0) && (p.trueMembers.length == 1)) {
				p.members.push(p.trueMembers[0]);
			}
		}
		this.log('increase:'+increase+' '+min+'x'+(increase/min));
		this.log('SIDE1',this.pots,this.bets,betsToRemove);
		if (this.pots[this.pots.length-1].value) {
			assert(this.pots[this.pots.length-1].members.length)
		}
		this.pots.push(new Pot());
	} while (min != max);
	for (var x=0; x<(this.pots.length-1); x++) {
		// safety
		if (this.pots[x].value) assert(this.pots[x].members.length);

		var set1 = this.pots[x].members.join(',');
		var set2 = this.pots[x+1].members.join(',');
		this.log(set1,set2);
		if (set1 == set2) {
			this.pots[x].value += this.pots[x+1].value;
			this.pots.splice(x+1,1);
			this.log(this.pots);
			if (x >= 0) x--;
		}
	}
	this.log('post merge: %j',this.pots);
	//if (this.pots.length > 1 && this.pots[1].members.length > 1) assert(this.pots.length < 3);
	for (var potid=0; potid<this.pots.length; potid++) {
		if (this.pots[potid].trueMembers.length == 1) {
			var returnseat = this.pots[potid].members[0];
			removeBet(returnseat,-(this.pots[potid].value));
			if (this.members[returnseat]) {
				this.seats[returnseat].conn.log('CHECK returning',this.members[returnseat].chips);
				this.members[returnseat].chips += this.pots[potid].value;
				this.seats[returnseat].conn.log('CHECK returned',this.pots[potid].value,this.members[returnseat].chips);
			}
			this.pots.splice(potid,1);
		}
	}

	// FIXME, remove this check later?
	for (var x=0; x<this.seats.length; x++) if (this.seats[x]) assert(this.seats[x].userid);

	token1.stop(); // 9ms avg
	async.parallel([
		function (cb) {
			this.updateMongoState({},function () {
				//this.log('pot for game updated');
				cb();
			}.bind(this));
		}.bind(this),
		function (cb2) {
			var token2 = profiler.start('moveToPot-inner2');
			// FIXME< use async.each
			var jobs = [];
			for (var x=0; x<this.obj.seats; x++) {
				if (!this.seats[x]) continue;
				if (this.members[x]) {
					if (['psOutOfHand','psOutOfPlay'].indexOf(this.members[x].status) != -1) continue;
				}
				jobs.push({seat:x});
			}
			token2.tag += '.'+jobs.length;
			token1.tag += '.'+jobs.length;
			token.tag += '.'+jobs.length;
			async.each(jobs,function repeat(job,cb) {
				// FIXME, clean up this code
				var priv = this.seats[job.seat];
				var item = this.members[job.seat];
				if (betsToRemove[job.seat] === undefined) betsToRemove[job.seat] = 0;
				this.log('removing chips userid:%s idx:%d bets:%j',priv.userid,job.seat,betsToRemove);
				assert(priv.userid);
				assert.equal(typeof betsToRemove[job.seat],'number');
				this.balance_changes[job.seat] -= betsToRemove[job.seat];
				cb();
			}.bind(this),function finish(err) {
				error.handleError(err);
				//this.log('remove chips done',betsToRemove);
				token2.stop(); // 12ms avg
				cb2();
			});
		}.bind(this)],function () {
			this.log('done moving to pot 1');
			this.minBet = 0;
			token.stop(); // 26ms avg
			cb1();
		}.bind(this));
}
Game.prototype.updateMongoState = function (options,cb) {
	if (this.gameinactive) return cb();
	var token = profiler.start('updateMongoState');
	if (this.stateRow._events) assert(this.stateRow._events.isNew.length < 100);
	this.stateRow.pots = this.pots;
	this.stateRow.current_seat = this.current_seat;
	this.stateRow.dealer = this.dealer;
	this.stateRow.bets = this.bets;
	this.stateRow.state = this.state;
	this.stateRow.handid = this.handid;
	this.stateRow.history = this.history; // maybe only update it in some spots?
	this.stateRow.balance_changes = this.balance_changes;
	this.stateRow.rake = this.rake;
	this.stateRow.minBet = this.minBet;
	this.stateRow.minimum_raise = this.minimum_raise;
	if (options.members) {
		var keys = ['hand','status','chips','seat','sitOutNextRound','SittingOutRoundsCount','handsPlayed','can_show'];
		while (this.stateRow.members.length) this.stateRow.members.pop();
		for (var x=0; x<this.members.length; x++) {
			var input = this.members[x];
			if (!input) continue;
			var out = {userid:this.seats[x].userid};
			for (var y=0; y<keys.length; y++) {
				var key = keys[y];
				out[key] = input[key];
			}
			this.stateRow.members.push(out);
			var out = this.stateRow.members[this.stateRow.members.length-1];
			for (var y=0; y<input.hand.cards.length; y++) {
				out.hand.cards[y] = input.hand.cards[y];
			}
		}
	}
	if (options.users) {
		var U = [];
		for (var key in this.users) U.push(this.users[key].userid);
		this.stateRow.users = U;
	}
	var tracer = new Error();
	this.stateRow.save(function (err) {
		error.handleError(err,tracer);
		token.stop();
		cb();
	}.bind(this));
}
Game.prototype.putChips = function (conn,chips,cb,cb3) {
	assert.equal(this.Lock.readers,-1);
	var seat = this.findSeat(conn);
	assert.equal(this.current_seat,seat);
	conn.log('putchips, counter==%d',this.stateRow.moveCounter);
	if (['tsPreFlop','tsFlop','tsTurn','tsRiver'].indexOf(this.state) == -1) {
		this.log('putChips fail 1');
		cb();
		return;
	}
	
	var increase = chips - this.bets[seat];
	var event;
	var oldbet = this.bets[seat];
	var maxbet = this.getLimit(seat);


	if (chips > maxbet) { // cheater!
		conn.reply(0,util.format('trying to go over pot limit %d %d %d %d seat:%d',chips,oldbet,maxbet,this.members[seat].chips,seat));
		//conn.error('cheater, going over pot limit '+chips+' '+maxbet);
		//conn.destroy();
		cb([],0);
		return;
	} else if (chips < oldbet) { // cheater!
		conn.reply(0,'you tried to lower your bet!');
		//conn.error('cheater detected, lowering bet '+chips+','+oldbet);
		//conn.destroy();
		cb([],0);
		return;
	} else if (this.members[seat].chips == increase) {
		this.members[seat].status = 'psAllIn';
		event = 'teAllIn';
	} else if (chips < this.minBet) { // cheater!
		conn.reply(0,'not meeting min bet');
		//conn.error('cheater detected, betting low '+chips+','+this.minBet);
		//conn.destroy();
		cb([],0);
		return;
	} else if (chips > this.minBet) {
		if ((chips - this.minBet) < this.minimum_raise) {
			conn.reply(0,'not meeting min raise');
			//conn.error(util.format('cheater detected, not meeting min raise, chips:%d minBet:%d minRaise:%d inplay:%d increase:%d',chips,this.minBet,this.minimum_raise,this.members[seat].chips,increase));
			//conn.destroy();
			cb([],0);
			return;
		}
		event = 'teRaise';
	} else if (this.bets[seat] == chips) { // check
		event = 'teCheck';
	} else if (chips == this.minBet) {
		event = 'teCall';
	}
	this.clearCanShow();
	this.stopTimer(seat);

	if (increase > this.members[seat].chips) {
		conn.error('cheater detected, overbetting '+chips+','+increase+','+this.members[seat].chips);
		conn.destroy();
		cb([],0);
		return;
	}
	this.log('MOVE '+event+' '+this.seats[seat].conn.nick+' '+this.seats[seat].userid);
	this.addHistory({seat:seat,bet:chips,code:[event]});
	this.stateRow.keycount--;
	this.stateRow.moveCounter++;

	conn.log('eating bets:'+JSON.stringify(this.bets)+' increase:'+increase+' chips:'+chips+' seat:'+seat);
	this.setBet(seat,chips);
	
	//this.saveHistory(function () {
		this.stateMachine(function (events,offset) {
			assert.equal(typeof offset,'number');
			this.updateMongoState({members:true},function () {
				cb(events,offset);
			});
		}.bind(this),null,null,[this.makeEvent(event,seat)],0,cb3);
	//}.bind(this));
}
Game.prototype.saveHistory = function (cb) {
	var updates = {$set:{moves:this.history.moves,deck:this.deck.cards,rake:this.rake,cards:this.history.cards}};
	if (this.history.WinnerPotData) {
		updates['$set'].WinnerPotData = this.history.WinnerPotData;
		updates['$set'].winnercount = this.history.winnercount;
		updates['$set'].balance_changes = this.balance_changes;
		updates['$set'].totalrake = this.history.totalrake;
		updates['$set'].endtime = Math.floor(Date.now()/1000);
		updates['$set'].result = this.lastResult;
		updates['$set'].players = this.history.players;
	}
	// FIXME, re-save players obj at end of round
	// FIXME, reuse mongoose Document
	models.HandHistory.findOneAndUpdate({seq:this.handid},updates,function (err,res) {
		error.handleError(err);
		assert(res);
		cb();
	});
}
Game.prototype.findSeat = function (conn) {
	for (var x=0; x<this.seats.length; x++) {
		if ((this.seats[x]) && (this.seats[x].conn == conn)) {
			return x;
		}
	}
	return -1;
}
Game.prototype.nextDealer = function () {
	var limit = 100;
	this.dealer++;
	while (limit-- > 0) { // FIXME
		//this.log('dealer loop',limit,this.dealer);
		if (limit-- < 0) break;
		if (this.dealer >= this.obj.seats) this.dealer = 0;
		if (!this.members[this.dealer]) { this.dealer++; continue; }
		if (this.ignoreOffline && this.members[this.dealer].disconnected) { this.dealer++; continue; }
		if (this.members[this.dealer].status == 'psOutOfPlay') { this.dealer++; continue; }
		if (this.members[this.dealer].chips > 0) break;
		this.dealer++;
	}
	if (limit < 10) { // FIXME
		this.dealer = -1;
	}
	this.log('DEALER set to seat %d',this.dealer);
}
Game.prototype.checkDelayedLeave = function () {
	// FIXME, delete
	if ((this.state == 'tsIdle') || (this.Lock.readers == 0)) {
		for (var x=0; x<this.seats.length; x++) {
			var priv = this.seats[x];
			if (!priv) continue;
			var pub = this.members[x];
			if (!pub) {
				if (priv.delayed) {
					this.log('finishing delayed leave');
					this.seats[x] = null;
				}
			}
		}
	}
}
Game.prototype.stateMachine = function stateMachine(cb,conn,config,events,extradelay,cb3) {
	function finish1() {
		if (config && config.silent) {
		} else this.broadcastStatus(conn,null,events);
		cb(events);
	}
	function finish(events,offset) {
		assert(events);
		assert.equal(typeof offset,'number');
		this.log('sm finish %j',events);
		if (this.state != 'tsWinning') {
			this.current_seat = this.getNextSeat(this.current_seat);
			if (this.members[this.current_seat].autoplay) {
				this.log('need to skip player %d',this.current_seat);
				this.broadcastStatus(null,null,events);
				setTimeout(function () {
					this.fold(this.current_seat,function (events2) {
						for (var x=0; x<events2.length; x++) events.push(events2[x]);
						cb(events,offset);
					}.bind(this));
				}.bind(this),1500);
				return;
			}
			if (this.members[this.current_seat].chips == 0) {
				this.ranOut = true;
				this.log('skipping');
				return this.stateMachine(cb,null,null,events,extradelay);
			}
			if (this.ranOut && (this.inHandCount() == 2)) {
				this.log('somebody ran out, auto finishing');
				return this.stateMachine(cb,null,null,events,extradelay);
			}
		}
		//this.broadcastStatus(null);
		cb(events,offset);
	}
	function loop() {
		var x = to_kick.pop();
		this.standUp(this.seats[x].conn,function (folded,events2,offset) {
			if (to_kick.length > 0) return loop.call(this);
			else this.stateMachine(cb,conn,config,events,extradelay);
		}.bind(this));
	}
	clearTimeout(this.idleUnstickTimer);
	assert.equal(this.Lock.readers,-1);
	assert(events);
	assert.equal(typeof extradelay,'number');
	this.log('state machine: %s events:%j currentSeat:%d',this.state,events,this.current_seat);
	this.checkDelayedLeave();
	switch (this.state) {
	case 'tsWinning':
		cb(events,0); // FIXME
		break;
	case 'tsWinning2':
		var havechips = 0;
		for (var x=0; x<this.members.length; x++) if (this.members[x] && (this.members[x].chips > 0)) havechips++;
		if (havechips == 0) {
			this.log('nobody has chips');
			this.dealer = -1;
			this.current_seat = -1;
		} else if (havechips < 2) {
			// FIXME, tourmanement: merge tables or declare winner
			this.log('only one guy has chips');
			//this.nextDealer();
		}
		this.state = 'tsIdle';
		this.checkDelayedLeave();
		this.current_seat = -1;
		//this.nextDealer();
		var jobs = [];
		for (var x=0; x<this.members.length; x++) {
			if (!this.members[x]) continue;
			if (this.members[x].status == 'psOutOfPlay') continue;
			this.log('found %d %s %d',x,this.members[x].status,this.members[x].sitTime);
			jobs.push(x);
		}
		async.each(jobs,function (seatIdx,cb2) {
			this.updateLeaveStats(seatIdx,true,cb2);
		}.bind(this),function () {
			this.handOver(function () {
				this.stateMachine(cb,conn,config,events,extradelay);
			}.bind(this),this.handid);
		}.bind(this));
		break;
	case 'tsIdle':
		if (this.autoDelete) {
			this.close(conn,function () {
				cb(events);
			});
			return;
		}
		if (this.tourn && this.tourn.onBreak) {
			this.tourn.break_start(this,function () {
				cb(events);
			});
			return;
		}
		var havechips = 0;
		var emptyseat = false;
		for (var x=0; x<this.members.length; x++) {
			if (!this.members[x]) {
				emptyseat = true;
				continue;
			}
			if (this.members[x].status == 'psOutOfPlay') continue;
			if (this.ignoreOffline && this.members[x].disconnected) continue;
			if (this.members[x].chips > 0) {
				this.members[x].sitTime = Date.now();
				this.log('sm found one',x,this.members[x].status,this.members[x].chips);
				havechips++;
			} else if (this.members[x].chips == 0) {
				this.members[x].status = 'psOutOfPlay';
				this.updateLeaveStats(x);
				this.lastplayer[x] = this.seats[x].userid;
				continue;
			}
		}
		if (this.members.length != this.obj.seats) emptyseat = true;
		if (!emptyseat || this.tournament) {
			var to_kick = [];
			for (var x=0; x<this.members.length; x++) {
				if (!this.members[x]) continue;
				//console.log('seat:%d chips:%d tournament:%j',x,this.members[x].chips,this.tourn);
				if (!emptyseat && (this.members[x].status == 'psOutOfPlay')) {
					if (this.members[x].SittingOutRoundsCount >= (this.obj.seats * 2)) {
						to_kick.push(x);
						continue;
					}
				}
				if ((this.members[x].chips == 0) && this.tournament) {
					to_kick.push(x);
					continue;
				}
			}
			if (to_kick.length > 0) {
				loop.call(this);
				return;
			}
		}
		//if (this.dealer == -1) this.nextDealer();
		if (havechips > 1) {
			this.log('enough are sitting, checking sitOutBB');
			var dealerbackup = this.dealer;
			//if (this.dealer == -1) this.nextDealer();
			this.nextDealer(); // TODO, figure out why this is needed
			var pos = this.dealer;
			if (havechips == 2) {
				this.headsup = true;
				pos = this.getNextSeat(pos,['psInHand','psAllIn','psOutOfHand']);
			} else this.headsup = false;
			var small_blind = this.getNextSeat(pos,['psInHand','psAllIn','psOutOfHand']);
			var big_blind = this.getNextSeat(small_blind,['psInHand','psAllIn','psOutOfHand']);
			this.log('future dealer:%d, sb:%d, bb:%d',this.dealer,small_blind,big_blind);
			this.dealer = dealerbackup;
			if (this.members[big_blind].sitOutBB) {
				this.members[big_blind].sitOutBB = false;
				if (this.tournament) {
					this.members[big_blind].autoplay = true;
				} else {
					this.members[big_blind].status = 'psOutOfPlay';
					this.updateLeaveStats(big_blind);
					this.stateMachine(cb,null,config,events,extradelay);
					return;
				}
			}
			this.deal(cb,config,emptyseat);
		} else {
			if (!emptyseat) {
				this.log('table hung until somebody leaves');
				this.idleUnstickTimer = setTimeout(this.idleUnstick.bind(this),20000);
			}
			finish1.call(this);
		}
		break;
	case 'tsPreFlop':
	case 'tsFlop':
	case 'tsTurn':
	case 'tsRiver':
		//this.log('normal state',this.state,this.current_seat);
		//if (this.members[this.current_seat]) this.log('chips:',this.members[this.current_seat].chips);
		var cantplay = 0;
		var canplay = 0;
		var cancheck = 0;
		for (var x=0; x<this.members.length; x++) {
			if (!this.members[x]) continue;
			if (this.members[x].status == 'psInHand') {
				canplay++;
				if (this.canCheck(x)) cancheck++;
			} else if (this.members[x].status == 'psAllIn') cantplay++;
		}
		this.log('cantplay:'+cantplay+' canplay:'+canplay+' cancheck:'+cancheck);
		var skip = false;
		// FIXME, improve logic for more players
		if ((cantplay == 1) && (canplay == 1) && (cancheck == 1)) skip = true;
		if ((cantplay == 2) && (canplay == 1) && (cancheck == 1)) skip = true;
		if ((cantplay == 3) && (canplay == 1) && (cancheck == 1)) skip = true;
		if ((canplay == 0) && (cancheck == 0)) {
			skip = true;
			this.stateRow.keycount = -1;
		}
		// if all but 1 have gone all-in
		if (canplay == 1) {
			this.minimum_raise = 0;
		}
		if (skip) {
			this.log('skipping a player');
			this.stateRow.keycount--;
			var last = this.current_seat;
			this.current_seat = this.getNextSeat(this.current_seat);
			this.checkRoundPass(function (events,extradelay) {
				assert.equal(typeof extradelay,'number');
				this.log('player '+last+' skipped, doing state again, FIXME %d',events);
				return this.stateMachine(cb,null,null,events,extradelay);
			}.bind(this),events,extradelay,cb3,true);
			return;
		}
		this.checkRoundPass(finish.bind(this),events,0,cb3,false);
	}
}
Game.prototype.idleUnstick = function () {
	this.Lock.writeLock(function (release) {
		function loop() {
			var x = to_kick.pop();
			this.standUp(this.seats[x].conn,function (folded,events2,offset) {
				if (to_kick.length > 0) return loop.call(this);
				else {
					this.log('all kicked');
					this.broadcastStatus(null,null,[]);
					release();
				}
			}.bind(this));
		}
		this.log('should unstick the table');
		var to_kick = [];
		for (var x=0; x<this.members.length; x++) {
			if (!this.members[x]) continue;
			if (this.members[x].status == 'psOutOfPlay') {
				to_kick.push(x);
			}
		}
		if (to_kick.length > 0) {
			loop.call(this);
			return;
		}
		this.log('none found???');
		release();
	}.bind(this));
}
Game.prototype.canCheck = function (seatIdx) {
	// find the highest bet
	var max = 0;
	for (var x=0; x<this.members.length; x++) {
		if (!this.members[x]) continue;
		if (['psInHand','psAllIn'].indexOf(this.members[x].status) == -1) continue;
		if (this.bets[x] > max) max = this.bets[x];
	}
	if (this.bets[seatIdx] == max) return true;
	return false;
}
Game.prototype.makeEvent = function (event,seat,data) {
	var obj = {event:event};
	if (data) obj.pots = data;
	if (typeof seat == 'number') obj.seat = seat;
	if (typeof seat == 'object') {
		if (seat && seat.bets) obj.bets = seat.bets;
		if (seat && seat.cards) obj.cards = seat.cards;
//		if (seat && seat.oldpots) obj.oldpots = seat.oldpots;
	}
	return obj;
}
Game.prototype.broadcastStatus = function (conn,forceunlock,events) {
	var token = profiler.start('broadcastStatus');
	assert(events);
	//this.log('sending table status to all 2, state:%s',this.state);
	for (var key in this.users) {
		if (this.users[key] == conn) continue;
		if (!this.users[key]) continue;
		var status = this.getTableStatus(this.users[key],forceunlock,events);
		this.users[key].send(codes.seTableStatus,status,'Poker.TableStatus');
	}
	token.stop();
}
var counter = 0;
Game.prototype.updatePotRakes = function () {
	for (var x=0; x<this.pots.length; x++) {
		this.pots[x].rake = this.pots[x].value - this.pots[x].getPostRake(this.rake);
	}
}
Game.prototype.getTableStatus = function getTableStatus(self,forceunlock,events) {
	assert(self);
	assert(events);
	assert(self.nick);
	/*if ((['tsIdle','tsDealing','tsWinning','tsWinning2'].indexOf(this.state) == -1)) {
		assert(this.timer,util.inspect(this));
	}*/
	var tableStatus = {rake_percent:this.rake, table_mongo_id: this.id,seats:[], state:this.state, bets:this.bets, pots:[], locked:this.Lock.readers == -1, seq:counter++, minimum_bet:this.minBet, minimum_raise:this.minBet + this.minimum_raise,small_blind:this.small_blind, big_blind:this.big_blind, events:events};
	if (forceunlock) tableStatus.locked = false;
	if (this.handid) tableStatus.handid = this.handid;
	if (this.club) tableStatus.table_type = 'ttLive';
	else tableStatus.table_type = 'ttTournament';
	if (this.pots) {
		this.updatePotRakes();
		tableStatus.pots = this.pots;
	}
	if (this.timer && this.timer.time) tableStatus.time = this.timer.time;
	for (var x=0; x<this.members.length; x++) {
		if (!this.members[x]) continue;
		var seat = this.members[x];
		var priv = this.seats[x];
		assert(priv.userid);
		//console.log('table debug',x,seat.conn.userid,seat.hand.prettyPrint());
		if (!this.timebanks[priv.userid]) this.timebanks[priv.userid] = sharedconfig.max_timebank * 1000;
		var timebank = this.timebanks[priv.userid];
		if (timebank < 0) timebank = 0;
		var obj = {seat:x, player_mongo_id:priv.userid, chips:seat.chips, status:seat.status, timebank:timebank, disconnected:seat.disconnected, autoplay:seat.autoplay };
		var showcards = false;
		if (this.testmode) showcards = true;
		if ((['tsWinning','tsWinning2'].indexOf(this.state) != -1) && !seat.muck) showcards = true;

		obj.cards_visible = showcards;
		obj.can_show = this.members[x].can_show;

		if (priv.conn === self) showcards = true;
		if (showcards) {
			obj.cards = new Buffer(seat.hand.cards);
		}
		if (priv.conn == self) {
			tableStatus.maximum_raise = this.getLimit(x);
			if (tableStatus.minimum_raise > seat.chips) tableStatus.minimum_raise = seat.chips + this.bets[x];
		}
		obj.card_count = seat.hand.cards.length;
		if (this.state == 'tsIdle') assert.equal(obj.card_count,0);
		else {
			if (['psOutOfPlay','psOutOfHand','psFolded'].indexOf(seat.status) != -1) {
			} else if (this.omaha) assert.equal(obj.card_count,4);
			else {
				if (obj.card_count != 2) console.log('card count %s %j %s',util.inspect(seat),obj,this.state);
				assert.equal(obj.card_count,2);
			}
		}
		tableStatus.seats.push(obj);
	}
	tableStatus.dealer = this.dealer;
	tableStatus.current_seat = this.current_seat;
	if (['tsFlop','tsTurning','tsTurn','tsRiverTime','tsRiver'].indexOf(this.state) != -1) tableStatus.flop = new Buffer(this.flop.cards);
	if (['tsTurn','tsRiverTime','tsRiver'].indexOf(this.state) != -1) tableStatus.turn = new Buffer(this.turn.cards);
	if (this.state == 'tsRiver') tableStatus.river = new Buffer(this.river.cards);
	tableStatus.current_game = this.omaha ? "gtOmaha" : "gtHoldem";
	tableStatus.game_limit = this.game_limit;
	tableStatus.rotation = this.rotation;
	tableStatus.table_message = this.message;
	//this.log('made status:%d %s %j',counter-1,self ? 'for '+self.nick: '',tableStatus);
	return tableStatus;
}
Game.prototype.sittingCount = function () {
	var count = 0;
	for (var x=0; x<this.members.length; x++) {
		if (!this.members[x]) continue;
		if (this.members[x].chips <= 0) continue;
		count++;
	}
	return count;
}
Game.prototype.setMessage = function (obj) {
	assert.equal(this.Lock.readers,-1);
	this.message.push(obj);
	this.broadcastStatus(null,true,[]);
};
Game.prototype.clearMessage = function (type) {
	assert.equal(this.Lock.readers,-1);
	for (var x=0; x<this.message.length; x++) {
		if (this.message[x].message == type) {
			this.message.slice(x,1);
			this.broadcastStatus(null,true,[]);
			return;
		}
	}
}
Game.prototype.inHandCount = function () {
	var count = 0;
	for (var x=0; x<this.members.length; x++) {
		if (!this.members[x]) continue;
		if (['psInHand','psAllIn'].indexOf(this.members[x].status) == -1) continue;
		count++;
	}
	return count;
}
Game.prototype.roundEnd = function () {
	if (this.state == 'tsPreFlop') {
		this.minimum_raise = this.obj.big_blind;
	}
	var havechips = 0;
	for (var x=0; x<this.members.length; x++) {
		if (!this.members[x]) continue;
		if (this.members[x].status == 'psOutOfHand') continue;
		if (this.members[x].status == 'psOutOfPlay') continue;
		if (this.members[x].status == 'psFolded') continue;
		if (this.members[x].status == 'psAllIn') continue;
		if (this.members[x].chips > 0) {
			this.log('roundend found one',x,this.members[x].status,this.members[x].chips);
			havechips++;
		}
	}
	this.stateRow.keycount = havechips;
}
Game.prototype.updateCashOut = function (userid,buyin,cb) {
	var mods = { $push:{cashouts:{
		$each:[buyin],
		$slice:-50
	}}};
	var key = {gameid:this.obj._id,userid:userid};
	global.log('updating %s %s',key.gameid,key.userid);
	models.GameStats.findOneAndUpdate(key,mods,function (err) {
		error.handleError(err);
		this.handOver(function () {
			cb();
		});
	}.bind(this));
}
Game.prototype.standUp = function (conn,cb1,seatIdxIn) {
	assert.equal(this.Lock.readers,-1);
	if (seatIdxIn >= 0) var seatIdx = seatIdxIn;
	else var seatIdx = this.findSeat(conn);
	var seatObj = this.members[seatIdx];
	var folded = false;
	var token;
	var token2 = profiler.start('standup-inner5');
	var token3 = profiler.start('standup-inner6');
	var token9 = profiler.start('standup-step1');

	this.log('standing up seat:%d bet:%d status:%s locked:%d',seatIdx,this.bets[seatIdx],util.inspect(seatObj),this.Lock.readers);
	this.updateLeaveStats(seatIdx);
	this.logEvent('geCashout',conn.userid,seatObj.chips);
	conn.boughtin -= seatObj.chips;
	if (this.club) this.club.cashout(conn.userid,seatObj.chips);
	
	this.members[seatIdx] = null;
	this.lastplayer[seatIdx] = conn.userid;
	this.log('nulled out seat',seatIdx);
	
	if ((['tsIdle','tsWinning'].indexOf(this.state) == -1) && (['psInHand','psAllIn'].indexOf(seatObj.status) != -1)) {
		token = profiler.start('standup-inner2');
		this.fold(seatIdx,finish1.bind(this));
		folded = true;
	} else {
		token = profiler.start('standup-inner3');
		this.stateRow.keycount--;
		finish1.call(this,[],-1);
	}
	function finish1(events,offset) {
		token.stop(); // 24ms 25%
		token9.stop(); // 21ms
		token9 = profiler.start('standup-step2.1');
		token = profiler.start('standup-inner4');
		assert.equal(typeof offset,'number');
		this.log('1events are %j',events);
		assert.equal(this.Lock.readers,-1);
		this.log('standing up seat:',seatIdx,'bet:',this.bets[seatIdx],'status:',seatObj.status);
		var priv = this.seats[seatIdx];
		this.log('instant leave');
		//this.broadcastStatus();
		if (this.bets[seatIdx] === undefined) this.bets[seatIdx] = 0;
		this.log('bets:',this.bets);
		assert.equal(typeof this.bets[seatIdx],'number');
		var increase = this.bets[seatIdx];
		this.log('increase is',increase);
		assert(priv);
		if (['tsIdle','tsWinning'].indexOf(this.state) != -1) {
			token9.stop();
			token9 = profiler.start('standup-step2.2');
			assert.equal(increase,0);
			this.seats[seatIdx] = null;
			this.log('nulled out internal seat');
			//this.broadcastStatus();
			finish2.call(this,offset);
		} else {
			token9.stop(); // 5ms
			token9 = profiler.start('standup-step2.3'); // 6.7ms
			var token8 = profiler.start('standup-inner8');
			this.pots[0].value += increase;
			models.UserModel.findOneAndUpdate({_id:priv.userid},{ $inc:{chips:-this.bets[seatObj.seat]}},function (err,res) {
				error.handleError(err);
				assert(res);
				priv.conn.log('lost chips',increase,this.bets[seatIdx],seatIdx);
				priv.conn.boughtin -= this.bets[seatIdx];
				this.bets[seatIdx] = 0;
				this.seats[seatIdx] = null;
				this.log('nulled out internal seat');
				//this.broadcastStatus();
				token8.stop(); // 5ms
				finish2.call(this,offset);
			}.bind(this));
		}
		function finish2(offset) {
			token9.stop();
			token9 = profiler.start('standup-step3');
			token3.stop(); // 42ms, 42%
			var token7 = profiler.start('standup-inner7');
			assert.equal(typeof offset,'number');
			conn.log('in standup finish2');
			//var status = this.getTableStatus();
			events.push(this.makeEvent('teStandUp',seatIdx));
			if (this.sittingCount() == 0) {
				this.dealer = -1;
				this.current_seat = -1;
			}
			//this.broadcastStatus(conn);
			conn.log('a');
			token.stop();
			if (this.club) this.club.seGameChanged(this,finish3.bind(this),conn);
			else finish3.call(this);
			function finish3() {
				token9.stop(); // 5ms
				token9 = profiler.start('standup-step4.1');
				if (seatObj.handsPlayed > 0 ) {
					this.lastCashout[conn.userid] = { chips:parseInt(seatObj.chips), when:Date.now() };
				}
				this.updateCashOut(conn.userid,seatObj.chips,function () {
					token9.stop(); // 7ms
					token9 = profiler.start('standup-step4.2');
					this.updateMongoState({members:true},function () {
						token2.stop();
						token7.stop(); // 31ms 31%
						token9.stop(); // 3ms
						cb1(folded,events,offset);
					});
				}.bind(this));
			}
		}
	}
}
Game.prototype.leave = function leave(conn,reason,cb1) {
	conn.log('getting lock:%s',this.Lock.trace);
	delete this.users[conn.userid];
	this.Lock.writeLock(function (release) {
		conn.log('got lock',this.Lock.readers);
		var seatIdx = this.findSeat(conn);
		conn.log('leave idx %d %s',seatIdx,reason);
		if (seatIdx >= 0) {
			this.standUp(conn,function (folded,events) {
					conn.log('releasing lock events:%j',events);
					if (folded && (this.current_seat >= 0)) this.startTimer(this.current_seat,0);
					this.broadcastStatus(null,true,events);
					finish.call(this);
				}.bind(this));
		} else finish.call(this);
		function finish() {
			var count = 0,key;
			for (key in this.users) {
				count++;
				//console.log('key:%s count:%d',key,count);
			}
			for (key in this.reconnect) count++;
			if (count == 0) {
				if (this.state2 == 'gsClosing') {
					this.log('staying alive!');
				} else {
					this.log('self-deleting');
					delete activeGames[this.id];
					if (this.state2 == 'gsClosed') {
						clearTimeout(this.deleteTimer);
						this.doDelete();
					}
					this.gameinactive = true;
					this.stateRow.remove(function (err,res) {
						error.handleError(err);
						cb1();
						release();
					}.bind(this));
					return;
				}
			}
			this.updateMongoState({users:true},function () {
				cb1();
				release();
			});
		}
	}.bind(this));
}
Game.prototype.handleDisconnect = function (conn,reason,cb) {
	assert(conn.userid);
	if (this.club && (reason == 'logout')) {
		this.leave(conn,reason,cb);
		return;
	}
	if (this.tournament && (reason == 'logout')) {
		conn.log('its a tournament logout, checking seat');
		var seatIdx = this.findSeat(conn);
		conn.log('seat is %d',seatIdx);
		if (seatIdx == -1) {
			this.leave(conn,reason,cb);
			return;
		}
	}
	delete this.users[conn.userid];
	this.reconnect.push(conn.userid);
	var userid = conn.userid;
	this.Lock.writeLock(function (release) {
		function finish() {
			cb();
			release();
		}
		var seatIdx = this.findSeat(conn);
		conn.log('leave idx %d',seatIdx);
		if (seatIdx >= 0) {
			this.members[seatIdx].disconnected = true;
			if (this.tourn) {
				this.members[seatIdx].autoplay = true;
			} else {
				this.members[seatIdx].disconnectTimer = setTimeout(this.eject.bind(this,seatIdx,userid),5 * 60 * 1000);
			}
			var fakeconn = {log:lazy.ClientSocket.prototype.log,userid:userid, nick:this.seats[seatIdx].conn.nick};
			this.seats[seatIdx].conn = fakeconn;
			var events = [];
			events.push(this.makeEvent('teDisconnect',seatIdx));
			this.broadcastStatus(null,true,events);
			finish.call(this);
		} else finish.call(this);
	}.bind(this));
}
Game.prototype.eject = function (seatIdx,userid) {
	assert(userid);
	this.Lock.writeLock(function (release) {
		this.standUp(this.seats[seatIdx].conn,function eject_locked(folded,events,offset) {
			for (var x=0; x<this.reconnect.length; x++) {
				if (myutils.compareObjectID(userid,this.reconnect[x])) {
					this.reconnect.splice(x,1);
				}
			}
			this.broadcastStatus(null,true,events);
			release();
		}.bind(this),seatIdx);
	}.bind(this));
}
Game.prototype.doDelete = function () {
	assert(this.club);
	var g = makeGameProtobuf(this.obj);
	g.state = 'gsClosed';
	var conn = activeUsers[this.club.obj.owner];
	if (conn) conn.send(codes.seGameDelete,g,'Poker.Game');
	if (this.club.obj.is_private) {
		if (this.club.obj.members) {
			for (var x=0; x<this.club.obj.members.length; x++) {
				conn = activeUsers[this.club.obj.members[x]];
				if (!conn) continue;
				conn.send(codes.seGameDelete,g,'Poker.Game');
			}
		}
	} else {
		for (var key in activeUsers) {
			activeUsers[key].send(codes.seGameDelete,g,'Poker.Game');
		}
	}
}
Game.prototype.startTimer = function startTimer(seat,offset) {
	assert.equal(typeof offset,'number');
	this.stopTimer(seat);
	this.log('starting timer for seat %d in state %s',seat,this.state);
	//this.log('public: %j',this.members[seat]);
	//this.log('private: %s',util.inspect(this.seats[seat]));
	assert(this.members[seat]);
	this.timer = { time: (sharedconfig.max_play_time*1000) + Date.now() + offset, seat:seat };
	var priv = this.seats[seat];
	if (!this.timebanks[priv.userid]) this.timebanks[priv.userid] = sharedconfig.max_timebank * 1000;
	this.timer.timerid = setTimeout(function () {
		this.log('DING!');
		this.Lock.writeLock(function (release) {
			assert.equal(this.timer.seat,seat);
			this.stopTimer(seat);
			this.log('minbet:%d seatbet:%d',this.minBet,this.bets[seat]);
			if (this.minBet == this.bets[seat]) {
				if (this.current_seat != seat) {
					this.log('WARNING, timebank tried to force somebody to play when he isnt on the move!');
					release();
					return;
				}
				this.log('checking');
				// FIXME, this will fail hard if that is not the current player, something didnt reset the timer right
				this.putChips(this.seats[seat].conn,this.minBet,function (events,offset) {
					this.log('checked %j',events);
					if (this.current_seat >= 0) this.startTimer(this.current_seat,offset); /// FIXME?
					this.broadcastStatus(null,true,events);
					release();
				}.bind(this));
			} else {
				this.log('folding');
				this.fold(seat,function (events) {
					this.log('folded %j',events);
					if (this.current_seat >= 0) this.startTimer(this.current_seat,0); /// FIXME?
					this.broadcastStatus(null,true,events);
					release();
				}.bind(this));
			}
		}.bind(this));
	}.bind(this),(sharedconfig.max_play_time*1000) + this.timebanks[this.seats[seat].userid] + offset);
}
Game.prototype.stopTimer = function stopTimer(seat) {
	if (this.timer) {
		var spent = Date.now() - this.timer.time;
		var priv = this.seats[seat];
		if (!this.timebanks[priv.userid]) this.timebanks[priv.userid] = sharedconfig.max_timebank * 1000;
		if (spent > 0) this.timebanks[this.seats[seat].userid] -= spent;
		if (this.timebanks[this.seats[seat].userid] < -1) this.timebanks[this.seats[seat].userid] = -1;
		this.log('removed %d from timebank, %d remains',spent,this.timebanks[this.seats[seat].userid]);
		clearTimeout(this.timer.timerid);
	}
	this.timer = null;
}
Game.handleDisconnect = function handleDisconnect(conn,reason,cb1) {
	conn.log('handling disconnect:%s',reason);
	var jobs = [];
	for (var key in activeGames) {
		var game = activeGames[key];
		if (game.users[conn.userid]) jobs.push(game);
	}
	async.each(jobs,function (game,cb2) {
		game.handleDisconnect(conn,reason,cb2);
	},cb1);
}
Game.prototype.logEvent = function (type,userid,change) {
	return;
	var doc = {eventtype:type};
	if (userid) doc.userid = userid;
	if (change) doc.change = change;
	//GameEvents.insert(doc,function (){});
}
Game.getGame = function getgame(id,cb1) {
	getGameLock.writeLock(function getGameLocked(release) {
		if (!activeGames[id]) {
			models.Game.findOne({_id:id},function (err,obj) {
				if (!obj) {
					release();
					return cb1();
				}
				var token = profiler.start('game-create');
				var game = new Game(obj);
				game.logEvent('geOpened');
				// FIXME, concurrent calls, grab a lock here
				game.deck = new Deck();
				game.deck.shuffle(function shuffled(){
					//this.send(codes.SR_DECKREPLY,{deck:deck.prettyPrint()},'Poker.GetDeckReply');
					if (obj.clubid) { // club based game
						Club.getClubById(obj.clubid,function (err,club) {
							if (!club) {
								release();
								cb1('parent club missing');
								return;
							}
							game.real_rake = club.obj.rake;
							game.testmode = club.obj.testmode;
							game.club = club;
							finishGameInit(function () {
								var g = makeGameProtobuf(obj);
								var conn = activeUsers[club.obj.owner];
								if (conn) conn.send(codes.seGameChange,g,'Poker.Game');
								if (club.obj.members) { // FIXME, remove
									for (var x=0; x<club.obj.members.length; x++) {
										conn = activeUsers[club.obj.members[x]];
										if (!conn) continue;
										conn.send(codes.seGameChange,g,'Poker.Game');
									}
								}
								cb1(null,game);
							});
						});
					} else if (obj.tournament) { // tournament game
						game.real_rake = 0;
						game.ignoreOffline = false;
						game.obj.blinds = 'gbOther';
						Tournament.core.getByIdUnlocked(obj.tournament,function (err,tourn) { // FIXME, tournament needs several locks
							if (tourn) {
								game.tournament = tourn.obj;
								game.tourn = tourn;
								game.updateBlinds();
							} else game.log('tournament not found');
							finishGameInit(function () {
								cb1(null,game);
							});
						});
					}
					function finishGameInit(cb2) {
						game.rake = 0;

						models.GameState.findOne({_id:game.id},function (err,row) {
							error.handleError(err);
							if (row) {
								game.stateRow = row;
								token.stop();
								release();
								cb2();
							} else {
								models.GameState.create({_id:game.id},function (err,row) {
									error.handleError(err);
									game.stateRow = row;
									token.stop();
									release();
									cb2();
								});
							}
						});
					}
				}.bind(this));
			}.bind(this));
		} else {
			release();
			cb1(null,activeGames[id]);
		}
	}.bind(this));
}
Game.prototype.updateBlinds = function () {
	var x = this.tourn.getLevel();
	if (x >= this.tourn.blind_schedule.blinds.length) x = this.tourn.blind_schedule.blinds.length - 1;
	this.obj.small_blind = this.tourn.obj.blind_schedule.blinds[x].sb * 100;
	this.obj.big_blind = this.tourn.obj.blind_schedule.blinds[x].bb * 100;
}
Game.prototype.resume = function (game,cb) {
	console.log('FINDME',game.members);
	if (game.users) this.reconnect = game.users;
	if (game.members) {
		for (var x=0; x<game.members.length; x++) {
			var item = game.members[x];
			var pubSeat = { muck:true, disconnected:true, hand:new Hand(), status:item.status, chips:item.chips, seat:item.seat, sitOutNextRound:item.sitOutNextRound, SittingOutRoundsCount:item.SittingOutRoundsCount, handsPlayed:item.handsPlayed, can_show:item.can_show };
			pubSeat.disconnectTimer = setTimeout(this.eject.bind(this,item.seat,item.userid),5 * 60 * 1000);
			var privSeat = {conn:{log:lazy.ClientSocket.prototype.log,userid:item.userid, nick:'FIXME'}, userid:item.userid};
			pubSeat.hand.cards = item.hand.cards;
			this.members[item.seat] = pubSeat;
			this.seats[item.seat] = privSeat;
			if (this.club) this.club.buyin(item.userid,item.chips);
		}
	}
	if (game.flop) {
		this.flop = new Hand();
		this.turn = new Hand();
		this.river = new Hand();

		this.flop.cards = game.flop.cards;
		this.turn.cards = game.turn.cards;
		this.river.cards = game.river.cards;
	}
	if (game.deck) {
		this.deck.cards = game.deck;
	}
	this.handid = game.handid;
	this.state = game.state;
	this.current_seat = game.current_seat;
	this.stateRow.keycount = game.keycount;
	this.balance_changes = game.balance_changes;
	this.bets = game.bets;
	this.dealer = game.dealer;
	this.rake = game.rake;
	if (game.minimum_raise) this.minimum_raise = game.minimum_raise;
	if (game.minBet) this.minBet = game.minBet;
	if (game.pots) {
		for (var x=0; x<game.pots.length; x++) {
			this.pots[x] = new Pot(this);
			this.pots[x].value = game.pots[x].value;
			this.pots[x].members = game.pots[x].members;
			this.pots[x].trueMembers = game.pots[x].trueMembers;
			this.pots[x].trueUsers = game.pots[x].trueUsers;
		}
	}
	if (game.history) this.history = game.history;
	cb();
}
Game.checkAndResume = function (cb1) {
	models.GameState.find().lean(true).exec(function (err,badgames) {
		if (badgames.length > 0) {
			global.log('%d bad games found, recovering',badgames.length);
			async.eachSeries(badgames,function (game,cb2) {
				//gameState.remove({_id:game._id},cb)
				//console.log('game is',game);
				Game.getGame(game._id,function (err,gameObj) {
					if (err == 'parent club missing') {
						log('club missing for game %j',game);
						cb2();
						return;
					}
					error.handleError(err);
					global.log('bad game %j',game);
					if (!gameObj) {
						log('game is missing!');
						cb2();
						return;
					}
					if (!game.state) {
						log('state is missing');
						cb2();
						return;
					}
					if (gameObj.state2 == 'gsClosed') {
						log('game was closed!!!');
						cb2();
						return;
					}
					gameObj.resume(game,cb2);
				});
			},cb1);
		} else {
			cb1();
		}
	});
}
Game.prototype.reconnectUser = function (conn,seated,seat,cb) {
	this.Lock.writeLock(function (release) {
		function finish2(events) {
			this.log('finish2');
			this.broadcastStatus(conn,true,events);
			if (['tsFlop','tsTurn','tsRiver'].indexOf(this.state) != -1) {
				var cards = this.flop.cards;
				if (['tsTurn','tsRiver'].indexOf(this.state) != -1) cards = cards.concat(this.turn.cards);
				if (this.state == 'tsRiver') cards = cards.concat(this.river.cards);
				events.push(this.makeEvent('teExistingCards',{cards:new Buffer(cards)}));
			}
			var status = this.getTableStatus(conn,true,events);
			release();
			cb(status);
		}
		this.users[conn.userid] = conn;
		this.log('game state is %s',this.state);
		this.log('game obj is %s',util.inspect(this));
		var events = [];
		if (seated) {
			this.log('found seat, clearing disconnected');
			clearTimeout(this.members[seat].disconnectTimer);
			this.members[seat].disconnected = false;
			this.seats[seat].conn = conn;
			var kickstart = true;
			if (this.tourn) {
				if (this.tourn.onBreak) kickstart = false;
			}
			if (this.state == 'tsIdle' && kickstart) {
				this.stateMachine(finish2.bind(this),null,{silent:true},events,0);
			} else finish2.call(this,events);
		} else finish2.call(this,events);
	}.bind(this));
}
