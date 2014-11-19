log("testing");

function tableStatus(ts) {
	log("TS hook");
	log(ts);
	var max = ts.seatCount();
	for (var i=0; i<max; i++) {
		var seat = ts.readSeat(i);
		log("index:"+i+" seat#:"+seat.seat_index);
	}
}
function dump(i) {
	for (key in i) {
		log("key:"+key+" type:"+typeof i[key]);
	}
}