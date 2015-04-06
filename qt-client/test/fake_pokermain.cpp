#include <QNetworkAccessManager>
#include <QMetaMethod>

#include "pokermain.h"
#include "data/user.h"
#include "sound_effects.h"
#include "../client/minidumpuploader.h"

PokerMain *core;

PokerMain::PokerMain(QObject*) {
	manager_ = new QNetworkAccessManager(this);
	self_ = new Data::User(this);
	effects_ = new SoundEffects(this);
	uploader = new MiniDumpUploader();
}
QNetworkAccessManager *PokerMain::manager() {
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
void PokerMain::send_ping(){}
void PokerMain::doLogin(QString,QString){}
void PokerMain::RegisterListener(QObject *listener) {
	const QMetaObject *mo = listener->metaObject();
	for (int i = 0; i < mo->methodCount(); ++i) {
#if (QT_VERSION >= QT_VERSION_CHECK(5, 0, 0))
		QByteArray slot_raw = mo->method(i).methodSignature();
		const char *slot = slot_raw.data();
#else
		const char *slot = mo->method(i).signature();
#endif
		Q_ASSERT(slot);
		if (slot[0] != 'O' || slot[1] != 'n' || slot[2] != '_') continue;
		int sigIndex = metaObject()->indexOfSignal(slot + 3);
		if (sigIndex < 0) continue;
		const char *signal;
#if (QT_VERSION >= QT_VERSION_CHECK(5, 0, 0))
		QByteArray signal_raw = metaObject()->method(sigIndex).methodSignature();
		signal = signal_raw.data();
#else
		signal = metaObject()->method(sigIndex).signature();
#endif
		//qDebug() << "connecting" << signal << "to" << slot;
		if (connect(core,qPrintable(QString("2%1").arg(signal)),listener,qPrintable(QString("1%1").arg(slot)))) {
		} else qWarning("QMetaObject::connectSlotsByName: No matching signal for %s", slot);
	}
}
int parseValue(QString input) {
	QString x = input.section('.', 0, 0) + input.section('.', 1, 1).leftJustified(2, '0');
	return x.toInt();
}
void PokerMain::doneHashing() {
}
void PokerMain::httpsErrors(QNetworkReply *, const QList<QSslError> &) {
}
