#ifndef TABLE_H
#define TABLE_H

#include <QMainWindow>

#include "tablestatus.h"

class TablePrivate;

namespace Ui {
class Table;
}
namespace Data {
class Game;
}

class Table : public QMainWindow
{
	Q_OBJECT

public:
	explicit Table(QWidget *parent = 0);
	~Table();
	bool event(QEvent *event);
	void setGame(const Data::Game *game) {
		this->game = game;
	}

private slots:
	void table_status(const Data::TableStatus &ts);
private:
	Ui::Table *ui;
	TablePrivate *p;
	const Data::Game *game;
};

#endif // TABLE_H
