#ifndef DATA_SEATINFO_H
#define DATA_SEATINFO_H

#include "cpp/message.pb.h"

namespace Data {

class SeatInfo {
public:
	void update(const Poker::SeatInfo &in);
};

} // namespace Data

#endif // DATA_SEATINFO_H
