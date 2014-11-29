#ifndef CARD_H
#define CARD_H

#include <QObject>

#include "tableprivate.h"

class CardObject;

class CardObjectUi : public GameObjectUi {
Q_OBJECT
public:
	CardObjectUi(TableUi *parent, CardObject *jsobj);
	virtual QPoint getPosition();
	void updateFace();
protected:
	void paintEvent(QPaintEvent *event);
private:
	QPixmap loadFace(QString name);

	QPixmap face;
	CardObject *jsobj;
	QFont font;
};
class CardObject : public GameObject {
Q_OBJECT
public:
	CardObject(TablePrivate *parent);

	Q_PROPERTY(int card READ getCard WRITE setCard)
	int getCard() { return card_; }
	void setCard(int in) { card_ = in; card->updateFace(); }
private:
	CardObjectUi *card;
	int card_;
};
#endif // CARD_H
