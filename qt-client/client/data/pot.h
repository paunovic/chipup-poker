#ifndef DATA_POT_H
#define DATA_POT_H

#include <QList>

#include "cpp/message.pb.h"

namespace Data {

class Pot {
public:
	void update(const Poker::Pot &in);

	int value;
	QList<int> members;
	int rake;
};

} // namespace Data

#endif // DATA_POT_H
