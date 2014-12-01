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
	SeatInfo(QObject *parent=0) :QObject(parent) {}
	void update(const Poker::SeatInfo &in);
	int card_count() { return card_count_; }
	void setCard_count(int in) { card_count_ = in; }
	int getSeatIndex() { return seat_index; }
	void setStatus(Poker::SeatInfo::PlayerStatus in) { status_ = in; }
	QString status();

	int seat_index;
	QByteArray userid;

	Q_PROPERTY(QByteArray userid READ getUserid)
	Q_PROPERTY(QObject* user READ getUser)
	Q_PROPERTY(int card_count READ card_count WRITE setCard_count)
	Q_PROPERTY(int seat_index READ getSeatIndex)
	Q_PROPERTY(QString status READ status)
public slots:
	QByteArray getUserid() { return userid; }
	QObject *getUser();
private:
	int card_count_;
	Poker::SeatInfo::PlayerStatus status_;
};

} // namespace Data

#endif // DATA_SEATINFO_H
