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

	int seat_index;
	int getSeatIndex() { return seat_index; }
	Q_PROPERTY(int seat_index READ getSeatIndex)

	QByteArray userid;
	Q_PROPERTY(QByteArray userid READ getUserid)
	Q_PROPERTY(QObject* user READ getUser)
public slots:
	QByteArray getUserid() { return userid; }
	QObject *getUser();
};

} // namespace Data

#endif // DATA_SEATINFO_H
