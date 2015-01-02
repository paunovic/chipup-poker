#include <QFile>
#include <QDebug>
#include <QStringList>
#include <QPainter>

#include "tableprivate.h"
#include "table/visible_seat.h"
#include "table/card.h"
#include "table/chip.h"
#include "table/animation.h"
#include "table/animatecore.h"
#include "table/dealerbutton.h"
#include "sound_effects.h"
#include "pokermain.h"

static QScriptValue js_log(QScriptContext *context, QScriptEngine *engine) {
	qDebug() << "JS:" << context->argument(0).toString();
	return engine->undefinedValue();
}
static QScriptValue renderPosition(QScriptContext *context, QScriptEngine *engine) {
	SeatObject *seatobj = static_cast<SeatObject*>(context->thisObject().toQObject());
	QPoint pos = seatobj->getSeatUi()->getPosition();
	QScriptValue ret = engine->newObject();
	qDebug() << pos;
	Q_ASSERT(pos.y() > 0);
	ret.setProperty("x",pos.x());
	ret.setProperty("y",pos.y());
	return ret;
}

static QScriptValue NewSeatObject(QScriptContext *, QScriptEngine *engine) {
	TablePrivate *parent = static_cast<TablePrivate*>(engine->globalObject().property("root").toQObject());
	SeatObject *seatobj = new SeatObject(parent);
	QScriptValue jsobj = engine->newQObject(seatobj, QScriptEngine::ScriptOwnership);
	jsobj.setProperty("renderPosition",engine->newFunction(renderPosition,0));
	return jsobj;
}
static QScriptValue NewCardObject(QScriptContext*, QScriptEngine *engine) {
	TablePrivate *parent = static_cast<TablePrivate*>(engine->globalObject().property("root").toQObject());
	CardObject *cardobj = new CardObject(parent);
	QScriptValue jsobj = engine->newQObject(cardobj,QScriptEngine::ScriptOwnership);
	return jsobj;
}
static QScriptValue NewChipStack(QScriptContext*,QScriptEngine *engine) {
	TablePrivate *parent = static_cast<TablePrivate*>(engine->globalObject().property("root").toQObject());
	ChipObject *stack = new ChipObject(parent);
	return engine->newQObject(stack,QScriptEngine::ScriptOwnership);
}
static QScriptValue NewDealerButton(QScriptContext *,QScriptEngine *engine) {
	TablePrivate *parent = static_cast<TablePrivate*>(engine->globalObject().property("root").toQObject());
	TableInternal::DealerButton *db = new TableInternal::DealerButton(parent);
	return engine->newQObject(db,QScriptEngine::ScriptOwnership);
}

static QScriptValue Animate(QScriptContext *context,QScriptEngine *engine) {
	GameObject *object = static_cast<GameObject*>(context->argument(0).toQObject());
	float endx = context->argument(1).toNumber();
	float endy = context->argument(2).toNumber();
	float seconds = context->argument(3).toNumber();
	Animation *a = new Animation(object,endx,endy,seconds);
	animateCore->addAnimation(a);
	return engine->undefinedValue();
}
static QScriptValue PlaySound(QScriptContext *context, QScriptEngine *engine) {
	float id = context->argument(1).toNumber();
	core->effects()->PlaySound((SoundEffects::SoundId)id);
}

TablePrivate::TablePrivate(QObject *parent) :
	QObject(parent) {

	QScriptValue global = engine.globalObject();

	engine.globalObject().setProperty("log",engine.newFunction(js_log,1));
	engine.globalObject().setProperty("Animate",engine.newFunction(Animate,4));
	global.setProperty("PlaySound",engine.newFunction(PlaySound,1));
	QScriptValue ctor = engine.newFunction(NewSeatObject);
	QScriptValue metaObject = engine.newQMetaObject(&SeatObject::staticMetaObject, ctor);
	engine.globalObject().setProperty("SeatObject",metaObject);

	engine.globalObject().setProperty("Card",engine.newQMetaObject(&CardObject::staticMetaObject,engine.newFunction(NewCardObject)));
	global.setProperty("ChipStack",engine.newQMetaObject(&ChipObject::staticMetaObject,engine.newFunction(NewChipStack)));
	global.setProperty("DealerButton",engine.newQMetaObject(&TableInternal::DealerButton::staticMetaObject,engine.newFunction(NewDealerButton)));
	engine.globalObject().setProperty("root",engine.newQObject(this));
	tableui = 0;
}
TablePrivate::~TablePrivate() {
	// tableui is a child of the QWidget in the window, it will die with the parent
	delete game;
}
bool TablePrivate::loadJs(QString code,QString file) {
	engine.evaluate(code,file);
	if (engine.hasUncaughtException()) {
		qDebug() << engine.uncaughtExceptionBacktrace();
		qDebug() << engine.uncaughtExceptionLineNumber();
		qDebug() << "uncaught excepion" << engine.uncaughtException().toString();
		engine.clearExceptions();
		return false;
	} else {
		//qDebug() << "JS loaded";
		return true;
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
bool TablePrivate::table_status(QSharedPointer<Data::TableStatus> ts) {
	lastTs = ts;
	QScriptValue func = engine.globalObject().property("tableStatus");
	if (!func.isFunction()) {
		qDebug() << "tableStatus isnt a function!";
		return false;
	}
	QScriptValueList args;
	QScriptValue jsts = engine.newQObject(ts.data());
	QList<Data::Pot*>::Iterator i1;
	QScriptValue pots = engine.newArray();
	jsts.setProperty("pots",pots);
	int index;
	for (i1=ts->pots.begin(), index=0; i1!=ts->pots.end(); ++i1, index++) {
		pots.setProperty(index,engine.newQObject(*i1));
	}
	args.append(jsts);
	func.call(engine.globalObject(),args);
	if (engine.hasUncaughtException()) {
		qDebug() << engine.uncaughtExceptionBacktrace();
		qDebug() << engine.uncaughtException().toString();
		engine.clearExceptions();
		return false;
	}
	QScriptValue func2 = engine.globalObject().property("tableEvent");
	if (!func2.isFunction()) {
		qDebug() << "tableEvent isnt a function";
		return false;
	}
	QList<QSharedPointer<Data::TableEvent> >::Iterator i2;
	for (i2=ts->events.begin(); i2!=ts->events.end(); ++i2) {
		QSharedPointer<Data::TableEvent> e = *i2;
		QScriptValue event = engine.newQObject(e.data());
		QScriptValueList args;
		args.append(event);
		func2.call(engine.globalObject(),args);
		if (engine.hasUncaughtException()) {
			qDebug() << engine.uncaughtExceptionBacktrace();
			qDebug() << engine.uncaughtException().toString();
			engine.clearExceptions();
			return false;
		}
	}
	return true;
}
void TablePrivate::setGame(const Data::Game *game) {
	rawgame = game;
	this->game = new GameWrap(game);
	engine.globalObject().setProperty("game",engine.newQObject(this->game));
}
void TablePrivate::setupUi(QWidget *parent, QGridLayout *layout) {
	tableui = new TableUi(parent);
	//layout->setRowStretch(1,1);
	layout->addWidget(tableui,0,0);
	//layout->addWidget(new QWidget(parent),1,0);
	//qDebug() << "rows" << layout->rowCount();
}

QScriptValue TablePrivate::eval(QString code) {
	QScriptValue ret = engine.evaluate(code,"chat");
	if (engine.hasUncaughtException()) {
		qDebug() << engine.uncaughtExceptionBacktrace();
		qDebug() << engine.uncaughtException().toString();
		engine.clearExceptions();
	}
	return ret;
}
void TablePrivate::editJs(QString newcode) {
	eval(newcode);
	if (engine.hasUncaughtException()) {
		qDebug() << engine.uncaughtExceptionBacktrace();
		qDebug() << engine.uncaughtException().toString();
		engine.clearExceptions();
	}
}
