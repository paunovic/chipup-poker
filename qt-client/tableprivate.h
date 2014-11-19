#ifndef TABLEPRIVATE_H
#define TABLEPRIVATE_H

#include "config.h"

#include <QObject>
#include <QScriptEngine>

#include "tablestatus.h"

class TablePrivate : public QObject
{
	Q_OBJECT
public:
	explicit TablePrivate(QObject *parent = 0);
	void table_status(QSharedPointer<Data::TableStatus> ts);

signals:

public slots:
private:
	QScriptEngine engine;
};

#endif // TABLEPRIVATE_H
