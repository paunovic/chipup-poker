var ObjectID = require('mongodb').ObjectID;
var assert = require('assert');

module.exports.toMongoId = toMongoId;
module.exports.fromMongoId = fromMongoId;
module.exports.compareObjectID = compareObjectID;
module.exports.getNextSequence = getNextSequence;
module.exports.containsObjectID = containsObjectID;
module.exports.throttle = throttle;

var models = require('./db').models;

module.exports.init = function () {
	models.Counter.create({_id:'club',seq:1},function (err,res) {}); // default value
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
	models.Counter.findOneAndUpdate({_id:name},
		{ $inc:{seq:1}},
	function (err,res) {
		assert.ifError(err);
		//console.log('seq',name,err,res);
		if (res) {
			cb(res.seq);
		} else {
			models.Counter.create({_id:name,seq:0},function (err,row) {
				cb(1);
			});
		}
	});
}
function containsObjectID(list,id) {
	for (var x=0; x<list.length; x++) {
		if (compareObjectID(id,list[x])) return true;
	}
	return false;
}
var throttled_funcs = {};
function throttle(key,interval,func) {
	console.log(throttled_funcs);
	if (!throttled_funcs[key]) {
		throttled_funcs[key] = { lastrun: Date.now() };
		func();
		return;
	}
	if ((Date.now() - throttled_funcs[key].lastrun) > (interval * 1000)) {
		if (throttled_funcs[key].timer) clearTimeout(throttled_funcs[key].timer);
		throttled_funcs[key].timer = null;
		throttled_funcs[key].lastrun = Date.now();
		func();
		return;
	}
	if (throttled_funcs[key].timer) clearTimeout(throttled_funcs[key].timer);
	throttled_funcs[key].timer = setTimeout(function () {
		throttled_funcs[key].timer = null;
		throttled_funcs[key].lastrun = Date.now();
		func();
	},(interval * 1000) - (Date.now() - throttled_funcs[key].lastrun));
}
