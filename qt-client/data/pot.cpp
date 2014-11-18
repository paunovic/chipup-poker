#include "pot.h"

namespace Data {

void Pot::update(const Poker::Pot &in) {
	int i;
	value = in.value();
	for (i=0; i<in.members_size(); i++) {
		members.append(in.members(i));
	}
	rake = in.rake();
}
} // namespace Data
