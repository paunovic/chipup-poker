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

class GameObjectUi;
class SeatObject;

typedef enum {
	Left=0,
	Right,
	Top
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
	virtual QPoint getPosition();
	float getRenderHeight() const;

	float w, x,y;
	AlignmentSide keyside;
protected:
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
	void setupUi(QWidget *parent, QGridLayout *layout);
	TableUi *getUi() { Q_ASSERT(tableui); return tableui; }
	void setGame(const Data::Game *game);
	const Data::Game *getRawGame() const { return rawgame; }
	QScriptValue eval(QString code);
	void editJs(QString newcode);
	QScriptValue global() { return engine.globalObject(); }
	QSharedPointer<Data::TableStatus> getLastTs() { return lastTs; }
signals:

public slots:
private:
	QScriptEngine engine;
	TableUi *tableui;
	GameWrap *game;
	const Data::Game *rawgame;
	QSharedPointer<Data::TableStatus> lastTs;
};
class GameObject : public QObject {
Q_OBJECT
public:
	GameObject(TablePrivate *table);
	float x() { return internal->x; }
	float y() { return internal->y; }
	TablePrivate *getTable() { return table; }
	bool visible() { return internal->isVisible(); }

	Q_PROPERTY(bool visible READ visible WRITE setVisible)
	Q_PROPERTY(float renderHeight READ getRenderHeight)
public slots:
	void setPosition(float x, float y);
	void setSize(float w);
	void setSide(int side);
protected:
	GameObjectUi *internal;
	TablePrivate *table;
private:
	void setVisible(bool in) { internal->setVisible(in); }
	float getRenderHeight() const;
};

#endif // TABLEPRIVATE_H
