#ifndef DATA_TABLELAYOUT_H
#define DATA_TABLELAYOUT_H

#include <QLayout>
#include <QLayoutItem>

class GameObjectUi;
class TableUi;

namespace TableInternal {

class TableLayout : public QLayout
{
	Q_OBJECT
public:
	explicit TableLayout(TableUi *parent = 0);
	void activate();
	QSize sizeHint() const;
	void addItem(QLayoutItem *);
	QLayoutItem *itemAt(int index) const;
	QLayoutItem *takeAt(int index);
	int count() const;
	void addElement(GameObjectUi *element);

signals:

public slots:
private slots:
	void element_deleted(QObject *element);
private:
	TableUi *uiparent;
	QList<GameObjectUi*> uiElements;
};

} // namespace Data

#endif // DATA_TABLELAYOUT_H
