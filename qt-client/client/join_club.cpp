#include "join_club.h"
#include "ui_join_club.h"
#include <poker/message.pb.h>
#include "pokermain.h"

JoinClub::JoinClub(QWidget *parent) : QDialog(parent), ui(new Ui::JoinClub) {
	ui->setupUi(this);
	connect(this,SIGNAL(accepted()),this,SLOT(do_join()));
}

JoinClub::~JoinClub() {
	delete ui;
}
void JoinClub::do_join() {
	Poker::Club club;
	club.set_seq(ui->edClubId->text().toInt());
	club.set_password(qPrintable(ui->edClubPassword->text()));
	core->sendMessage(Poker::scJoinClub,&club);
}
