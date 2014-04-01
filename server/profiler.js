module.exports.start = start;
module.exports.setup = setup;

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
}
Token.prototype.stop = function () {
	var end = Date.now();
	var doc = {time:end-start, tag:this.tag};
	PokerProfiler.insert(doc,function (err,result){});
}
