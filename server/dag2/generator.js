var fs = require('fs');

var tablecards = [];
var limit = 13;
for (var card1 = 0; card1 < limit; card1++) {
	for (var card2 = 0; card2 < limit; card2++) {
		if (card2 < card1) continue;
		for (var card3 = 0; card3 < limit; card3++) {
			if (card3 < card2) continue;
			for (var card4 = 0; card4 < limit; card4++) {
				if (card4 < card3) continue;
				for (var card5 = 0; card5 < limit; card5++) {
					if (card5 < card4) continue;
					if (notvalid([card1,card2,card3,card4,card5])) continue;
					//console.log(format(card1,card2,card3,card4,card5));
					tablecards.push([card1,card2,card3,card4,card5]);
				}
			}
		}
	}
}
function format(cards) {
	var out = '';
	for (var x=0; x<cards.length; x++) out += format1(cards[x]);
	return out;
}
function format1(card) {
	if ((card >= 0) && (card <= 7)) return ''+(card+2); 
	else if (card == 8) return 'T';
	else if (card == 9) return 'J';
	else if (card == 10) return 'Q';
	else if (card == 11) return 'K';
	else if (card == 12) return 'A';
	else throw 'invalid card';
}
function notvalid(cards) {
	var counts = [];
	for (var x = 0; x < cards.length; x++) {
		var card = cards[x];
		if (!counts[card]) counts[card] = 1;
		else counts[card]++;
	}
	for (var key in counts) {
		if (counts[key] > 4) return true;
	}
	return false;
	console.log(counts);
	process.exit();
}
function evalHand(table,hand) {
	var hunique = {},tunique = {};
	for (var x1 = 0; x1 < 4; x1++) {
		for (var x2=0; x2<4; x2++) {
			if (x2 <= x1) continue;
			hunique[format1(hand[x1])+format1(hand[x2])] = [hand[x1],hand[x2]];
		}
	}
	for (var x1=0; x1<5; x1++) {
		for (var x2=0; x2<5; x2++) {
			if (x2 <= x1) continue;
			for (var x3=0; x3<5; x3++) {
				if (x3 <= x2) continue;
				tunique[format1(table[x1])+format1(table[x2])+format1(table[x3])] = [ table[x1],table[x2],table[x3]];
			}
		}
	}
	//console.log(hunique);
	//console.log(tunique);
	// find 3 of a kind
	var count = 0;
	var bestmatch = null;
	var bestinput = null;
	for (key1 in hunique) {
		for (key2 in tunique) {
			var set = hunique[key1].concat(tunique[key2]);
			//var counts = countCards(set);
			//console.log('\nset',format(set));
			for (var x1 = 0; x1<5; x1++) {
				for (var x2=0; x2<5; x2++) {
					if (x2 == x1) continue;
					for (var x3=0; x3<5; x3++) {
						if (x3 == x1) continue;
						if (x3 == x2) continue;
						for (var x4=0; x4<5; x4++) {
							if (x4 == x1) continue;
							if (x4 == x2) continue;
							if (x4 == x3) continue;
							for (x5=0; x5<5; x5++) {
								if (x5 == x1) continue;
								if (x5 == x2) continue;
								if (x5 == x3) continue;
								if (x5 == x4) continue;
								console.log(x1,x2,x3,x4,x5);
								var set2 = [ set[x1], set[x2], set[x3], set[x4], set[x5] ];
								var key = format(set2);
								var obj = eqcindex[key];
								if (!obj) continue;
								if (!bestmatch) {
									//console.log('initial match',obj);
									bestmatch = obj;
									bestinput = set2;
									break;
								} else if (bestmatch.id == obj.id) {
									continue;
								} else if (obj.id < bestmatch.id) {
									//console.log('improvement',obj);
									bestmatch = obj;
									bestinput = set2;
								} else continue;
								//console.log('combo #%d ',count++,key,x1,x2,x3,x4,x5);
								//console.log(obj);
							}
						}
					}
				}
			}
		}
	}
	//console.log('%s+%s => %s %j',format(table),format(hand),format(bestinput),bestmatch);
	//if ([310,321,320,2462,2459].indexOf(bestmatch.id) == -1) process.exit();
	return bestmatch.id;
}
function countCards(cards) {
	var counts = [];
	for (var x=0; x<cards.length; x++) {
		if (!counts[cards[x]]) counts[cards[x]] = 1;
		else counts[cards[x]]++;
	}
	return counts;
}

var raweqc = fs.readFileSync('../eqcllist',{encoding:'ascii'}).split('\n');
var eqc = [];
var eqcindex = {};
for (var x=0; x<raweqc.length; x++) {
	var line = raweqc[x].split('\t');
	var obj = { id:parseInt(line[0]), cards:line[1], type:parseInt(line[2]), desc:line[3], domination:parseFloat(line[4]), likelihood:parseFloat(line[5])}
	eqc[obj.id] = obj;
	eqcindex[obj.cards] = obj;
}
//console.log(eqc[310]);

var count = 0;
for (var x=0; x<tablecards.length; x++) {
	for (var card1 = 0; card1 < limit; card1++) {
		for (var card2 = 0; card2 < limit; card2++) {
			if (card2 < card1) continue;
			for (var card3 = 0; card3 < limit; card3++) {
				if (card3 < card2) continue;
				for (var card4 = 0; card4 < limit; card4++) {
					if (card4 < card3) continue;
					count++;
					var hand = [card1,card2,card3,card4];
					if (notvalid(tablecards[x].concat([card1,card2,card3,card4]))) continue;
					var eqcId = evalHand(tablecards[x],hand);
					//console.log('%s %s %d',format(tablecards[x]),format([card1,card2,card3,card4]),eqcId);
					if (count > 10000) process.exit();
				}
			}
		}
	}
}
