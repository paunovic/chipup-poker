#include "createclub.h"
#include "ui_createclub.h"
#include "cpp/message.pb.h"
#include "pokermain.h"

CreateClub::CreateClub(QWidget *parent) : QDialog(parent), ui(new Ui::CreateClub) {
	ui->setupUi(this);
	connect(this,SIGNAL(accepted()),this,SLOT(do_create()));
}

void CreateClub::do_create() {
	Poker::Club club;
	club.set_name(qPrintable(ui->edClubName->text()));
	club.set_rake(5);
	club.set_password(qPrintable(ui->edClubPassword->text()));
	club.set_buyin_reset(30);
	PokerMain *core = PokerMain::getInstance();
	core->sendMessage(Poker::scCreateClub,&club);
}
CreateClub::~CreateClub() {
	delete ui;
}
