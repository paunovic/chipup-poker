#include <QFile>
#include <QDebug>
#include <QStringList>
#include <QPainter>

#include "tableprivate.h"

static QScriptValue js_log(QScriptContext *context, QScriptEngine *engine) {
	qDebug() << "JS:" << context->argument(0).toString();
	return engine->undefinedValue();
 }
static QScriptValue NewSeatObject(QScriptContext *context, QScriptEngine *engine) {
	TablePrivate *parent = static_cast<TablePrivate*>(engine->globalObject().property("root").toQObject());
	SeatObject *seatobj = new SeatObject(parent);
	return engine->newQObject(seatobj, QScriptEngine::ScriptOwnership);
}
TablePrivate::TablePrivate(QObject *parent) :
	QObject(parent) {

	engine.globalObject().setProperty("log",engine.newFunction(js_log,1));
	QScriptValue ctor = engine.newFunction(NewSeatObject);
	QScriptValue metaObject = engine.newQMetaObject(&SeatObject::staticMetaObject, ctor);
	engine.globalObject().setProperty("SeatObject",metaObject);
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
	QScriptValueList  args;
	args.append(engine.newQObject(ts.data()));
	func.call(engine.globalObject(),args);
	if (engine.hasUncaughtException()) {
		qDebug() << engine.uncaughtExceptionBacktrace();
		qDebug() << engine.uncaughtException().toString();
		engine.clearExceptions();
	}
}
void TablePrivate::setGame(const Data::Game *game) {
	this->game = new GameWrap(game);
	engine.globalObject().setProperty("game",engine.newQObject(this->game));
}
SeatObject::SeatObject(TablePrivate *root) : GameObject(root) {
	qDebug() << "table info" << root->getUi()->size() << root->getUi()->pos();
	internal = seat = new VisibleSeat(root->getUi());
	root->getUi()->addElement(internal);
	qDebug() << "seat info" << internal->size() << internal->pos() << internal->isVisible() << internal->isHidden();
}
void TablePrivate::setupUi(QWidget *parent, QHBoxLayout *layout) {
	qDebug() << __func__;
	tableui = new TableUi(parent);
	layout->addWidget(tableui);
}
TableUi::TableUi(QWidget *parent) : QWidget(parent) {
	qDebug() << __func__;
}
void TableUi::resizeEvent(QResizeEvent *event) {
	for (int i=0; i<uiElements.length(); i++) {
		GameObjectUi *el = uiElements.at(i);
		el->setGeometry(width() * el->x,height()*el->y, width()*el->w,height()*el->h);
	}
}
void TableUi::paintEvent(QPaintEvent *event) {
	QPainter painter(this);
	painter.setPen(Qt::NoPen);
	painter.setBrush(QColor(0,127,0,127));
}
void TableUi::addElement(GameObjectUi *element) {
	uiElements.append(element);
	connect(element,SIGNAL(destroyed(QObject*)),this,SLOT(element_deleted(QObject*)));
}
void TableUi::element_deleted(QObject *item) {
	qDebug() << "element deleting" << item;
	uiElements.removeOne(static_cast<GameObjectUi*>(item));
}
VisibleSeat::VisibleSeat(TableUi *parent) : GameObjectUi(parent) {
	qDebug() << __func__;
	seatRight = QPixmap(":/resources/seats/SeatRight.png");
}
QSize TableUi::sizeHint() const {
	qDebug() << "table" << __func__;
	//return QWidget::sizeHint();
	return QSize(500,500);
}
void VisibleSeat::paintEvent(QPaintEvent *event) {
	QPainter painter(this);
	painter.setPen(Qt::NoPen);
	painter.setBrush(QColor(127,0,0));
	painter.drawRect(0,0,width(),height());
	painter.drawPixmap(0,0,seatRight);
}
GameObject::GameObject(TablePrivate *root) {
}
void GameObject::setPosition(float x, float y) {
	qDebug() << __func__ << x << y;
	internal->moveRatio(x,y);
	internal->show();
}
void GameObject::setSize(float w, float h) {
	internal->setSize(w,h);
}
GameObjectUi::GameObjectUi(TableUi *parent) : QWidget(parent), tbl(parent) {
}
QSize GameObjectUi::sizeHint() const {
	qDebug() << "gameobject resize" << __func__;
	return QSize(tbl->width() * w,tbl->height() * h);
}
void GameObjectUi::moveRatio(float x, float y) {
	this->x = x;
	this->y = y;
	move(tbl->width() * x, tbl->height() * y);
}
void GameObjectUi::setSize(float w, float h) {
	qDebug() << "updating object size" << w << h;
	this->w = w;
	this->h = h;
	resize(tbl->width() * w,tbl->height() * h);
}
