#ifndef DATA_SEATINFO_H
#define DATA_SEATINFO_H

#include <QObject>
#include <QDebug>

#include "cpp/message.pb.h"
#include "pokermain.h"

namespace Data {

class User;

class SeatInfo : public QObject {
Q_OBJECT
public:
	SeatInfo(QObject *parent=0) :QObject(parent) { cards=0; }
	void update(const Poker::SeatInfo &in);
	int card_count() { return card_count_; }
	void setCard_count(int in) { card_count_ = in; }
	int getSeatIndex() { return seat_index; }
	void setStatus(Poker::SeatInfo::PlayerStatus in) { status_ = in; }
	QString status();
	Poker::SeatInfo::PlayerStatus rawStatus() { return status_; }
	int chips() { return chips_; }
	void setChips(int in) { chips_ = in; }
	int timebank() { return timebank_; }

	int seat_index;
	QByteArray userid;

	Q_PROPERTY(QByteArray userid READ getUserid)
	Q_PROPERTY(QObject* user READ getUser)
	Q_PROPERTY(QObject* hand READ getHand)
	Q_PROPERTY(int card_count READ card_count WRITE setCard_count)
	Q_PROPERTY(int seat_index READ getSeatIndex)
	Q_PROPERTY(QString status READ status)
public slots:
	QByteArray getUserid() { return userid; }
	QObject *getUser();
private:
	QObject *getHand() { return cards; }

	int card_count_,chips_;
	Poker::SeatInfo::PlayerStatus status_;
	Data::Hand *cards;
	int timebank_;
};

} // namespace Data

#endif // DATA_SEATINFO_H
