#include <QDebug>
#include <QScriptEngine>

#include "scriptagent.h"

ScriptAgent::ScriptAgent(QScriptEngine *parent) :
	QScriptEngineAgent(parent)
{
}
void ScriptAgent::positionChange(qint64 scriptId, int lineNumber, int) {
	//qDebug() << __func__ << scriptId << lineNumber << code[lineNumber-1].trimmed();
}
void ScriptAgent::functionEntry(qint64 scriptId) {
	const QScriptContext *context = engine()->currentContext();
	//qDebug() << __func__ << scriptId;
}
void ScriptAgent::functionExit(qint64 scriptid, const QScriptValue &returnValue) {
	//qDebug() << __func__ << scriptid << returnValue.toString();
}
