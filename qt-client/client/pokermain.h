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
#include <QDir>

#ifdef QT_NO_SSL
#error SSL disabled in QT!
#endif

#include "cpp/message.pb.h"
#include "club.h"
#include "game.h"
#include "tablestatus.h"
#include "data/user.h"
#include "data/chat.h"
#include "updatehasher.h"

class QApplication;
class QNetworkAccessManager;
class QNetworkReply;
class MiniDumpUploader;
class SoundEffects;

namespace Data {
class PlayerClubStatus;
}

class PokerMain : public QObject
{
    Q_OBJECT
public:
	explicit PokerMain(QObject *parent = 0);
	QList<Data::Club*> public_clubs();
	QList<Data::Club*> private_clubs();
	Data::User *findUser(QByteArray userid);
	const Data::Game *getGame(QByteArray gameid) const;
	QNetworkAccessManager *manager();
	void RegisterListener(QObject *listener);
	void doLogin(QString username, QString password);
	void fileSaved(Core::UpdateFileInfo row);
	void setDataDir(QDir datadir);
	bool loadCachedAvatar(QString id, QPixmap *output);
	void saveAvatar(QString id, QByteArray rawdata);

	QSettings& config() { return *settings; }
	QAbstractSocket::SocketState socketState() { return socket.state(); }
	qint64 getUptime() { return uptime.elapsed(); }
	qint64 getServerTime() { return clock_offset + uptime.elapsed(); }
	Data::User *self() { Q_ASSERT(self_); return self_; }
	void testDisconnect() { socket.disconnectFromHost(); }
	SoundEffects *effects() { return effects_; }
	void setAllowUpdates(bool in) { allowUpdates = in; }

	Data::ClubList clubs;
	Data::GameListModel game_model;
	QList<Data::Game*> games;
	Poker::ValidCharsRegex validCharacters;
	bool delayQuit;
	QList<Data::User*> users;
	int max_play_time;
	QString serverAddress;
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
	void seat_taken(QByteArray gameid);
	void PlayerClubStatus(Data::PlayerClubStatus &pcs);
	void club_changed(const Data::Club *);
	void reserved_seat_free(QByteArray gameid, quint32 seat_index);
	void startHashing(QString scriptspath);
	void sit_timeout(QByteArray gameid);
	void chat_event(Data::Chat packet);
public slots:
    void try_connect();
    void socket_state_change(QAbstractSocket::SocketState state);
    void socket_sslErrors ( const QList<QSslError> & errors );
    void socket_ready();
	void sendMessage(Poker::ServerCodes code,google::protobuf::Message *message=0);
    void socket_readyRead();
    void parsePacket(Poker::ServerCodes code,std::string data);
	void replyFinished(QNetworkReply *reply);
	void httpsErrors(QNetworkReply *reply, const QList<QSslError> &errors);
private slots:
	void send_ping();
	void doneHashing();
private:
	void srLoginReply(std::string data);
	void seGameChange(std::string data);
	void seGameCreate(std::string data);
	void seGameDelete(std::string data);
	void seTableStatus(std::string data);
	void srInvalidTableBuyin(std::string data);
	void srTableSitOk(std::string data);
	void srTableStandUpOk(std::string data);
	void srTableSitSeatTaken(std::string data);
	void srTableBuyinLessThanCashout(std::string data);
	void sePlayerClubStatus(std::string data);
	void seClubChange(std::string data);
	void seReservedSeatFree(std::string data);
	void seReservedSeatTimeout(std::string data);
	void seChat(std::string data);
	void doUpdate(const Poker::HelloReply hr);

	enum ReconnectState { notSignedIn, SignedIn };

    QSslSocket socket;
    QByteArray buffer;
    QTimer pinger;
    QElapsedTimer uptime;
    QSettings *settings;
	QNetworkAccessManager *manager_;
	Data::User *self_;
	quint64 clock_offset;
	bool first_ping, allowUpdates;
	int totalError;
	SoundEffects *effects_;
	QString username,password;
	enum ReconnectState reconnectState;
	QThread *workerThread;
	Core::UpdateHasher *hasher;
	QDir approot,datadir,avatarCache;
	QList<Core::UpdateFileInfo> files_in;
	unsigned int pending_updates;
	MiniDumpUploader *uploader;
};
int parseValue(QString input);

extern PokerMain *core;

#endif // POKERMAIN_H
