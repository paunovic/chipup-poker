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
		seat.setPosition(i*0.05,i*0.05);
        seat.setSize(0.2);
		seat_objects[i] = seat;
	}
}
//initSeats();
seat_objects[0] = new SeatObject();
seat_objects[0].setSize(0.16);
seat_objects[0].setPosition(0.62,0.02); // #1
seat_objects[1] = new SeatObject();
seat_objects[1].setSize(0.16);
seat_objects[1].setPosition(0.78,0.18); // #2
seat_objects[2] = new SeatObject();
seat_objects[2].setSize(0.16);
seat_objects[2].setPosition(0.82,0.45); // #3

// seat images should be 90x32 by default
