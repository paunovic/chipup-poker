print("LOAD!");
var seat_objects = [];
var localFlop = [];
var localTurn = [];
var localRiver = [];

function tableStatus(ts) {
	log("TS hook:"+ts.state);
	var max = ts.seatCount();
	for (var i=0; i<max; i++) {
		var seat = ts.readSeat(i);
		var local = seat_objects[seat.seat_index];
		log("index:"+i+" seat#:"+seat.seat_index);
		log(JSON.stringify(seat));
		local.updateInfo(seat);
		seat_objects[seat.seat_index].empty = false;
		var user = seat.getUser();
		seat_objects[seat.seat_index].avatar = user.avatar;
		if (local.cards.length != seat.card_count) {
			log("local:"+local.cards.length+" remote:"+seat.card_count);
			for (var j=0; j<seat.card_count; j++) {
				if (local.cards[j]) {
					local.cards[j].card = -1;
					local.cards[j].visible = true;
				} else {
					card = new Card();
					var pos = calcCardPosition(seat.seat_index,j);
					card.setPosition(pos.x, pos.y);
					card.setSize(0.1);
					card.card = -1;
					local.cards[j] = card;
				}
				local.cards[j].stackUnder(local);
			}
		}
	}
}
function tableEvent(event) {
	log('EVENT:'+event.event);
	switch (event.event) {
	case "teStandUp":
		seat_objects[event.seat].empty = true;
	case "teFlop":
		for (var i=0; i<event.getCardCount(); i++) {
			var card = event.getCard(i);
			for (var x=0; x<3; x++) {
				if (!localFlop[x]) localFlop[x] = new Card();
				localFlop[x].setSize(0.063);
				localFlop[x].card = card.cards[x];
			}
			localFlop[0].setPosition(0.318,0.477);
			localFlop[1].setPosition(0.387,0.477);
			localFlop[2].setPosition(0.454,0.477);
		}
		break;
	case "teTurn":
		for (var i=0; i<event.getCardCount(); i++) {
			var card = event.getCard(i);
			if (!localTurn[0]) localTurn[0] = new Card();
			localTurn[0].setSize(0.063);
			localTurn[0].card = card.cards[0];
			localTurn[0].setPosition(0.523,0.477);
		}
		break;
	case "teRiver":
		for (var i=0; i<event.getCardCount(); i++) {
			var card = event.getCard(i);
			if (!localRiver[0]) localRiver[0] = new Card();
			localRiver[0].setSize(0.063);
			localRiver[0].card = card.cards[0];
			localRiver[0].setPosition(0.592,0.477);
		}
		break;
	case "teExistingCards":
		for (var i=0; i<event.getCardCount(); i++) {
			var card = event.getCard(i);
			dump(card.cards);
		}
		break;
	case "teWinning":
		localFlop[0].visible = false;
		localFlop[1].visible = false;
		localFlop[2].visible = false;
		localTurn[0].visible = false;
		localRiver[0].visible = false;
		break;
	default:
		dump(event);
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
	
	var x = ((rawx/2)*0.7)+0.5;
	var y = ((rawy/2)*-0.62)+0.45;
	log("seat:"+index+" angle:"+(index*interval)+" x:"+rawx+" y:"+rawy);

	return { rawx:rawx, rawy:rawy, x:x, y:y };
}
function calcCardPosition(seat,card) {
	var seatpos = seat_objects[seat].renderPosition();
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

initSeats();
dump(game);

// seat images should be 90x32 by default
//card = new Card();
//card.setPosition(0.2,0.25);
//card.setSize(0.1);
//card.card = 0;

//Animate(card,0.5,0.5,1);
