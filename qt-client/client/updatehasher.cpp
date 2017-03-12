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

void UpdateHasher::startHashing(QString scriptspath) {
  qDebug() << QThread::currentThread() << "scriptpath:" << scriptspath;
  files.clear();
#if defined(Q_OS_MAC)
  recurseDirectory(approot,approot);
#endif
  UpdateFileInfo scripts;
  scripts.path = "assets/scripts.rcc";
  QFile fh(scriptspath);
  if (fh.exists()) {
    if (fh.open(QFile::ReadOnly)) {
      QCryptographicHash hasher(QCryptographicHash::Sha256);
      hasher.addData(&fh);
      fh.close();
      scripts.hash = hasher.result();
    } else qDebug() << "failed to open scripts.rcc";
  } else qDebug() << "scripts.rcc not found, hash left blank";
  this->files.append(scripts);
  qDebug() << "done hashing in thread";
  emit doneHashing();
}

void UpdateHasher::recurseDirectory(QDir root, QDir path) {
	//qDebug() << "checking" << path;
	QFileInfoList files = path.entryInfoList(QDir::NoDotAndDotDot | QDir::AllEntries);
	QCryptographicHash hasher(QCryptographicHash::Sha256);
	UpdateFileInfo entry;
	foreach (QFileInfo item, files) {
        if (item.isSymLink()) {
             //qDebug() << "skipping symlink" << item.absoluteFilePath();
        } else if (item.isDir()) {
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
                //qDebug() << entry.path << entry.hash.toHex();
				this->files.append(entry);
            } else qDebug() << "failed to open" << item.absoluteFilePath();
		}
	}
}

}
