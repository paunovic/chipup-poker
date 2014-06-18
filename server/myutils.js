var ObjectID = require('mongodb').ObjectID;
var assert = require('assert');

module.exports.toMongoId = toMongoId;
module.exports.fromMongoId = fromMongoId;
module.exports.compareObjectID = compareObjectID;
module.exports.getNextSequence = getNextSequence;
var allCounters;
module.exports.init = function (db) {
	allCounters = db.collection('counters');
}
function toMongoId(buf) {
	return new ObjectID(buf.toString('hex'));
}
function fromMongoId(id) {
	return new Buffer(id.id,'binary');
}
function compareObjectID(a,b) {
	if (!b) return false;
	var astr = a.toString();
	var bstr = b.toString();
	return astr == bstr;
}
function getNextSequence(name,cb) {
	allCounters.findAndModify({_id:name},[],
		{ $inc:{seq:1}},
	function (err,res) {
		assert.ifError(err);
		//console.log('seq',name,err,res);
		if (res) {
			cb(res.seq);
		} else {
			allCounters.insert({_id:name,seq:0},function (err,row) {
				cb(1);
			});
		}
	});
}
