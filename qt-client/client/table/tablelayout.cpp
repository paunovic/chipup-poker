#include "tablelayout.h"
#include "tableprivate.h"

namespace TableInternal {

TableLayout::TableLayout(TableUi *parent) :
	QLayout(0), uiparent(parent)
{
}
void TableLayout::activate() {
	qDebug() << "activate";
	float h = uiparent->rootHeight();
	uiparent->yoffset = h * 0.14;

	for (int i=0; i<uiElements.length(); i++) {
		GameObjectUi *el = uiElements.at(i);
		//qDebug() << "layout out" << el << el->x << el->y << el->w << (int)el->keyside;
		//int new_width = width() * el->w;
		QPoint pos = el->getPosition();
		QSize size = el->sizeHint();
		el->setGeometry(pos.x(),pos.y(), size.width(),size.height());
	}
}
void TableLayout::addElement(GameObjectUi *element) {
	qDebug() << "add element" << element;
	uiElements.append(element);
	connect(element,SIGNAL(destroyed(QObject*)),this,SLOT(element_deleted(QObject*)));
	invalidate();
}
void TableLayout::element_deleted(QObject *item) {
	qDebug() << "element deleting" << item;
	uiElements.removeOne(static_cast<GameObjectUi*>(item));
}
void TableLayout::addItem(QLayoutItem *) {
}
QLayoutItem *TableLayout::itemAt(int index) const {
	return NULL;
}
QLayoutItem *TableLayout::takeAt(int index) {
	return NULL;
}
int TableLayout::count() const {
	return uiElements.count();
}
QSize TableLayout::sizeHint() const {
	return uiparent->sizeHint();
}
} // namespace Data
