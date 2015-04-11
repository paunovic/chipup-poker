#ifndef CHIP_H
#define CHIP_H

#include <QFontMetrics>

#include "tableprivate.h"

class ChipObject;

class ChipObjectUi : public GameObjectUi {
Q_OBJECT
public:
	ChipObjectUi(TableUi *parent, ChipObject *jsobj);
	void updateValue();
	QSize sizeHint() const;
protected:
	void paintEvent(QPaintEvent *);
	virtual void resizeEvent(QResizeEvent *event);
private:
	ChipObject *jsobj;
	QPixmap c1,c5,c25,c100,c500,c1000,offscreenbuffer;
	QList<QPixmap> chips;
	QFont font;
	QFontMetrics *fm;
	QString text;
	QRect textRegion;
	QSize sizeHintInternal;
	bool redraw;
};

class ChipObject : public GameObject {
Q_OBJECT
public:
	ChipObject(TablePrivate *);
	int value() { return value_; }
	void setValue(int in) { value_ = in; chips->updateValue(); }
	bool visible() { return chips->isVisible(); }
	void setVisible(bool in);
	bool rake() { return rake_; }
	void setRake(bool in) { rake_ = in; chips->updateValue(); }

	Q_PROPERTY(int value READ value WRITE setValue)
	Q_PROPERTY(bool visible READ visible WRITE setVisible)
	Q_PROPERTY(bool rake READ rake WRITE setRake)
private:
	ChipObjectUi *chips;
	int value_;
	bool rake_;
};

#endif // CHIP_H
