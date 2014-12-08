#ifndef JOINTABLE_H
#define JOINTABLE_H

#include <QWidget>

#include "game.h"
#include "tablestatus.h"

namespace Ui {
class TableSit;
}

class TableSit : public QWidget
{
	Q_OBJECT

public:
	explicit TableSit(const Data::Game *gamein, int seat, QSharedPointer<Data::TableStatus> ts);
	~TableSit();

private slots:
	void on_btOK_clicked();
	void on_btMin_clicked();
	void on_btMax_clicked();
	void on_btCancel_clicked();
	void on_seBuyin_textEdited();
	void sit_ok(QByteArray gameid);
	void seat_taken(QByteArray gameid);
private:
	float GetBuyinMin();
	float GetBuyinMax();

	Ui::TableSit *ui;
	const Data::Game *g;
	int seat;
};

#endif // JOINTABLE_H
