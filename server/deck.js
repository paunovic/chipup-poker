var fs = require('fs');
var rand = -1;
var getRandom;
fs.open('/dev/urandom','r',function (err,fd) {
	if (err) {
		getRandom = function winGetRandom(size,callback) {
			var buffer = new Buffer(size);
			for (var x=0; x<size; x++) buffer[x] = Math.floor(Math.random() * 255);
			callback(buffer);
		}
		console.log('falling back to Math.random, reason: cant open random:',err);
	} else {
		rand = fd;
		getRandom = function getRandom(size,callback) {
			var buffer = new Buffer(size);
			fs.read(rand,buffer,0,size,null,function () {
				callback(buffer);
			});
		}
	}
	if (require.main === module) {
		var deck = new Deck();
		console.log('initial  deck is',deck.prettyPrint());
		deck.shuffle(function () {
			console.log('shuffled deck is',deck.prettyPrint());
			var hand = new Hand();
			deck.draw(3,hand);
			console.log('first 3 cards are',hand.prettyPrint());
		});
	}
});
module.exports.Deck = Deck;
module.exports.Hand = Hand;
function Deck() {
	if (!(this instanceof Deck)) return new Deck();
	this.cards = [];
	for (var i=0; i<52; i++) {
		this.cards[i] = i;
	}
	this.pos = 51;
}
function Hand() {
	this.cards = [];
}
Deck.suits = ['H','D','S','C'];
Hand.prototype.prettyPrint = Deck.prototype.prettyPrint = function prettyPrint() {
	var out = [];
	for (var i=0; i<this.cards.length; i++) {
		out.push(getValue(this.cards[i])+getSuit(this.cards[i]));
	}
	return out.join('');
}
function getValue(code) {
	var c = Math.floor(code/4);
	switch (c) {
	case 8: return 'T';
	case 9: return 'J';
	case 10: return 'Q';
	case 11: return 'K';
	case 12: return 'A';
	}
	return c+2;
}
function getSuit(code) {
	var c = code%4;
	switch (c) {
	case 0: return 'H';
	case 1: return 'S';
	case 2: return 'C';
	case 3: return 'D';
	}
}
Deck.prototype.shuffle = function shuffle(callback) {
	var output = [];
	var recurse = function () {
		if (this.cards.length) {
			getRandom(2,function (buffer) {
				var index2 = buffer.readUInt16LE(0) % this.cards.length;
				var index = 0;
				//console.log(index2);
				var x = this.cards.splice(index2,1);
				output.push(x[0]);
				recurse();
			}.bind(this));
		} else {
			this.cards = output;
			// sidepots
			//this.cards = [6,49,39,21,45,11,25,38,29,33,1,30,43,4,3,23,20,40,19,8,42,35,18,14,2,32,31,47,27,24,26,22,28,44,37,41,51,46,12,9,0,10,36,17,5,16,7,15,34,50,48,13];
			callback();
		}
	}.bind(this);
	recurse();
}
// FIXME, use the same logic as the DAG, dont shuffle
Deck.prototype.draw = function (count,hand) {
	//console.log('before:'+this.prettyPrint());
	var out = this.cards.splice(0,count);
	//console.log(out);
	//console.log('after:'+this.prettyPrint());
	//console.log('before2:',hand.cards);
	hand.cards = hand.cards.concat(out);
	//console.log('after2:',hand.cards);
}
module.exports.getRandom = function (size,cb) { getRandom(size,cb); }
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
