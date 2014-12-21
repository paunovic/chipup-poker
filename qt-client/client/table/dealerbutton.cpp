#include <QPainter>

#include "dealerbutton.h"

namespace TableInternal {

DealerButton::DealerButton(TablePrivate *parent) :
	GameObject(parent)
{
	internal = button = new DealerButtonUi(parent->getUi(),this);
	parent->getUi()->addElement(internal);
	setSize(0.03);
}
DealerButtonUi::DealerButtonUi(TableUi *parent, DealerButton *jsobj): GameObjectUi(parent),jsobj(jsobj) {
	pix = dealer = QPixmap(":/resources/table/DealerButton.png");
}
void DealerButtonUi::paintEvent(QPaintEvent *event) {
	qDebug() << "dealer paint" << getPosition() << sizeHint();
	QPainter p(this);
	p.setRenderHints(QPainter::SmoothPixmapTransform);
	p.drawPixmap(0,0,width(),height(),pix);
}
} // namespace TableInternal
