#include <QPainter>
#include <QStyle>

#include "chip.h"

static inline int chipSep(int tblwidth) {
	return tblwidth * 0.005;
}

ChipObject::ChipObject(TablePrivate *parent) :GameObject(parent) {
	value_ = 1;
	internal = chips = new ChipObjectUi(parent->getUi(),this);
	setSize(0.09);
	parent->getUi()->addElement(internal);
}

ChipObjectUi::ChipObjectUi(TableUi *parent, ChipObject *jsobj) : GameObjectUi(parent),
	jsobj(jsobj) {
	font.setPixelSize(tbl->width()*0.02);
	font.setBold(true);
	fm = new QFontMetrics(font);
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
	qDebug() << "chip stack changed";
	update();
	updateGeometry();
	text = QString("%1").arg((float)jsobj->value()/100);

	int chipWidth = (qreal)tbl->width() * 0.025;
	int chipHeight = ((qreal)c1.height()*chipWidth)/c1.width();

	int new_width = tbl->width() * w;
	int height = (chips.length() * chipSep(tbl->width())) + chipHeight;
	textRegion = QRect(chipWidth,0,(qreal)pix.width()*1.1,height);
	qDebug() << textRegion << "chip text";
}
static inline void drawChip(QPainter &p, QPixmap chip,int x, int y, int rootheight, int tblwidth) {
	int chipWidth = (qreal)tblwidth * 0.025;
	int chipHeight = ((qreal)chip.height()*chipWidth)/chip.width();
	p.drawPixmap(x,rootheight-(y+chipHeight),chipWidth,chipHeight,chip);
}

void ChipObjectUi::paintEvent(QPaintEvent *) {
	// TODO, draw text on left or right
	QPainter p(this);
	//drawDebug(p);
	p.setBrush(QColor(127,0,0));
	p.setPen(Qt::NoPen);
	//p.drawRect(0,0,width(),height());

	p.save();
	QList<QPixmap>::Iterator i;
	int y=0;
	for (i=chips.begin(); i!=chips.end(); ++i, y+=chipSep(tbl->width())) {
		QPixmap chip = *i;
		drawChip(p,chip,0,y,height(),tbl->width());
	}
	p.restore();

	//p.setBrush(Qt::green);

	p.setPen(QColor(255,255,255));
	p.setFont(font);
	style()->drawItemText(&p,textRegion,Qt::AlignVCenter | Qt::AlignLeft,palette(),true,text);
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
