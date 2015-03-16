#include "pot.h"
#include "data/winnerdata.h"

namespace Data {

void Pot::update(const Poker::Pot &in) {
	int i;
	value_ = in.value();
	for (i=0; i<in.members_size(); i++) {
		members_.append(in.members(i));
	}
	rake_ = in.rake();
	for (i=0; i<in.winnerdata_size(); i++) {
		WinnerData *wd = new WinnerData(this);
		wd->update(in.winnerdata(i));
		winnerData.append(wd);
	}
}
} // namespace Data
