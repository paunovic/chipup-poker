var assert = require('assert');

var activeGames;

module.exports.makeGameProtobuf = makeGameProtobuf;
module.exports.init = function (input) {
	activeGames = input;
}

function makeGameProtobuf(g) {
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
	g._id = new Buffer(g._id.toString(),'hex');
	assert(g._id.length > 0);
	g.creator_mongo_id = new Buffer(g.creator_mongo_id.toString(),'hex');
	return g;
}
