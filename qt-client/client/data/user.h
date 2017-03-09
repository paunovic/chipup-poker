#ifndef DATA_USER_H
#define DATA_USER_H

#include <QObject>
#include <poker/message.pb.h>

namespace Data {

class User : public QObject
{
	Q_OBJECT
public:
	explicit User(QObject *parent = 0);
	~User();
	void update(Poker::User in);
	QByteArray avatar() { return avatar_; }
	QString avatarHex() { return avatar_.toHex(); }
	QString displayName() const { return displayname_; }
	void setDisplayName(QString in) { displayname_ = in; }

	Q_PROPERTY(QString avatar READ avatarHex)
	Q_PROPERTY(QString displayName READ displayName())
	QByteArray id;
signals:

public slots:
private:
	QByteArray avatar_;
	QString displayname_;
};

} // namespace Data

#endif // DATA_USER_H
