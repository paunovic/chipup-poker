#pragma once

#include <QByteArray>
#include <QString>

namespace Data {
class Chat {
public:
	Chat();
	void update(const Poker::ChatEvent &in);

	Poker::ChatEvent::EventType event;
	QString username,msg;
	quint32 timestamp;
	QByteArray table_id;
};
}
