#include <QPainter>

#include "card.h"

static QString getValue(int card) {
	int x = card/4;
	switch (x) {
	case 8: return "T";
	case 9: return "J";
	case 10: return "Q";
	case 11: return "K";
	case 12: return "A";
	default:
		return QString("%1").arg(x+2);
	}
}
static inline QString getSuit(int card) {
	int x = card % 4;
	switch (x) {
	case 0: return "h";
	case 1: return "s";
	case 2: return "c";
	case 3: return "d";
	default: return "error";
	}
}
static inline QColor getSuitColor(int card) {
	int x = card % 4;
	switch (x) {
	case 0:
	case 3:
		return QColor(255,0,0);
	case 1:
	case 2:
	default:
		return QColor(0,0,0);
	}
}

CardObject::CardObject(TablePrivate *parent) :GameObject(parent) {
	card_ = 0;
	internal = card = new CardObjectUi(parent->getUi(),this);
	parent->getUi()->addElement(internal);
}
CardObjectUi::CardObjectUi(TableUi *parent, CardObject *jsobj) : GameObjectUi(parent),
	jsobj(jsobj) {
	pix = QPixmap(":/resources/cards/CardFrontBackground.png");
	font = QFont("Card Characters");
	updateFace();
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

	int card = jsobj->getCard();
	p.setPen(getSuitColor(card));
	p.setFont(font);
	p.drawText(5,0,80,30,0,getValue(card));
}
QPixmap CardObjectUi::loadFace(QString name) {
	qDebug() << "loading " << name;
	return QPixmap(":/resources/cards/artworks/"+name+".png");
}
QPoint CardObjectUi::getPosition() {
	QPoint out = GameObjectUi::getPosition();
	int newwidth = tbl->width() * w;
	int new_height = heightForWidth(newwidth);
	out.setY(out.y() - (new_height/2));
	return out;
}
void CardObjectUi::updateFace() {
	int card = jsobj->getCard();
	face = loadFace(QString("CardArtwork%1%2").arg(getValue(card)).arg(getSuit(card)));
	update();
}
