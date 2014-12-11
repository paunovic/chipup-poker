#include "seatinfo.h"
#include "pokermain.h"
#include "data/user.h"

namespace Data {

void SeatInfo::update(const Poker::SeatInfo &in) {
	std::string id = in.player_mongo_id();
	userid = QByteArray(id.data(),id.length());
	seat_index = in.seat_index();
	card_count_ = in.card_count();
	status_ = in.status();
	chips_ = in.chips();
	cards = new Hand(in.cards());
}
QObject *SeatInfo::getUser() {
	return core->findUser(userid);
}
QString SeatInfo::status() {
	switch (status_) {
	case Poker::SeatInfo::psInHand: return "psInHand";
	case Poker::SeatInfo::psOutOfPlay: return "psOutOfPlay";
	case Poker::SeatInfo::psOutOfHand: return "psOutOfHand";
	case Poker::SeatInfo::psFolded: return "psFolded";
	case Poker::SeatInfo::psAllIn: return "psAllIn";
	}
	return "error";
}
} // namespace Data
