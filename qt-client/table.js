print("LOAD!");
var seat_objects = [];

function tableStatus(ts) {
	log("TS hook");
	var max = ts.seatCount();
	for (var i=0; i<max; i++) {
		var seat = ts.readSeat(i);
		log("index:"+i+" seat#:"+seat.seat_index);
		if (!seat_objects[seat.seat_index]) {
			//seat_objects[seat.seat_index] = new SeatObject();
			//seat_objects[seat.seat_index].setPosition(i*0.1,i*0.1);
            //seat_objects[seat.seat_index].setSize(0.2);
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
		var x = ((Math.sin(fakeindex*interval)/2)+0.5)*0.81;
		var y = ((Math.cos(fakeindex*interval)/2)-0.5)*-0.65;
		log("seat:"+i+" angle:"+(i*interval)+" x:"+x+" y:"+y);
		seat_objects[i].setPosition(x,y);
	}
}

initSeats();

// seat images should be 90x32 by default
