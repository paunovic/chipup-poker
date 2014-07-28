var models = require('./db').models,
	util = require('util'),
	EventEmitter = require('events').EventEmitter,
	myutils = require('./myutils');

var error = require('./error');

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
		cb();
	});
}
function TournamentCore() {
}
util.inherits(TournamentCore,EventEmitter);
util.inherits(Tournament,EventEmitter);
TournamentCore.prototype.join = function (tournid,userid,cb) {
	models.Tournament.findById(tournid,function (err,doc) {
		console.log(err,userid,doc);
		if (myutils.containsObjectID(doc.players,userid)) {
			// error, already a member
			return cb('alreadyMember');
		} else if (doc.registered_players => doc.maxplayers) {
			return cb('full');
		} else {
			doc.players.push(userid);
			doc.registered_players = doc.players.length;
			doc.save(function (err) {
				console.log('saved',arguments,doc);
				cb('OK');
			});
		}
	});
}
TournamentCore.prototype.leave = function (tournid,userid,cb) {
	models.Tournament.findById(tournid,function (err,doc) {
		doc.players.pull(userid);
		doc.save(function (err) {
			error.handleError(err);
			cb('OK');
		});
	});
}
var core = new TournamentCore();
Tournament.core = core;
