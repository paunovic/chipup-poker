#include <QDebug>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QMetaMethod>
#include <QApplication>
#include <QWidget>
#include <QMainWindow>
#include <QThread>
#if (QT_VERSION >= QT_VERSION_CHECK(5, 0, 0))
#include <QStandardPaths>
#else
#include <QDesktopServices>
#endif
#include <QProcess>
#include <QResource>

#include "pokermain.h"
#include "cpp/message.pb.h"
#include "club.h"
#include "tablestatus.h"
#include "data/user.h"
#include "data/playerclubstatus.h"
#include "sound_effects.h"
#include "table.h"
#include "updatehasher.h"
#include "filesaver.h"
#include "minidumpuploader.h"

#define DEVSERVER

using namespace Poker;

PokerMain *core;

static void flagOffline(QMainWindow *window);

PokerMain::PokerMain(QObject *parent) :
    QObject(parent), settings(new QSettings("ChipUPPoker","ChipUPPoker"))
{
#if defined(Q_OS_MAC)
    qDebug() << "appdirpath" << QApplication::applicationDirPath();
    QDir binaryDir(QApplication::applicationDirPath());
    approot = binaryDir.absoluteFilePath("../../");
#endif
	setObjectName("core");
	delayQuit = false;
	allowUpdates = true;
	workerThread = new QThread();
	workerThread->start();
	uploader = new MiniDumpUploader();
    if (approot.exists()) {
        hasher = new Core::UpdateHasher(approot);
        hasher->moveToThread(workerThread);
        connect(this,SIGNAL(startHashing(QString)),hasher,SLOT(startHashing(QString)));
        connect(hasher,SIGNAL(doneHashing()),this,SLOT(doneHashing()));
    }
#ifdef DEVSERVER
	serverAddress = "dev-server.chipuppoker.com";
#else
	serverAddress = "server.chipuppoker.com";
#endif
	reconnectState = notSignedIn;
	manager_ = new QNetworkAccessManager(this);
	effects_ = new SoundEffects(this);
	self_ = new Data::User(this);
	connect(manager(), SIGNAL(finished(QNetworkReply*)),this, SLOT(replyFinished(QNetworkReply*)));

    connect(&socket,SIGNAL(stateChanged(QAbstractSocket::SocketState)),this,SLOT(socket_state_change(QAbstractSocket::SocketState)));
    connect(&socket,SIGNAL(sslErrors(QList<QSslError>)),this,SLOT(socket_sslErrors(QList<QSslError>)));
    connect(&socket,SIGNAL(encrypted()),this,SLOT(socket_ready()));
	connect(&socket,SIGNAL(readyRead()),this,SLOT(socket_readyRead()));
	connect(&pinger,SIGNAL(timeout()),this,SLOT(send_ping()));
	connect(manager_,SIGNAL(sslErrors(QNetworkReply*,QList<QSslError>)),this,SLOT(httpsErrors(QNetworkReply*,QList<QSslError>)));
	uptime.start();
}
QNetworkAccessManager *PokerMain::manager() {
	return manager_;
}
void PokerMain::httpsErrors(QNetworkReply *reply, const QList<QSslError> &errors) {
	qDebug() << reply << errors;
	if (errors.length() > 0) {
		QSslError err = errors.at(0);
		qDebug() << "cert" << err.certificate();
	}
}

void PokerMain::replyFinished(QNetworkReply *reply) {
	qDebug() << reply;
	foreach (Core::UpdateFileInfo item, files_in) {
		if (item.reply != reply) continue;
        //qDebug() << "found it" << item.path;
		FileSaver *fs = new FileSaver(reply,item);
		return;
	}
	reply->deleteLater();
}
void PokerMain::try_connect() {
	if (socket.state() == QAbstractSocket::UnconnectedState) {
		socket.connectToHostEncrypted(serverAddress,12346);
	}
}
void PokerMain::socket_state_change(QAbstractSocket::SocketState state) {
	qDebug() << state;
	switch (state) {
	case QAbstractSocket::HostLookupState:
		break;
	case QAbstractSocket::ConnectingState:
		break;
	case QAbstractSocket::ConnectedState:
		//qDebug() << "socket connected";
		break;
	case QAbstractSocket::ClosingState:
		qDebug() << "socket closing";
		break;
	case QAbstractSocket::UnconnectedState:
		QResource::unregisterResource(datadir.absoluteFilePath("scripts.rcc"));
		// set a timer to reconnect
		qDebug() << "unconnected";
		emit protocol_ready(false);
		foreach (QWidget *widget, QApplication::topLevelWidgets()) {
			qDebug() << widget << widget->metaObject()->className();
			QMainWindow *mainWindow = qobject_cast<QMainWindow*>(widget);
			if (mainWindow) {
				flagOffline(mainWindow);
			}
		}
		try_connect();
		break;
	}
}
static void flagOffline(QMainWindow *mainWindow) {
}
void PokerMain::socket_sslErrors(const QList<QSslError> &errors) {
	qDebug() << "incoming err" << errors;
#ifndef DEVSERVER
	QList<QSslCertificate> cert = QSslCertificate::fromPath(":/resources/OfficialServerCertificate.pem");
#else
	QList<QSslCertificate> cert = QSslCertificate::fromPath(":/resources/DevServerCertificate.pem");
#endif
	//qDebug() << "certs" << cert;
	QSslError errorSelfSigned(QSslError::SelfSignedCertificate, cert.at(0));
	QList<QSslError> expectedSslErrors;
#ifdef DEVSERVER
	QSslError wrongHostError(QSslError::HostNameMismatch, cert.at(0));
	expectedSslErrors.append(wrongHostError);
#endif
	expectedSslErrors.append(errorSelfSigned);
	socket.ignoreSslErrors(expectedSslErrors);
	qDebug() << "expected error" << expectedSslErrors;
}
void PokerMain::socket_ready() {
	first_ping = true;
    pinger.setSingleShot(false);
    pinger.setInterval(30000);
	pinger.start();
	if (allowUpdates) {
		qDebug() << "starting hashing" << QThread::currentThread();
		emit startHashing(datadir.absoluteFilePath("scripts.rcc"));
	} else doneHashing();
}
void PokerMain::doneHashing() {
	Poker::HelloParams hp;
#ifdef Q_OS_WIN
	hp.set_appcode(Poker::HelloParams::QtWindows32);
#elif defined(Q_OS_LINUX)
	hp.set_appcode(Poker::HelloParams::QtLinux32);
#elif defined(Q_OS_MAC)
	hp.set_appcode(Poker::HelloParams::QtMac);
#endif
	hp.set_debug(false);
	foreach (Core::UpdateFileInfo item, hasher->files) {
		Poker::UpdateFileInfo *ufi = hp.add_files();
		ufi->set_path(qPrintable(item.path));
		ufi->set_hash(item.hash.data(),item.hash.length());
	}

	//qDebug() << "sending hello";
	sendMessage(Poker::scHello,&hp);
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
void PokerMain::doUpdate(const HelloReply hr) {
	Core::UpdateFileInfo ufi;
#if (QT_VERSION >= QT_VERSION_CHECK(5, 0, 0))
	//QDir tempdir(QStandardPaths::writableLocation(QStandardPaths::TempLocation));
#else
	//QDir tempdir(QDesktopServices::storageLocation(QDesktopServices::TempLocation));
#endif
	//if (!tempdir.exists("chipuppoker")) tempdir.mkpath("chipuppoker");
	//tempdir.cd("chipuppoker");
	//if (!tempdir.exists("update")) tempdir.mkpath("update");
	//tempdir.cd("update");
    pending_updates = 0;
	//qDebug() << "downloading to" << tempdir;
	for (int x=0; x<hr.update_files_size(); x++) {
		qDebug() << x << hr.update_files(x).file_type();
		QString temp = hr.update_files(x).path().c_str();
		temp = temp.replace(':',".");
		QString file;
		if (temp == "assets/scripts.rcc") {
			file = datadir.absoluteFilePath("scripts.rcc");
		} else {
			file = approot.absoluteFilePath(temp);
		}
		qDebug() << file << hr.update_files(x).url().c_str();
		ufi.url = hr.update_files(x).url().c_str();
		ufi.path = file;
		ufi.size = hr.update_files(x).file_size();
		if (hr.update_files(x).file_type() == Poker::UpdateFileInfo::ufFull) {
			qDebug() << "downloading";
			ufi.reply = core->manager()->get(QNetworkRequest(ufi.url));
            pending_updates++;
		} else if (hr.update_files(x).file_type() == Poker::UpdateFileInfo::ufRemove) {
			qDebug() << "deleting";
			approot.remove(temp);
		} else {
			qDebug() << "TODO, patch";
		}
		files_in.append(ufi);
	}
	// TODO, restart when done
}
void PokerMain::fileSaved(Core::UpdateFileInfo)  {
	pending_updates--;
	if (pending_updates == 0) {
		QString self = QApplication::applicationFilePath();
		qDebug() << "update ready to restart" << self;
		QProcess::startDetached(self);
		QApplication::quit();
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
		if (allowUpdates && hr.update_files_size()) {
			doUpdate(hr);
		} else {
			uploader->checkForDumps();
			emit protocol_ready(true);
			if (reconnectState == SignedIn) {
				doLogin(username,password);
			}
		}
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
	case Poker::srLeaveClubReply: // 6
		srLeaveClubReply(data);
		break;
	case Poker::srLogout: // 8
		QResource::unregisterResource(datadir.absoluteFilePath("scripts.rcc"));
		delayQuit = false;
		reconnectState = notSignedIn;
		break;
	case Poker::srKickPlayerReply: // 11
		qDebug() << "srKickPlayerReply";
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
		//qDebug() << "ping:" << ping << "server clock:" << server_clock << "offset:" << clock_offset << "diff:" << diff << totalError;
		break; }
	case Poker::srReinstatePlayerOk: // 32
		qDebug() << "srReinstatePlayerOk";
		break;
	case Poker::srTableAddonOk: // 33
		seTableStatus(data,true);
		break;
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
		foreach (QWidget *widget, QApplication::topLevelWidgets()) {
			qDebug() << widget << widget->metaObject()->className();
			Table *tbl = qobject_cast<Table*>(widget);
			if (tbl) tbl->close();
		}
		QResource::unregisterResource(datadir.absoluteFilePath("scripts.rcc"));
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
	case Poker::seChat: // 50
		seChat(data);
		break;
	case Poker::seClubChange: // 53
		qDebug() << "seClubChange";
		seClubChange(data);
		break;
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
		seTableStatus(data,false);
		break;
	case Poker::sePlayerClubStatus: // 63
		sePlayerClubStatus(data);
		break;
	case Poker::seReservedSeatFree: // 64
		seReservedSeatFree(data);
		break;
	case Poker::seReservedSeatTimeout: // 65
		seReservedSeatTimeout(data);
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
void PokerMain::seTableStatus(std::string data, bool addonok) {
	Poker::TableStatus ts;
	ts.ParseFromString(data);
	QSharedPointer<Data::TableStatus> out(new Data::TableStatus);
	out->update(ts);
	emit table_status(out);
	if (addonok) emit tableAddonOk(out->gameid);
#if 0
	QByteArray rawts(data.data(),data.length());
	static int packetid = 0;
	QFile fh(QString("recording-%1.proto").arg(packetid++));
	fh.open(QFile::WriteOnly);
	fh.write(rawts);
	fh.close();
#endif
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
void PokerMain::seClubChange(std::string data) {
	Poker::Club input;
	input.ParseFromString(data);
	int seq = input.seq();
	Data::Club *club = 0;
	for (int i=0; i<clubs.size(); i++) {
		club = clubs.at(i);
		if (club->seq == seq) break;
	}
	Q_ASSERT(club);
	club->update(input);
	emit club_changed(club);
}
void PokerMain::seReservedSeatFree(std::string data) {
	Poker::ReservedSeatFree rsf;
	rsf.ParseFromString(data);
	quint32 seat_index = rsf.seat_index();
	QSharedPointer<Data::TableStatus> out(new Data::TableStatus);
	out->update(rsf.ts());
	emit table_status(out);
	emit reserved_seat_free(out->gameid,seat_index);
}
void PokerMain::seReservedSeatTimeout(std::string data) {
	Poker::TableStatus ts;
	ts.ParseFromString(data);
	QSharedPointer<Data::TableStatus> out(new Data::TableStatus);
	out->update(ts);
	emit sit_timeout(out->gameid);
	emit table_status(out);
}
void PokerMain::srLoginReply(std::string data) {
	Poker::LoginReply lr;
	int i;
	qDebug() << "srLoginReply";
	lr.ParseFromString(data);
	if (lr.login_status() == LoginReply::lrSuccess) {
		QResource::registerResource(datadir.absoluteFilePath("scripts.rcc"));
		qDebug() << "sucess!";
		reconnectState = SignedIn;
		// TODO, convert and use tournament_infos,registered_tournaments,clubs,self,games,player_club_statuses
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
			qDebug() << "found game" << g_out->gameid.toHex();
		}
		for (i=0; i<lr.users_size(); i++) {
			Poker::User u = lr.users(i);
			Data::User *u_out = new Data::User;
			u_out->update(u);
			users.append(u_out);
		}
		Poker::User self = lr.self();
		self_->update(self);
		for (i=0; i<lr.reconnect_tables_size(); i++) {
			Poker::TableStatus ts = lr.reconnect_tables(i);
			QSharedPointer<Data::TableStatus> out(new Data::TableStatus);
			out->update(ts);
			bool found = false;
			foreach (QWidget *widget, QApplication::topLevelWidgets()) {
				qDebug() << widget << widget->metaObject()->className();
				Table *tbl = qobject_cast<Table*>(widget);
				if (tbl) {
					if (out->gameid == tbl->getGameId()) {
						found = true;
						break;
					}
				}
			}
			qDebug() << "tbl found?" << found;
			if (!found) {
				qDebug() << "lookign for game" << out->gameid.toHex();
				const Data::Game *game = getGame(out->gameid);
				Q_ASSERT(game);
				Table *t = new Table();
				const Data::Club *club = clubs.getClub(game->clubid);
				t->setGame(game,club);
				t->show();
			}
			emit table_status(out);
		}
		emit login_sucess();
		emit clubs_changed();
		emit games_changed();
	} else {
		qDebug() << "failure";
		emit login_failure();
	}
}
const Data::Game *PokerMain::getGame(QByteArray gameid) const {
	foreach (const Data::Game *g, games) {
		qDebug() << "searching" << g->gameid.toHex();
		if (g->gameid == gameid) return g;
	}
	return 0;
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
void PokerMain::seChat(std::string data) {
	Poker::ChatEvent ce;
	ce.ParseFromString(data);
	Data::Chat out;
	out.update(ce);
	emit chat_event(out);
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
        //qDebug() << "connecting" << signal << "to" << slot;
		if (connect(core,qPrintable(QString("2%1").arg(signal)),listener,qPrintable(QString("1%1").arg(slot)))) {
		} else qWarning("PokerMain::RegisterListener: No matching signal for %s", slot);
	}
}
int parseValue(QString input) {
	QString x = input.section('.', 0, 0) + input.section('.', 1, 1).leftJustified(2, '0');
	return x.toInt();
}
void PokerMain::doLogin(QString username, QString password) {
	Poker::LoginParams lp;
	lp.set_username(qPrintable(username));
	lp.set_password(qPrintable(password));
	this->username = username;
	this->password = password;
	core->sendMessage(Poker::scLogin,&lp);
}
void PokerMain::srLeaveClubReply(std::string data) {
	Poker::ClubCommandReply ccr;
	ccr.ParseFromString(data);
	std::string clubid = ccr.club()._id();
	const Data::Club *club = clubs.getClub(QByteArray(clubid.data(),clubid.length()));
	if (club) {
		clubs.remove(club);
		emit clubLeft(club);
	}
}
