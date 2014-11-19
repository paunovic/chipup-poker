#include "seatinfo.h"

namespace Data {

void SeatInfo::update(const Poker::SeatInfo &in) {
	seat_index = in.seat_index();
}

} // namespace Data
