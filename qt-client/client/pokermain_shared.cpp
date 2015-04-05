#include <QPixmap>

#include "pokermain.h"
#include "minidumpuploader.h"

bool PokerMain::loadCachedAvatar(QString id, QPixmap *output) {
	bool result = false;
	if (avatarCache.exists(id)) {
		result = output->load(avatarCache.absoluteFilePath(id));
		if (!result) avatarCache.remove(id);
	}
	return result;
}
void PokerMain::saveAvatar(QString id, QByteArray rawdata) {
	QFile fh(avatarCache.absoluteFilePath(id));
	if (fh.open(QFile::WriteOnly | QFile::Truncate)) {
		fh.write(rawdata);
		fh.close();
	}
}
void PokerMain::setDataDir(QDir path) {
//#if (QT_VERSION >= QT_VERSION_CHECK(5, 0, 0))
//	datadir = QStandardPaths::writableLocation(QStandardPaths::DataLocation);
//#else
//	datadir(QDesktopServices::storageLocation(QDesktopServices::DataLocation));
//#endif
	datadir = path;
	if (!datadir.exists("avatars")) datadir.mkdir("avatars");
	avatarCache = path.absoluteFilePath("avatars");
	uploader->setMinidumpPath(path.absoluteFilePath("minidumps"));
}
void PokerMain::GetPlayers(QList<QByteArray> &toFetch) {
	Poker::GetUserParams gup;
	foreach (QByteArray id, toFetch) {
		gup.add_user_mongo_ids(std::string(id.data(),id.length()));
	}
	core->sendMessage(Poker::scGetPlayers,&gup);
}
