#include <QDebug>
#include <QUrl>
#include <QNetworkReply>
#include <QHttpMultiPart>

#include "minidumpuploader.h"
#include "pokermain.h"

MiniDumpUploader::MiniDumpUploader(QObject *parent) :
	QObject(parent)
{
	reply = 0;
}

void MiniDumpUploader::setMinidumpPath(QString path) {
	minidumppath = path;
}
void MiniDumpUploader::checkForDumps() {
	if (reply) return;
	QFileInfoList dumps = minidumppath.entryInfoList(QDir::NoDotAndDotDot | QDir::AllEntries);
	if (dumps.size()) {
		currentFile = dumps[0];
		qDebug() << currentFile.size() << currentFile.fileName();
		QHttpMultiPart *multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);
		QHttpPart minidump;
		minidump.setHeader(QNetworkRequest::ContentTypeHeader,QVariant("application/octed-stream"));
		minidump.setHeader(QNetworkRequest::ContentDispositionHeader,QVariant(QString("form-data; name=\"minidump\"; filename=\"%1\"").arg(currentFile.fileName())));
		input = new QFile(currentFile.absoluteFilePath());
		if (!input->open(QFile::ReadOnly)) {
			qDebug() << "unable to open a crash dump";
			return;
		}
		minidump.setBodyDevice(input);
		input->setParent(multiPart);
		multiPart->append(minidump);

		QUrl url("https://chipuppoker.com/minidumpUpload");
		QNetworkRequest req(url);
		reply = core->manager()->post(req,multiPart);
		multiPart->setParent(reply);
		connect(reply,SIGNAL(finished()),this,SLOT(finished()));
	}
}
void MiniDumpUploader::finished() {
	qDebug() << reply->readAll();
	reply->deleteLater();
	reply = 0;
	input->close();
	input = 0;
	qDebug() << minidumppath << currentFile.fileName();
	if (minidumppath.remove(currentFile.fileName())) {
		checkForDumps();
	} else {
		qDebug() << "unable to delete a dump";
	}
}
