#include "tableprivate.h"

GameObject::GameObject(TablePrivate *table) {
	this->table = table;
}
void GameObject::setPosition(float x, float y) {
	//qDebug() << __func__ << x << y;
	Q_ASSERT(x > 0);
	Q_ASSERT(y > 0);
	internal->moveRatio(x,y);
	internal->show();
}
void GameObject::setSize(float w) {
	internal->setSize(w);
}
GameObjectUi::GameObjectUi(TableUi *parent) : QWidget(parent), tbl(parent) {
	keyside = Left;
}
QSize GameObjectUi::sizeHint() const {
	int new_width = tbl->width() * w;
	return QSize(new_width,heightForWidth(new_width));
}
void GameObjectUi::moveRatio(float x, float y) {
	this->x = x;
	this->y = y;
	move(getPosition());
}
QPoint GameObjectUi::getPosition() {
	int width;
	int rootheight = tbl->rootHeight();
	qDebug() << "root height" << rootheight;
	if ( (x > 1) && (y > 1) && (keyside == Left) ) {
		return QPoint(x,y);
	} else {
		switch (keyside) {
		case Left:
		default:
			return QPoint(tbl->width() * x, (rootheight * y) - tbl->yoffset);
		case Right:
			width = tbl->width() * w;
			return QPoint((tbl->width() * x) - width, (rootheight * y) - tbl->yoffset);
		case Top:
			width = tbl->width() * w;
			return QPoint((tbl->width() * x) - (width/2), (rootheight * y) - tbl->yoffset);
		}
	}
}

void GameObjectUi::setSize(float w) {
	this->w = w;
	int new_width = tbl->width() * w;
	resize(new_width,heightForWidth(new_width));
}
int GameObjectUi::heightForWidth( int width ) const {
	Q_ASSERT(pix.height());
	return ((qreal)pix.height()*width)/pix.width();
}
void GameObject::setSide(int side){
	internal->keyside = (AlignmentSide) side;
}
