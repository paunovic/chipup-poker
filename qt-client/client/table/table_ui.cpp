#include <QPainter>
#include <QEvent>

#include "tableprivate.h"

TableUi::TableUi(QWidget *parent) : QWidget(parent) {
	pix = QPixmap(":/resources/table/Table.png");
	yoffset = 0;
	int em = fontMetrics().boundingRect("M").width();
	setMinimumSize(85*em,41*em);
}
void TableUi::resizeEvent(QResizeEvent *) {
	int em = fontMetrics().boundingRect("M").width();
	qDebug() << "tableui size" << size() << (size()/em);

	float h = rootHeight();
	yoffset = h * 0.1;

	for (int i=0; i<uiElements.length(); i++) {
		GameObjectUi *el = uiElements.at(i);
		//qDebug() << "layout out" << el << el->x << el->y << el->w << (int)el->keyside;
		//int new_width = width() * el->w;
		QPoint pos = el->getPosition();
		QSize size = el->sizeHint();
		el->setGeometry(pos.x(),pos.y(), size.width(),size.height());
	}
	QSizePolicy qsp(QSizePolicy::Preferred,QSizePolicy::Preferred);
	qsp.setHeightForWidth(true);
	setSizePolicy(qsp);
	setMinimumHeight(((qreal)(41*em)*width())/(85*em));
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
	painter.drawPixmap(0.095*width(),0,w,h,pix);
	painter.restore();
	//painter.drawEllipse(ring);
	//drawGrid(painter);
}
void TableUi::drawCross(QPainter &p) {
	int w = width();
	int h = ((float)pix.height() * width()) / pix.width();
	p.drawLine(0,(h/2)-yoffset,w,(h/2)-yoffset);
	p.drawLine(w/2,0,w/2,h);
}
void TableUi::drawGrid(QPainter &p) {
	for (int x=0; x<101; x=x+10) {
		float x1 = ((float)x/100)*width();
		p.drawLine(x1,0,x1,height());

		float y1 = ((float)x/100)*rootHeight();
		p.drawLine(0,y1,width(),y1);
	}
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
bool TableUi::event(QEvent *event) {
	if (event->type() == QEvent::LayoutRequest) {
		resizeEvent(NULL);
		return true;
	} else {
		return QWidget::event(event);
	}
}
/*int TableUi::heightForWidth( int width ) const {
	return ((qreal)pix.height()*width)/pix.width();
}*/
