#ifndef DATA_POT_H
#define DATA_POT_H

#include <QList>
#include <QObject>

#include "cpp/message.pb.h"

namespace Data {

class WinnerData;

class Pot : public QObject {
Q_OBJECT
public:
	void update(const Poker::Pot &in);
	int value() { return value_; }
	QList<int> members() { return members_; }
	int rake() { return rake_; }

	QList<WinnerData*> winnerData;

	Q_PROPERTY(int value READ value)
	Q_PROPERTY(QList<int> members READ members)
	Q_PROPERTY(int rake READ rake)
private:
	int value_;
	QList<int> members_;
	int rake_;
};

} // namespace Data

#endif // DATA_POT_H
