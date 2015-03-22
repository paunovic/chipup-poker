#ifndef UPDATEHASHER_H
#define UPDATEHASHER_H

#include <QObject>
#include <QDir>

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
    explicit UpdateHasher(QDir approot);

	QList<UpdateFileInfo> files;
signals:
	void doneHashing();
public slots:
	void startHashing(QString scriptspath);
private:
	void recurseDirectory(QDir root, QDir path);
    QDir approot;
};
}

#endif // UPDATEHASHER_H
