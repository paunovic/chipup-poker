#ifndef JOINTABLE_H
#define JOINTABLE_H

#include <QWidget>

#include "game.h"

namespace Ui {
class TableSit;
}

class TableSit : public QWidget
{
	Q_OBJECT

public:
	explicit TableSit(const Data::Game *gamein);
	~TableSit();

private:
	Ui::TableSit *ui;
	const Data::Game *g;
};

#endif // JOINTABLE_H
