#include <QNetworkReply>
#include <QDebug>
#include <QFile>
#include <QDir>

#include "filesaver.h"
#include "pokermain.h"

FileSaver::FileSaver(QNetworkReply *reply, Core::UpdateFileInfo row)
{
	this->reply = reply;
	this->row = row;
	connect(reply,SIGNAL(readyRead()),this,SLOT(readyRead()));
	QByteArray data = reply->readAll();
    //qDebug() << row.path << "read in x bytes:" << data.size() << "/" << row.size;
	QFile fh(row.path);
	QDir test(row.path);
    if (!test.exists()) {
        QDir parent(test.absoluteFilePath(".."));
        if (!parent.exists()) {
            qDebug() << "parent doesnt exist" << parent;
            parent.mkpath(".");
        }
    }
	if (fh.open(QFile::WriteOnly)) {
		fh.write(data);
		fh.close();
        core->fileSaved(row);
	} else {
		qDebug() << "failed to open file";
	}
}
void FileSaver::readyRead() {
	qDebug() << row.path << "readyRead";
}
