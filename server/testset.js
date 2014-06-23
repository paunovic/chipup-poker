var Core = require('./core');
var async = require('async');
var http = require('http');
var MongoClient = require('mongodb').MongoClient;
var async = require('async');
var assert = require('assert');
var mongoose = require('mongoose');

var mdb = require('./db');
var myutils = require('./myutils');

var clubid;

process.send = function (obj) {
	console.log(obj);
}

exports.club = {
	makeanddelete: function (test) {
		var activeUsers = {};
		var activeGames = {};
		var Club = require('./club').Club
		test.expect(3);
		mdb.open();
		Club.init(activeUsers,activeGames,Core.pb);
		myutils.init();
		mdb.models.UserModel.findOne(function (err,user) {
			test.ok(user);
			mdb.models.Clubs.remove({name:'clubname'},function (err) {
				Club.createClub('clubname','password',user._id,5,function (worked,clubObj) {
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
	},
	joinClub: function (test) {
		var activeUsers = {};
		var activeGames = {};
		var Club = require('./club').Club;
		mdb.open();
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
						mdb.close();
						test.done();
				})
			});
		});
	},
	goPublic: function (test) {
		var activeUsers = {};
		var activeGames = {};
		var Club = require('./club').Club;
		var game = require('./game');
		test.expect(6);
		activeUsers['fake'] = { send: function(code,object,type) {
			test.ok(true);
		}};
		mdb.open();
		Club.init(activeUsers,activeGames,Core.pb);
		game.Game.init(activeGames,activeUsers,{},null,null,null);
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
		var activeUsers = {};
		var activeGames = {};
		var Club = require('./club').Club;
		test.expect(5);
		mdb.open();
		Club.init(activeUsers,activeGames,Core.pb);
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
		mdb.open();
		Club.init(activeUsers,activeGames,Core.pb);
		myutils.init();
		Club.getClubBySeq(clubid,function (err,clubObj) {
			test.ok(clubObj);
			clubObj.Leave(clubObj.obj.members[0],function () {
				test.ok(true);
				mdb.close();
				test.done();
			});
		});
	},
	changeOwner: function (test) {
		var activeUsers = {};
		var activeGames = {};
		var Club = require('./club').Club;
		mdb.open();
		Club.init(activeUsers,activeGames,Core.pb);
		myutils.init();
		Club.getClubBySeq(clubid,function (err,clubObj) {
			test.ok(clubObj);
			clubObj.setOwner(clubObj.obj.members[0],function () {
				mdb.close();
				test.done();
			});
		});
	},
	deleteClub: function (test) {
		var activeUsers = {};
		var activeGames = {};
		var Club = require('./club').Club;
		mdb.open();
		test.expect(1);
		Club.init(activeUsers,activeGames,Core.pb);
		myutils.init();
		Club.getClubBySeq(clubid,function (err,clubObj) {
			test.ok(clubObj);
			console.log(clubObj);
			clubObj.deleteClub(function () {
				mdb.close();
				test.done();
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
		var activeUsers = {};
		var activeGames = {};
		var Club = require('./club').Club;
		var Game = require('./game').Game;
		var profiler = require('./profiler');
		mdb.open();
		Club.init(activeUsers,activeGames,Core.pb);
		myutils.init();
		profiler.setup(mdb.models.PokerProfile);
		Game.init(activeGames,activeUsers,{max_play_time:15,max_timebank:30},console.log,{});
		mdb.models.UserModel.find().limit(2).exec(function (err,users) {
			assert.ifError(err);
			var owner = users[0];
			var opponent = users[1];
			test.ok(owner);
			test.ok(opponent);
			mdb.models.Clubs.remove({name:'clubname'},function (err) {
				assert.ifError(err);
				Club.createClub('clubname','password',owner._id,5,function (worked,clubObj) {
					test.ok(worked);
					clubid = clubObj.obj.seq;
					var gamerow = new mdb.models.Game({game_type:'gtHoldem',blinds:'gb1x2',seats:10,clubseq:clubObj.obj.seq,clubid:clubObj.obj._id,gamename:'unit test',game_limit:'glNoLimit',buyin_min:5,buyin_max:500,rake:0,rotation:0,hands:0});
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
					phase5(owner,opponent,game,release);
				});
			});
		}
		function phase5(owner,opponent,game,release) {
			game.putChips(opponent,0,function (events,offset) {
				console.log('put5',events,offset);
				game.putChips(owner,0,function (events,offset) {
					console.log('put6',events,offset);
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
						release();
						test.done();
						mdb.close();
					});
				});
			});
		}
	},
	resume: function (test) {
		var activeUsers = {};
		var activeGames = {};
		var Club = require('./club').Club;
		var Game = require('./game').Game;
		var profiler = require('./profiler');
		mdb.open();
		Club.init(activeUsers,activeGames,Core.pb);
		myutils.init();
		profiler.setup(mdb.models.PokerProfile);
		Game.init(activeGames,activeUsers,{max_play_time:15,max_timebank:30},console.log,DummyConn);
		mdb.models.UserModel.find().limit(2).exec(function (err,users) {
			assert.ifError(err);
			var owner = users[0];
			var opponent = users[1];
			test.ok(owner);
			test.ok(opponent);
			mdb.models.Clubs.remove({name:'clubname'},function (err) {
				assert.ifError(err);
				Club.createClub('clubname','password',owner._id,5,function (worked,clubObj) {
					test.ok(worked);
					clubid = clubObj.obj.seq;
					var gamerow = new mdb.models.Game({game_type:'gtHoldem',blinds:'gb1x2',seats:10,clubseq:clubObj.obj.seq,clubid:clubObj.obj._id,gamename:'unit test',game_limit:'glNoLimit',buyin_min:5,buyin_max:500,rake:0,rotation:0,hands:0});
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
				game.putChips(owner,0,function (events,offset) {
					console.log('put6',events,offset);
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
						release();
						test.done();
						mdb.close();
					});
				});
			});
		}
	}
};
process.on('uncaughtException',function (err) {
	console.log(err);
	console.log(err.stack);
	process.exit(1);
});
