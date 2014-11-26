print("LOAD!");
var seat_objects = [];
var offset = 0;

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
	var extra = 0;
	var extra2 = 0;
	var mult = 1;
	switch (game.seats) {
	case 2:
		extra = 2;
		extra2 = 2;
		mult = 2;
		break;
	case 3:
		extra = 1;
		break;
	case 4:
		offset = Math.PI/4;
		break;
	case 5:
		extra = 1;
		offset = Math.PI * 1.83;
		break;
	case 7:
		extra = 1;
		extra2 = 1;
		break;
	}
	var interval = (Math.PI*2) / (game.seats+extra);
	log("splitting ring into "+(game.seats+extra)+" pieces");
	for (var i=0; i<game.seats; i++) {
		var fakeindex = (i*mult)+extra2;
		log("index "+i+" goes in slot "+fakeindex);
		var x = ((Math.sin(fakeindex+offset)/2)+0.5)*0.81;
		var y = ((Math.cos(fakeindex+offset)/2)-0.5)*-0.65;
		log("seat:"+i+" angle:"+(i*interval)+" x:"+x+" y:"+y);
		seat_objects[i].setPosition(x,y);
	}
}

initSeats();

// seat images should be 90x32 by default
