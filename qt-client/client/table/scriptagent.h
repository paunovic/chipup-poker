#ifndef SCRIPTAGENT_H
#define SCRIPTAGENT_H

#include <QScriptEngineAgent>
#include <QStringList>

class ScriptAgent : public QScriptEngineAgent
{
public:
	explicit ScriptAgent(QScriptEngine  *parent = 0);
	virtual void positionChange( qint64 scriptId, int lineNumber, int columnNumber );
	virtual void functionEntry(qint64 scriptId);
	virtual void functionExit(qint64 scriptid,const QScriptValue &returnValue);
	void setCode(QString code) { this->code = code.split("\n"); } // TODO, use scriptLoad
signals:

public slots:
private:
	QStringList code;
};

#endif // SCRIPTAGENT_H
