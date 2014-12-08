#include "table_sit.h"
#include "ui_table_sit.h"
#include "pokermain.h"

TableSit::TableSit(const Data::Game *gamein, int seat, QSharedPointer<Data::TableStatus> ts) :
	ui(new Ui::TableSit), g(gamein),seat(seat)
{
	ui->setupUi(this);
	float buyinmin = GetBuyinMin();
	float buyinmax = GetBuyinMax();
	ui->seBuyin->setValidator(new QDoubleValidator(buyinmin,buyinmax,2));
	ui->lbsTableName->setText(QString("%1 (%2/%3 %4)").arg(g->gamename).arg(g->sb).arg(g->bb).arg(g->typeToLongString()));
	// minbuyin is on tablestatus or game, ts takes priority
	// maxbuyin is based on chips at a seat
	// refer to Poker.Forms.TableSit.pas
	ui->lbsTableBuyins->setText(QString("(min buyin-in %1, max buyin, %2)").arg(buyinmin).arg(buyinmax));
	ui->seBuyin->setText(QString("%1").arg(buyinmax));
	connect(core,SIGNAL(sit_ok(QByteArray)),this,SLOT(sit_ok(QByteArray)));
	connect(core,SIGNAL(seat_taken(QByteArray)),this,SLOT(seat_taken(QByteArray)));
}

TableSit::~TableSit() {
	delete ui;
}

void TableSit::on_btOK_clicked() {
	Poker::TableSit ts;
	ts.set_game_id(g->gameid.data(),g->gameid.length());
	ts.set_chips(ui->seBuyin->text().toFloat()*100);
	ts.set_seat_index(seat);
	core->sendMessage(Poker::scTableSit,&ts);
}
float TableSit::GetBuyinMin() {
	// FIXME, also fetch via PlayerTableStatus
	return g->buyin_min/100;
}
float TableSit::GetBuyinMax() {
	// FIXME also fetch via several means
	return g->buyin_max/100;
}
void TableSit::on_btCancel_clicked() {
	close();
	deleteLater();
}
void TableSit::on_btMin_clicked() {
	ui->seBuyin->setText(QString("%1").arg(GetBuyinMin()));
}
void TableSit::on_btMax_clicked() {
	ui->seBuyin->setText(QString("%1").arg(GetBuyinMax()));
}
void TableSit::on_seBuyin_textEdited() {
	ui->btOK->setEnabled(ui->seBuyin->hasAcceptableInput());
}
void TableSit::sit_ok(QByteArray gameid) {
	if (gameid == g->gameid) {
		close();
		deleteLater();
	}
}
void TableSit::seat_taken(QByteArray gameid) {
	qDebug() << "FIXME, seat taken";
}
