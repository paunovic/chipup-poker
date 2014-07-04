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

function Token(tag) {
	this.tag = tag;
	this.start = Date.now();
	this.cpustart = util.getCpuTime();
}
Token.prototype.stop = function () {
	var end = Date.now();
	var cpuend = util.getCpuTime();
	var nanodiff = cpuend.tv_nsec - this.cpustart.tv_nsec;
	nanodiff += (cpuend.tv_sec - this.cpustart.tv_sec) * 1000000000
	nanodiff /= 1000000;
	var doc = {time:end-this.start, tag:this.tag,cputime:nanodiff};
	PokerProfile.create(doc,function (err,result){});
}
