#ifndef DATA_TABLEEVENT_H
#define DATA_TABLEEVENT_H

#include <QList>

#include "cpp/message.pb.h"
#include "data/hand.h"

namespace Data {

class TableEvent {
public:
	void update(const Poker::TableEvent &in);

	Poker::TableEvent::TableEventType event;
	int seat;
	// pots
	QList<int> bets;
	QList<Hand> cards;
};

} // namespace Data

#endif // DATA_TABLEEVENT_H
