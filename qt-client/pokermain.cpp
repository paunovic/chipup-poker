#include <QDebug>

#include "pokermain.h"
#include "cpp/message.pb.h"

using namespace Poker;

PokerMain *PokerMain::instance = 0;

PokerMain::PokerMain(QObject *parent) :
    QObject(parent)
{
    connect(&socket,SIGNAL(connected()),this,SLOT(socket_connected()));
    connect(&socket,SIGNAL(stateChanged(QAbstractSocket::SocketState)),this,SLOT(socket_state_change(QAbstractSocket::SocketState)));
    connect(&socket,SIGNAL(sslErrors(QList<QSslError>)),this,SLOT(socket_sslErrors(QList<QSslError>)));
    connect(&socket,SIGNAL(encrypted()),this,SLOT(socket_ready()));
	connect(&socket,SIGNAL(readyRead()),this,SLOT(socket_readyRead()));
}

PokerMain *PokerMain::getInstance() {
    if (!instance) instance = new PokerMain();
    return instance;
}
void PokerMain::socket_connected() {
    qDebug() << "socket connected";
}
void PokerMain::try_connect() {
    if (socket.state() == QAbstractSocket::UnconnectedState) {
        socket.connectToHostEncrypted("server.chipuppoker.com",12346);
    }
}
void PokerMain::socket_state_change(QAbstractSocket::SocketState state) {
    qDebug() << state;
}
void PokerMain::socket_sslErrors(const QList<QSslError> &errors) {
    qDebug() << "incoming err" << errors;
    QList<QSslCertificate> cert = QSslCertificate::fromData(
                "-----BEGIN CERTIFICATE-----\n"
                "MIIDiTCCAnGgAwIBAgIJAKfTetvcSDlkMA0GCSqGSIb3DQEBBQUAMFsxCzAJBgNV\n"
                "BAYTAlVTMRMwEQYDVQQIDApTb21lLVN0YXRlMRYwFAYDVQQKDA1jaGlwIHVwIHBv\n"
                "a2VyMR8wHQYDVQQDDBZzZXJ2ZXIuY2hpcHVwcG9rZXIuY29tMB4XDTE0MDQxNTE5\n"
                "MDkwM1oXDTE1MDQxNTE5MDkwM1owWzELMAkGA1UEBhMCVVMxEzARBgNVBAgMClNv\n"
                "bWUtU3RhdGUxFjAUBgNVBAoMDWNoaXAgdXAgcG9rZXIxHzAdBgNVBAMMFnNlcnZl\n"
                "ci5jaGlwdXBwb2tlci5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB\n"
                "AQDjvpOTvKb4tIMGpprvxeTGdOt5kkkTq47jyraPLCnMIEJluGKbfO8ByZFjH8aV\n"
                "hWIKG4+3U6LMnx1j8OWW611VooIFjxs4Chc3+EhdyT7muVsNB2N8UmP350jfi7wH\n"
                "J1+A7yXCHqxesqe9I4NTttXm6QrfT/vslSKo5kR/05Afe8Yj5r+6JlDhX+P2G0Dl\n"
                "6Hi9CDJ5YIby1fLygYk+NPaSdnXXwsfB3VXFda4MincxgmY7QURBrAjDmKkS4nTn\n"
                "shG4kYaqlTBCZH45a3xvqYcqtgpart31BbjAzwUtsW/fshBEJzcYUZ9pXiWgSrH9\n"
                "Nu1sefkcmMplkGM6jef1pinPAgMBAAGjUDBOMB0GA1UdDgQWBBTFB2O6DCiOqKq2\n"
                "47wrh0+IXTWjWzAfBgNVHSMEGDAWgBTFB2O6DCiOqKq247wrh0+IXTWjWzAMBgNV\n"
                "HRMEBTADAQH/MA0GCSqGSIb3DQEBBQUAA4IBAQBF0YjN6LsO7xTzjv3JPTtgSC/k\n"
                "uOdRx0MD7LLbrqglWuBLVDN1d+q7v44Nr6TbRRLS+wqPK9sBepnzUOMuYUfYzg1o\n"
                "Hxmcv3bW+yv9jR+9boIeFs9wkjCIMcNdOpM0b5GM1moGCvsX/0BFd+4yQYRCftb4\n"
                "R+5IFPZ2OM11/EgCyQ/dpjYHSj+nmL87qr+2TbdSJ//2afzMmM5v0+K1JoHOjJ7s\n"
                "HkaMVE+e0ZCaYpuDbl1bnhkYhOmP/p7rC/r0kuvwYFAgfbhOW70/wgwxz9qFRS0O\n"
                "8XZWdnYfZX068XiJMVxR7+Q44aR8nv7cpc8r7OfpxbShoL9W2RoPGn0u1Yrq\n"
                "-----END CERTIFICATE-----\n");
    qDebug() << "certs" << cert;
    QSslError error(QSslError::SelfSignedCertificate, cert.at(0));
    QList<QSslError> expectedSslErrors;
    expectedSslErrors.append(error);
    socket.ignoreSslErrors(expectedSslErrors);
    qDebug() << "expected error" << expectedSslErrors;
}
void PokerMain::socket_ready() {
    Poker::HelloParams hp;
    hp.set_debug(false);
    sendMessage(Poker::scHello,&hp);
}
void PokerMain::sendMessage(Poker::ServerCodes code, google::protobuf::Message *message) {
    Poker::RpcMessage header;
    header.set_methodid(code);
    if (message->ByteSize()) header.set_datasize(message->ByteSize());
    int size = header.ByteSize()+message->ByteSize();
    unsigned char *buffer = new unsigned char[size+2];
    buffer[0] = header.ByteSize() & 0xff;
    buffer[1] = header.ByteSize() >> 8;
    header.SerializeToArray(2+buffer,size);
    if (message->ByteSize()) {
        message->SerializeToArray(2+buffer+header.ByteSize(),size-header.ByteSize());
    }
    QByteArray packet((char*)buffer,2+size);
    socket.write(packet);
    delete buffer;
    socket.flush();
}
void PokerMain::socket_readyRead() {
	unsigned int bytes;
	
	buffer.append(socket.readAll());
	while (true) {
		QDataStream input(buffer);
		input.setByteOrder(QDataStream::LittleEndian);
		quint16 headerSize;
		input >> headerSize;
		if (input.atEnd()) break;
		char *rawheader = new char[headerSize];
		bytes = input.readRawData(rawheader,headerSize);
		if (bytes != headerSize) break;
		RpcMessage header;
		if (!header.ParseFromString(std::string(rawheader,headerSize))) {
			// parse error in header, disconnect
			socket.disconnect();
			// TODO, emit failure event
			break;
		}
		delete rawheader;
		int datasize = header.datasize();
		std::string data;
		if (datasize) {
			char *rawdata = new char[datasize];
			bytes = input.readRawData(rawdata,datasize);
			if (bytes != datasize) break;
			data = std::string(rawdata,datasize);
			delete rawdata;
		}
		Poker::ServerCodes code((Poker::ServerCodes)header.methodid());
		parsePacket(code,data);
		buffer = buffer.right(buffer.size() - (2 + headerSize + datasize));
	}
}
void PokerMain::parsePacket(Poker::ServerCodes code,std::string data) {
	Poker::HelloReply hr;
	Poker::LoginReply lr;

	switch (code) {
	case Poker::srHello:
		hr.ParseFromString(data);
		emit protocol_ready(true);
		break;
	case Poker::srLoginReply:
		qDebug() << "srLoginReply";
		lr.ParseFromString(data);
		if (lr.login_status() == LoginReply::lrSuccess) {
			qDebug() << "sucess!";
			// TODO, convert and use reconnect_tables,tournament_infos,registered_tournaments,clubs,users,self,games,player_club_statuses
			emit login_sucess();
		} else {
			qDebug() << "failure";
			emit login_failure();
		}
		break;
	case Poker::srTableStatsReply:
		qDebug() << "srTableStatsReply";
		break;
	default:
		qDebug() << "unhandled raw rpc method:" << code;
	}
}
