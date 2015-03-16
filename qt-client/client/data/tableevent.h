#ifndef DATA_TABLEEVENT_H
#define DATA_TABLEEVENT_H

#include <QList>
#include <QObject>

#include "cpp/message.pb.h"
#include "data/hand.h"

namespace Data {

class Pot;

class TableEvent : public QObject {
Q_OBJECT
public:
	void update(const Poker::TableEvent &in);
	QString getEvent();
	int getSeat() { return seat; }

	Poker::TableEvent::TableEventType event;
	int seat;
	// pots
	QList<int> bets;
	QList<Hand*> cards;
	QList<Pot*> pots;

	Q_PROPERTY(QString event READ getEvent)
	Q_PROPERTY(int seat READ getSeat)
public slots:
	int getCardCount();
	QObject *getCard(int index);
};

} // namespace Data

#endif // DATA_TABLEEVENT_H
