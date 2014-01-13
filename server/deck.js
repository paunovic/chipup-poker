var fs = require('fs');
var rand = -1;
fs.open('/dev/urandom','r',function (err,fd) {
	if (err) return console.log('cant open random:',err);
	rand = fd;
	if (require.main === module) {
		var deck = new Deck();
		console.log('initial  deck is',deck.prettyPrint());
		deck.shuffle(function () {
			console.log('shuffled deck is',deck.prettyPrint());
		});
	}
});
module.exports = Deck;
function Deck() {
	if (!(this instanceof Deck)) return new Deck();
	this.cards = [];
	for (var i=0; i<4; i++) {
		for (var j=1; j<14; j++) {
			this.cards.push(new Card(Deck.suits[i],j));
		}
	}
}
Deck.suits = ['H','D','S','C'];
Deck.prototype.prettyPrint = function prettyPrint() {
	var out = [];
	for (var i=0; i<this.cards.length; i++) {
		out.push(this.cards[i].getValue()+this.cards[i].suit);
	}
	return out.join('');
}
Deck.prototype.shuffle = function shuffle(callback) {
	var output = [];
	var recurse = function () {
		if (this.cards.length) {
			var buffer = new Buffer(2);
			fs.read(rand,buffer,0,2,null,function () {
				var index2 = buffer.readUInt16LE(0) % this.cards.length;
				var index = 0;
				//console.log(index2);
				var x = this.cards.splice(index2,1);
				output.push(x[0]);
				recurse();
			}.bind(this));
		} else {
			this.cards = output;
			callback();
		}
	}.bind(this);
	recurse();
}
function Card(suit,value) {
	this.value = value;
	this.suit = suit;
}
Card.prototype.getValue = function getValue() {
	switch (this.value) {
	case 1: return 'A';
	case 10: return 'T';
	case 11: return 'J';
	case 12: return 'Q';
	case 13: return 'K';
	default: return this.value;
	}
}

