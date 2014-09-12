var async = require('async');

var Tournament = require('./tournament.js'),
	ReadWriteLock = require('./lock');

exports.tournament = {
	balance: function (test) {
		function FakeTournament (input) {
			this.Lock = new ReadWriteLock();
			this.bustQueue = {};
			this.obj = { players:[], seats_per_table:input.seats };
			for (var x=0; x<input.players.length; x++) {
				this.obj.players[x] = { chips:10000, userid:'user'+x, gameid:'mongoid1', seat_index:x };
			}
			this.log = { records: {} };
			this.log.records.push = function (item) {
				console.log("LOG:%j",item);
			};
			this.log.save = function (cb) {
				console.log('log save');
				cb();
			}
			this.obj.save = function (cb) {
				console.log('tourn save');
				cb();
			};
		}
		FakeTournament.prototype.handOver = Tournament.prototype.handOver;
		FakeTournament.prototype.countPlayersPerTable = function () {
			return { counts:{}, total:this.obj.players.length, players_at_this_table:5, min:5, max:5 };
		};
		FakeTournament.prototype.emit = function (event,obj) {
			console.log('EMIT: %s',event);
		}
		function FakeGame() {
			this.obj = { gamename:'1' };
			this.id = 'mongoid1';
			this.members = [];
			this.seats = [];
			for (var x=0; x<5; x++) {
				this.members[x] = {};
				this.seats[x] = {};
			}
		}
		var inputs = [
			{ seats:6, players:['zero','one','two','three','four'] }
		];
		test.expect(inputs.length * 1);
		async.eachSeries(inputs,function (input,cb) {
			console.log('input:%j',input);
			var tourn = new FakeTournament(input);
			var game = new FakeGame();
			tourn.handOver(game,function () {
				test.ok(true);
				cb();
			});
		},function () {
			test.done();
		});
	}
};
