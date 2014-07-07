module.exports.start = start;
module.exports.setup = setup;

var util = require('./build/Release/profile_util');

var PokerProfile;
function setup(input) {
	PokerProfile = input;
}

function start(tag) {
	return new Token(tag);
}

function diff_timespec(start,end) {
	var nanodiff = end.tv_nsec - start.tv_nsec;
	nanodiff += (end.tv_sec - start.tv_sec) * 1000000000
	nanodiff /= 1000000;
	return nanodiff;
}
function Token(tag) {
	this.tag = tag;
	this.start = util.getMonoTime();
	this.cpustart = util.getCpuTime();
}
Token.prototype.stop = function () {
	var end = util.getMonoTime();
	var cpuend = util.getCpuTime();
	var nanodiff = diff_timespec(this.cpustart,cpuend);
	var realdiff = diff_timespec(this.start,end);
	var doc = {time:realdiff, tag:this.tag,cputime:nanodiff};
	PokerProfile.create(doc,function (err,result){});
}
