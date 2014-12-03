#include "table_sit.h"
#include "ui_table_sit.h"

TableSit::TableSit(const Data::Game *gamein) :
	ui(new Ui::TableSit), g(gamein)
{
	ui->setupUi(this);
	ui->lbsTableName->setText("test");
	ui->lbsTableName->setText(QString("%1 (%2/%3 %4)").arg(g->gamename).arg(g->sb).arg(g->bb).arg(g->typeToString()));
	// minbuyin is on tablestatus or game, ts takes priority
	// maxbuyin is based on chips at a seat
	// refer to Poker.Forms.TableSit.pas
	ui->lbsTableBuyins->setText(QString("(min buyin-in %1, max buyin, %2)")); // TODO
}

TableSit::~TableSit()
{
	delete ui;
}
