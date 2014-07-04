module.exports.start = start;
module.exports.setup = setup;

var util = require('./build/Release/profile_util');

var PokerProfile;
function setup(input) {
	PokerProfile = input;
	console.log(util);
}

function start(tag) {
	return new Token(tag);
}

function Token(tag) {
	this.tag = tag;
	this.start = Date.now();
}
Token.prototype.stop = function () {
	var end = Date.now();
	var doc = {time:end-this.start, tag:this.tag};
	PokerProfile.create(doc,function (err,result){});
}
