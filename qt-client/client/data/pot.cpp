#include "pot.h"

namespace Data {

void Pot::update(const Poker::Pot &in) {
	int i;
	value_ = in.value();
	for (i=0; i<in.members_size(); i++) {
		members_.append(in.members(i));
	}
	rake_ = in.rake();
}
} // namespace Data
