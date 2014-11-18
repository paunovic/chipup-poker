#ifndef DATA_TABLESTATUS_H
#define DATA_TABLESTATUS_H

#include <QObject>

#include "cpp/message.pb.h"
#include "data/seatinfo.h"
#include "data/tableevent.h"
#include "data/pot.h"
#include "data/tablemessage.h"

namespace Data {

class TableStatus : public QObject
{
	Q_OBJECT
public:
	explicit TableStatus(QObject *parent = 0);
	void update(const Poker::TableStatus &in);

	QByteArray gameid;
	QList<Data::SeatInfo> seats;
	Poker::TableStatus::TableState state;
	int dealer;
	int current_seat;
	QList<int> bets;
	bool locked;
	int seq;
	int minimum_bet, maximum_raise, minimum_raise;
	int sb,bb;
	int handid;
	quint64 time;
	QList<Data::TableEvent> events;
	QList<Data::Pot> pots;
	int rake_percent;
	Poker::Game::GameType current_game;
	int rotation;
	Poker::Game::GameLimit game_limit;
	Poker::TableStatus::TableType table_type;
	QList<Data::TableMessage> table_message;
signals:

public slots:

};

} // namespace Data

#endif // DATA_TABLESTATUS_H
