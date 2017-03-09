#ifndef DATA_TABLEMESSAGE_H
#define DATA_TABLEMESSAGE_H

#include <poker/message.pb.h>

namespace Data {

class TableMessage {
public:
	void update(const Poker::TableMessage &in);

};

} // namespace Data

#endif // DATA_TABLEMESSAGE_H
