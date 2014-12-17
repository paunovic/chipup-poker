#include <QDebug>
#include <QFile>

#include "table.h"
#include "ui_table.h"
#include "tableprivate.h"
#include "game.h"
#include "pokermain.h"
#include "jseditor.h"
#include "data/seatinfo.h"

Table::Table(QWidget *parent) :
	QMainWindow(parent),
	ui(new Ui::Table)
{
	ui->setupUi(this);
	p = new TablePrivate;
	p->setupUi(ui->centerWrap,ui->center);
	core->RegisterListener(this);
#ifdef JSDEBUG
	debuger = new JsEditor(this);
	debuger->show();
#endif
}

Table::~Table() {
	delete ui;
	delete p;
}
bool Table::event(QEvent *event) {
	if (event->type() == QEvent::Close) {
		Poker::Game g;
		g.set__id(game->gameid.data(),game->gameid.length());
		core->sendMessage(Poker::scTableLeave,&g);
		deleteLater();
	}
	return QMainWindow::event(event);
}
bool Table::On_table_status(QSharedPointer<Data::TableStatus> ts) {
	lastTableStatus = ts;
	qDebug() << QString("minbet:%1 maxbet:%2").arg(ts->minimum_bet).arg(ts->maximum_raise);
	bool result = p->table_status(ts);
	QList<Data::SeatInfo*>::Iterator i;
	bool self_found = false;
	Data::SeatInfo *seat = 0;
	for (i=ts->seats.begin(); i!=ts->seats.end(); ++i) {
		seat = *i;
		if (seat->getUserid() == core->self()->id) {
			self_found = true;
			break;
		}
	}
	ui->btStandUp->setVisible(self_found);
	if (!self_found) { // not sitting, cant play now
		ui->btPlayNow->setVisible(false);
		ui->btDouble->setVisible(false);
		ui->cbSitOutBB->setVisible(false);
		ui->btSitOut->setVisible(false);
		ui->cbFoldAny->setVisible(false);
		ui->stackedWidget->setCurrentIndex(0);
	} else { // sitting, play now may be needed
		switch (seat->rawStatus()) {
		case Poker::SeatInfo::psOutOfHand:
			ui->btDouble->setVisible(true);
			ui->cbSitOutBB->setVisible(true);
			ui->btSitOut->setVisible(true);
			ui->cbFoldAny->setVisible(true);
			ui->btPlayNow->setVisible(false);
			break;
		case Poker::SeatInfo::psOutOfPlay:
			ui->btPlayNow->setVisible(true);
			ui->stackedWidget->setCurrentIndex(0);
			break;
		case Poker::SeatInfo::psInHand:
			qDebug() << QString("i am in hand, current seat:%1, myself:%2, minbet:%3, mybet:%4").arg(ts->current_seat).arg(seat->seat_index).arg(ts->minimum_bet).arg(ts->bets()[seat->seat_index]);
			if (ts->current_seat == seat->seat_index) {
				qDebug() << "stack change";
				ui->stackedWidget->setCurrentIndex(1);
				if (ts->minimum_bet == ts->bets()[seat->seat_index]) {
					ui->btCheck->setText(tr("CHECK"));
				} else {
					ui->btCheck->setText(tr("CALL (%1)").arg((ts->minimum_bet - ts->bets()[seat->seat_index])/100));
				}
				ui->raiseSlider->setMinimum(ts->minimum_raise);
				ui->raiseSlider->setMaximum(ts->maximum_raise);
				ui->raiseSlider->setValue(ts->minimum_raise);
			} else {
				ui->stackedWidget->setCurrentIndex(2);
			}
			break;
		}
	}
	return result;
}
void Table::on_btMin_clicked() {
	ui->raiseSlider->setValue(lastTableStatus->minimum_raise);
}
void Table::on_btMax_clicked() {
	ui->raiseSlider->setValue(lastTableStatus->maximum_raise);
}

void Table::on_btCheck_clicked() {
	Poker::PutChips pc;
	pc.set_table_mongo_id(game->gameid.data(),game->gameid.length());
	pc.set_current_state(lastTableStatus->state());
	pc.set_chip_amount(lastTableStatus->minimum_bet);
	core->sendMessage(Poker::scPutChips,&pc);
}
void Table::setGame(const Data::Game *game, const Data::Club *club) {
	this->game = game;
	p->setGame(game);
	setWindowTitle(QString(tr("%1 (%2/%3 %4) - %5")).arg(game->gamename).arg(game->sb).arg(game->bb).arg(game->typeToString()).arg(club->name));
	p->loadJsFromResource();
}
bool Table::setGameForTesting(const Data::Game *game, QString jscode) {
	this->game = game;
	p->setGame(game);
	return p->loadJs(jscode,"table.js");
}
void Table::on_actionReload_triggered() {
	QFile input("table.js");
	if (!input.open(QIODevice::ReadOnly | QIODevice::Text)) {
		qDebug() << "failed to load js";
	} else {
		QTextStream stream(&input);
		QString code = stream.readAll();
		input.close();
		p->loadJs(code,"table.js");
	}
}
void Table::on_teChatInput_returnPressed() {
	QString message = ui->teChatInput->text();
	ui->teChatInput->setText("");
	ui->teChat->append(p->eval(message).toString());
	QGridLayout *layout = ui->center;
	qDebug() << layout->cellRect(0,0);
	qDebug() << layout->cellRect(1,0);

}
void Table::resizeEvent(QResizeEvent *event) {
	//qDebug() << height();
	QMainWindow::resizeEvent(event);
}
void Table::editJs(QString newcode) {
	p->editJs(newcode);
}
void Table::on_btStandUp_clicked() {
	Poker::Game g;
	g.set__id(game->gameid.data(),game->gameid.length());
	core->sendMessage(Poker::scTableStandUp,&g);
}
void Table::on_btPlayNow_clicked() {
	Poker::Game g;
	g.set__id(game->gameid.data(),game->gameid.length());
	core->sendMessage(Poker::scTablePlayNow,&g);
}
void Table::on_btFold_clicked() {
	Poker::Game g;
	g.set__id(game->gameid.data(),game->gameid.length());
	core->sendMessage(Poker::scFold,&g);
}
void Table::on_raiseSlider_valueChanged(int value) {
	ui->lbRaiseAmount->setText(QString("%1").arg((float)value/100));
	ui->btRaise->setText(QString("BET (%1)").arg((float)value/100));
}
void Table::on_btRaise_clicked() {
	Poker::PutChips pc;
	pc.set_table_mongo_id(game->gameid.data(),game->gameid.length());
	pc.set_current_state(lastTableStatus->state());
	pc.set_chip_amount(ui->raiseSlider->value());
	core->sendMessage(Poker::scPutChips,&pc);
}
