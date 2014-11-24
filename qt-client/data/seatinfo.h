#ifndef DATA_SEATINFO_H
#define DATA_SEATINFO_H

#include <QObject>
#include <QDebug>

#include "cpp/message.pb.h"

namespace Data {

class SeatInfo : public QObject {
Q_OBJECT
public:
	SeatInfo(QObject *parent=0) :QObject(parent) {}
	void update(const Poker::SeatInfo &in);

#define Y(type,name) Q_PROPERTY(type name READ get ## name )\
type name;\
type get ## name() { qDebug() << "read field";return name; }
#undef Y
	int seat_index;
	int getSeatIndex() { return seat_index; }
	Q_PROPERTY(int seat_index READ getSeatIndex)
};

} // namespace Data

#endif // DATA_SEATINFO_H
