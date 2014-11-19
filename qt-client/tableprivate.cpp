#include <QFile>
#include <QDebug>
#include <QStringList>

#include "tableprivate.h"

static QScriptValue js_log(QScriptContext *context, QScriptEngine *engine) {
	qDebug() << "JS:" << context->argument(0).toString();
	return engine->undefinedValue();
 }

TablePrivate::TablePrivate(QObject *parent) :
	QObject(parent) {

	engine.globalObject().setProperty("log",engine.newFunction(js_log,1));
	QFile input(":/table.js");
	if (!input.open(QIODevice::ReadOnly | QIODevice::Text)) {
		qDebug() << "failed to load js";
	} else {
		QTextStream stream(&input);
		QString code = stream.readAll();
		input.close();
		engine.evaluate(code,"table.js");
		if (engine.hasUncaughtException()) {
			qDebug() << engine.uncaughtExceptionBacktrace();
			qDebug() << engine.uncaughtExceptionLineNumber();
			qDebug() << "uncaught excepion" << engine.uncaughtException().toString();
			engine.clearExceptions();
		}
	}
}
void TablePrivate::table_status(QSharedPointer<Data::TableStatus> ts) {
	QScriptValue func = engine.globalObject().property("tableStatus");
	if (!func.isFunction()) {
		qDebug() << "tableStatus isnt a function!";
		return;
	}
	QScriptValueList  args;
	args.append(engine.newQObject(ts.data()));
	func.call(engine.globalObject(),args);
	if (engine.hasUncaughtException()) {
		qDebug() << engine.uncaughtExceptionBacktrace();
		qDebug() << engine.uncaughtException().toString();
		engine.clearExceptions();
	}
}
