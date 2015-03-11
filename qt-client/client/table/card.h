#ifndef CARD_H
#define CARD_H

#include <QObject>

#include "tableprivate.h"

class CardObject;
class QFontMetricsF;

class CardObjectUi : public GameObjectUi {
Q_OBJECT
public:
	CardObjectUi(TableUi *parent, CardObject *jsobj);
	virtual QPoint getPosition() const;
	void updateFace();
protected:
	void paintEvent(QPaintEvent *event);
private:
	QPixmap loadFace(QString name);

	QPixmap face,back;
	CardObject *jsobj;
	QFont font;
	QFontMetricsF *fm;
	int lastsize;
};
class CardObject : public GameObject {
Q_OBJECT
public:
	CardObject(TablePrivate *parent);

	Q_PROPERTY(int card READ getCard WRITE setCard)
	int getCard() { return card_; }
	void setCard(int in) { card_ = in; card->updateFace(); }
public slots:
	void stackUnder(SeatObject *seat);
private:
	CardObjectUi *card;
	int card_;
};
#endif // CARD_H
