#ifndef POKERMAIN_H
#define POKERMAIN_H

#include <QSslSocket>
#include <QObject>
#include <QElapsedTimer>
#include <QTimer>

#include "cpp/message.pb.h"
#include "club.h"
#include "game.h"

class PokerMain : public QObject
{
    Q_OBJECT
public:
    explicit PokerMain(QObject *parent = 0);
    static PokerMain *getInstance();

    QList<Data::Club> clubs,private_clubs,public_clubs;
	QList<Data::Game> games;
signals:
	void protocol_ready(bool);
	void login_sucess();
	void login_failure();
	void clubs_changed();
	void games_changed();

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
    static PokerMain *instance;
    QByteArray buffer;
    QTimer pinger;
    QElapsedTimer uptime;
};

#endif // POKERMAIN_H
