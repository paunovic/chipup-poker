#include "winnerdata.h"

namespace Data {

WinnerData::WinnerData(QObject *parent) :
	QObject(parent)
{
}
void WinnerData::update(const Poker::TableEvent::WinnerData &in) {
	_seat = in.seat();
	_msg = in.msg().c_str();
}
} // namespace Data
