#ifndef TABLEPRIVATE_H
#define TABLEPRIVATE_H

#include <QObject>
#include <QScriptEngine>

class TablePrivate : public QObject
{
	Q_OBJECT
public:
	explicit TablePrivate(QObject *parent = 0);

signals:

public slots:
private:
	QScriptEngine engine;
};

#endif // TABLEPRIVATE_H
