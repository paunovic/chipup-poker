#include <QPainter>

#include "chip.h"

ChipObject::ChipObject(TablePrivate *parent) :GameObject(parent) {
	value_ = 1;
	internal = chips = new ChipObjectUi(parent->getUi(),this);
	setSize(0.05);
	parent->getUi()->getLayout()->addElement(internal);
}

ChipObjectUi::ChipObjectUi(TableUi *parent, ChipObject *jsobj) : GameObjectUi(parent),
	jsobj(jsobj) {
	c1 = QPixmap(":/resources/chips/1.png");
	c5 = QPixmap(":/resources/chips/5.png");
	c25 = QPixmap(":/resources/chips/25.png");
	c100 = QPixmap(":/resources/chips/100.png");
	c500 = QPixmap(":/resources/chips/500.png");
	c1000 = QPixmap(":/resources/chips/1000.png");
	pix = c1;
	updateValue();
}

void ChipObjectUi::updateValue() {
	int v = jsobj->value()/100;
	chips.clear();
	while (v) {
		if (v >= 1000) {
			chips.prepend(c1000);
			v -= 1000;
		} else if (v >= 500) {
			chips.prepend(c500);
			v -= 500;
		} else if (v >= 100) {
			chips.prepend(c100);
			v -= 100;
		} else if (v >= 25) {
			chips.prepend(c25);
			v -= 25;
		} else if (v >= 5) {
			chips.prepend(c5);
			v -= 5;
		} else {
			chips.prepend(c1);
			v -= 1;
		}
	}
	qDebug() << "chip doing update";
	update();
	updateGeometry();
}
static inline void drawChip(QPainter &p, QPixmap chip,int x, int y, int rootheight) {
	float scale = 0.6;
	p.drawPixmap(x,rootheight-(y+(chip.height()*scale)),chip.width()*scale,chip.height()*scale,chip);
}

void ChipObjectUi::paintEvent(QPaintEvent *) {
	// TODO, draw text on left or right
	QPainter p(this);
	p.setBrush(QColor(127,0,0));
	p.setPen(Qt::NoPen);
	//p.drawRect(0,0,width(),height());

	p.save();
	QList<QPixmap>::Iterator i;
	int y=0;
	for (i=chips.begin(); i!=chips.end(); ++i, y+=5) {
		QPixmap chip = *i;
		drawChip(p,chip,0,y,height());
	}
	p.restore();

	p.setPen(QColor(255,255,255));
	int chipwidth = pix.width()*0.6;
	p.drawText(chipwidth,height()/2,width() - chipwidth,height(),0,QString("%1").arg((float)jsobj->value()/100));
}
QSize ChipObjectUi::sizeHint() const {
	int new_width = tbl->width() * w;
	qDebug() << new_width;
	int height = (chips.length() * 5) + (pix.height() * 0.6);
	return QSize(new_width+40,height);
}
