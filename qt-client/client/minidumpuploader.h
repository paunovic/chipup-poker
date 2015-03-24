#ifndef MINIDUMPUPLOADER_H
#define MINIDUMPUPLOADER_H

#include <QObject>
#include <QDir>

class MiniDumpUploader : public QObject
{
	Q_OBJECT
public:
	explicit MiniDumpUploader(QObject *parent = 0);
	void setMinidumpPath(QString path);
	void checkForDumps();
signals:

public slots:
private:
	QDir minidumppath;
	bool uploading;
};

#endif // MINIDUMPUPLOADER_H
