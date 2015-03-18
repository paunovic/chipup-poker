#ifndef FILESAVER_H
#define FILESAVER_H

#include <QObject>
#include <QNetworkAccessManager>

#include "updatehasher.h"

class FileSaver : public QObject
{
	Q_OBJECT
public:
	explicit FileSaver(QNetworkReply *reply,Core::UpdateFileInfo row);

signals:

public slots:
	void readyRead();
private:
	QNetworkReply *reply;
	Core::UpdateFileInfo row;
};

#endif // FILESAVER_H
