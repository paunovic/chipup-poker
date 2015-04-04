print("LOAD!");
var seat_objects = [];
var localFlop = [];
var localTurn = [];
var localRiver = [];
var localPots = [];
var db = new DealerButton();
var testcase = false;

var cardStart = 0.31;
var cardWidth = 0.07;
var tableCardOffset = 0.075;

var idleChips = [];
function getChipStack() {
	if (idleChips.length) return idleChips.pop();
	else return new ChipStack();
}
function hideChips(input) {
	input.visible = false;
	idleChips.push(input);
}
function updatePots() {
	var toAnimate = [];
	for (var i=0; i<lastTS.seats.length; i++) {
		var remote = lastTS.seats[i];
		var local = seat_objects[remote.seat_index];
		if (lastTS.bets[remote.seat_index] == 0) {
			if (local.bet) {
				toAnimate.push(local.bet);
				local.bet = null;
			}
		}
	}
	queueAction(new AnimateBetsToPot(toAnimate));
	for (var i=0; i<lastTS.pots.length; i++) {
		if (!localPots[i]) {
			localPots[i] = getChipStack();
		}
		if (lastTS.pots[i].value == 0) continue;
		localPots[i].setPosition(0.5 + (0.1*i),0.3);
		queueAction(new ShowBet(localPots[i]));
		localPots[i].value = lastTS.pots[i].value - lastTS.pots[i].rake;
		// TODO, render rake
		// TODO, animate player bets into this pot
	}
}
function AnimateBetsToPot(bets) {
	this.bets = bets;
	this.count = bets.length;
}
AnimateBetsToPot.prototype.begin = function () {
	var that = this;
	for (var i=0; i<this.bets.length; i++) {
		Animate(this.bets[i],0.5,0.3,0.5,once(function () { that.check(); }));
	}
	if (this.bets.length == 0) eventDone();
}
AnimateBetsToPot.prototype.check = function () {
	this.count--;
	if (this.count == 0) {
		for (var i=0; i<this.bets.length; i++) hideChips(this.bets[i]);
		eventDone();
	}
}
var lastTS;
function tableStatus(ts) {
	log("TS hook:"+ts.state+" JSON:"+JSON.stringify(ts));
	updateSeats(ts);
	lastTS = ts;
	if (ts.state == 'tsIdle') {
		for (var x=0; x<seat_objects.length; x++) {
			var local = seat_objects[x];
			if (!local) continue;
			for (var y=0; y<local.cards.length; y++) {
				if (local.cards[y]) queueAction(new HideCard(local.cards[y]));
				delete local.cards[y];
			}
		}
	}
	var sets = [];
	for (var j=0; j<ts.events.length; j++) {
		log("event:"+j+" out of "+ts.events.length);
		var event = ts.events[j];
		switch (event.event) {
		case "teFlop":
			for (var i=0; i<event.getCardCount(); i++) {
				var card = event.getCard(i);
				var offset = i*3;
				for (var x=0; x<3; x++) {
					if (!localFlop[x+offset]) localFlop[x+offset] = new Card();
					localFlop[x+offset].setSize(cardWidth);
					localFlop[x+offset].card = card.cards[x];
					localFlop[x+offset].visible = false;
				}
				log("queueing flop reveal");
				if (!sets[i]) sets[i] = [];
				sets[i].push(new AnimateFlop(card.cards,offset));
			}
			updatePots();
			break;
		case "teTurn":
			queueAction(new SimpleDelay(1000));
			for (var i=0; i<event.getCardCount(); i++) {
				var card = event.getCard(i);
				if (!localTurn[i]) localTurn[i] = new Card();
				localTurn[i].setSize(cardWidth);
				localTurn[i].visible = false;
				if (!sets[i]) sets[i] = [];
				if (i == 0) height = 0.477;
				else height = 0.55;
				sets[i].push(new DealCard(cardStart + (tableCardOffset*3),height,localTurn[i]));
				sets[i].push(new RevealCard(localTurn[i],card.cards[0]));
			}
			updatePots();
			break;
		case "teRiver":
			queueAction(new SimpleDelay(1000));
			for (var i=0; i<event.getCardCount(); i++) {
				var card = event.getCard(i);
				if (!localRiver[i]) localRiver[i] = new Card();
				localRiver[i].setSize(cardWidth);
				localRiver[i].visible = false;
				if (!sets[i]) sets[i] = [];
				if (i == 0) height = 0.477;
				else height = 0.55;
				sets[i].push(new DealCard(cardStart + (tableCardOffset*4),height,localRiver[i]));
				sets[i].push(new RevealCard(localRiver[i],card.cards[0]));
			}
			updatePots();
			break;
		}
	}
	for (var j=0; j<sets.length; j++) {
		for (var i=0; i<sets[j].length; i++) {
			queueAction(sets[j][i]);
		}
	}
	for (var j=0; j<ts.events.length; j++) {
		log("event:"+j+" out of "+ts.events.length);
		var event = ts.events[j];
		tableEvent(event);
	}
	var mySeat = controls.MySeatIndex;
	if (mySeat >= 0) {
		log("myBet:"+ts.bets[mySeat]+" minBet:"+ts.minimumBet);
		var myBet = ts.bets[mySeat];
		if (myBet < ts.minimumBet) {
			controls.AutoCheckFoldVisible = false;
			controls.AutoFoldVisible = true;
			controls.AutoCallVisible = true;
		} else {
			controls.AutoCheckFoldVisible = true;
			controls.AutoFoldVisible = false;
			controls.AutoCallVisible = false;
		}
		if (mySeat == ts.current_seat) {
			controls.tryAutoAction();
			ClearCheckBoxes();
		}
	}
}
function updateSeats(ts,opts) {
	var i;
	for (i=0; i<ts.seats.length; i++) {
		var seat = ts.seats[i];
		var local = seat_objects[seat.seat_index];
		local.updateInfo(seat);
		seat_objects[seat.seat_index].empty = false;
		local.active = (seat.seat_index == ts.current_seat); // FIXME, ignore when idle?
		var user = seat.getUser();
		seat_objects[seat.seat_index].avatar = user.avatar;
	}
	for (i=0; i<game.seats; i++) seat_objects[i].reserved = false;
	for (i=0; i<ts.reservedSeats.length; i++) {
		seat_objects[ts.reservedSeats[i]].reserved = true;
	}
}
function AnimateCards(opts) {
	for (var i=0; i<lastTS.seats.length; i++) {
		var seat = lastTS.seats[i];
		var local = seat_objects[seat.seat_index];
		//log("index:"+i+" seat#:"+seat.seat_index);
		//log(JSON.stringify(seat));
		//log("index:"+seat.seat_index+" current:"+ts.current_seat);
		//log("local:"+local.cards.length+" remote:"+seat.card_count);
		if (seat.card_count >= local.cards.length) {
			for (var j=0; j<seat.card_count; j++) {
				var cardvalue = -1;
				if (seat.hand.cards.length) cardvalue = seat.hand.cards[j];
				var pos = calcCardPosition(seat.seat_index,j,seat.card_count);
				if (local.cards[j]) {
					var skip = false;
					if (opts && opts.reveal) {
						if (local.cards[j].card != cardvalue) {
							queueAction(new RevealCard(local.cards[j],cardvalue));
							skip = true;
						}
					}
					if (!skip) {
						if (local.cards[j].card != cardvalue) {
							queueAction(new DealCard(pos.x,pos.y,local.cards[j]));
							queueAction(new RevealCard(local.cards[j],cardvalue));
						}
					}
				} else {
					card = new Card();
					log('placing card at:'+JSON.stringify(pos));
					card.setSize(cardWidth);
					local.cards[j] = card;
					queueAction(new DealCard(pos.x,pos.y,local.cards[j]));
					queueAction(new RevealCard(local.cards[j],cardvalue));
				}
				local.cards[j].stackUnder(local);
			}
		} else {
			for (var j=0; j<local.cards.length; j++) {
				if (local.cards[j]) local.cards[j].visible = false;
				delete local.cards[j];
			}
		}
	}
}
var actions = [];
function queueAction(action) {
	actions.push(action);
	if (actions.length == 1) actions[0].begin();
}
function AnimateFlop(cards,offset) {
	this.cards = cards;
	this.secondDone = false;
	this.thirdDone = false;
	this.offset = offset;
	if (offset == 0) this.y = 0.477;
	else this.y = 0.55;
	log("starting flop animation for:"+cards);
}
AnimateFlop.prototype.begin = function () {
	for (var x=0; x<3; x++) {
		if (!localFlop[x+this.offset]) localFlop[x+this.offset] = new Card();
		localFlop[x+this.offset].visible = false;
		localFlop[x+this.offset].setSize(cardWidth);
	}
	localFlop[0+this.offset].card = -1;
	localFlop[0+this.offset].setPosition(0.5,0.1);
	localFlop[0+this.offset].visible = true;
	PlaySound(0);
	var that = this;
	Animate(localFlop[0+this.offset], cardStart,this.y, 0.25,once(function () { that.reveal(); }));
}
AnimateFlop.prototype.reveal = function () {
	for (var x=0; x<3; x++) {
		localFlop[x+this.offset].card = this.cards[x];
	}
	localFlop[1+this.offset].setPosition(cardStart,this.y);
	localFlop[2+this.offset].setPosition(cardStart,this.y);
	localFlop[1+this.offset].visible = true;
	localFlop[2+this.offset].visible = true;
	var that = this;
	Animate(localFlop[1+this.offset],cardStart + tableCardOffset,this.y,0.25,once(function () { that.second(); }));
	Animate(localFlop[2+this.offset],cardStart + (tableCardOffset*2),this.y,0.25,once(function () { that.third(); }));
}
AnimateFlop.prototype.second = function () {
	this.secondDone = true;
	this.check();
}
AnimateFlop.prototype.third = function () {
	this.thirdDone = true;
	this.check();
}
AnimateFlop.prototype.check = function () {
	if (this.secondDone && this.thirdDone) eventDone();
}
function HideCard(obj) {
	this.card = obj;
}
HideCard.prototype.begin = function () {
	this.card.visible = false;
	eventDone();
}
function tableEvent(event) {
	log('EVENT:'+event.event);
	queueAction(new UpdateChat(JSON.stringify(event.event)));
	switch (event.event) {
	case "teSit":
		var seat = lastTS.readSeatBySeat(event.seat);
		var local = seat_objects[event.seat];
		local.updateInfo(seat);
		seat_objects[event.seat].empty = false;
		local.active = (event.seat == lastTS.current_seat); // FIXME, ignore when idle?
		var user = seat.getUser();
		seat_objects[event.seat].avatar = user.avatar;
		break;
	case "teStandUp":
		var local = seat_objects[event.seat];
		for (var x=0; x<local.cards.length; x++) {
			if (local.cards[x]) local.cards[x].visible = false;
			delete local.cards[x];
		}
		seat_objects[event.seat].empty = true;
		if (seat_objects[event.seat].bet) {
			hideChips(seat_objects[event.seat].bet);
			seat_objects[event.seat].bet = null;
		}
		break;
	case "teExistingCards":
		updateDealer(lastTS.dealer);
		updateBets({sound:true});
		AnimateCards();
		for (var i=0; i<event.getCardCount(); i++) {
			var card = event.getCard(i);
			dump(card.cards);
			if (card.cards.length >= 3) {
				var offset = 0;
				for (var x=0; x<3; x++) {
					if (!localFlop[x+offset]) localFlop[x+offset] = new Card();
					localFlop[x+offset].setSize(cardWidth);
					localFlop[x+offset].card = card.cards[x];
					localFlop[x+offset].visible = false;
				}
				log("queueing flop reveal");
				queueAction(new AnimateFlop(card.cards,offset));
			}
			var height = 0.477;
			if (card.cards.length >= 4) {
				if (!localTurn[0]) localTurn[0] = new Card();
				localTurn[0].setSize(cardWidth);
				localTurn[0].card = card.cards[3];
				localTurn[0].visible = false;
				queueAction(new DealCard(cardStart + (tableCardOffset*3),height,localTurn[0]));
				queueAction(new RevealCard(localTurn[0],card.cards[3]));
			}
			if (card.cards.length = 5) {
				if (!localRiver[0]) localRiver[0] = new Card();
				localRiver[0].setSize(cardWidth);
				localRiver[0].card = card.cards[4];
				localRiver[0].visible = false;
				queueAction(new DealCard(cardStart + (tableCardOffset*4),height,localRiver[0]));
				queueAction(new RevealCard(localRiver[0],card.cards[4]));
			}
			break;
		}
		updatePots();
		break;
	case "teWinning":
		AnimateCards({reveal:true});
		queueAction(new SimpleDelay(1500));
		var perSeatWins = [];
		for (var i=0; i<game.seats; i++) perSeatWins[i] = 0;
		//queueAction(new UpdateChat(JSON.stringify(event.pots)));
		var seatMap = [];
		for (var i=0; i<lastTS.seats.length; i++) {
			var index = lastTS.seats[i].seat_index;
			seatMap[index] = lastTS.seats[i];
			if (lastTS.bets[index] && local.bet) seat_objects[index].bet.value = lastTS.bets[index];
		}
		for (var i=0; i<event.pots.length; i++) {
			var winnerCount = event.pots[i].WinnerData.length;
			for (var k=0; k<event.pots[i].WinnerData.length; k++) {
				log("i:"+i+" k:"+k+" wd:"+JSON.stringify(event.pots[i].WinnerData[k]));
				var winnerSeat = event.pots[i].WinnerData[k].seat;
				var winnerName = seatMap[winnerSeat].user.displayName;
				var potvalue = event.pots[i].value - event.pots[i].rake;
				var gain = 0;
				if (winnerCount == 1) {
					queueAction(new UpdateChat(winnerName+" won "+(potvalue/100)+" chips"));
					gain = potvalue;
				} else {
					queueAction(new UpdateChat(winnerName+" won "+((potvalue/winnerCount)/100)+"/"+(potvalue/100)+" chips"));
					gain = potvalue/winnerCount;
				}
				// TODO, rake
				perSeatWins[winnerSeat] += gain;
			}
		}
		var p;
		while (p=localPots.shift()) {
			hideChips(p);
		}
		var sets = [];
		for (var i=0; i<game.seats; i++) {
			var pos = calcBetLocation(i);
			if (perSeatWins[i] == 0) continue;
			log("seat#"+i+" won:"+perSeatWins[i]+" coords:"+JSON.stringify(pos));
			sets.push({position:pos,gain:perSeatWins[i]});
		}
		if (sets.length) queueAction(new AnimateChipWin(sets));
		updateBets();
		queueAction(new SimpleDelay(250));
		for (var i=0; i<localFlop.length; i++) {
			if (localFlop[i]) {
				log("hiding flop:"+i);
				queueAction(new HideCard(localFlop[i]));
			}
		}
		for (var i=0; i<localTurn.length; i++) {
			if (localTurn[i]) queueAction(new HideCard(localTurn[i]));
		}
		for (var i=0; i<localRiver.length; i++) {
			if (localRiver[i]) queueAction(new HideCard(localRiver[i]));
		}
		queueAction(new SimpleDelay(250));
		for (var i=0; i<lastTS.seats.length; i++) {
			var local = seat_objects[lastTS.seats[i].seat_index];
			for (var y=0; y<local.cards.length; y++) {
				if (local.cards[y]) queueAction(new HideCard(local.cards[y]));
				delete local.cards[y];
			}
		}
		break;
	case 'teDealing':
		updateDealer(lastTS.dealer);
		updateBets({sound:true});
		AnimateCards();
		break;
	case 'teCall':
		updateBets({sound:true});
		break;
	case 'teCheck':
		updateBets();
		break;
	case 'teRaise':
		updateBets({sound:true});
		break;
	case "teAllIn":
		updateBets({sound:true});
		break;
	case 'tePostRiver':
		break;
	default:
		dump(event);
	}
}
function AnimateChipWin(sets) {
	this.stack = [];
	this.dest = [];
	this.chips = [];
	for (var i=0; i<sets.length; i++) {
		this.stack[i] = getChipStack();
		this.dest[i] = sets[i].position;
		this.chips[i] = sets[i].gain;
	}
	this.count = sets.length;
}
AnimateChipWin.prototype.begin = function () {
	var that = this;
	for (var i=0; i<this.stack.length; i++) {
		this.stack[i].value = this.chips[i];
		this.stack[i].setPosition(0.5,0.3);
		Animate(this.stack[i], this.dest[i].x, this.dest[i].y, 0.5, function () { that.check(); });
	}
}
AnimateChipWin.prototype.check = function () {
	this.count--;
	if (this.count) return;
	for (var i=0; i<this.stack.length; i++) {
		hideChips(this.stack[i]);
	}
	eventDone();
}
function UpdateChat(msg) {
	this.msg = msg;
}
UpdateChat.prototype.begin = function () {
	root.renderWinning(this.msg);
	eventDone();
}
function SimpleDelay(delay) {
	this.delay = delay;
}
SimpleDelay.prototype.begin = function () {
	this.timer = setTimeout(eventDone,this.delay);
}
function updateBets(opts) {
	for (var i=0; i<lastTS.seats.length; i++) {
		var remote = lastTS.seats[i];
		var local = seat_objects[remote.seat_index];
		if (lastTS.bets[remote.seat_index] == 0) {
			if (local.bet) {
				hideChips(local.bet);
				local.bet = null;
			}
			log("hiding chips for "+remote.seat_index);
			continue;
		}
		if (!local.bet) local.bet = getChipStack();
		var pos = calcBetLocation(remote.seat_index);
		local.bet.setPosition(pos.x,pos.y);
		if (local.bet.value != lastTS.bets[remote.seat_index]) {
			local.bet.value = lastTS.bets[remote.seat_index];
			local.bet.setSide(pos.keyside);
			log("updating seat "+remote.seat_index+" bet to "+lastTS.bets[remote.seat_index]);
			if (opts && opts.sound) {
				log("queuing chip show");
				queueAction(new ShowBet(local.bet));
			} else local.bet.visible = true;
		}
	}
}
function dump(i) {
	log("dumping:"+i);
	for (key in i) {
		log("key:"+key+" type:"+typeof i[key]);
	}
}
function initSeats() {
	log("doing init seats");
	for (var i=0; i<game.seats; i++) {
		var seat = new SeatObject();
		seat.setSize(0.16);
		seat.seat = i;
		seat.tournament = false;
		seat.empty = true;
		seat.cards = [];
		seat.bet = null;
		seat_objects[i] = seat;
	}
	adjustSeats();
}
var input = 1;
function setInput(x) {
	input = x;
	adjustSeats();
}
function calcSeatPosition(index) {
	var interval = (Math.PI*2) / game.seats;
	var fakeindex = index+0.5;
	log("index "+index+" goes in slot "+fakeindex);
	var rawx = Math.sin(fakeindex*interval);
	var rawy = Math.cos(fakeindex*interval);
	
	var x = ((rawx/2)*0.65)+0.495;
	var y = ((rawy/2)*-0.62)+0.45;
	log("seat:"+index+" angle:"+(index*interval)+" x:"+rawx+" y:"+rawy);

	return { rawx:rawx, rawy:rawy, x:x, y:y };
}
function calcCardPosition(seat,card,cards) {
	var seatpos = seat_objects[seat].renderPosition();
	//log('seat pos is:'+JSON.stringify(seatpos));
	var cardOffset = cardWidth;
	if (cards == 4) cardOffset = 0.029;
	var seatWidth = 0.16;
	var handWidth = ((cards - 1) * cardOffset)+cardWidth;
	var center = (seatpos.x + (seatWidth/2)) - (handWidth/2);
	return { x:center + (card * cardOffset), y:seatpos.y - 0.015 };
}
function adjustSeats() {
	var interval = (Math.PI*2) / game.seats;
	log("splitting ring into "+game.seats+" pieces");
	for (var i=0; i<game.seats; i++) {
		var pos = calcSeatPosition(i);
		var fakeindex = i+0.5;
		seat_objects[i].left = pos.rawx < 0;

		if (pos.rawy < -0.5) seat_objects[i].setSide(2);
		else if (pos.rawx < 0) seat_objects[i].setSide(1);
		else seat_objects[i].setSide(0);
		
		seat_objects[i].setPosition(pos.x,pos.y);
	}
}
function updateDealer(seat) {
	if (seat == -1) {
		db.visible = false;
		return;
	} else db.visible = true;
	moveDealer(db,seat);
}
function moveDealer(button,index) {
	var interval = (Math.PI*2) / game.seats;
	var fakeindex = index+0.5;
	var rawx = Math.sin(fakeindex*interval);
	var rawy = Math.cos(fakeindex*interval);

	var x = ((rawx/2)*0.58)+0.48;
	var y = ((rawy/2)*-0.4)+0.42;
	button.setPosition(x,y);
}
var test = [];
var alignment_test = false;
function alignment() {
	alignment_test = true;
	for (var i=1; i<game.seats; i++) {
		test[i] = new DealerButton();
		moveDealer(test[i],i);
	}
	updateBets();
}
function calcBetLocation(seat) {
	var interval = (Math.PI*2) / game.seats;
	var fakeindex = seat+0.5;
	var rawx = Math.sin(fakeindex*interval);
	var rawy = Math.cos(fakeindex*interval);

	var scale = 0.7;
	if (alignment_test || (lastTS.dealer == seat) ) scale = 0.55;
	log("bet #"+seat+" scale:"+scale);
	var x = (((rawx/2)*0.8)*scale)+0.495;
	var y = (((rawy/2)*-0.62)*scale)+0.45;
	var keyside;
	if ( (rawy < 0.25) && (rawy > -0.25) ) {
		if (rawx > 0) keyside = 0;
		else keyside = 1;
	} else if (rawy > 0) keyside = 2;
	else if (rawy < 0) keyside = 3;
	return {x:x, y:y, keyside:keyside };
}
function DealCard(destx,desty,cardobj) {
	this.destx = destx;
	this.desty = desty;
	if (this.destx < 0) throw "invalid x pos";
	this.cardobj = cardobj;
	//cardobj.visible = false;
}
DealCard.prototype.begin = function DealCardBegin() {
	//log("starting card animation "+this.destx+" "+this.desty);
	this.cardobj.card = -1;
	this.cardobj.visible = true;
	this.cardobj.setPosition(0.5,0.1);
	Animate(this.cardobj, this.destx,this.desty, 0.25,eventDone);
	PlaySound(0);
}
function RevealCard(obj,value) {
	this.obj = obj;
	this.value = value;
}
RevealCard.prototype.begin = function () {
	this.obj.card = this.value;
	eventDone();
}
function eventDone() {
	//log('event done, doing next:'+actions.length);
	var self = actions.shift();
	if (actions.length > 0) actions[0].begin();
}
function ShowBet(chipobj) {
	this.chipobj = chipobj;
	this.chipobj.visible = false;
}
ShowBet.prototype.begin = function ShowBetBegin() {
	this.chipobj.visible = true;
	PlaySound(1);
	this.timer = setTimeout(eventDone,200);
}
function setTimeout(cb,delay) {
	if (testcase) {
		cb();
		return;
	}
	var timer = new QTimer();
	timer.interval = delay;
	timer.singleShot = true;
	timer.timeout.connect(this,cb);
	timer.start();
	return timer;
}
function once(fn) {
	var done = false;
	return function () {
		if (done) return;
		done = true;
		fn();
	}
}
initSeats();
dump(game);

// seat images should be 90x32 by default
//card = new Card();
//card.setPosition(0.2,0.25);
//card.setSize(0.1);
//card.card = 0;

//Animate(card,0.5,0.5,1);
