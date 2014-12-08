#include "hand.h"

namespace Data {

Hand::Hand(const std::string &in)
{
	const unsigned char *raw = (const unsigned char*) in.data();
	int count = in.length();
	for (int i=0; i<count; i++) cards.append(raw[i]);
}
QList<int> Hand::getCards() {
	return cards;
}
} // namespace Data
