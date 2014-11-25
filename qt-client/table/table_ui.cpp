#include <QPainter>

#include "tableprivate.h"

TableUi::TableUi(QWidget *parent) : QWidget(parent) {
	qDebug() << __func__;
	pix = QPixmap(":/resources/table/Table.png");
}
void TableUi::resizeEvent(QResizeEvent *) {
	for (int i=0; i<uiElements.length(); i++) {
		GameObjectUi *el = uiElements.at(i);
		int new_width = width()*el->w;
		el->setGeometry(width() * el->x,height()*el->y, new_width,el->heightForWidth(new_width));
	}
	QSizePolicy qsp(QSizePolicy::Preferred,QSizePolicy::Preferred);
	qsp.setHeightForWidth(true);
	setSizePolicy(qsp);
}
void TableUi::paintEvent(QPaintEvent *) {
	QPainter painter(this);
	//painter.setPen(Qt::NoPen);
	//painter.setBrush(QColor(0,127,0));
	painter.setPen(QColor(255,0,0));
	//painter.drawRect(0,0,width(),height());
	QRectF ring(width()*0.08,height()*0.1,width()*0.835,height()*0.67);
	painter.drawPixmap(0,0,width(),height(),pix);
	painter.drawArc(ring,0,5760);
}
void TableUi::addElement(GameObjectUi *element) {
	uiElements.append(element);
	connect(element,SIGNAL(destroyed(QObject*)),this,SLOT(element_deleted(QObject*)));
}
void TableUi::element_deleted(QObject *item) {
	qDebug() << "element deleting" << item;
	uiElements.removeOne(static_cast<GameObjectUi*>(item));
}
QSize TableUi::sizeHint() const {
	qDebug() << "table" << __func__;
	return QSize(100,heightForWidth(100));
}
int TableUi::heightForWidth( int width ) const {
	return ((qreal)pix.height()*width)/pix.width();
}
