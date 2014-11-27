#include "seatinfo.h"
#include "pokermain.h"
#include "data/user.h"

namespace Data {

void SeatInfo::update(const Poker::SeatInfo &in) {
	std::string id = in.player_mongo_id();
	userid = QByteArray(id.data(),id.length());
	seat_index = in.seat_index();
}
QObject *SeatInfo::getUser() {
	return core->findUser(userid);
}
} // namespace Data
