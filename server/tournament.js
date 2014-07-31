var models = require('./db').models,
	util = require('util'),
	EventEmitter = require('events').EventEmitter,
	myutils = require('./myutils');

var error = require('./error');

var async = require('async');

module.exports = Tournament;

function Tournament() {
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
		core.resetTimer();
		cb();
	});
}
function TournamentCore() {
}
util.inherits(TournamentCore,EventEmitter);
util.inherits(Tournament,EventEmitter);
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
TournamentCore.prototype.resetTimer = function () {
	if (this.timer) clearTimeout(this.timer);
	delete this.timer;
	models.Tournament.find({state:'tnsOpen'},{name:1,start_time:1,state:1}).sort({start_time:1}).limit(1).exec(function (err,rows) {
		if (rows.length != 1) return; // dont start a timer, there is nothing to wait for
		var row = rows[0];
		var now = Date.now() / 1000;
		var timeleft = row.start_time - now;
		if (timeleft < 0) this.checkTournaments();
		else {
			console.log('found',err,rows,timeleft);
			console.log('%d now',now);
			console.log('%d goal',row.start_time);
			this.timer = setTimeout(this.checkTournaments.bind(this),(timeleft+60)*1000);
		}
	}.bind(this));
}
TournamentCore.prototype.checkTournaments = function () {
	models.Tournament.find({state:'tnsOpen'}).sort({name:1,start_time:1}).limit(1).exec(function (err,rows) {
		if (rows.length != 1) return; // nothing found
		var row = rows[0];
		var now = Date.now() / 1000;
		var timeleft = row.start_time - now;
		if (timeleft > 0) return this.resetTimer();
		if (row.registered_players < row.minplayers) {
			row.state = 'tnsCancelled';
			row.save(function () {
				core.emit('tournament_start',row);
				this.resetTimer();
			}.bind(this));
			return;
		}
		this.startTournament(row,function () {
			this.resetTimer();
		});
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
	async.each(todo,function (doc,cb) {
		models.Game.create(doc,function (err,game) {
			cb();
		});
	},function () {
		row.save(function () {
			this.emit('tournament_start',row);
			cb();
		}.bind(this));
	}.bind(this));
}
var core = new TournamentCore();
Tournament.core = core;
