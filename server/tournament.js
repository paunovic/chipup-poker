var models = require('./db').models,
	util = require('util'),
	EventEmitter = require('events').EventEmitter;

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
var core = new TournamentCore();
Tournament.core = core;
