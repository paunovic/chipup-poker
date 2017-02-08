#include <QFile>
#include <QDebug>
#include <QStringList>
#include <QPainter>
#include <QScriptEngineDebugger>
#include <QMainWindow>

#include "tableprivate.h"
#include "table/visible_seat.h"
#include "table/card.h"
#include "table/chip.h"
#include "table/animation.h"
#include "table/animatecore.h"
#include "table/dealerbutton.h"
#include "data/seatinfo.h"
#include "sound_effects.h"
#include "pokermain.h"
#include "table.h"
#include "refholder.h"

static QScriptValue js_log(QScriptContext *context, QScriptEngine *engine) {
	qDebug() << /*QDateTime::currentDateTime() <<*/ "JS:" << context->argument(0).toString();
	return engine->undefinedValue();
}
static QScriptValue renderPosition(QScriptContext *context, QScriptEngine *engine) {
	SeatObject *seatobj = static_cast<SeatObject*>(context->thisObject().toQObject());
	//QPoint pos = seatobj->getSeatUi()->getPosition();
	QScriptValue ret = engine->newObject();
	float x = seatobj->x();
	if (seatobj->getKeySide() == Right) x -= seatobj->getSeatUi()->w;
	else if (seatobj->getKeySide() == Top) x -= (seatobj->getSeatUi()->w/2);
	ret.setProperty("x",x);
	ret.setProperty("y",seatobj->y());
	ret.setProperty("keySide",seatobj->getKeySide());
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
	if (object) {
		float endx = context->argument(1).toNumber();
		float endy = context->argument(2).toNumber();
		float seconds = context->argument(3).toNumber();
		QScriptValue callback = context->argument(4);
		Animation *a = new Animation(object,endx,endy,seconds,callback);
		animateCore->addAnimation(a);
		return engine->undefinedValue();
	} else {
		return context->throwError("object was null");
	}
}
static QScriptValue PlaySound(QScriptContext *context, QScriptEngine *engine) {
	int id = context->argument(0).toNumber();
	core->effects()->PlaySound((SoundEffects::SoundId)id);
	return engine->undefinedValue();
}
static QScriptValue NewTimer(QScriptContext *,QScriptEngine *engine) {
	QTimer *t = new QTimer();
	return engine->newQObject(t,QScriptEngine::ScriptOwnership);
}
static QScriptValue ClearCheckBoxes(QScriptContext *context, QScriptEngine *engine) {
	TablePrivate *parent = static_cast<TablePrivate*>(engine->globalObject().property("root").toQObject());
	parent->rootwindow->clearCheckBoxes();
	return engine->undefinedValue();
}

TablePrivate::TablePrivate(QObject *parent) :
	QObject(parent) {

	agent = new ScriptAgent(&engine);
	//engine.setAgent(agent);
	//QScriptEngineDebugger *debuger = new QScriptEngineDebugger(this);
	//debuger->setAutoShowStandardWindow(true);
	//debuger->attachTo(&engine);
	//QMainWindow *debugWindow = debuger->standardWindow();
	//debugWindow->show();

	QScriptValue global = engine.globalObject();

	global.setProperty("log",engine.newFunction(js_log,1));
	global.setProperty("PlaySound",engine.newFunction(PlaySound,1));
	global.setProperty("Animate",engine.newFunction(Animate,5));
	global.setProperty("ClearCheckBoxes",engine.newFunction(ClearCheckBoxes,0));
	QScriptValue ctor = engine.newFunction(NewSeatObject);
	QScriptValue metaObject = engine.newQMetaObject(&SeatObject::staticMetaObject, ctor);
	global.setProperty("SeatObject",metaObject);

	global.setProperty("Card",engine.newQMetaObject(&CardObject::staticMetaObject,engine.newFunction(NewCardObject)));
	global.setProperty("ChipStack",engine.newQMetaObject(&ChipObject::staticMetaObject,engine.newFunction(NewChipStack)));
	global.setProperty("DealerButton",engine.newQMetaObject(&TableInternal::DealerButton::staticMetaObject,engine.newFunction(NewDealerButton)));
	global.setProperty("root",engine.newQObject(this));
	global.setProperty("QTimer",engine.newQMetaObject(&QTimer::staticMetaObject,engine.newFunction(NewTimer)));
	tableui = 0;
	game = 0;
}
TablePrivate::~TablePrivate() {
	// tableui is a child of the QWidget in the window, it will die with the parent
	delete game;
}
bool TablePrivate::loadJs(QString code,QString file) {
	agent->setCode(code);
	engine.evaluate(code,file);
	if (engine.hasUncaughtException()) {
		qDebug() << engine.uncaughtExceptionBacktrace();
		qDebug() << engine.uncaughtExceptionLineNumber();
		qDebug() << "uncaught excepion while loading js" << engine.uncaughtException().toString();
		engine.clearExceptions();
		return false;
	} else {
		qDebug() << "JS loaded";
		return true;
	}
}
void TablePrivate::renderWinning(QString msg) {
	rootwindow->renderWinning(msg);
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
	RefHolder *holder = new RefHolder;
	holder->ts = ts;
	jsts.setProperty("refholder",engine.newQObject(holder));
	QList<Data::Pot*>::Iterator i1;
	QScriptValue pots = engine.newArray();
	jsts.setProperty("pots",pots);
	int index;
	for (i1=ts->pots.begin(), index=0; i1!=ts->pots.end(); ++i1, index++) {
		pots.setProperty(index,engine.newQObject(*i1));
	}

	QList<QSharedPointer<Data::TableEvent> >::Iterator i2;
	QScriptValue events = engine.newArray();
	int j=0,k;
	for (i2=ts->events.begin(); i2!=ts->events.end(); ++i2) {
		QSharedPointer<Data::TableEvent> e = *i2;
		QScriptValue event = engine.newQObject(e.data());
		QScriptValue pots = engine.newArray();
		k = 0;
		foreach (Data::Pot *p, e->pots) {
			QScriptValue pot = engine.newQObject(p);
			QScriptValue wda = engine.newArray();
			int l=0;
			foreach (Data::WinnerData *wd , p->winnerData) {
				wda.setProperty(l,engine.newQObject((QObject*)wd));
				l++;
			}
			pot.setProperty("WinnerData",wda);
			pots.setProperty(k,pot);
			k++;
		}
		event.setProperty("pots",pots);
		events.setProperty(j,event);
		j++;
	}
	jsts.setProperty("events",events);

	QList<Data::SeatInfo*>::Iterator i3;
	QScriptValue seats = engine.newArray();
	j = 0;
	for (i3=ts->seats.begin(); i3!=ts->seats.end(); ++i3) {
		Data::SeatInfo *seat = *i3;
		seats.setProperty(j,engine.newQObject(seat));
		j++;
	}
	jsts.setProperty("seats",seats);

	args.append(jsts);
	func.call(engine.globalObject(),args);
	if (engine.hasUncaughtException()) {
		qDebug() << engine.uncaughtExceptionBacktrace();
		qDebug() << engine.uncaughtException().toString();
		engine.clearExceptions();
		return false;
	}
	return true;
}
void TablePrivate::setGame(const Data::Game *game) {
	rawgame = game;
	this->game = new GameWrap(game);
	engine.globalObject().setProperty("game",engine.newQObject(this->game));
}
void TablePrivate::setupUi(QWidget *parent, QGridLayout *layout, Table *rootwindow) {
	tableui = new TableUi(parent);
	this->rootwindow = rootwindow;
	//layout->setRowStretch(1,1);
	layout->addWidget(tableui,0,0);
	//layout->addWidget(new QWidget(parent),1,0);
	//qDebug() << "rows" << layout->rowCount();
	engine.globalObject().setProperty("controls",engine.newQObject(rootwindow));
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
Data::SeatInfo * TablePrivate::findMySeat() const {
	for (int x=0; x < lastTs->seats.length(); x++) {
		Data::SeatInfo *seat = lastTs->seats[x];
		if (seat->userid == core->self()->id) return seat;
	}
	return 0;
}
bool TablePrivate::autoCall() { return rootwindow->autoCall(); }
bool TablePrivate::autoCallAny() { return rootwindow->autoCallAny(); }
bool TablePrivate::autoCheck() { return rootwindow->autoCheck(); }
bool TablePrivate::autoCheckFold() { return rootwindow->autoCheckFold(); }
