#ifndef DATA_WINNERDATA_H
#define DATA_WINNERDATA_H

#include <QObject>
#include "cpp/message.pb.h"

namespace Data {

class WinnerData : public QObject
{
	Q_OBJECT
public:
	explicit WinnerData(QObject *parent = 0);
	void update(const Poker::TableEvent::WinnerData &in);

	int seat;
	QString msg;
signals:

public slots:

};

} // namespace Data

#endif // DATA_WINNERDATA_H
