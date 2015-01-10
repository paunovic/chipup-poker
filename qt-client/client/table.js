print("LOAD!");
var seat_objects = [];
var localFlop = [];
var localTurn = [];
var localRiver = [];
var localPots = [];
var db = new DealerButton();

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
	for (var i=0; i<lastTS.pots.length; i++) {
		if (!localPots[i]) {
			localPots[i] = getChipStack();
		}
		if (lastTS.pots[i].value == 0) continue;
		localPots[i].setPosition(0.35 + (0.1*i),0.3);
		localPots[i].visible = true;
		localPots[i].value = lastTS.pots[i].value;
	}
}
var lastTS;
function tableStatus(ts) {
	updateSeats(ts);
	lastTS = ts;
	log("TS hook:"+ts.state+" JSON:"+JSON.stringify(ts));
}
function updateSeats(ts,opts) {
	var max = ts.seatCount();
	for (var i=0; i<max; i++) {
		var seat = ts.readSeat(i);
		var local = seat_objects[seat.seat_index];
		local.updateInfo(seat);
		seat_objects[seat.seat_index].empty = false;
		local.active = (seat.seat_index == ts.current_seat); // FIXME, ignore when idle?
		var user = seat.getUser();
		seat_objects[seat.seat_index].avatar = user.avatar;
	}
}
function AnimateCards() {
	var max = lastTS.seatCount();
	for (var i=0; i<max; i++) {
		var seat = lastTS.readSeat(i);
		var local = seat_objects[seat.seat_index];
		//log("index:"+i+" seat#:"+seat.seat_index);
		//log(JSON.stringify(seat));
		//log("index:"+seat.seat_index+" current:"+ts.current_seat);
		//log("local:"+local.cards.length+" remote:"+seat.card_count);
		if (seat.card_count >= local.cards.length) {
			for (var j=0; j<seat.card_count; j++) {
				var cardvalue = -1;
				if (seat.hand.cards.length) cardvalue = seat.hand.cards[j];
				var pos = calcCardPosition(seat.seat_index,j);
				if (local.cards[j]) {
					if (local.cards[j].card != cardvalue) {
						local.cards[j].card = cardvalue;
						queueAction(new DealCard(pos.x,pos.y,local.cards[j]));
					}
				} else {
					card = new Card();
					log('placing card at:'+JSON.stringify(pos));
					card.setSize(0.1);
					card.card = cardvalue;
					local.cards[j] = card;
					queueAction(new DealCard(pos.x,pos.y,local.cards[j]));
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
function tableEvent(event) {
	log('EVENT:'+event.event);
	switch (event.event) {
	case "teSit":
		var seat = lastTS.readSeat(event.seat);
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
	case "teFlop":
		for (var i=0; i<event.getCardCount(); i++) {
			var card = event.getCard(i);
			for (var x=0; x<3; x++) {
				if (!localFlop[x]) localFlop[x] = new Card();
				localFlop[x].setSize(0.063);
				localFlop[x].card = card.cards[x];
				localFlop[x].visible = false;
			}
			log("queueing flop reveal");
			queueAction(new DealCard(0.318,0.477,localFlop[0]));
			queueAction(new DealCard(0.387,0.477,localFlop[1]));
			queueAction(new DealCard(0.454,0.477,localFlop[2]));
		}
		updatePots();
		break;
	case "teTurn":
		for (var i=0; i<event.getCardCount(); i++) {
			var card = event.getCard(i);
			if (!localTurn[0]) localTurn[0] = new Card();
			localTurn[0].setSize(0.063);
			localTurn[0].card = card.cards[0];
			localTurn[0].visible = false;
			queueAction(new DealCard(0.523,0.477,localTurn[0]));
		}
		updatePots();
		break;
	case "teRiver":
		for (var i=0; i<event.getCardCount(); i++) {
			var card = event.getCard(i);
			if (!localRiver[0]) localRiver[0] = new Card();
			localRiver[0].setSize(0.063);
			localRiver[0].card = card.cards[0];
			localRiver[0].visible = false;
			queueAction(new DealCard(0.592,0.477,localRiver[0]))
		}
		updatePots();
		break;
	case "teExistingCards":
		for (var i=0; i<event.getCardCount(); i++) {
			var card = event.getCard(i);
			dump(card.cards);
		}
		break;
	case "teWinning":
		updateBets();
		AnimateCards();
		if (localFlop[0]) {
			localFlop[0].visible = false;
			localFlop[1].visible = false;
			localFlop[2].visible = false;
		}
		if (localTurn[0]) localTurn[0].visible = false;
		if (localRiver[0]) localRiver[0].visible = false;
		var p;
		while (p=localPots.shift()) {
			hideChips(p);
		}
		break;
	case 'teDealing':
		updateDealer(lastTS.dealer);
		AnimateCards();
		updateBets({sound:true});
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
	case 'tePostRiver':
		break;
	default:
		dump(event);
	}
}
function updateBets(opts) {
	for (var i=0; i<lastTS.seatCount(); i++) {
		var remote = lastTS.readSeat(i);
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
function calcCardPosition(seat,card) {
	// TODO, switch to float based positioning
	var seatpos = seat_objects[seat].renderPosition();
	log('seat pos is:'+JSON.stringify(seatpos));
	return { x:seatpos.x + (card*25), y:seatpos.y + 10 };
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

	var x = ((rawx/2)*0.58)+0.485;
	var y = ((rawy/2)*-0.45)+0.45;
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

	var scale = 0.8;
	if (alignment_test || (lastTS.dealer == seat) ) scale = 0.6;
	log("bet #"+seat+" scale:"+scale);
	var x = (((rawx/2)*0.77)*scale)+0.495;
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
	this.cardobj = cardobj;
	cardobj.visible = false;
}
DealCard.prototype.begin = function DealCardBegin() {
	log("starting card animation");
	this.cardobj.visible = true;
	this.cardobj.setPosition(0.5,0.1);
	Animate(this.cardobj, this.destx,this.desty, 0.25,eventDone);
	PlaySound(0);
}
function eventDone() {
	log('event done, doing next:'+actions.length);
	var self = actions.shift();
	if (actions.length > 0) actions[0].begin();
}
function ShowBet(chipobj) {
	this.chipobj = chipobj;
	this.chipobj.visible = false;
}
ShowBet.prototype.begin = function ShowBetBegin() {
	log("showing a chip");
	this.chipobj.visible = true;
	PlaySound(1);
	this.timer = setTimeout(eventDone,200);
}
function setTimeout(cb,delay) {
	var timer = new QTimer();
	timer.interval = delay;
	timer.singleShot = true;
	timer.timeout.connect(this,cb);
	timer.start();
	return timer;
}
initSeats();
dump(game);

// seat images should be 90x32 by default
//card = new Card();
//card.setPosition(0.2,0.25);
//card.setSize(0.1);
//card.card = 0;

//Animate(card,0.5,0.5,1);
