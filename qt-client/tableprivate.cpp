#include <QFile>
#include <QDebug>
#include <QStringList>
#include <QPainter>

#include "tableprivate.h"
#include "table/visible_seat.h"
#include "table/card.h"

static QScriptValue js_log(QScriptContext *context, QScriptEngine *engine) {
	qDebug() << "JS:" << context->argument(0).toString();
	return engine->undefinedValue();
}
static QScriptValue NewSeatObject(QScriptContext *, QScriptEngine *engine) {
	TablePrivate *parent = static_cast<TablePrivate*>(engine->globalObject().property("root").toQObject());
	SeatObject *seatobj = new SeatObject(parent);
	return engine->newQObject(seatobj, QScriptEngine::ScriptOwnership);
}
static QScriptValue NewCardObject(QScriptContext*, QScriptEngine *engine) {
	TablePrivate *parent = static_cast<TablePrivate*>(engine->globalObject().property("root").toQObject());
	CardObject *cardobj = new CardObject(parent);
	return engine->newQObject(cardobj,QScriptEngine::ScriptOwnership);
}

TablePrivate::TablePrivate(QObject *parent) :
	QObject(parent) {

	engine.globalObject().setProperty("log",engine.newFunction(js_log,1));

	QScriptValue ctor = engine.newFunction(NewSeatObject);
	QScriptValue metaObject = engine.newQMetaObject(&SeatObject::staticMetaObject, ctor);
	engine.globalObject().setProperty("SeatObject",metaObject);

	engine.globalObject().setProperty("Card",engine.newQMetaObject(&CardObject::staticMetaObject,engine.newFunction(NewCardObject)));
	engine.globalObject().setProperty("root",engine.newQObject(this));
	tableui = 0;
}
TablePrivate::~TablePrivate() {
	delete tableui;
}
void TablePrivate::loadJs(QString code,QString file) {
	engine.evaluate(code,file);
	if (engine.hasUncaughtException()) {
		qDebug() << engine.uncaughtExceptionBacktrace();
		qDebug() << engine.uncaughtExceptionLineNumber();
		qDebug() << "uncaught excepion" << engine.uncaughtException().toString();
		engine.clearExceptions();
	} else {
		qDebug() << "JS loaded";
	}
}
void TablePrivate::loadJsFromResource() {
	QFile input(":/table.js");
	if (!input.open(QIODevice::ReadOnly | QIODevice::Text)) {
		qDebug() << "failed to load js";
	} else {
		QTextStream stream(&input);
		QString code = stream.readAll();
		input.close();
		loadJs(code,"table.js");
	}
}
void TablePrivate::table_status(QSharedPointer<Data::TableStatus> ts) {
	QScriptValue func = engine.globalObject().property("tableStatus");
	if (!func.isFunction()) {
		qDebug() << "tableStatus isnt a function!";
		return;
	}
	QScriptValueList args;
	args.append(engine.newQObject(ts.data()));
	func.call(engine.globalObject(),args);
	if (engine.hasUncaughtException()) {
		qDebug() << engine.uncaughtExceptionBacktrace();
		qDebug() << engine.uncaughtException().toString();
		engine.clearExceptions();
	}
	QScriptValue func2 = engine.globalObject().property("tableEvent");
	if (!func2.isFunction()) {
		qDebug() << "tableEvent isnt a function";
		return;
	}
	QList<QSharedPointer<Data::TableEvent> >::Iterator i;
	for (i=ts->events.begin(); i!=ts->events.end(); ++i) {
		QSharedPointer<Data::TableEvent> e = *i;
		QScriptValue event = engine.newQObject(e.data());
		QScriptValueList args;
		args.append(event);
		func2.call(engine.globalObject(),args);
	}
}
void TablePrivate::setGame(const Data::Game *game) {
	this->game = new GameWrap(game);
	engine.globalObject().setProperty("game",engine.newQObject(this->game));
}
void TablePrivate::setupUi(QWidget *parent, QGridLayout *layout) {
	qDebug() << __func__;
	tableui = new TableUi(parent);
	//layout->setRowStretch(1,1);
	layout->addWidget(tableui,0,0);
	//layout->addWidget(new QWidget(parent),1,0);
	//qDebug() << "rows" << layout->rowCount();
}

QScriptValue TablePrivate::eval(QString code) {
	return engine.evaluate(code,"chat");
}
void TablePrivate::editJs(QString newcode) {
	eval(newcode);
	if (engine.hasUncaughtException()) {
		qDebug() << engine.uncaughtExceptionBacktrace();
		qDebug() << engine.uncaughtException().toString();
		engine.clearExceptions();
	}
}
