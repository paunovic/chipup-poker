var fs = require('fs');
module.exports.evalHand = evalHand;
module.exports.format = format;
module.exports.doEval = doEval;

var raweqc = fs.readFileSync('eqcllist',{encoding:'ascii'}).split('\n');
var eqc = [];
var eqcindex = {};
for (var x=0; x<raweqc.length; x++) {
	var line = raweqc[x].split('\t');
	var obj = { id:parseInt(line[0]), cards:line[1], type:parseInt(line[2]), desc:line[3], domination:parseFloat(line[4]), likelihood:parseFloat(line[5])}
	eqc[obj.id] = obj;
	if (eqcindex[obj.cards]) {
		console.log('collision %j %j',eqcindex[obj.cards],obj);
	}
	if ([0,1,2,4,7].indexOf(obj.type) != -1) {
		eqcindex[obj.cards] = obj;
	}
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
	var count = 0;
	var bestmatch = null;
	var bestinput = null;
	var checked = {};
	function checkCombo(key,set2) {
		var obj = eqcindex[key];
		if (!obj) {
			//console.log('combo #%d ',count++,key);//,x1,x2,x3,x4,x5);
			return false;
		}
		//if ([4].indexOf(obj.type) == -1) return false;
		if (!bestmatch) {
			//console.log('initial match',obj);
			bestmatch = obj;
			bestinput = set2;
			return true;
		} else if (bestmatch.id == obj.id) {
			return false;
		} else if (obj.id < bestmatch.id) {
			//console.log('improvement',obj);
			bestmatch = obj;
			bestinput = set2;
		} else return false;
		//console.log(obj);
	}
	function checkSet(set) {
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
							//console.log(x1,x2,x3,x4,x5);
							var set2 = [ set[x1], set[x2], set[x3], set[x4], set[x5] ];
							//console.log('set2',format(set2));
							var key = format(set2);
							//if (checked[key]) {
							//	bestmatch = checked[key];
							//	return;
							//}
							if (checkCombo(key,set2)) return;
							//checked[key] = bestmatch;
						}
					}
				}
			}
		}
	}
	for (key1 in hunique) {
		for (key2 in tunique) {
			var set = hunique[key1].concat(tunique[key2]);
			//console.log('\nset',format(set));
			checkSet(set);
		}
	}
	/*if ([250, 262, 274, 286, 298, 310,311,312,313,314,315,316,317,318,319,320,321,322, 2402,2403,2404,2405,2406,2407,2408,2409,2410, 2413,2414,2415,2416,2417,2418,2419,2420, 2423,2424,2425,2426,2427,2428,2429, 2432,2433,2434,2435,2436,2437, 2440,2441,2442,2443,2444, 2447,2448,2449,2450, 2453,2454,2455,2458,2459,2462].indexOf(bestmatch.id) == -1) {
		console.log('id not in whitelist');
		console.log('%s+%s => %s %j',format(table),format(hand),format(bestinput),bestmatch);
		process.exit();
	}*/
	return bestmatch.id;
}
function format1(card) {
	if ((card >= 0) && (card <= 7)) return ''+(card+2); 
	else if (card == 8) return 'T';
	else if (card == 9) return 'J';
	else if (card == 10) return 'Q';
	else if (card == 11) return 'K';
	else if (card == 12) return 'A';
	else throw 'invalid card:'+card;
}
function format(cards) {
	var out = '';
	for (var x=0; x<cards.length; x++) out += format1(cards[x]);
	return out;
}
function doEval(flop,turn,river,hands) {
	var start = Date.now();
	var tbl = [];
	var tsuits = [0,0,0,0];
	for (var x=0; x<3; x++) {
		tbl.push(Math.floor(flop.cards[x]/4));
		tsuits[flop.cards[x]%4]++;
	}
	tbl.push(Math.floor(turn.cards[0]/4));
	tsuits[turn.cards[0]%4]++;
	tbl.push(Math.floor(river.cards[0]/4));
	tsuits[river.cards[0]%4]++;
	console.log('tbl:%s %j',format(tbl),tsuits);
	for (var y=0; y<hands.length; y++) {
		var p = [];
		var player = hands[y].hand;
		for (var x=0; x<4; x++) p.push(Math.floor(player[x]/4));
		console.log('p:%s',format(p));
		var res = evalHand(tbl,p);
		hands[y].id = res;
		var obj = eqc[res];
		hands[y].desc = obj.desc;
		hands[y].domination = obj.domination;
		hands[y].likelihood = obj.likelyhood;
		hands[y].cards = obj.cards;
	}
	var end = Date.now();
	console.log('runtime %d',end-start);
	return {outputs:hands};
}
