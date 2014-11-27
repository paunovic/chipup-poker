print("LOAD!");
var seat_objects = [];

function tableStatus(ts) {
	//log("TS hook");
	var max = ts.seatCount();
	for (var i=0; i<max; i++) {
		var seat = ts.readSeat(i);
		//log("index:"+i+" seat#:"+seat.seat_index);
		seat_objects[seat.seat_index].empty = false;
		var user = seat.getUser();
		seat_objects[i].avatar = user.avatar;
	}
}
function tableEvent(event) {
	log('EVENT:'+event.event);
	switch (event.event) {
	case "teStandUp":
		seat_objects[event.seat].empty = true;
	default:
		//dump(event);
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
		seat_objects[i] = seat;
	}
	adjustSeats();
}
var input = 1;
function setInput(x) {
	input = x;
	adjustSeats();
}
function adjustSeats() {
	var interval = (Math.PI*2) / game.seats;
	log("splitting ring into "+game.seats+" pieces");
	for (var i=0; i<game.seats; i++) {
		var fakeindex = i+0.5;
		log("index "+i+" goes in slot "+fakeindex);
		var rawx = Math.sin(fakeindex*interval);
		var rawy = Math.cos(fakeindex*interval);
		seat_objects[i].left = rawx < 0;
		var x = ((rawx/2)+0.5)*0.81;
		var y = ((rawy/2)-0.5)*-0.65;
		log("seat:"+i+" angle:"+(i*interval)+" x:"+rawx+" y:"+rawy);
		seat_objects[i].setPosition(x,y);
	}
}

initSeats();
dump(game);
var testcard = new Card();
testcard.setPosition(0,0);
testcard.setSize(0.5);
// seat images should be 90x32 by default
