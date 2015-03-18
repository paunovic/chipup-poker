#ifndef UPDATEHASHER_H
#define UPDATEHASHER_H

#include <QObject>

class QDir;
class QNetworkReply;

namespace Core {

class UpdateFileInfo {
public:
	QString path,url;
	QByteArray hash;
	QNetworkReply *reply;
	quint32 size;
};

class UpdateHasher : public QObject
{
	Q_OBJECT
public:
	explicit UpdateHasher(QObject *parent = 0);

	QList<UpdateFileInfo> files;
signals:
	void doneHashing();
public slots:
	void startHashing();
	void startDownload();
private:
	void recurseDirectory(QDir root, QDir path);
};
}

#endif // UPDATEHASHER_H
