var async = require('async');

var Tournament = require('./tournament.js'),
	ReadWriteLock = require('./lock');

function FakeTournament (input,test) {
	this.test = test;
	this.Lock = new ReadWriteLock();
	this.bustQueue = {};
	this.obj = { players:[], seats_per_table:input.seats };
	for (var x=0; x<input.players.length; x++) {
		this.obj.players[x] = { chips:10000, _id:'user'+x, gameid:'mongoid1', seat_index:x, nick:input.players[x] };
	}
	this.log = { records: {} };
	this.log.records.push = function (item) {
		console.log(" LOG:%j",item);
	};
	this.log.save = function (cb) {
		test.ok(true);
		cb();
	}
	this.obj.save = function (cb) {
		test.ok(true);
		cb();
	};
	this.tables = [];
	for (var x=0; x<input.tables.length; x++) {
		this.tables[x] = new FakeGame(this,input.tables[x]);
		this.tables[x].dealer = input.dealers[x];
	}
	this.user_table_xref = {};
	this.obj.prizes = [];
	this.obj.prizes[0] = { place:0, name:'gold' };
}
FakeTournament.prototype.handOver = Tournament.prototype.handOver;
FakeTournament.prototype.countPlayersPerTable = Tournament.prototype.countPlayersPerTable;
FakeTournament.prototype.countPlayers = Tournament.prototype.countPlayers;
FakeTournament.prototype.findEmptyTable = Tournament.prototype.findEmptyTable;
FakeTournament.prototype.doRebalance = Tournament.prototype.doRebalance;
FakeTournament.prototype.findHoles = Tournament.prototype.findHoles;
FakeTournament.prototype.findCandidates = Tournament.prototype.findCandidates;
FakeTournament.prototype.emit = function (event,obj) {
	console.log(' EMIT: %s',event);
}
FakeTournament.prototype.postTransfer = function () {
}
FakeTournament.prototype.rerebalance = function () {
}
function FakeGame(tourn,input) {
	this.obj = { gamename:'1', seats:tourn.obj.seats_per_table };
	this.id = 'gameid1'; // FIXME, should be unique, along with gamename above
	this.members = [];
	this.seats = [];
	for (var x=0; x<input.length; x++) {
		this.members[x] = { disconnected:true, chips:10000 };
		console.log('game input:%d %j',input[x],tourn.obj.players);
		this.seats[x] = { conn:{nick:tourn.obj.players[input[x]].nick }, userid:'user'+input[x] };
	}
	this.Lock = new ReadWriteLock();
	this.lastplayer = [];
	this.users = {};
	this.reconnect = [];
	this.test = tourn.test;
}
FakeGame.prototype.log = function () {
	arguments[0] = ' GLOG:'+arguments[0];
	console.log.apply(console,arguments);
}
FakeGame.prototype.makeEvent = function (code,data) {
	console.log('make event:%s',code);
}
FakeGame.prototype.standUp = function (conn,cb) {
	cb();
}
FakeGame.prototype.leave = function (conn,reason,cb) {
	this.test.equal(reason,'tournamentWinner');
	cb();
}
FakeGame.prototype.broadcastStatus = function () {
	this.test.ok(true);
}
exports.tournament = {
	basic: function (test) {
		var input = { seats:6, players:['zero','one','two','three','four'], tables:[ [0,1,2,3,4] ], trigger:0, dealers:[0] };
		test.expect(3);
		console.log('input:%j',input);
		var tourn = new FakeTournament(input,test);
		tourn.handOver(tourn.tables[input.trigger],function () {
			test.ok(true);
			test.done();
		});
	},split_4_2: function (test) {
		var input = { seats:6, players:['zero','one','two','three','four','five'], tables:[ [0,1,2,3], [4,5] ], trigger:1, dealers:[0,0] };
		test.expect(7);
		console.log('input:%j',input);
		var tourn = new FakeTournament(input,test);
		tourn.handOver(tourn.tables[input.trigger],function () {
			test.ok(true);
			test.done();
		});
	},end_boot: function (test) {
		global.activeUsers = {};
		global.activeUsers.user0 = {};
		global.activeUsers.user0.send = function (code,obj,type) {
			test.equal(type,'Poker.TournamentPlayerFinished');
			test.equal(obj.place,0);
			test.equal(obj.prize.name,'gold');
		}
		var input = { seats:6, players:['winner'], tables:[ [0] ], trigger:0, dealers:[0] };
		test.expect(7);
		console.log('tournament input:%j',input);
		var tourn = new FakeTournament(input,test);
		tourn.handOver(tourn.tables[input.trigger],function () {
			test.ok(true);
			test.done();
		});
	}
};
