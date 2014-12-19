#include <QDebug>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QMetaMethod>

#include "pokermain.h"
#include "cpp/message.pb.h"
#include "club.h"
#include "tablestatus.h"
#include "data/user.h"
#include "data/playerclubstatus.h"

using namespace Poker;

PokerMain *core;

PokerMain::PokerMain(QObject *parent) :
    QObject(parent), settings(new QSettings("ChipUPPoker","ChipUPPoker"))
{
	setObjectName("core");
	delayQuit = false;
	manager_ = new QNetworkAccessManager(this);
	self_ = new Data::User(this);
	connect(manager(), SIGNAL(finished(QNetworkReply*)),this, SLOT(replyFinished(QNetworkReply*)));

    connect(&socket,SIGNAL(connected()),this,SLOT(socket_connected()));
    connect(&socket,SIGNAL(stateChanged(QAbstractSocket::SocketState)),this,SLOT(socket_state_change(QAbstractSocket::SocketState)));
    connect(&socket,SIGNAL(sslErrors(QList<QSslError>)),this,SLOT(socket_sslErrors(QList<QSslError>)));
    connect(&socket,SIGNAL(encrypted()),this,SLOT(socket_ready()));
	connect(&socket,SIGNAL(readyRead()),this,SLOT(socket_readyRead()));
	connect(&pinger,SIGNAL(timeout()),this,SLOT(send_ping()));
	uptime.start();
}
QNetworkAccessManager *PokerMain::manager() {
	return manager_;
}
void PokerMain::replyFinished(QNetworkReply *reply) {
	reply->deleteLater();
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
    switch (state) {
    case QAbstractSocket::UnconnectedState:
        // set a timer to reconnect
        break;
    }
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
	first_ping = true;
    Poker::HelloParams hp;
    hp.set_debug(false);
	qDebug() << "sending hello";
    sendMessage(Poker::scHello,&hp);
    pinger.setSingleShot(false);
    pinger.setInterval(30000);
    pinger.start();
}
void PokerMain::sendMessage(Poker::ServerCodes code, google::protobuf::Message *message) {
    Poker::RpcMessage header;
    header.set_methodid(code);
	int messagesize = 0;
	if (message && message->ByteSize()) {
		messagesize = message->ByteSize();
		header.set_datasize(messagesize);
	}
	int size = header.ByteSize()+messagesize;
    unsigned char *buffer = new unsigned char[size+2];
    buffer[0] = header.ByteSize() & 0xff;
    buffer[1] = header.ByteSize() >> 8;
    header.SerializeToArray(2+buffer,size);
	if (message && message->ByteSize()) {
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
	Poker::PingReply ping_reply;
	int recv_time = uptime.elapsed();

	switch (code) {
	case Poker::srHello:
		hr.ParseFromString(data);
		validCharacters = hr.valid_chars_regex();
		max_play_time = hr.max_play_time();
		send_ping();
		emit protocol_ready(true);
		break;
	case Poker::srLoginReply: // 2
		srLoginReply(data);
		break;
    case Poker::srRegisterReply: { // 3
        Poker::RegisterReply rr;
        rr.ParseFromString(data);
        switch (rr.status()) {
        case RegisterReply::regSuccess:
            emit register_success();
            break;
        default:
            qDebug() << "srRegisterReply unhandled status" << rr.status();
        }
        break; }
	case Poker::srCreateClubReply: { // 4
		Poker::ClubCommandReply ccr;
		ccr.ParseFromString(data);
		switch (ccr.status()) {
		case ClubCommandReply::csSuccess: {
			Data::Club *c = new Data::Club();
			c->update(ccr.club());
			clubs.add(c);
			emit club_create_reply(ccr.status());
			emit clubs_changed();
			break;
		}
        case ClubCommandReply::csInvalidName:
            emit club_create_reply(ccr.status());
            break;
		default:
			qDebug() << "unhandled srCreateClubReply status" << ccr.status();
		}
		break; }
	case Poker::srLogout: // 8
		delayQuit = false;
		break;
	case Poker::srTableSitOk: // 27
		srTableSitOk(data);
		break;
	case Poker::srTableSitSeatTaken: // 28
		srTableSitSeatTaken(data);
		break;
	case Poker::srTableStandUpOk: // 29
		srTableStandUpOk(data);
		break;
	case Poker::srPong: { // 30
		ping_reply.ParseFromString(data);
		int previous_uptime = ping_reply.uptime();
		quint64 ping = recv_time - previous_uptime;
		quint64 server_clock = ping_reply.servertime() + (ping/2);
		qint64 diff = server_clock - getServerTime();
		clock_offset = server_clock - recv_time;
		if (first_ping) {
			first_ping = false;
			totalError = 0;
			diff = 0;
		}
		totalError += diff;
		qDebug() << "ping:" << ping << "server clock:" << server_clock << "offset:" << clock_offset << "diff:" << diff << totalError;
		break; }
	case Poker::srTableStatsReply: // 35
		qDebug() << "srTableStatsReply";
		break;
	case Poker::srTableBuyinLessThanCashout: // 37
		srTableBuyinLessThanCashout(data);
		break;
	case Poker::srInvalidTableBuyin: // 38
		srInvalidTableBuyin(data);
		break;
	case Poker::seSecondaryLoginDetected:
		emit secondary_login();
		break;
	case Poker::srJoinClubReply: {
		// TODO, parse games in ccr
		Poker::ClubCommandReply ccr;
		ccr.ParseFromString(data);
		qDebug() << "status" << ccr.status();
		switch (ccr.status()) {
		case ClubCommandReply::csSuccess: {
			std::string clubid1 = ccr.club()._id();
			QByteArray clubid = QByteArray(clubid1.data(),clubid1.length());
			qDebug() << "clubid" << clubid.toHex();
			bool clubfound = false;
			int i;
			for (i=0; i<clubs.size(); i++) {
				if (clubs.at(i)->clubid == clubid) {
					Data::Club *c = clubs.at(i);
					bool old_private = c->is_private;
					c->update(ccr.club());
					clubs.modified(c,old_private);
					clubfound = true;
					break;
				}
			}
			if (!clubfound) {
				// TODO
				Data::Club *c = new Data::Club();
				c->update(ccr.club());
				clubs.add(c);
			}
			emit clubs_changed();
			break; }
		default:
			// TODO
			qDebug() << "unhandled srJoinClubReply status" << ccr.status();
		}
		break;
	}
	case Poker::seGameChange: // 55
		seGameChange(data);
		break;
	case Poker::seGameCreate: // 56
		seGameCreate(data);
		break;
	case Poker::seGameDelete: // 57
		seGameDelete(data);
		break;
	case Poker::seTableStatus: // 58
		seTableStatus(data);
		break;
	case Poker::sePlayerClubStatus: // 63
		sePlayerClubStatus(data);
		break;
	default:
		qDebug() << "unhandled raw rpc method:" << code;
	}
}
void PokerMain::send_ping() {
	Poker::PingParams pp;
	pp.set_uptime(uptime.elapsed());
	sendMessage(Poker::scPing,&pp);
}
QList<Data::Club*> PokerMain::public_clubs() {
	QList<Data::Club*> out;
	for (int i=0; i<clubs.size(); i++) {
		if (!clubs.at(i)->is_private) out.append(clubs.at(i));
	}
	return out;
}
QList<Data::Club*> PokerMain::private_clubs() {
	QList<Data::Club*> out;
	for (int i=0; i<clubs.size(); i++) {
		if (clubs.at(i)->is_private) out.append(clubs.at(i));
	}
	return out;
}
void PokerMain::seGameChange(std::string data) {
	Poker::Game g;
	g.ParseFromString(data);

	std::string gameid2 = g._id();
	QByteArray gameid(gameid2.data(),gameid2.length());

	for (int i=0; i<games.size(); i++) {
		if (games.at(i)->gameid == gameid) {
			Data::Game *g2 = games[i];
			g2->update(g);
			game_model.updated(g2);
			break;
		}
	}
}
void PokerMain::seGameCreate(std::string data) {
	Poker::Game g;
	g.ParseFromString(data);

	qDebug() << "seGameCreate";

	Data::Game *g2 = new Data::Game;
	g2->update(g);
	games.append(g2);
	game_model.add(g2);
}
void PokerMain::seGameDelete(std::string data) {
	Poker::Game g;
	g.ParseFromString(data);

	qDebug() << "seGameDelete";

	std::string rawid = g._id();
	QByteArray gameid(rawid.data(),rawid.length());
	for (int i=0; i<games.size(); i++) {
		if (games.at(i)->gameid == gameid) {
			game_model.remove(games[i]);
			games.removeAt(i);
			break;
		}
	}
}
void PokerMain::seTableStatus(std::string data) {
	Poker::TableStatus ts;
	ts.ParseFromString(data);
	QSharedPointer<Data::TableStatus> out(new Data::TableStatus);
	out->update(ts);
	emit table_status(out);
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
void PokerMain::srLoginReply(std::string data) {
	Poker::LoginReply lr;
	int i;
	qDebug() << "srLoginReply";
	lr.ParseFromString(data);
	if (lr.login_status() == LoginReply::lrSuccess) {
		qDebug() << "sucess!";
		// TODO, convert and use reconnect_tables,tournament_infos,registered_tournaments,clubs,self,games,player_club_statuses
		clubs.clear();
		for (i=0; i<lr.clubs_size(); i++) {
			Poker::Club c = lr.clubs(i);
			Data::Club *c_out = new Data::Club;
			c_out->update(c);
			clubs.add(c_out);
		}
		games.clear();
		for (i=0; i<lr.games_size(); i++) {
			Poker::Game g = lr.games(i);
			Data::Game *g_out = new Data::Game;
			g_out->update(g);
			games.append(g_out);
		}
		for (i=0; i<lr.users_size(); i++) {
			Poker::User u = lr.users(i);
			Data::User *u_out = new Data::User;
			u_out->update(u);
			users.append(u_out);
		}
		Poker::User self = lr.self();
		self_->update(self);
		emit login_sucess();
		emit clubs_changed();
		emit games_changed();
	} else {
		qDebug() << "failure";
		emit login_failure();
	}
}
void PokerMain::srInvalidTableBuyin(std::string data) {
	Poker::BuyinError be;
	be.ParseFromString(data);
	qDebug() << "invalid buyin" << be.last_cashout();
}
void PokerMain::srTableSitOk(std::string data) {
	Poker::TableStatus ts;
	ts.ParseFromString(data);
	QSharedPointer<Data::TableStatus> out(new Data::TableStatus);
	out->update(ts);
	emit table_status(out);
	emit sit_ok(out->gameid);
}
void PokerMain::srTableStandUpOk(std::string data) {
	Poker::TableStatus ts;
	ts.ParseFromString(data);
	QSharedPointer<Data::TableStatus> out(new Data::TableStatus);
	out->update(ts);
	emit table_status(out);
}
void PokerMain::srTableSitSeatTaken(std::string data) {
	Poker::TableStatus ts;
	ts.ParseFromString(data);
	QSharedPointer<Data::TableStatus> out(new Data::TableStatus);
	out->update(ts);
	emit table_status(out);
	emit seat_taken(out->gameid);
}
void PokerMain::srTableBuyinLessThanCashout(std::string data) {
	Poker::BuyinError be;
	be.ParseFromString(data);
	qDebug() << "invalid buyin#2" << be.last_cashout();
}
void PokerMain::sePlayerClubStatus(std::string data) {
	Poker::PlayerClubStatus pcs;
	pcs.ParseFromString(data);
	Data::PlayerClubStatus out;
	out.update(pcs);
	emit PlayerClubStatus(out);
}
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
		//qDebug() << sigIndex << slot << (slot+3);
		if (sigIndex < 0) continue;
		const char *signal;
#if (QT_VERSION >= QT_VERSION_CHECK(5, 0, 0))
		QByteArray signal_raw = metaObject()->method(sigIndex).methodSignature();
		signal = signal_raw.data();
#else
		signal = metaObject()->method(sigIndex).signature();
#endif
		qDebug() << "connecting" << signal << "to" << slot;
		if (connect(core,qPrintable(QString("2%1").arg(signal)),listener,qPrintable(QString("1%1").arg(slot)))) {
		} else qWarning("PokerMain::RegisterListener: No matching signal for %s", slot);
	}
}
