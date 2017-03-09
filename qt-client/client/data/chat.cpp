#include <poker/message.pb.h>

#include "chat.h"

namespace Data {
Chat::Chat() {
	timestamp = 0;
}
void Chat::update(const Poker::ChatEvent &in) {
	event = in.event();
	Poker::ChatMessage x = in.msg();
	if (x.has_username()) username = x.username().c_str();
	msg = x.msg().c_str();
	if (x.has_timestamp()) timestamp = x.timestamp();
	if (in.has_table_id()) {
		std::string y = in.table_id();
		table_id = QByteArray(y.data(),y.length());
	}
}
}
