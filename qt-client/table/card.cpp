#include <QPainter>

#include "card.h"

CardObject::CardObject(TablePrivate *parent) :GameObject(parent) {
	internal = card = new CardObjectUi(parent->getUi(),this);
	parent->getUi()->addElement(internal);
}
CardObjectUi::CardObjectUi(TableUi *parent, CardObject *jsobj) {

}
void CardObjectUi::paintEvent(QPaintEvent *event) {
	QPainter p(this);
	p.setPen(Qt::NoPen);
	p.setBrush(QColor(127,0,0));
	p.drawRect(0,0,width(),height());
}
