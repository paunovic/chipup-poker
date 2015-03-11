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
	int seat() const { return _seat; }
	QString msg() const { return _msg; }

	Q_PROPERTY(int seat READ seat)
	Q_PROPERTY(QString msg READ msg)
signals:

public slots:
private:
	int _seat;
	QString _msg;
};

} // namespace Data

#endif // DATA_WINNERDATA_H
