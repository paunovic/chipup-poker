#include <QThread>
#include <QDebug>
#include <QDir>
#include <QCryptographicHash>
#include <QNetworkAccessManager>
#include <QNetworkRequest>

#include "pokermain.h"
#include "updatehasher.h"

namespace Core {

UpdateHasher::UpdateHasher(QDir approot): approot(approot)
{
}

void UpdateHasher::startHashing() {
	qDebug() << QThread::currentThread();
    files.clear();
    recurseDirectory(approot,approot);
	qDebug() << "done hashing in thread";
	emit doneHashing();
}
void UpdateHasher::startDownload() {
}

void UpdateHasher::recurseDirectory(QDir root, QDir path) {
	//qDebug() << "checking" << path;
	QFileInfoList files = path.entryInfoList(QDir::NoDotAndDotDot | QDir::AllEntries);
	QCryptographicHash hasher(QCryptographicHash::Sha256);
	UpdateFileInfo entry;
	foreach (QFileInfo item, files) {
		if (item.isDir()) {
			//qDebug() << "want to recurse" << item.absoluteFilePath();
			recurseDirectory(root,QDir(item.absoluteFilePath()));
		} else {
			hasher.reset();
			QFile fh(item.absoluteFilePath());
			if (fh.open(QFile::ReadOnly)) {
				hasher.addData(&fh);
				fh.close();
                entry.path = root.relativeFilePath(item.absoluteFilePath()).replace("\\","/");
				entry.hash = hasher.result();
                qDebug() << entry.path << entry.hash.toHex();
				this->files.append(entry);
			}
		}
	}
}

}
