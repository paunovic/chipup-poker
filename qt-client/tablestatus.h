#ifndef DATA_TABLESTATUS_H
#define DATA_TABLESTATUS_H

#include <QObject>
#include <QSharedPointer>

#include "cpp/message.pb.h"
//#include "data/seatinfo.h"
#include "data/tableevent.h"
#include "data/pot.h"
#include "data/tablemessage.h"

namespace Data {
class SeatInfo;

class TableStatus : public QObject
{
	Q_OBJECT
public:
	TableStatus(QObject *parent = 0);
	~TableStatus();
	void update(const Poker::TableStatus &in);

#define X(type,name) Q_PROPERTY(QString name READ get ## name )\
type name;\
QString get ## name();
#define Y(type,name) Q_PROPERTY(type name READ get ## name )\
type name;\
type get ## name() { return name; }


	QByteArray gameid;
	QList<Data::SeatInfo*> seats;
	X(Poker::TableStatus::TableState,state)
	Y(int,dealer)
	Y(int,current_seat)
	QList<int> bets;
	bool locked;
	int seq;
	int minimum_bet, maximum_raise, minimum_raise;
	int sb,bb;
	int handid;
	quint64 time;
	QList<QSharedPointer<Data::TableEvent> > events;
	QList<Data::Pot> pots;
	int rake_percent;
	Poker::Game::GameType current_game;
	int rotation;
	Poker::Game::GameLimit game_limit;
	Poker::TableStatus::TableType table_type;
	QList<Data::TableMessage> table_message;
signals:

public slots:
	QObject *readSeat(int index);
	int seatCount() { return seats.length(); }
};

} // namespace Data

#endif // DATA_TABLESTATUS_H
