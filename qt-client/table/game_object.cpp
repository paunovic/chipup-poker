#include "tableprivate.h"

GameObject::GameObject(TablePrivate *) {
}
void GameObject::setPosition(float x, float y) {
	qDebug() << __func__ << x << y;
	internal->moveRatio(x,y);
	internal->show();
}
void GameObject::setSize(float w) {
	internal->setSize(w);
}
GameObjectUi::GameObjectUi(TableUi *parent) : QWidget(parent), tbl(parent) {
}
QSize GameObjectUi::sizeHint() const {
	qDebug() << "gameobject resize" << __func__;
	int new_width = tbl->width() * w;
	return QSize(new_width,heightForWidth(new_width));
}
void GameObjectUi::moveRatio(float x, float y) {
	this->x = x;
	this->y = y;
	move(tbl->width() * x, tbl->height() * y);
}
void GameObjectUi::setSize(float w) {
	qDebug() << "updating object size" << w;
	this->w = w;
	int new_width = tbl->width() * w;
	resize(new_width,heightForWidth(new_width));
}
int GameObjectUi::heightForWidth( int width ) const {
	return ((qreal)pix.height()*width)/pix.width();
}
