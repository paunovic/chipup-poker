#include <QPainter>

#include "tableprivate.h"

VisibleSeat::VisibleSeat(TableUi *parent, SeatObject *jsobj) : GameObjectUi(parent), jsobj(jsobj) {
	qDebug() << __func__;
	seatRight = QPixmap(":/resources/seats/SeatRight.png");
	seatRightEmpty = QPixmap(":/resources/seats/SeatRightEmpty.png");
	pix = seatRightEmpty;
}
void VisibleSeat::paintEvent(QPaintEvent *) {
	QPainter painter(this);
	//painter.setPen(Qt::NoPen);
	//painter.setBrush(QColor(127,0,0));
	//painter.drawRect(0,0,width(),height());
	painter.drawPixmap(0,0,width(),height(),pix);
}
SeatObject::SeatObject(TablePrivate *root) : GameObject(root) {
	qDebug() << "table info" << root->getUi()->size() << root->getUi()->pos();
	internal = seat = new VisibleSeat(root->getUi(),this);
	root->getUi()->addElement(internal);
	qDebug() << "seat info" << internal->size() << internal->pos() << internal->isVisible() << internal->isHidden();
}
void VisibleSeat::mousePressEvent(QMouseEvent *) {
	pix = seatRight;
	update();
	qDebug() << jsobj->getSeat();
}
void VisibleSeat::mouseReleaseEvent(QMouseEvent *) {
	pix = seatRightEmpty;
	update();
}
