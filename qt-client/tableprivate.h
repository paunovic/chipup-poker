#ifndef TABLEPRIVATE_H
#define TABLEPRIVATE_H

#include "config.h"

#include <QObject>
#include <QScriptEngine>
#include <QWidget>
#include <QHBoxLayout>

#include "tablestatus.h"
#include "table/game_wrap.h"

class GameObjectUi;

class TableUi : public QWidget {
Q_OBJECT
public:
	TableUi(QWidget *parent=0);
	QSize sizeHint() const;
	void addElement(GameObjectUi *element);
private slots:
	void element_deleted(QObject *element);
protected:
	void paintEvent(QPaintEvent *event);
	void resizeEvent(QResizeEvent *event);
	QList<GameObjectUi*> uiElements;
};
class GameObjectUi : public QWidget {
Q_OBJECT
public:
	GameObjectUi(TableUi *parent=0);
	void setSize(float w, float h);
	QSize sizeHint() const;
	void moveRatio(float x, float y);

	float w,h, x,y;
private:
	TableUi *tbl;
};
class VisibleSeat : public GameObjectUi {
Q_OBJECT
public:
	VisibleSeat(TableUi *parent);
protected:
	void paintEvent(QPaintEvent *event);
private:
	QPixmap seatRight;
};
class CardObjectUi : public GameObjectUi {
Q_OBJECT
public:
	CardObjectUi(QWidget *parent);
};
class ChipObjectUi : public GameObjectUi {
Q_OBJECT
public:
	ChipObjectUi(QWidget *parent);
};

class TablePrivate : public QObject
{
	Q_OBJECT
public:
	explicit TablePrivate(QObject *parent = 0);
	~TablePrivate();
	void table_status(QSharedPointer<Data::TableStatus> ts);
	void loadJs(QString code,QString file);
	void loadJsFromResource();
	void setupUi(QWidget *parent, QHBoxLayout *layout);
	TableUi *getUi() { return tableui; }
	void setGame(const Data::Game *game);

signals:

public slots:
private:
	QScriptEngine engine;
	TableUi *tableui;
	GameWrap *game;
};
class GameObject : public QObject {
Q_OBJECT
public:
	GameObject(TablePrivate *parent);
public slots:
	void setPosition(float x, float y);
	void setSize(float w, float h);
protected:
	GameObjectUi *internal;
};

class SeatObject : public GameObject {
Q_OBJECT
public:
	SeatObject(TablePrivate *parent);
private:
	VisibleSeat *seat;
};

class CardObject : public GameObject {
Q_OBJECT
public:
	CardObject(TablePrivate *parent);
private:
	CardObjectUi *card;
};

class ChipObject : public GameObject {
Q_OBJECT
public:
	ChipObject(TablePrivate *);
private:
	ChipObjectUi *chips;
};
#endif // TABLEPRIVATE_H
