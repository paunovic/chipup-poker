#ifndef TABLEPRIVATE_H
#define TABLEPRIVATE_H

#include "config.h"

#include <QObject>
#include <QScriptEngine>
#include <QWidget>
#include <QHBoxLayout>
#include <QPixmap>

#include "tablestatus.h"
#include "table/game_wrap.h"
#include "table/scriptagent.h"

class GameObjectUi;
class SeatObject;
class Table;

typedef enum {
	Left=0,
	Right=1,
	Top=2,
	Bottom=3,
	Center=4
} AlignmentSide;

class TableUi : public QWidget {
Q_OBJECT
public:
	TableUi(QWidget *parent=0);
	QSize sizeHint() const;
	void addElement(GameObjectUi *element);
//	int heightForWidth(int w) const;
	int rootHeight();

	int yoffset;
private slots:
	void element_deleted(QObject *element);
protected:
	void paintEvent(QPaintEvent *event);
	void resizeEvent(QResizeEvent *event);
	void drawCross(QPainter &p);
	void drawGrid(QPainter &p);
	virtual bool event(QEvent *event);

	QList<GameObjectUi*> uiElements;
	QPixmap pix;
};
class GameObjectUi : public QWidget {
Q_OBJECT
public:
	GameObjectUi(TableUi *parent);
	void setSize(float w);
	QSize sizeHint() const;
	void moveRatio(float x, float y);
	int heightForWidth(int w) const;
	virtual QPoint getPosition() const;
	float getRenderHeight() const;

	float w, x,y;
	AlignmentSide keyside;
	bool redraw;
protected:
	void drawDebug(QPainter &p);

	QPixmap pix;
	TableUi *tbl;
};
class TablePrivate : public QObject
{
	Q_OBJECT
public:
	explicit TablePrivate(QObject *parent = 0);
	~TablePrivate();
	bool table_status(QSharedPointer<Data::TableStatus> ts);
	bool loadJs(QString code,QString file);
	void loadJsFromResource();
	void setupUi(QWidget *parent, QGridLayout *layout, Table *rootwindow);
	TableUi *getUi() { Q_ASSERT(tableui); return tableui; }
	void setGame(const Data::Game *game);
	const Data::Game *getRawGame() const { return rawgame; }
	QScriptValue eval(QString code);
	void editJs(QString newcode);
	QScriptValue global() { return engine.globalObject(); }
	QSharedPointer<Data::TableStatus> getLastTs() { return lastTs; }
	Data::SeatInfo *findMySeat() const;
	bool autoCheck();
	bool autoCheckFold();
	bool autoCall();
	bool autoCallAny();

	Q_PROPERTY(bool autoCheck READ autoCheck)
	Q_PROPERTY(bool autoCheckFold READ autoCheckFold)
	Q_PROPERTY(bool autoCall READ autoCall)
	Q_PROPERTY(bool autoCallAny READ autoCallAny)

	Table *rootwindow;
signals:

public slots:
	void renderWinning(QString msg);
protected:
	TableUi *tableui;
	friend class Table;
private:
	QScriptEngine engine;
	GameWrap *game;
	const Data::Game *rawgame;
	QSharedPointer<Data::TableStatus> lastTs;
	ScriptAgent *agent;
};
class GameObject : public QObject {
Q_OBJECT
public:
	GameObject(TablePrivate *table);
	~GameObject();
	float x() { return internal->x; }
	float y() { return internal->y; }
	TablePrivate *getTable() { return table; }
	bool visible() { return internal->isVisible(); }
	int getKeySide() const { return (int)internal->keyside; }
	void setSide(int side);

	Q_PROPERTY(bool visible READ visible WRITE setVisible)
	Q_PROPERTY(float renderHeight READ getRenderHeight)
	Q_PROPERTY(int keySide READ getKeySide WRITE setSide)
public slots:
	void setPosition(float x, float y);
	void setSize(float w);
protected:
	GameObjectUi *internal;
	TablePrivate *table;
private:
	void setVisible(bool in) { internal->setVisible(in); }
	float getRenderHeight() const;
};

#endif // TABLEPRIVATE_H
