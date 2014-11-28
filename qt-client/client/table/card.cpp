#include <QPainter>

#include "card.h"

CardObject::CardObject(TablePrivate *parent) :GameObject(parent) {
	internal = card = new CardObjectUi(parent->getUi(),this);
	parent->getUi()->addElement(internal);
}
CardObjectUi::CardObjectUi(TableUi *parent, CardObject *jsobj) : GameObjectUi(parent) {
	pix = QPixmap(":/resources/cards/CardFrontBackground.png");
	face = loadFace("CardArtwork2c");
}
void CardObjectUi::paintEvent(QPaintEvent *) {
	QPainter p(this);
	p.setPen(Qt::NoPen);
	p.setBrush(QColor(127,0,0));
	//p.drawRect(0,0,width(),height());

	p.drawPixmap(0,0,width(),height(),pix);
	int target_width = (qreal)width() * 0.5;
	int target_height = ((qreal)face.height()*target_width)/face.width();
	int target_x = (width() - target_width) /2;
	int target_y = (height() - target_height) / 2;
	p.drawPixmap(target_x,target_y,target_width,target_height,face);
	qDebug() << "drawing card" << width() << height();
}
QPixmap CardObjectUi::loadFace(QString name) {
	return QPixmap(":/resources/cards/artworks/"+name+".png");
}
