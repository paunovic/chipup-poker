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
	QString getState();
	Poker::TableStatus::TableState state() { return state_; }
	void setState(Poker::TableStatus::TableState in) { state_ = in; }
	int getCurrentSeat() { return current_seat; }
	QList<int> bets() { return bets_; }
	int dealer() { return dealer_; }

#define X(type,name) Q_PROPERTY(QString name READ get ## name )\
type name;\
QString get ## name();
#define Y(type,name) Q_PROPERTY(type name READ get ## name )\
type name;\
type get ## name() { return name; }


	Q_PROPERTY(QString state READ getState)
	Q_PROPERTY(int current_seat READ getCurrentSeat)
	Q_PROPERTY(QList<int> bets READ bets)
	Q_PROPERTY(int dealer READ dealer)
	
	QByteArray gameid;
	QList<Data::SeatInfo*> seats;
	int current_seat;
	bool locked;
	int seq;
	int minimum_bet, maximum_raise, minimum_raise;
	int sb,bb;
	int handid;
	qint64 time;
	QList<QSharedPointer<Data::TableEvent> > events;
	QList<Data::Pot*> pots;
	int rake_percent;
	Poker::Game::GameType current_game;
	int rotation;
	Poker::Game::GameLimit game_limit;
	Poker::TableStatus::TableType table_type;
	QList<Data::TableMessage> table_message;
	int queue_position;
signals:

public slots:
	QObject *readSeatBySeat(int seat);
private:
	QList<int> bets_;
	Poker::TableStatus::TableState state_;
	int dealer_;
};

} // namespace Data

#endif // DATA_TABLESTATUS_H
