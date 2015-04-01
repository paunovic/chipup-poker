#include <QDesktopWidget>
#include "table_sit.h"
#include "ui_table_sit.h"
#include "pokermain.h"

TableSit::TableSit(const Data::Game *gamein, int seat, QSharedPointer<Data::TableStatus> ts) :
	ui(new Ui::TableSit), g(gamein),seat(seat)
{
	ui->setupUi(this);
	updateLimits();
	ui->lbsTableName->setText(tr("%1 (%2/%3 %4)").arg(g->gamename).arg(g->sb).arg(g->bb).arg(g->typeToLongString()));
	Poker::Game g;
	g.set__id(gamein->gameid.data(),gamein->gameid.length());
	core->sendMessage(Poker::scTableSitOpen,&g);
	core->RegisterListener(this);
	setWindowFlags(windowFlags() & ~Qt::WindowMinMaxButtonsHint);
	setFixedSize(size());
	setWindowFlags(
	#ifdef Q_OS_MAC
		Qt::Popup// This type flag is the second point
	#else
		Qt::Tool |
	#endif
		//Qt::FramelessWindowHint |
		//Qt::WindowSystemMenuHint
		//Qt::WindowStaysOnTopHint |
		//Qt::WindowDoesNotAcceptFocus
	);
	setAttribute(Qt::WA_TranslucentBackground,false);
	setAttribute(Qt::WA_DeleteOnClose,true);
	setGeometry(QStyle::alignedRect(Qt::RightToLeft,Qt::AlignCenter,size(),
									QApplication::desktop()->availableGeometry()));
}
void TableSit::updateLimits() {
	double buyinmin = GetBuyinMin();
	double buyinmax = GetBuyinMax();
	ui->seBuyin->setValidator(new QDoubleValidator(buyinmin,buyinmax,2));
	// minbuyin is on tablestatus or game, ts takes priority
	// maxbuyin is based on chips at a seat
	// refer to Poker.Forms.TableSit.pas
	ui->lbsTableBuyins->setText(tr("(min buyin-in %1, max buyin, %2)").arg(buyinmin).arg(buyinmax));
	ui->seBuyin->setText(QString("%1").arg(buyinmax));
}
TableSit::~TableSit() {
	delete ui;
}
void TableSit::on_btOK_clicked() {
	Poker::TableSit ts;
	int chips = parseValue(ui->seBuyin->text());
	qDebug() << ui->seBuyin->text() << chips;
	ts.set_game_id(g->gameid.data(),g->gameid.length());
	ts.set_chips(chips);
	ts.set_seat_index(seat);
	core->sendMessage(Poker::scTableSit,&ts);
}
double TableSit::GetBuyinMin() {
	// FIXME, also fetch via PlayerTableStatus
	if (lastPcs.buyin_min > 0) return (double)lastPcs.buyin_min / 100;
	return (double)g->buyin_min/100;
}
double TableSit::GetBuyinMax() {
	// FIXME also fetch via several means
	if (lastPcs.buyin_max > 0) return (double)lastPcs.buyin_max/100;
	return (double)g->buyin_max/100;
}
void TableSit::on_btCancel_clicked() {
	Poker::Game g2;
	g2.set__id(g->gameid.data(),g->gameid.length());
	core->sendMessage(Poker::scTableSitClose,&g2);
	close();
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
void TableSit::On_sit_ok(QByteArray gameid) {
	if (gameid == g->gameid) {
		close();
	}
}
void TableSit::On_seat_taken(QByteArray gameid) {
#ifndef Q_OS_WIN
#warning finish this later
#endif
	qDebug() << "FIXME, seat taken" << gameid;
}
void TableSit::On_sit_timeout(QByteArray gameid) {
	if (g->gameid != gameid) return;
	close();
}
void TableSit::On_PlayerClubStatus(Data::PlayerClubStatus &pcs) {
	qDebug() << pcs.buyin_min << pcs.buyin_max;
	lastPcs = pcs;
	updateLimits();
}
