#ifndef POKERMAIN_H
#define POKERMAIN_H

#include "config.h"

#include <QSslSocket>
#include <QObject>
#include <QElapsedTimer>
#include <QTimer>
#include <QSettings>
#include <QSharedPointer>
#include <QAbstractSocket>

#ifdef QT_NO_SSL
#error SSL disabled in QT!
#endif

#include "cpp/message.pb.h"
#include "club.h"
#include "game.h"
#include "tablestatus.h"

class QApplication;
class QNetworkAccessManager;
class QNetworkReply;

namespace Data {
class User;
}

class PokerMain : public QObject
{
    Q_OBJECT
public:
	explicit PokerMain(QObject *parent = 0);
	QList<Data::Club*> public_clubs();
	QList<Data::Club*> private_clubs();
	QSettings& config() { return *settings; }
	QAbstractSocket::SocketState socketState() { return socket.state(); }
	Data::User *findUser(QByteArray userid);
	QNetworkAccessManager *manager();
	qint64 getUptime() { return uptime.elapsed(); }

	Data::ClubList clubs;
	Data::GameListModel game_model;
	QList<Data::Game*> games;
	Poker::ValidCharsRegex validCharacters;
	bool delayQuit;
	QApplication *app;
	QList<Data::User*> users;
signals:
	void protocol_ready(bool);
	void login_sucess();
	void login_failure();
	void clubs_changed();
	void games_changed();
    void register_success();
    void club_create_reply(Poker::ClubCommandReply::ClubStatus status);
	void secondary_login();
	void table_status(QSharedPointer<Data::TableStatus> ts);
	void sit_ok(QByteArray gameid);

public slots:
    void try_connect();
    void socket_state_change(QAbstractSocket::SocketState state);
    void socket_sslErrors ( const QList<QSslError> & errors );
    void socket_ready();
	void sendMessage(Poker::ServerCodes code,google::protobuf::Message *message=0);
    void socket_readyRead();
    void parsePacket(Poker::ServerCodes code,std::string data);
	void replyFinished(QNetworkReply *reply);
private slots:
    void socket_connected();
    void send_ping();
private:
	void srLoginReply(std::string data);
	void seGameChange(std::string data);
	void seGameCreate(std::string data);
	void seGameDelete(std::string data);
	void seTableStatus(std::string data);
	void srInvalidTableBuyin(std::string data);
	void srTableSitOk(std::string data);

    QSslSocket socket;
    QByteArray buffer;
    QTimer pinger;
    QElapsedTimer uptime;
    QSettings *settings;
	QNetworkAccessManager *manager_;
};

extern PokerMain *core;

#endif // POKERMAIN_H
