#include "updatehasher.h"
#include <QThread>
#include <QDebug>
#include <QDir>
#include <QCryptographicHash>

namespace Core {

UpdateHasher::UpdateHasher(QObject *parent) :
	QObject(parent)
{
}

void UpdateHasher::startHashing() {
	QDir root("c:/mac/");
	qDebug() << QThread::currentThread();
	recurseDirectory(root,root);
	qDebug() << "done hashing in thread";
	emit doneHashing();
}
void UpdateHasher::recurseDirectory(QDir root, QDir path) {
	qDebug() << "checking" << path;
	QFileInfoList files = path.entryInfoList(QDir::NoDotAndDotDot | QDir::AllEntries);
	QCryptographicHash hasher(QCryptographicHash::Sha256);
	UpdateFileInfo entry;
	foreach (QFileInfo item, files) {
		if (item.isDir()) {
			qDebug() << "want to recurse" << item.absoluteFilePath();
			recurseDirectory(root,QDir(item.absoluteFilePath()));
		} else {
			hasher.reset();
			QFile fh(item.absoluteFilePath());
			if (fh.open(QFile::ReadOnly)) {
				hasher.addData(&fh);
				fh.close();
				entry.path = root.relativeFilePath(item.absoluteFilePath());
				entry.hash = hasher.result();
				qDebug() << item.baseName() << entry.hash.toHex();
				this->files.append(entry);
			}
		}
	}
}

}
