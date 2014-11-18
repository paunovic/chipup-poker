#include "tableevent.h"

namespace Data {

void TableEvent::update(const Poker::TableEvent &in) {
	int i;

	event = in.event();
	seat = in.seat();
	for (i=0; i<in.bets_size(); i++) {
		bets.append(in.bets(i));
	}
	for (i=0; i<in.cards_size(); i++) {
		cards.append(Hand(in.cards(i)));
	}
}

} // namespace Data
