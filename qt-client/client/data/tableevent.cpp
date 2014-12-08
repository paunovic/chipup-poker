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
		cards.append(new Hand(in.cards(i)));
	}
}
QString TableEvent::getEvent() {
	switch (event) {
	case Poker::TableEvent::teFold: return "teFold"; // 0
	case Poker::TableEvent::teSit: //1
		return "teSit";
	case Poker::TableEvent::teStandUp: // 2
		return "teStandUp";
	case Poker::TableEvent::teWinning: return "teWinning"; // 3
	case Poker::TableEvent::teDealing: return "teDealing"; // 4
	case Poker::TableEvent::teCheck: return "teCheck"; // 5
	case Poker::TableEvent::teCall: return "teCall"; // 6
	case Poker::TableEvent::teFlop: return "teFlop"; // 9
	case Poker::TableEvent::teTurn: return "teTurn"; // 10
	case Poker::TableEvent::teRiver: return "teRiver"; // 11
	case Poker::TableEvent::tePostRiver: return "tePostRiver"; // 12
	default:
		return QString("FIXME:%1").arg(event);
	}
}
int TableEvent::getCardCount() {
	return cards.length();
}
QObject *TableEvent::getCard(int index) {
	return cards.at(index);
}
} // namespace Data
