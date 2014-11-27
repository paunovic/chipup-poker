#include <QNetworkAccessManager>

#include "pokermain.h"
#include "data/user.h"

PokerMain *core;

PokerMain::PokerMain(QObject *parent) {
}
QNetworkAccessManager *PokerMain::manager() {
	manager_ = new QNetworkAccessManager(this);
	return manager_;
}
Data::User *PokerMain::findUser(QByteArray userid) {
	QList<Data::User*>::Iterator i;
	for (i=users.begin(); i != users.end(); ++i) {
		Data::User *u = *i;
		if (u->id == userid) return u;
	}
	qDebug() << "finding user" << userid.toHex();
	qDebug() << "none found";
	return 0;
}
void PokerMain::try_connect() {}
void PokerMain::socket_state_change(QAbstractSocket::SocketState){}
void PokerMain::socket_sslErrors(QList<QSslError> const &){}
void PokerMain::socket_ready(){}
void PokerMain::sendMessage(Poker::ServerCodes,google::protobuf::Message*){}
void PokerMain::socket_readyRead(){}
void PokerMain::parsePacket(Poker::ServerCodes,std::string){}
void PokerMain::replyFinished(QNetworkReply*){}
void PokerMain::socket_connected(){}
void PokerMain::send_ping(){}
