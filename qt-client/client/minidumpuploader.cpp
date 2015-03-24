#include <QDebug>

#include "minidumpuploader.h"

MiniDumpUploader::MiniDumpUploader(QObject *parent) :
	QObject(parent)
{
	uploading = false;
}

void MiniDumpUploader::setMinidumpPath(QString path) {
	minidumppath = path;
}
void MiniDumpUploader::checkForDumps() {
	if (uploading) return;
	QFileInfoList dumps = minidumppath.entryInfoList();
	if (dumps.size()) {
		QFileInfo first = dumps[0];
		uploading = true;
		qDebug() << first.size() << first.fileName();
	}
}
