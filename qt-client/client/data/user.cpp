#include <QDebug>

#include "user.h"

namespace Data {

User::User(QObject *parent) :
	QObject(parent)
{
}
User::~User() {
}
void User::update(Poker::User in) {
	std::string avatar = in.avatar();
	avatar_ = QByteArray(avatar.data(),avatar.length());

	std::string id = in._id();
	this->id = QByteArray(id.data(),id.length());
	displayname_ = in.displayname().c_str();
}
} // namespace Data
