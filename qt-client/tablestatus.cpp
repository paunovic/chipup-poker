#include "tablestatus.h"

namespace Data {

TableStatus::TableStatus(QObject *parent) :
	QObject(parent)
{
}

void TableStatus::update(const Poker::TableStatus &in) {
	std::string rawid = in.table_mongo_id();
	int i;

	gameid = QByteArray(rawid.data(),rawid.size());
	for (i=0; i<in.seats_size(); i++) {
		Data::SeatInfo *seat = new Data::SeatInfo;
		seat->update(in.seats(i));
		seats.append(seat);
	}
	state = in.state();
	dealer = in.dealer();
	current_seat = in.current_seat();
	for (i=0; i<in.bets_size(); i++) {
		bets.append(in.bets(i));
	}
	locked = in.locked();
	seq = in.seq();
	minimum_bet = in.minimum_bet();
	maximum_raise = in.maximum_raise();
	minimum_raise = in.minimum_raise();
	sb = in.small_blind();
	bb = in.big_blind();
	handid = in.handid();
	time = in.time();
	for (i=0; i<in.events_size(); i++) {
		Data::TableEvent e;
		e.update(in.events(i));
		events.append(e);
	}
	for (i=0; i<in.pots_size(); i++) {
		Data::Pot p;
		p.update(in.pots(i));
		pots.append(p);
	}
	rake_percent = in.rake_percent();
	current_game = in.current_game();
	rotation = in.rotation();
	game_limit = in.game_limit();
	table_type = in.table_type();
	for (i=0; i<in.table_message_size(); i++) {
		Data::TableMessage m;
		m.update(in.table_message(i));
		table_message.append(m);
	}
}
QString TableStatus::getstate() {
	switch (state) {
	case Poker::TableStatus::tsIdle: return "tsIdle";
	default: return "err";
	}
}
TableStatus::~TableStatus() {
	// TODO, try setting the parent of the seats
	while (!seats.isEmpty()) {
		Data::SeatInfo *x = seats.takeFirst();
		delete x;
	}
}
QObject *TableStatus::readSeat(int index) {
	return seats.at(index);
}
} // namespace Data
