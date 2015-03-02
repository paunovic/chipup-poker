#include <QPainter>

#include "card.h"
#include "table/visible_seat.h"

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
static QString getDisplayValue(int card) {
	int x = card/4;
	switch (x) {
	case 8: return "=";
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
	case 1: return "d";
	case 2: return "c";
	case 3: return "s";
	default: return "error";
	}
}
static inline QString getSuitFontCode(int card) {
	int x = card % 4;
	switch (x) {
	case 0: return "{";
	case 1: return "[";
	case 2: return "]";
	case 3: return "}";
	default: return "error";
	}
}

static inline QColor getSuitColor(int card) {
	int x = card % 4;
	switch (x) {
	case 0:
	case 1:
		return QColor(255,0,0);
	case 2:
	case 3:
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
	back = QPixmap(":/resources/cards/Background.png");
	font = QFont("Card Characters");
	font.setPixelSize(10);
	updateFace();
}
void CardObjectUi::paintEvent(QPaintEvent *) {
	QPainter p(this);
	p.setPen(Qt::NoPen);
	p.setBrush(QColor(127,0,0));
	int pixelsize = (qreal)width() * 0.25;
	font.setPixelSize(pixelsize);
	//p.drawRect(0,0,width(),height());

	int card = jsobj->getCard();
	if (card == -1) {
		p.drawPixmap(0,0,width(),height(),back);
	} else {
		p.drawPixmap(0,0,width(),height(),pix);
		int target_width = (qreal)width() * 0.6;
		int target_height = ((qreal)face.height()*target_width)/face.width();
		int target_x = (qreal)width() * 0.20;
		int target_y = (qreal)height() * 0.056;
		QRectF faceLocation(target_x,target_y,target_width,target_height);
		p.drawPixmap(faceLocation,face,QRectF());

		p.setPen(getSuitColor(card));
		p.setFont(font);
		QRectF rank(2,0,80,30);
		p.drawText(rank,0,getDisplayValue(card)+"\n"+getSuitFontCode(card));
	}
}
QPixmap CardObjectUi::loadFace(QString name) {
	//qDebug() << "loading " << name;
	return QPixmap(":/resources/cards/artworks/"+name+".png");
}
QPoint CardObjectUi::getPosition() const {
	QPoint out = GameObjectUi::getPosition();
	Q_ASSERT(out.y() < 10000);
	int newwidth = tbl->width() * w;
	Q_ASSERT(newwidth);
	int new_height = heightForWidth(newwidth);
	Q_ASSERT(new_height);
	out.setY(out.y() - (new_height/2));
	return out;
}
void CardObjectUi::updateFace() {
	int card = jsobj->getCard();
	face = loadFace(QString("CardArtwork%1%2").arg(getValue(card)).arg(getSuit(card)));
	update();
}
void CardObject::stackUnder(SeatObject *seat) {
	card->stackUnder(seat->getSeatUi());
}
