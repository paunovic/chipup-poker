#include <QPainter>

#include "tableprivate.h"

TableUi::TableUi(QWidget *parent) : QWidget(parent) {
	pix = QPixmap(":/resources/table/Table.png");
	qDebug() << "layout was" << layout();
	mylayout = new TableInternal::TableLayout(this);
	setLayout(mylayout);
	qDebug() << "now" << layout();
}
void TableUi::resizeEvent(QResizeEvent *) {
	qDebug() << "tableui resize";
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


QSize TableUi::sizeHint() const {
	return QSize(300,200);
}
/*int TableUi::heightForWidth( int width ) const {
	return ((qreal)pix.height()*width)/pix.width();
}*/
