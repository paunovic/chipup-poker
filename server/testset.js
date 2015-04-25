var Core = require('./core');
var async = require('async');
var http = require('http');
var MongoClient = require('mongodb').MongoClient;
var async = require('async');
var assert = require('assert');
var mongoose = require('mongoose');
var crypto = require('crypto');

var mdb = require('./db');
var myutils = require('./myutils');
var deck = require('./deck');
var Deck = deck.Deck;
var Hand = deck.Hand;

var clubid;

process.send = function (obj) {
	if (obj.type == 'game') console.log(obj.objects);
	else console.log(obj);
}
/*var realExit = process.exit;
process.exit = function () {
	console.log('EXIT CALLED!',new Error().stack);
	realExit.call(process,arguments);
}*/

exports.club = {
	makeanddelete: function (test) {
		var activeUsers = {};
		var activeGames = {};
		var Club = require('./club').Club
		test.expect(3);
		mdb.open('nodeunit');
		Club.init(activeUsers,activeGames,Core.pb);
		myutils.init();
		mdb.models.UserModel.create({displayname:'user1',chips:1000000,email:'email1'},function (err,rows) {
			mdb.models.UserModel.create({displayname:'user2',chips:1000000,email:'email2'},function (err,rows) {
				mdb.models.UserModel.create({displayname:'user3',chips:1000000,email:'email3'},function (err,rows) {
					mdb.models.UserModel.findOne(function (err,user) {
						test.ok(user);
						assert(user);
						console.log(user);
						mdb.models.Clubs.remove({name:'clubname'},function (err) {
							Club.createClub('clubname','password',user._id,5,30,function (worked,clubObj) {
								clubid = clubObj.obj.seq;
								test.ok(worked);
								Club.dupCheck('clubname',function (dup) {
									test.ok(dup);
									mdb.close();
									test.done();
								});
							});
						});
					});
				});
			});
		});
	},
	joinClub: function (test) {
		var activeUsers = {};
		var activeGames = {};
		var Club = require('./club').Club;
		mdb.open('nodeunit');
		Club.init(activeUsers,activeGames,Core.pb);
		myutils.init();
		mdb.models.UserModel.find().limit(3).exec(function (err,users) {
			Club.getClubBySeq(clubid,function (err,clubObj) {
				console.log('spot 1',err);
				test.ok(clubObj);
				var out = [];
				console.log('users:',users);
				for (var x=0; x<users.length; x++) {
					if (!clubObj.isOwner(users[x]._id)) out.push(users[x]);
				}
				console.log('out:',out);
				async.eachSeries(out,function (user2,cb) {
					console.log('user2',user2,typeof user2);
					clubObj.joinClub(user2._id,function () {
						cb();
					});
				},function () {
						console.log(clubObj.obj);
						setTimeout(function () {
							mdb.close();
							test.done();
						},100);
				})
			});
		});
	},
	goPublic: function (test) {
		global.activeUsers = {};
		var activeGames = {};
		var Club = require('./club').Club;
		var game = require('./game');
		test.expect(6);
		global.activeUsers['fake'] = { send: function(code,object,type) {
			test.ok(true);
		}};
		mdb.open('nodeunit');
		Club.init(activeGames);
		game.Game.init(activeGames);
		mdb.models.Clubs.findOne(function (err,row) {
			test.ok(true);
			mdb.models.UserModel.findOne(function (err,userRow) {
				//console.log('userRow',userRow);
				test.ok(true);
				mdb.models.ClubBalance.create({clubid:row._id,userid:userRow._id,balance:0,balance_limit:0,unlimited_limit:true},function (err) {
					test.ok(true);
					Club.getClubById(row._id,function (err,clubobj) {
						test.ok(true);
						//console.log('clubobj',clubobj);
						clubobj.goPublic(function () {
							test.ok(true);
							test.done();
							mdb.close();
						});
					});
				});
			});
		});
	},suspend: function (test) {
		global.activeUsers = {};
		var activeGames = {};
		var Club = require('./club').Club;
		test.expect(5);
		mdb.open('nodeunit');
		Club.init(activeGames);
		mdb.models.Clubs.findOne(function (err,row) {
			test.ok(true);
			test.ok(row.members.length > 0);
			if (row.members.length == 0) return test.done();
			mdb.models.UserModel.findOne({_id:row.members[0]},function (err,userRow) {
				test.ok(true);
				Club.getClubById(row._id,function (err,clubobj) {
					test.ok(true);
					clubobj.setSuspended(true,userRow._id,function () {
						test.ok(true);
						clubobj.setSuspended(false,userRow._id,function () {
							mdb.close();
							test.done();
						});
					});
				});
			});
		});
	},
	kick: function (test) {
		var activeUsers = {};
		var activeGames = {};
		var Club = require('./club').Club;
		mdb.open('nodeunit');
		Club.init(activeUsers,activeGames,Core.pb);
		myutils.init();
		Club.getClubBySeq(clubid,function (err,clubObj) {
			test.ok(clubObj);
			clubObj.Leave(clubObj.obj.members[0],function () {
				test.ok(true);
				setTimeout(function () {
					mdb.close();
					test.done();
				},100);
			});
		});
	},
	changeOwner: function (test) {
		var activeUsers = {};
		var activeGames = {};
		var Club = require('./club').Club;
		mdb.open('nodeunit');
		Club.init(activeUsers,activeGames,Core.pb);
		myutils.init();
		Club.getClubBySeq(clubid,function (err,clubObj) {
			test.ok(clubObj);
			clubObj.setOwner(clubObj.obj.members[0],function () {
				setTimeout(function () {
					mdb.close();
					test.done();
				},100);
			});
		});
	},
	deleteClub: function (test) {
		var activeUsers = {};
		var activeGames = {};
		var Club = require('./club').Club;
		mdb.open('nodeunit');
		test.expect(1);
		Club.init(activeUsers,activeGames,Core.pb);
		myutils.init();
		Club.getClubBySeq(clubid,function (err,clubObj) {
			test.ok(clubObj);
			console.log(clubObj);
			clubObj.deleteClub(function () {
				setTimeout(function () {
					mdb.close();
					test.done();
				},100);
			});
		});
	}
};
function DummyConn(user) {
	this.userid = user._id;
	this.state = 2;
	this.chips = 100000;
	this.boughtin = 0;
}
DummyConn.prototype.log = function () {
	console.log.apply(console,arguments);
}
exports.game = {
	create: function (test) {
		global.activeUsers = {};
		var activeGames = {};
		var Club = require('./club').Club;
		var Game = require('./game').Game;
		var profiler = require('profiler');
		mdb.open('nodeunit');
		global.pb = Core.pb;
		Club.init(activeGames);
		myutils.init();
		profiler.setup(mdb.models.PokerProfile);
		global.sharedconfig = {max_play_time:15,max_timebank:30};
		global.log = console.log;
		Game.init(activeGames);
		mdb.models.UserModel.find().limit(3).exec(function (err,users) {
			assert.ifError(err);
			var owner = users[0];
			var opponent = users[1];
			var p3 = users[2];
			test.ok(owner);
			test.ok(opponent);
			mdb.models.Clubs.remove({name:'clubname'},function (err) {
				assert.ifError(err);
				Club.createClub('clubname','password',owner._id,5,30,function (worked,clubObj) {
					test.ok(worked);
					clubid = clubObj.obj.seq;
					var gamerow = new mdb.models.Game({game_type:'gtHoldem',blinds:'gb1x2',seats:10,clubseq:clubObj.obj.seq,clubid:clubObj.obj._id,gamename:'unit test',game_limit:'glNoLimit',buyin_min:100000,buyin_max:150000,rake:0,rotation:0,hands:0});
					gamerow.save(function (err) {
						assert.ifError(err);
						Game.getGame(gamerow._id,function (err,gameObj) {
							assert.ifError(err);
							test.ok(gameObj);
							resit(new DummyConn(owner),new DummyConn(opponent),new DummyConn(p3),gameObj);
						});
					});
				});
			});
		});
		function resit(p1,p2,p3,gameObj) {
			p1.nick = 'owner';
			p2.nick = 'opponent';
			p3.nick = 'p3';
			p1.send = function (code,obj,type) {
				console.log('owner send:',code,obj,type);
			}
			p3.send = function (code,obj,type) {
				console.log('p3 send:',code,obj,type);
			}
			gameObj.Lock.writeLock(function (release) {
				gameObj.testing = true;
				gameObj.join(p3,function (err) {
					test.ifError(err);
					gameObj.join(p1,function (err) {
						test.ifError(err);
						gameObj.join(p3,function (err) {
							test.ifError(err);
							gameObj.sitDown(p3,{chips:100000,seat_index:3},function (worked,events) {
								test.ok(worked);
								console.log(worked,events);
								assert(worked);
								gameObj.standUp(p3,function (folded,events,offset) {
									release();
									gameObj.leave(p3,'nodeunit',function () {
										phase2(p1,p2,gameObj);
									});
								},3);
							});
						});
					});
				});
			});
		}
		function phase2(owner,opponent,gameObj) {
			opponent.send = function (code,obj,type) {
				console.log('opponent send:',code,obj,type);
			}
			console.log('this game is:',gameObj.id);
			gameObj.Lock.writeLock(function (release) {
					gameObj.join(opponent,function (err) {
						test.ifError(err);
						gameObj.sitDown(owner,{chips:100000,seat_index:0},function (worked,events) {
							test.ok(worked);
							console.log(worked,events);
							gameObj.sitDown(opponent,{chips:100000,seat_index:2},function (worked,events) {
								test.ok(worked);
								console.log(worked,events);
								phase3(owner,opponent,gameObj,release);
							});
						});
					});
			});
		}
		function phase3(owner,opponent,game,release) {
			game.members[0].status = 'psOutOfHand'; // FIXME, make a playnow function
			game.members[2].status = 'psOutOfHand';
			assert.equal(game.state,'tsIdle');
			game.stateMachine(function (events) {
				console.log(events);
				game.putChips(owner,200,function (events,offset) {
					console.log('put1',events,offset);
					game.putChips(opponent,200,function (events,offset) {
						console.log('put2',events,offset);
						test.ok(events[1].event == 'teFlop');
						test.ok(events[1].cards.length == 1);
						test.ok(events[1].cards[0].length == 3);
						test.ok(events[1].bets[0] > 0);
						phase4(owner,opponent,game,release);
					});
				});
			},owner,{},[],0);
		}
		function phase4(owner,opponent,game,release) {
			game.putChips(opponent,0,function (events,offset) {
				console.log('put3',events,offset);
				game.putChips(owner,0,function (events,offset) {
					console.log('put4',events,offset);
					test.ok(events[1].event == 'teTurn');
					test.ok(events[1].cards.length == 1);
					phase5(owner,opponent,game,release);
				});
			});
		}
		function phase5(owner,opponent,game,release) {
			game.members[0].sitOutNextRound = true;
			game.putChips(opponent,0,function (events,offset) {
				console.log('put5',events,offset);
				game.putChips(owner,0,function (events,offset) {
					console.log('put6',events,offset);
					test.ok(events[1].event == 'teRiver');
					test.ok(events[1].cards.length == 1);
					phase6(owner,opponent,game,release);
				});
			});
		}
		function phase6(owner,opponent,game,release) {
			game.putChips(opponent,0,function (events,offset) {
				console.log('put7',events,offset);
				game.putChips(owner,0,function (events,offset) {
					console.log('put8',events,offset);
					mdb.models.GameState.findOne({_id:game.obj._id},function (err,state) {
						console.log(state);
						test.ok(state.flop.cards.length == 3);
						test.ok(state.turn.cards.length == 1);
						test.ok(state.river.cards.length == 1);
						release();
					});
				},function () {
					// post doWin delay
					mdb.models.HandHistory.findOne({seq:game.handid},function (err,history) {
						test.equal(history.cards[0].cards.length,5);
						test.equal(history.deck.length,43);
						test.done();
						mdb.close();
					});
				});
			});
		}
	},
	resume: function (test) {
		global.activeUsers = {};
		global.sharedconfig = {max_play_time:15,max_timebank:30};
		global.log = console.log;
		global.pb = Core.pb;
		var activeGames = {};
		var Club = require('./club').Club;
		var Game = require('./game').Game;
		var profiler = require('profiler');
		mdb.open('nodeunit');
		Club.init(activeGames);
		myutils.init();
		profiler.setup(mdb.models.PokerProfile);
		Game.init(activeGames);
		mdb.models.UserModel.find().limit(2).exec(function (err,users) {
			assert.ifError(err);
			var owner = users[0];
			var opponent = users[1];
			test.ok(owner);
			test.ok(opponent);
			mdb.models.Clubs.remove({name:'clubname'},function (err) {
				assert.ifError(err);
				Club.createClub('clubname','password',owner._id,5,30,function (worked,clubObj) {
					test.ok(worked);
					clubid = clubObj.obj.seq;
					var gamerow = new mdb.models.Game({game_type:'gtHoldem',blinds:'gb1x2',seats:10,clubseq:clubObj.obj.seq,clubid:clubObj.obj._id,gamename:'unit test',game_limit:'glNoLimit',buyin_min:100000,buyin_max:150000,rake:0,rotation:0,hands:0});
					gamerow.save(function (err) {
						assert.ifError(err);
						Game.getGame(gamerow._id,function (err,gameObj) {
							assert.ifError(err);
							test.ok(gameObj);
							phase2(new DummyConn(owner),new DummyConn(opponent),gameObj);
						});
					});
				});
			});
		});
		function phase2(owner,opponent,gameObj) {
			owner.nick = 'owner';
			opponent.nick = 'opponent';
			owner.send = function (code,obj,type) {
				console.log('owner send:',code,obj,type);
			}
			opponent.send = function (code,obj,type) {
				console.log('opponent send:',code,obj,type);
			}
			console.log('this game is:',gameObj.id);
			gameObj.Lock.writeLock(function (release) {
				gameObj.join(owner,function (err) {
					test.ifError(err);
					gameObj.join(opponent,function (err) {
						test.ifError(err);
						gameObj.testing = true;
						gameObj.sitDown(owner,{chips:100000,seat_index:0},function (worked,events) {
							test.ok(worked);
							console.log(worked,events);
							gameObj.sitDown(opponent,{chips:100000,seat_index:2},function (worked,events) {
								test.ok(worked);
								console.log(worked,events);
								phase3(owner,opponent,gameObj,release);
							});
						});
					});
				});
			});
		}
		function phase3(owner,opponent,game,release) {
			game.members[0].status = 'psOutOfHand'; // FIXME, make a playnow function
			game.members[2].status = 'psOutOfHand';
			assert.equal(game.state,'tsIdle');
			game.stateMachine(function (events) {
				console.log(events);
				game.putChips(owner,200,function (events,offset) {
					console.log('put1',events,offset);
					game.putChips(opponent,200,function (events,offset) {
						console.log('put2',events,offset);
						assert.notEqual(game.flops[0].cards[0],game.turns[0].cards[0]);
						phase4(owner,opponent,game,release);
					});
				});
			},owner,{},[],0);
		}
		function phase4(owner,opponent,game,release) {
			delete activeGames[game.id];
			mdb.models.GameState.findOne({_id:game.obj._id}).lean(true).exec(function (err,state) {
				Game.getGame(game.id,function (err,game2) {
					//console.log('game2',game2);
					test.equal(state.history.cards.length,1);
					game2.resume(state,function () {});
					// reconnect players to game
					game2.reconnectUser(owner,true,0,function (status1) {
						console.log(status1);
						game2.reconnectUser(opponent,true,2,function (status2) {
							console.log(status2);
							game2.Lock.writeLock(function (release) {
								game2.putChips(opponent,0,function (events,offset) {
									console.log('put3',events,offset);
									game2.putChips(owner,0,function (events,offset) {
										console.log('put4',events,offset);
										phase5(owner,opponent,game2,release);
									});
								});
							});
						});
					});
				});
			});
		}
		function phase5(owner,opponent,game,release) {
			game.putChips(opponent,0,function (events,offset) {
				console.log('put5',events,offset);
				assert.notEqual(game.flops[0].cards[0],game.turns[0].cards[0]);
				game.putChips(owner,0,function (events,offset) {
					console.log('put6',events,offset);
					phase6(owner,opponent,game,release);
				});
			});
		}
		function phase6(owner,opponent,game,release) {
			game.putChips(opponent,0,function (events,offset) {
				console.log('put7',events,offset);
				console.log(game.flop,game.turn);
				assert.notEqual(game.flops[0].cards[0],game.turns[0].cards[0]);
				game.putChips(owner,0,function (events,offset) {
					console.log('put8',events,offset);
					mdb.models.GameState.findOne({_id:game.obj._id},function (err,state) {
						console.log(state);
						release();
						test.done();
						mdb.close();
					});
				});
			});
		}
	},
	headsup: function (test) {
		test.expect(9);
		global.activeUsers = {};
		global.sharedconfig = {max_play_time:15,max_timebank:30};
		global.log = console.log;
		global.pb = Core.pb;
		var activeGames = {};
		var Club = require('./club').Club;
		var Game = require('./game').Game;
		var profiler = require('profiler');
		mdb.open('nodeunit');
		Club.init(activeGames);
		myutils.init();
		profiler.setup(mdb.models.PokerProfile);
		Game.init(activeGames);
		mdb.models.UserModel.find().limit(2).exec(function (err,users) {
			assert.ifError(err);
			var owner = users[0];
			var opponent = users[1];
			test.ok(owner);
			test.ok(opponent);
			mdb.models.Clubs.remove({name:'clubname'},function (err) {
				assert.ifError(err);
				Club.createClub('clubname','password',owner._id,5,30,function (worked,clubObj) {
					test.ok(worked);
					clubid = clubObj.obj.seq;
					var gamerow = new mdb.models.Game({game_type:'gtHoldem',blinds:'gb1x2',seats:2,clubseq:clubObj.obj.seq,clubid:clubObj.obj._id,gamename:'unit test',game_limit:'glNoLimit',buyin_min:100000,buyin_max:150000,rake:0,rotation:0,hands:0});
					gamerow.save(function (err) {
						assert.ifError(err);
						Game.getGame(gamerow._id,function (err,gameObj) {
							assert.ifError(err);
							test.ok(gameObj);
							phase2(new DummyConn(owner),new DummyConn(opponent),gameObj);
						});
					});
				});
			});
		});
		function phase2(owner,opponent,gameObj) {
			owner.nick = 'owner';
			opponent.nick = 'opponent';
			owner.send = function (code,obj,type) {
				console.log('owner send:',code,obj,type);
			}
			opponent.send = function (code,obj,type) {
				console.log('opponent send:',code,obj,type);
			}
			console.log('this game is:',gameObj.id);
			gameObj.Lock.writeLock(function (release) {
				gameObj.join(owner,function (err) {
					test.ifError(err);
					gameObj.join(opponent,function (err) {
						test.ifError(err);
						gameObj.sitDown(owner,{chips:100000,seat_index:0},function (worked,events) {
							test.ok(worked);
							console.log(worked,events);
							gameObj.sitDown(opponent,{chips:100000,seat_index:1},function (worked,events) {
								test.ok(worked);
								console.log(worked,events);
								phase3(owner,opponent,gameObj,release);
							});
						});
					});
				});
			});
		}
		function phase3(owner,opponent,game,release) {
			game.members[0].status = 'psOutOfHand'; // FIXME, make a playnow function
			game.members[1].status = 'psOutOfHand';
			assert.equal(game.state,'tsIdle');
			game.stateMachine(function (events) {
				test.equal(events[0].event,'teDealing');
				clearTimeout(game.timer.timerid);
				mdb.close();
				test.done();
			},owner,{},[],0);
		}
	},
	splitholdem: function (test) {
		test.expect(15);
		global.activeUsers = {};
		global.sharedconfig = {max_play_time:15,max_timebank:30};
		global.log = console.log;
		global.pb = Core.pb;
		var activeGames = {};
		var Club = require('./club').Club;
		var Game = require('./game').Game;
		var profiler = require('profiler');
		mdb.open('nodeunit');
		Club.init(activeGames);
		myutils.init();
		profiler.setup(mdb.models.PokerProfile);
		Game.init(activeGames);
		mdb.models.UserModel.find().limit(2).exec(function (err,users) {
			assert.ifError(err);
			var owner = users[0];
			var opponent = users[1];
			test.ok(owner);
			test.ok(opponent);
			mdb.models.Clubs.remove({name:'clubname'},function (err) {
				assert.ifError(err);
				Club.createClub('clubname','password',owner._id,5,30,function (worked,clubObj) {
					test.ok(worked);
					clubid = clubObj.obj.seq;
					var gamerow = new mdb.models.Game({game_type:'gtHoldem',blinds:'gb1x2',seats:6,clubseq:clubObj.obj.seq,clubid:clubObj.obj._id,gamename:'unit test',game_limit:'glNoLimit',buyin_min:100000,buyin_max:150000,rake:0,rotation:0,hands:0});
					gamerow.save(function (err) {
						assert.ifError(err);
						Game.getGame(gamerow._id,function (err,gameObj) {
							assert.ifError(err);
							test.ok(gameObj);
							phase2(new DummyConn(owner),new DummyConn(opponent),gameObj);
						});
					});
				});
			});
		});
		function phase2(owner,opponent,gameObj) {
			owner.nick = 'owner';
			opponent.nick = 'opponent';
			owner.send = function (code,obj,type) {
				//console.log('owner send:',code,obj,type);
			}
			opponent.send = function (code,obj,type) {
				//console.log('opponent send:',code,obj,type);
			}
			console.log('this game is:',gameObj.id);
			gameObj.Lock.writeLock(function (release) {
				gameObj.join(owner,function (err) {
					test.ifError(err);
					gameObj.join(opponent,function (err) {
						test.ifError(err);
						gameObj.testing = true;
						gameObj.sitDown(owner,{chips:100000,seat_index:0},function (worked,events) {
							test.ok(worked);
							console.log(worked,events);
							gameObj.sitDown(opponent,{chips:100000,seat_index:1},function (worked,events) {
								test.ok(worked);
								console.log(worked,events);
								phase3(owner,opponent,gameObj,release);
							});
						});
					});
				});
			});
		}
		function phase3(owner,opponent,game,release) {
			game.members[0].status = 'psAllIn';
			game.members[1].status = 'psInHand';
			game.members[0].want_split = true;
			game.members[1].want_split = true;
			game.members[0].hand = new Hand();
			game.members[1].hand = new Hand();
			game.members[0].sitOutNextRound = true;
			game.state = 'tsPreFlop';
			game.flops = [ new Hand() ];
			game.turns = [ new Hand() ];
			game.rivers = [ new Hand() ];
			game.history = { cards:[], moves:[], players:[{},{}] };
			game.balance_changes = [0,0];
			game.bets = [ 100,100 ];
			game.current_seat = 0;
			game.dealer = 0;
			game.rake = 0;
			game.real_rake = 0;
			game.deck.cards = [1,40,17,41,29,51,48,20,9,25,13,19,46,42,10,8,16,47,0,11,18,14,31,4,2,24,32,33,6,15,12,39,21,37,30,26,34,7,22,3,35,27,44,5,36,50,49,28,23,43,38,45];
			game.deck.draw(2,game.members[0].hand);
			game.deck.draw(2,game.members[1].hand);
			game.stateMachine(function (events) {
				test.equal(events.length,5);
				test.equal(events[0].event,'teFlop');
				test.equal(events[1].event,'teTurn');
				test.equal(events[2].event,'teRiver');
				test.equal(events[3].event,'tePostRiver');
				test.equal(events[4].event,'teWinning');
				test.equal(events[4].pots[0].value,200);
				console.log('event 4',events[4].pots[0].WinnerData);
				release();
				game.stopTimer();
				setTimeout(function () {
					mdb.close();
					test.done();
				},1000);
			},owner,{},[],0);
		}
	},
	splitomaha: function (test) {
		global.activeUsers = {};
		global.sharedconfig = {max_play_time:15,max_timebank:30};
		global.log = console.log;
		global.pb = Core.pb;
		var activeGames = {};
		var Club = require('./club').Club;
		var Game = require('./game').Game;
		var profiler = require('profiler');
		mdb.open('nodeunit');
		Club.init(activeGames);
		myutils.init();
		profiler.setup(mdb.models.PokerProfile);
		Game.init(activeGames);
		mdb.models.UserModel.find().limit(2).exec(function (err,users) {
			assert.ifError(err);
			var owner = users[0];
			var opponent = users[1];
			test.ok(owner);
			test.ok(opponent);
			mdb.models.Clubs.remove({name:'clubname'},function (err) {
				assert.ifError(err);
				Club.createClub('clubname','password',owner._id,5,30,function (worked,clubObj) {
					test.ok(worked);
					clubid = clubObj.obj.seq;
					var gamerow = new mdb.models.Game({game_type:'gtOmaha',blinds:'gb1x2',seats:6,clubseq:clubObj.obj.seq,clubid:clubObj.obj._id,gamename:'unit test',game_limit:'glNoLimit',buyin_min:100000,buyin_max:150000,rake:0,rotation:0,hands:0});
					gamerow.save(function (err) {
						assert.ifError(err);
						Game.getGame(gamerow._id,function (err,gameObj) {
							assert.ifError(err);
							test.ok(gameObj);
							phase2(new DummyConn(owner),new DummyConn(opponent),gameObj);
						});
					});
				});
			});
		});
		function phase2(owner,opponent,gameObj) {
			owner.nick = 'owner';
			opponent.nick = 'opponent';
			owner.send = function (code,obj,type) {
				//console.log('owner send:',code,obj,type);
			}
			opponent.send = function (code,obj,type) {
				//console.log('opponent send:',code,obj,type);
			}
			console.log('this game is:',gameObj.id);
			gameObj.Lock.writeLock(function (release) {
				gameObj.join(owner,function (err) {
					test.ifError(err);
					gameObj.join(opponent,function (err) {
						test.ifError(err);
						gameObj.testing = true;
						gameObj.sitDown(owner,{chips:100000,seat_index:0},function (worked,events) {
							test.ok(worked);
							console.log(worked,events);
							gameObj.sitDown(opponent,{chips:100000,seat_index:1},function (worked,events) {
								test.ok(worked);
								console.log(worked,events);
								phase3(owner,opponent,gameObj,release);
							});
						});
					});
				});
			});
		}
		function phase3(owner,opponent,game,release) {
			game.members[0].status = 'psAllIn';
			game.members[1].status = 'psInHand';
			game.members[0].want_split = true;
			game.members[1].want_split = true;
			game.members[0].hand = new Hand();
			game.members[1].hand = new Hand();
			game.members[0].sitOutNextRound = true;
			game.state = 'tsPreFlop';
			game.flops = [ new Hand() ];
			game.turns = [ new Hand() ];
			game.rivers = [ new Hand() ];
			game.history = { cards:[], moves:[], players:[{},{}] };
			game.balance_changes = [0,0];
			game.bets = [ 100,100 ];
			game.current_seat = 0;
			game.dealer = 0;
			game.rake = 0;
			game.real_rake = 0;
			game.deck.cards = [1,40,17,41,29,51,48,20,9,25,13,19,46,42,10,8,16,47,0,11,18,14,31,4,2,24,32,33,6,15,12,39,21,37,30,26,34,7,22,3,35,27,44,5,36,50,49,28,23,43,38,45];
			game.deck.draw(4,game.members[0].hand);
			game.deck.draw(4,game.members[1].hand);
			game.stateMachine(function (events) {
				console.log('events',events);
				release();
				game.stopTimer();
				setTimeout(function () {
					mdb.close();
					test.done();
				},1000);
			},owner,{},[],0);
		}
	},
	rakecontrib: function (test) {
		rakecontrib_template({bets:[100,200],cap:25,mainrake:26,contrib:13},test,template2);
		function template2() {
			rakecontrib_template({bets:[1000,2000],cap:100,mainrake:100,contrib:50},test,function () {
				test.done();
			});
		}
	}
};
function rakecontrib_template(opts,test,finalcb) {
	global.activeUsers = {};
	global.sharedconfig = {max_play_time:15,max_timebank:30};
	global.log = console.log;
	global.pb = Core.pb;
	global.ignoreThrottle = true;
	var activeGames = {};
	var Club = require('./club').Club;
	var Game = require('./game').Game;
	var profiler = require('profiler');
	mdb.open('nodeunit');
	Club.init(activeGames);
	myutils.init();
	profiler.setup(mdb.models.PokerProfile);
	Game.init(activeGames);
	mdb.models.UserModel.find().limit(2).exec(function (err,users) {
		assert.ifError(err);
		var owner = users[0];
		var opponent = users[1];
		test.ok(owner);
		test.ok(opponent);
		mdb.models.Clubs.remove({name:'clubname'},function (err) {
			assert.ifError(err);
			Club.createClub('clubname','password',owner._id,5,30,function (worked,clubObj) {
				test.ok(worked);
				clubid = clubObj.obj.seq;
				var gamerow = new mdb.models.Game({game_type:'gtHoldem',blinds:'gb1x2',seats:2,clubseq:clubObj.obj.seq,clubid:clubObj.obj._id,gamename:'unit test',game_limit:'glNoLimit',buyin_min:100000,buyin_max:150000,rake:10,rotation:0,hands:0,max_rake_per_hand:opts.cap});
				gamerow.save(function (err) {
					assert.ifError(err);
					Game.getGame(gamerow._id,function (err,gameObj) {
						assert.ifError(err);
						test.ok(gameObj);
						phase2(new DummyConn(owner),new DummyConn(opponent),gameObj);
					});
				});
			});
		});
	});
	function phase2(owner,opponent,gameObj) {
		owner.nick = 'owner';
		opponent.nick = 'opponent';
		owner.send = function (code,obj,type) {
			console.log('owner send:',code,obj,type);
		}
		opponent.send = function (code,obj,type) {
			console.log('opponent send:',code,obj,type);
		}
		//console.log('this game is:',gameObj.id);
		gameObj.Lock.writeLock(function (release) {
			gameObj.join(owner,function (err) {
				test.ifError(err);
				gameObj.join(opponent,function (err) {
					test.ifError(err);
					gameObj.sitDown(owner,{chips:100000,seat_index:0},function (worked,events) {
						test.ok(worked);
						console.log(worked,events);
						gameObj.sitDown(opponent,{chips:100000,seat_index:1},function (worked,events) {
							test.ok(worked);
							console.log(worked,events);
							phase3(owner,opponent,gameObj,release);
						});
					});
				});
			});
		});
	}
	function phase3(owner,opponent,game,release) {
		game.members[0].status = 'psInHand';
		game.members[1].status = 'psInHand';
		game.members[0].hand = new Hand();
		game.members[1].hand = new Hand();
		game.members[0].sitOutNextRound = true;
		game.seats[0].rakecontrib = 0;
		game.seats[1].rakecontrib = 0;
		game.state = 'tsPreFlop';
		game.flops = [ new Hand() ];
		game.turns = [ new Hand() ];
		game.rivers = [ new Hand() ];
		game.history = { cards:[], moves:[], players:[{},{}] };
		game.balance_changes = [0,0];
		game.bets = [ opts.bets[0], opts.bets[0] ];
		game.current_seat = 0;
		game.dealer = 0;
		game.rake = 0;
		game.real_rake = 10;
		game.deck.cards = [1,40,17,41,29,51,48,20,9,25,13,19,46,42,10,8,16,47,0,11,18,14,31,4,2,24,32,33,6,15,12,39,21,37,30,26,34,7,22,3,35,27,44,5,36,50,49,28,23,43,38,45];
		game.deck.draw(2,game.members[0].hand);
		game.deck.draw(2,game.members[1].hand);
		game.deck.draw(2,game.members[0].hand);
		game.stateRow.moveCounter = 0;
		game.putChips(owner,opts.bets[1],function (events,offset) {
			test.equal(events[0].event,'teRaise');
			game.putChips(opponent,opts.bets[1],function (events,offset) {
				var contrib = (game.real_rake / 100) * opts.bets[1];
				test.equal(game.seats[0].rakecontrib,contrib);
				test.equal(game.seats[1].rakecontrib,contrib);
				game.putChips(opponent,0,function (events,offset) {
					game.putChips(owner,0,function (events,offset) {
						game.putChips(opponent,0,function (events,offset) {
							game.putChips(owner,0,function (events,offset) {
								game.putChips(opponent,0,function (events,offset) {
									game.putChips(owner,0,function (events,offset) {
										console.log('EVENT'.green,events[2]);
										test.equal(events[2].pots[0].rake,opts.mainrake);
										phase4(game);
										game.stopTimer();
										release();
									});
								});
							});
						});
					});
				});
			});
		});
	}
	function phase4(game) {
		test.equal(game.seats[0].rakecontrib,opts.contrib);
		test.equal(game.seats[1].rakecontrib,opts.contrib);
		mdb.close();
		finalcb();
	}
}
exports.user = {
	changePassword: function (test) {
		var user = require('./user');
		mdb.open('nodeunit');
		mdb.models.UserModel.findOne(function (err,user2) {
			if (err) {
				console.log(err);
				test.done();
				return;
			}
			var oldsalt = user2.salt;
			var oldpass = user2.password;
			user.changePassword('password',user2._id,function (err,row) {
				if (err) {
					console.log(err);
					test.done();
					return;
				}
				var hasher = crypto.createHash('sha256');
				hasher.update(row.salt);
				hasher.update('password');
				var hash = hasher.digest();
				assert.equal(hash.toString('hex'),row.password.toString('hex'));
				user2.salt = oldsalt;
				user2.password = oldpass;
				user2.save(function (err) {
					assert.ifError(err);
					mdb.close();
					test.done();
				});
			});
		});
	}
};
exports.tournament = {
	start: function (test) {
		mdb.open('nodeunit');
		var Tournament = require('./tournament');
		var activeGames = {};
		global.activeUsers = {};
		var game = require('./game');
		var profiler = require('profiler');
		game.Game.init(activeGames);
		profiler.setup(mdb.models.PokerProfile);
		function setupUsers() {
			var todo = [];
			for (var x=0; x<12; x++) {
				var user = {displayname:'test'+x,email:'test'+x+'@server.com'};
				todo.push(user);
			}
			var users = [];
			async.each(todo,function (x,cb) {
				mdb.models.UserModel.remove({displayname:x.displayname},function (err,y) {
					mdb.models.UserModel.create(x,function (err,doc) {
						assert.ifError(err);
						console.log('made',doc);
						users.push({_id:doc._id, displayname:doc.displayname, chips:150000});
						cb();
					});
				});
			},function (err) {
				assert.ifError(err);
				console.log('done making users');
				dotest(users);
			});
		}
		function dotest(users) {
			var blind_schedule = Tournament.PrintBlindStructure(5,10,1000,10,1);
			mdb.models.Tournament.create({ "description" : "notes", "gametype" : "gtHoldem", "limit" : "glNoLimit", "maxplayers" : 20, "minplayers" : 10, "name" : "name", "registered_players" : users.length, "seats_per_table" : 9, "start_time" : 1406628000, "startingchips" : 1500, "state" : "tnsOpen", "timeperlevel" : 15,players:users, prizes:[{place:0,name:'gold'}], blind_schedule:blind_schedule, length:1, sb:5, bb:10 },function (err,doc) {
			if (err) {
				console.log(err);
				test.done();
			}
			console.log('tournament made',arguments);
			Tournament.core.commonLock.writeLock(function (release) {
				Tournament.core.startTournament(doc,function () {
					release();
					test.done();
					mdb.close();
				});
			});
		});
		}
		setupUsers();
	}
};
process.on('uncaughtException',function (err) {
	console.log(err);
	console.log(err.stack);
	process.exit(1);
});
