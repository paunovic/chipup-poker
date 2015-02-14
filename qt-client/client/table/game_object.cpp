#include <QPainter>

#include "tableprivate.h"

GameObject::GameObject(TablePrivate *table) {
	this->table = table;
}
void GameObject::setPosition(float x, float y) {
	Q_ASSERT(x >= 0);
	Q_ASSERT(y >= 0);
	internal->moveRatio(x,y);
	internal->show();
}
void GameObject::setSize(float w) {
	Q_ASSERT(internal);
	internal->setSize(w);
}
GameObjectUi::GameObjectUi(TableUi *parent) : QWidget(parent), tbl(parent) {
	keyside = Left;
	x = y = 0;
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
QPoint GameObjectUi::getPosition() const {
	int width;
	int rootheight = tbl->rootHeight();
	//qDebug() << "root height" << rootheight << x << y << tbl->yoffset;
	if ( (x > 1) && (y > 1) && (keyside == Left) ) {
		return QPoint(x,y); // FIXME, remove this mode
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
		case Bottom:
			width = tbl->width() * w;
			QSize size = sizeHint();
			QPoint ret((tbl->width() * x) - (width/2),( (rootheight * y) - tbl->yoffset ) - size.height());
			qDebug() << "chip" << ret;
			return ret;
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
float GameObjectUi::getRenderHeight() const {
	return ((float)pix.height()*w)/pix.width();
}
float GameObject::getRenderHeight() const {
	return internal->getRenderHeight();
}

void GameObject::setSide(int side){
	qDebug() << "chip" << internal << side;
	internal->keyside = (AlignmentSide) side;
	internal->updateGeometry();
}
void GameObjectUi::drawDebug(QPainter &p) {
	switch (keyside) {
	case Top:
		p.setBrush(QColor(255,0,0));
		break;
	case Bottom:
		p.setBrush(QColor(0,255,0));
		break;
	case Left:
		p.setBrush(QColor(0,0,255));
		break;
	case Right:
		p.setBrush(QColor(255,255,0));
		break;
	case Center:
		p.setBrush(QColor(255,255,255));
		break;
	}
	p.setPen(Qt::NoPen);
	p.drawRect(0,0,width(),height());
}
