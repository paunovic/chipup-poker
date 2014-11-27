#ifndef DATA_USER_H
#define DATA_USER_H

#include <QObject>
#include "cpp/message.pb.h"

namespace Data {

class User : public QObject
{
	Q_OBJECT
public:
	explicit User(QObject *parent = 0);
	void update(Poker::User in);
	QByteArray avatar() { return avatar_; }
	QString avatarHex() { return avatar_.toHex(); }

	Q_PROPERTY(QString avatar READ avatarHex)

	QByteArray id;
signals:

public slots:
private:
	QByteArray avatar_;
};

} // namespace Data

#endif // DATA_USER_H
