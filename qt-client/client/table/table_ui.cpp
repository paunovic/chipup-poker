#include <QPainter>

#include "tableprivate.h"

TableUi::TableUi(QWidget *parent) : QWidget(parent) {
	qDebug() << __func__;
	pix = QPixmap(":/resources/table/Table.png");
}
void TableUi::resizeEvent(QResizeEvent *) {
	float h = rootHeight();
	yoffset = h * 0.14;

	for (int i=0; i<uiElements.length(); i++) {
		GameObjectUi *el = uiElements.at(i);
		//qDebug() << "layout out" << el << el->x << el->y << el->w << (int)el->keyside;
		int new_width = width() * el->w;
		QPoint pos = el->getPosition();
		el->setGeometry(pos.x(),pos.y(), new_width,el->heightForWidth(new_width));
	}
	QSizePolicy qsp(QSizePolicy::Preferred,QSizePolicy::Preferred);
	qsp.setHeightForWidth(true);
	setSizePolicy(qsp);
}
int TableUi::rootHeight() {
	return ((float)pix.height()*width())/pix.width();
}

void TableUi::paintEvent(QPaintEvent *) {
	QPainter painter(this);
	painter.setRenderHint(QPainter::Antialiasing);
	//painter.setPen(Qt::NoPen);
	//painter.setBrush(QColor(0,127,0));
	painter.setPen(QColor(255,0,0));
	//painter.drawRect(0,0,width(),height());
	//QRectF ring(width()*0.08,height()*0.1,width()*0.835,height()*0.67);
	// round part of table should be ~400x200
	//QRectF ring((width()-400)/2,30,400,200);
	painter.save();
	//painter.translate(60,0);
	float scale = 0.81;
	float w = (float)width() * scale;
	float h = (((float)pix.height() * width()) / pix.width()) * scale;
	qDebug() << w << h << width();
	painter.drawPixmap(55,0,w,h,pix);
	painter.restore();
	//painter.drawEllipse(ring);
	drawCross(painter);
}
void TableUi::drawCross(QPainter &p) {
	int w = width();
	int h = ((float)pix.height() * width()) / pix.width();
	p.drawLine(0,(h/2)-yoffset,w,(h/2)-yoffset);
	p.drawLine(w/2,0,w/2,h);
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
	return QSize(300,200);
}
/*int TableUi::heightForWidth( int width ) const {
	return ((qreal)pix.height()*width)/pix.width();
}*/
