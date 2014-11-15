#ifndef POKERMAIN_H
#define POKERMAIN_H

#include <QSslSocket>
#include <QObject>
#include <QElapsedTimer>
#include <QTimer>
#include <QSettings>

#include "cpp/message.pb.h"
#include "club.h"
#include "game.h"

class PokerMain : public QObject
{
    Q_OBJECT
public:
	explicit PokerMain(QObject *parent = 0);
	QList<Data::Club*> public_clubs();
	QList<Data::Club*> private_clubs();
    QSettings& config() { return *settings; }

	Data::ClubList clubs;
	QList<Data::Game> games;
    Poker::ValidCharsRegex validCharacters;
signals:
	void protocol_ready(bool);
	void login_sucess();
	void login_failure();
	void clubs_changed();
	void games_changed();
    void register_success();
    void club_create_reply(Poker::ClubCommandReply::ClubStatus status);

public slots:
    void try_connect();
    void socket_state_change(QAbstractSocket::SocketState state);
    void socket_sslErrors ( const QList<QSslError> & errors );
    void socket_ready();
    void sendMessage(Poker::ServerCodes code,google::protobuf::Message *message);
    void socket_readyRead();
    void parsePacket(Poker::ServerCodes code,std::string data);
private slots:
    void socket_connected();
    void send_ping();
private:
    QSslSocket socket;
    QByteArray buffer;
    QTimer pinger;
    QElapsedTimer uptime;
    QSettings *settings;
};

extern PokerMain *core;

#endif // POKERMAIN_H
