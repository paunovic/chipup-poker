#ifndef UPDATEHASHER_H
#define UPDATEHASHER_H

#include <QObject>

class QDir;

namespace Core {

class UpdateFileInfo {
public:
	QString path;
	QByteArray hash;
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
private:
	void recurseDirectory(QDir root, QDir path);
};
}

#endif // UPDATEHASHER_H
