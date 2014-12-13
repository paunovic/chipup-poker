#ifndef DATA_PLAYERCLUBSTATUS_H
#define DATA_PLAYERCLUBSTATUS_H

#include <QByteArray>

namespace Poker {
class PlayerClubStatus;
}

namespace Data {

class PlayerClubStatus
{
public:
	PlayerClubStatus();
	void update(Poker::PlayerClubStatus &in);

	QByteArray clubid;
	QByteArray tableid;
	int buyin_min;
	int buyin_max;
};

} // namespace Data

#endif // DATA_PLAYERCLUBSTATUS_H
