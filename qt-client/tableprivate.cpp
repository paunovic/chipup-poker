#include <QFile>
#include <QDebug>

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
			qDebug() << "uncaught excepion" << engine.uncaughtException().toString();
			engine.clearExceptions();
		}
	}
}
