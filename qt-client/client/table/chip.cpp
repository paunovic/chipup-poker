#include <QPainter>
#include <QStyle>

#include "chip.h"

static inline int chipSep(int tblwidth) {
	return tblwidth * 0.005;
}

ChipObject::ChipObject(TablePrivate *parent) :GameObject(parent) {
	value_ = 12345;
	internal = chips = new ChipObjectUi(parent->getUi(),this);
	setSize(0.09);
	parent->getUi()->addElement(internal);
	rake_ = false;
}

ChipObjectUi::ChipObjectUi(TableUi *parent, ChipObject *jsobj) : GameObjectUi(parent),
	jsobj(jsobj) {
	font.setPixelSize(tbl->width()*0.015);
	fm = new QFontMetrics(font);
	c1 = QPixmap(":/resources/chips/1.png");
	c5 = QPixmap(":/resources/chips/5.png");
	c25 = QPixmap(":/resources/chips/25.png");
	c100 = QPixmap(":/resources/chips/100.png");
	c500 = QPixmap(":/resources/chips/500.png");
	c1000 = QPixmap(":/resources/chips/1000.png");
	pix = c1;
	redraw = true;
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
	if (jsobj->rake() && (chips.length() == 0)) chips.append(c1);
	qDebug() << "chip stack changed";
	redraw = true;
	update();
	updateGeometry();
	text = QString("%1").arg((float)jsobj->value()/100);

	resizeEvent(0);
}
void ChipObjectUi::resizeEvent(QResizeEvent *event) {
	font.setPixelSize(tbl->width()*0.015);
	if (!fm) delete fm;
	fm = new QFontMetrics(font);

	int chipWidth = (qreal)tbl->width() * 0.025;
	int chipHeight = ((qreal)c1.height()*chipWidth)/c1.width();

	int new_width = tbl->width() * w;
	int height = (chips.length() * chipSep(tbl->width())) + chipHeight;
	textRegion = QRect(chipWidth,0,(qreal)pix.width()*1.1,height);
	qDebug() << this << textRegion << "chip text" << pos() << jsobj->value();
	redraw = true;
}

static inline void drawChip(QPainter &p, QPixmap chip,int x, int y, int rootheight, int tblwidth) {
	int chipWidth = (qreal)tblwidth * 0.025;
	int chipHeight = ((qreal)chip.height()*chipWidth)/chip.width();
	p.drawPixmap(x,rootheight-(y+chipHeight),chipWidth,chipHeight,chip);
}

void ChipObjectUi::paintEvent(QPaintEvent *) {
	if (redraw) {
		offscreenbuffer = QPixmap(size());
		offscreenbuffer.fill(Qt::transparent);

		QPainter p2(&offscreenbuffer);
		// TODO, draw text on left or right
		//drawDebug(p);
		p2.setBrush(QColor(127,0,0));
		p2.setPen(Qt::NoPen);
		//p.drawRect(0,0,width(),height());

		p2.save();
		QList<QPixmap>::Iterator i;
		int y=0;
		for (i=chips.begin(); i!=chips.end(); ++i, y+=chipSep(tbl->width())) {
			QPixmap chip = *i;
			drawChip(p2,chip,0,y,height(),tbl->width());
		}
		p2.restore();

		//p.setBrush(Qt::green);

		p2.setPen(QColor(255,255,255));
		p2.setFont(font);
		style()->drawItemText(&p2,textRegion,Qt::AlignVCenter | Qt::AlignLeft,palette(),true,text);
		redraw = false;
	}
	QPainter p(this);
	if (jsobj->rake()) p.setOpacity(0.5);
	p.drawPixmap(0,0,width(),height(),offscreenbuffer);
}
QSize ChipObjectUi::sizeHint() const {
	int chipWidth = (qreal)tbl->width() * 0.025;
	int chipHeight = ((qreal)c1.height()*chipWidth)/c1.width();

	int new_width = tbl->width() * w;
	int height = (chips.length() * chipSep(tbl->width())) + chipHeight;
	QSize ret(new_width+textRegion.width(),height);
	QPoint x = textRegion.bottomRight();
	if (height < x.y()) height = x.y();
	return QSize(x.x(),height);
}
void ChipObject::setVisible(bool in) {
	chips->setVisible(in);
	if (!in) {
		//qDebug() << table->global().engine()->currentContext()->backtrace();
	}
}
