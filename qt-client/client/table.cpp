#include <QDebug>
#include <QFile>

#include "table.h"
#include "ui_table.h"
#include "tableprivate.h"
#include "game.h"
#include "pokermain.h"
#include "jseditor.h"
#include "data/seatinfo.h"
#include "table/table_sit.h"

Table::Table(QWidget *parent) :
	QMainWindow(parent),
	ui(new Ui::Table)
{
	ui->setupUi(this);
	p = new TablePrivate;
	p->setupUi(ui->centerWrap,ui->center,this);
	core->RegisterListener(this);
#ifdef JSDEBUG
	debuger = new JsEditor(this);
	debuger->show();
#endif
	ui->statusbar->setVisible(false);
	ui->btLeaveWaitingList->setVisible(false);
	ui->btJoinWaitingList->setVisible(false);
}
Table::~Table() {
	delete ui;
	delete p;
}
void Table::clearCheckBoxes() {
	ui->cbAutoCall->setChecked(false);
	ui->cbAutoCallAny->setChecked(false);
	ui->cbAutoCheck->setChecked(false);
	ui->cbAutoCheckFold->setChecked(false);
}
bool Table::autoCall() { return ui->cbAutoCall->isChecked(); }
bool Table::autoCallAny() { return ui->cbAutoCallAny->isChecked(); }
bool Table::autoCheck() { return ui->cbAutoCheck->isChecked(); }
bool Table::autoCheckFold() { return ui->cbAutoCheckFold->isChecked(); }

bool Table::event(QEvent *event) {
	if (event->type() == QEvent::Close) {
		Poker::Game g;
		g.set__id(game->gameid.data(),game->gameid.length());
		core->sendMessage(Poker::scTableLeave,&g);
		deleteLater();
	}
	return QMainWindow::event(event);
}
void Table::On_reserved_seat_free(QByteArray gameid, quint32 seat_index) {
	if (gameid != game->gameid) return;
	qDebug() << "my turn to sit in seat" << seat_index;
	sitwindow = new TableSit(game,seat_index,lastTableStatus);
	sitwindow->show();
}
int Table::findMySeatIndex() {
	QList<Data::SeatInfo*>::Iterator i;
	Data::SeatInfo *seat = 0;
	for (i=lastTableStatus->seats.begin(); i!=lastTableStatus->seats.end(); ++i) {
		seat = *i;
		if (seat->getUserid() == core->self()->id) {
			return seat->seat_index;
		}
	}
	return -1;
}

bool Table::On_table_status(QSharedPointer<Data::TableStatus> ts) {
	if (ts->gameid != game->gameid) return false;
	lastTableStatus = ts;
	qDebug() << QString("Table::on_table_status minbet:%1 maxbet:%2").arg(ts->minimumBet()).arg(ts->maximum_raise);
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
	// TODO, handle more of this in JS
	ui->btStandUp->setVisible(self_found);
	if (!self_found) { // not sitting, cant play now
		ui->btPlayNow->setVisible(false);
		ui->btDouble->setVisible(false);
		ui->cbSitOutBB->setVisible(false);
		ui->btSitOut->setVisible(false);
		ui->cbFoldAny->setVisible(false);
		ui->btLeaveWaitingList->setVisible(false);
		if ((ts->table_type == Poker::TableStatus::ttLive) &&
				(game->seats == ts->seats.length()) &&
				 (ts->queue_position == 0)) {
			ui->btJoinWaitingList->setVisible(true);
		} else ui->btJoinWaitingList->setVisible(false);
		ui->stackedWidget->setCurrentIndex(0);
	} else { // sitting, play now may be needed
		switch (seat->rawStatus()) {
		case Poker::SeatInfo::psOutOfHand:
			ui->btDouble->setVisible(true);
			ui->cbSitOutBB->setVisible(true);
			ui->btSitOut->setVisible(true);
			ui->cbFoldAny->setVisible(true);
			ui->cbFoldAny->setEnabled(false);
			ui->btPlayNow->setVisible(false);
			break;
		case Poker::SeatInfo::psOutOfPlay:
			ui->btPlayNow->setVisible(true);
			ui->stackedWidget->setCurrentIndex(0);
			break;
		case Poker::SeatInfo::psInHand:
			qDebug() << QString("i am in hand, current seat:%1, myself:%2, minbet:%3, mybet:%4").arg(ts->current_seat).arg(seat->seat_index).arg(ts->minimumBet()).arg(ts->bets()[seat->seat_index]);
			if (ts->current_seat == seat->seat_index) {
				qDebug() << "stack change";
				ui->stackedWidget->setCurrentIndex(1);
				if (ts->minimumBet() == ts->bets()[seat->seat_index]) {
					ui->btCheck->setText(tr("CHECK"));
				} else {
					ui->btCheck->setText(tr("CALL (%1)").arg((ts->minimumBet() - ts->bets()[seat->seat_index])/100));
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
bool Table::canCheck() {
	Data::SeatInfo *seat = p->findMySeat();
	if (!seat) return false;
	return lastTableStatus->minimumBet() == lastTableStatus->bets()[seat->seat_index];
}
bool Table::canFold() {
	Data::SeatInfo *seat = p->findMySeat();
	if (!seat) return false;
	return true; // FIXME?
}

void Table::on_btMin_clicked() {
	ui->raiseSlider->setValue(lastTableStatus->minimum_raise);
}
void Table::on_btMax_clicked() {
	ui->raiseSlider->setValue(lastTableStatus->maximum_raise);
}
void Table::renderWinning(QString msg) {
	ui->teChat->append(QString("<font color='#00ff00'>Dealer:</font> <font color='#a8ff99'>%1</font>").arg(msg));
}
void Table::on_btCheck_clicked() {
	Poker::PutChips pc;
	pc.set_table_mongo_id(game->gameid.data(),game->gameid.length());
	pc.set_current_state(lastTableStatus->state());
	pc.set_chip_amount(lastTableStatus->minimumBet());
	core->sendMessage(Poker::scPutChips,&pc);
}
void Table::setGame(const Data::Game *game, const Data::Club *club) {
	this->game = game;
	p->setGame(game);
	setWindowTitle(QString(tr("%1 (%2/%3 %4) - %5")).arg(game->gamename).arg(game->sb).arg(game->bb).arg(game->typeToString()).arg(club->name));
#if 0
	QFile input("/home/clever/apps/poker/qt-client/client/table.js");
	if (!input.open(QIODevice::ReadOnly | QIODevice::Text)) {
		qDebug() << "failed to load js";
	} else {
		QTextStream stream(&input);
		QString code = stream.readAll();
		input.close();
		p->loadJs(code,"table.js");
	}
#else
	p->loadJsFromResource();
#endif
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
#if 0
	int page = message.toInt();
	ui->stackedWidget->setCurrentIndex(page);
#elif 0
	ui->teChat->append(p->eval(message).toString());
	QGridLayout *layout = ui->center;
	qDebug() << layout->cellRect(0,0);
	qDebug() << layout->cellRect(1,0);
#else
	Poker::ChatEvent ce;
	ce.set_event(Poker::ChatEvent::ceUserMessage);
	ce.set_table_id(game->gameid.data(),game->gameid.length());
	Poker::ChatMessage *cm = new Poker::ChatMessage;
	cm->set_msg(qPrintable(message));
	ce.set_allocated_msg(cm); // takes ownership
	core->sendMessage(Poker::seChat,&ce);
#endif
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

	ui->btSitOut->setChecked(false);
	ui->cbSitOutBB->setChecked(false);
}
void Table::on_btFold_clicked() {
	if (canCheck() && core->config().value("table/autoCheckFold").toBool()) {
		Poker::PutChips pc;
		pc.set_table_mongo_id(game->gameid.data(),game->gameid.length());
		pc.set_current_state(lastTableStatus->state());
		pc.set_chip_amount(lastTableStatus->minimumBet());
		core->sendMessage(Poker::scPutChips,&pc);
	} else {
		Poker::Game g;
		g.set__id(game->gameid.data(),game->gameid.length());
		core->sendMessage(Poker::scFold,&g);
	}
}
void Table::on_raiseSlider_valueChanged(int value) {
	ui->lbRaiseAmount->setText(QString("%1").arg((float)value/100));
	ui->btRaise->setText(QString("BET (%1)").arg((float)value/100));
}
void Table::on_bt3BB_clicked() {
	int val = lastTableStatus->minimumBet();
	qDebug() << "3bb min bet" << val;
	if (val == 0) val = game->bb;
	qDebug() << "3bb final" << val;
	ui->lbRaiseAmount->setText(QString("%1").arg((float)val/100));
	ui->btRaise->setText(QString("BET (%1)").arg((float)val/100));
	ui->raiseSlider->setValue(val);
}
void Table::on_btPot_clicked() {
	int raise_value;
	int seat_bet = -1;
	QList<Data::SeatInfo*>::Iterator i;
	Data::SeatInfo *seat;
	for (i=lastTableStatus->seats.begin(); i!=lastTableStatus->seats.end(); ++i) {
		seat = *i;
		if (seat->getUserid() == core->self()->id) {
			seat_bet = lastTableStatus->bets()[seat->seat_index];
		}
	}
	raise_value = lastTableStatus->minimumBet() - seat_bet;

	QList<Data::Pot*>::Iterator i2;
	for (i2=lastTableStatus->pots.begin(); i2!=lastTableStatus->pots.end(); ++i2) {
		Data::Pot *pot = *i2;
		raise_value += pot->value() - pot->rake();
	}
	for (int x=0; x<lastTableStatus->bets().length(); x++) {
		raise_value += lastTableStatus->bets()[x];
	}
	raise_value += lastTableStatus->minimumBet();
	ui->lbRaiseAmount->setText(QString("%1").arg((float)raise_value/100));
	ui->btRaise->setText(QString("BET (%1)").arg((float)raise_value/100));
	ui->raiseSlider->setValue(raise_value);
}
void Table::on_btRaise_clicked() {
	Poker::PutChips pc;
	pc.set_table_mongo_id(game->gameid.data(),game->gameid.length());
	pc.set_current_state(lastTableStatus->state());
	pc.set_chip_amount(ui->raiseSlider->value());
	core->sendMessage(Poker::scPutChips,&pc);
}
void Table::eval(QString code) {
	p->eval(code);
}
void Table::on_btSitOut_stateChanged(int state) {
	qDebug() << "on_btSitOut_stateChanged" << state;
	Poker::TableBoolFlag tbf;
	tbf.set_table_mongo_id(game->gameid.data(),game->gameid.length());
	tbf.set_flag(state);
	core->sendMessage(Poker::scTableSitOutNextHand,&tbf);
}
void Table::on_cbSitOutBB_stateChanged(int state) {
	qDebug() << "on_cbSitOutBB_stateChanged" << state;
	Poker::TableBoolFlag tbf;
	tbf.set_table_mongo_id(game->gameid.data(),game->gameid.length());
	tbf.set_flag(state);
	core->sendMessage(Poker::scTableSitOutNextBB,&tbf);
}
void Table::on_btDouble_stateChanged(int state) {
	qDebug() << "on_btDouble_stateChanged" << state;
	Poker::TableBoolFlag tbf;
	tbf.set_table_mongo_id(game->gameid.data(),game->gameid.length());
	tbf.set_flag(state);
	core->sendMessage(Poker::scSplitTableCards,&tbf);
}

void Table::On_sit_ok(QByteArray gameid) {
	if (gameid != game->gameid) return;
}
void Table::on_btJoinWaitingList_clicked() {
	Poker::TableSit ts;
	ts.set_game_id(game->gameid.data(),game->gameid.length());
	ts.set_chips(0);
	ts.set_seat_index(-1);
	core->sendMessage(Poker::scTableSit,&ts);
}
void Table::On_chat_event(Data::Chat event) {
	if (event.event != Poker::ChatEvent::ceUserMessage) return;
	if (event.table_id != game->gameid) return;
	QString color = "#c0c0c0";
	if (event.username == core->self()->displayName()) color = "#46a3ff";
	ui->teChat->append(QString("<font color='#e1e1e1'>%1:</font> <font color='%2'>%3</font>").arg(event.username).arg(color).arg(event.msg));
}
QSize Table::sizeHint() const {
	qDebug() << ui->horizontalLayout_2->sizeHint();
	qDebug() << ui->center->sizeHint();
	qDebug() << ui->horizontalLayout->sizeHint();
	return QMainWindow::sizeHint();
}
void Table::resizeEvent(QResizeEvent *event) {
	QMainWindow::resizeEvent(event);
	qDebug() << ui->horizontalLayout_2->sizeHint() << ui->center->sizeHint() << ui->horizontalLayout->sizeHint();
	qDebug() << minimumSize() << maximumSize();
	qDebug() << isMaximized();
#ifndef Q_OS_MAC
	setMaximumHeight(minimumHeight());
#endif
}
bool Table::AutoFoldVisible() { return _AutoFoldVisible; }
void Table::SetAutoFoldVisible(bool in) {
	_AutoFoldVisible = in;

	ui->cbAutoCheckFold->setVisible(_AutoFoldVisible || _AutoCheckFoldVisible);

	if (_AutoFoldVisible) ui->cbAutoCheckFold->setText(tr("Fold"));
	else ui->cbAutoCheckFold->setText(tr("Check/Fold"));
}
void Table::SetAutoCheckFoldVisible(bool in) {
	_AutoCheckFoldVisible = in;

	ui->cbAutoCheckFold->setVisible(_AutoFoldVisible || _AutoCheckFoldVisible);

	if (_AutoFoldVisible) ui->cbAutoCheckFold->setText(tr("Fold"));
	else ui->cbAutoCheckFold->setText(tr("Check/Fold"));
}
void Table::SetAutoCallVisible(bool in) {
	_AutoCallVisible = in;

	ui->cbAutoCall->setVisible(_AutoCallVisible);
}
void Table::on_cbAutoCall_stateChanged(int state) {
	ui->cbAutoCallAny->setChecked(false);
	ui->cbAutoCheck->setChecked(false);
	ui->cbAutoCheckFold->setChecked(false);
}
void Table::on_cbAutoCallAny_stateChanged(int state) {
	ui->cbAutoCall->setChecked(false);
	ui->cbAutoCheck->setChecked(false);
	ui->cbAutoCheckFold->setChecked(false);
}
void Table::on_cbAutoCheck_stateChanged(int state) {
	ui->cbAutoCallAny->setChecked(false);
	ui->cbAutoCheck->setChecked(false);
	ui->cbAutoCheckFold->setChecked(false);
}
void Table::on_cbAutoCheckFold_stateChanged(int state) {
	ui->cbAutoCallAny->setChecked(false);
	ui->cbAutoCheck->setChecked(false);
	ui->cbAutoCheckFold->setChecked(false);
}
void Table::tryAutoAction() {
	Data::SeatInfo *my_seat = p->findMySeat();
	if (!my_seat) return;
	if (lastTableStatus->current_seat != my_seat->seat_index) return;
	int mybet = lastTableStatus->bets().at(my_seat->seat_index);
	if (ui->cbAutoCheckFold->isChecked()) {
		if (_AutoFoldVisible) {
			if (lastTableStatus->minimumBet() > mybet) {
				on_btFold_clicked();
			} else if (lastTableStatus->minimumBet() == mybet) {
				on_btCheck_clicked();
			}
		} else if (lastTableStatus->minimumBet() == mybet) on_btCheck_clicked();
	} else if (ui->cbAutoCall->isChecked()) {
		on_btCheck_clicked();
	} else if (ui->cbAutoCheck->isChecked()) {
		if (lastTableStatus->minimumBet() == mybet) on_btCheck_clicked();
	} else if (ui->cbAutoCallAny->isChecked()) {
		on_btCheck_clicked();
	}
}
QScriptValue Table::global() {
	return p->global();
}
void Table::hideAllControls() {
	ui->stackedWidget->setCurrentIndex(0);
}
