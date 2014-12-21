#ifndef TABLEINTERNAL_DEALERBUTTON_H
#define TABLEINTERNAL_DEALERBUTTON_H

#include "tableprivate.h"

namespace TableInternal {
class DealerButtonUi;

class DealerButton : public GameObject
{
	Q_OBJECT
public:
	explicit DealerButton(TablePrivate *parent);

signals:

public slots:
private:
		DealerButtonUi *button;
};
class DealerButtonUi : public GameObjectUi {
public:
	DealerButtonUi(TableUi *parent, DealerButton *jsobj);
protected:
	void paintEvent(QPaintEvent *event);
private:
	QPixmap dealer;
	DealerButton *jsobj;
};
} // namespace TableInternal

#endif // TABLEINTERNAL_DEALERBUTTON_H
