#ifndef CARD_H
#define CARD_H

#include <QObject>

#include "tableprivate.h"

class CardObject;

class CardObjectUi : public GameObjectUi {
Q_OBJECT
public:
	CardObjectUi(TableUi *parent, CardObject *jsobj);
protected:
	void paintEvent(QPaintEvent *event);
private:
	QPixmap loadFace(QString name);

	QPixmap face;
};
class CardObject : public GameObject {
Q_OBJECT
public:
	CardObject(TablePrivate *parent);
private:
	CardObjectUi *card;
};
#endif // CARD_H
