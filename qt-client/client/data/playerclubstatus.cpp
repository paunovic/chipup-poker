#include "playerclubstatus.h"
#include "cpp/message.pb.h"

namespace Data {

PlayerClubStatus::PlayerClubStatus()
{
	buyin_min = -1;
	buyin_max = -1;
}

void PlayerClubStatus::update(Poker::PlayerClubStatus &in) {
	buyin_min = in.buyin_min();
	buyin_max = in.buyin_max();
	std::string temp = in.clubid();
	clubid = QByteArray(temp.data(),temp.length());
	temp = in.tableid();
	tableid = QByteArray(temp.data(),temp.length());
}
} // namespace Data
