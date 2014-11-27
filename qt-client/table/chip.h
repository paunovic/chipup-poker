#ifndef CHIP_H
#define CHIP_H

#include "tableprivate.h"

class ChipObjectUi : public GameObjectUi {
Q_OBJECT
public:
	ChipObjectUi(QWidget *parent);
};

class ChipObject : public GameObject {
Q_OBJECT
public:
	ChipObject(TablePrivate *);
private:
	ChipObjectUi *chips;
};

#endif // CHIP_H
