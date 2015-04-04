#ifndef MINIDUMPUPLOADER_H
#define MINIDUMPUPLOADER_H

#include <QObject>
#include <QDir>
#include <QNetworkReply>

class MiniDumpUploader : public QObject
{
	Q_OBJECT
public:
	explicit MiniDumpUploader(QObject *parent = 0);
	void setMinidumpPath(QString path);
	void checkForDumps();
signals:

public slots:
	void finished();
private:
	QDir minidumppath;
	QNetworkReply *reply;
	QFileInfo currentFile;
	QFile *input;
};

#endif // MINIDUMPUPLOADER_H
