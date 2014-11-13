#ifndef POKERMAIN_H
#define POKERMAIN_H

#include <QSslSocket>
#include <QObject>

#include "cpp/message.pb.h"

class PokerMain : public QObject
{
    Q_OBJECT
public:
    explicit PokerMain(QObject *parent = 0);
    static PokerMain *getInstance();
signals:
	void protocol_ready(bool);
	void login_sucess();
	void login_failure();

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
private:
    QSslSocket socket;
    static PokerMain *instance;
    QByteArray buffer;
};

#endif // POKERMAIN_H
