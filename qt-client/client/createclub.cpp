#include <QMessageBox>

#include "createclub.h"
#include "ui_createclub.h"
#include "pokermain.h"

CreateClub::CreateClub(QWidget *parent) : QDialog(parent), ui(new Ui::CreateClub) {
	ui->setupUi(this);
	core->RegisterListener(this);
}

void CreateClub::on_btOk_clicked() {
	Poker::Club club;
	club.set_name(qPrintable(ui->edClubName->text()));
	club.set_rake(5);
	club.set_password(qPrintable(ui->edClubPassword->text()));
	club.set_buyin_reset(30);
	core->sendMessage(Poker::scCreateClub,&club);
}
void CreateClub::on_btCancel_clicked() {
    this->done(0);
}

CreateClub::~CreateClub() {
	delete ui;
}
void CreateClub::On_club_create_reply(Poker::ClubCommandReply::ClubStatus status) {
    QMessageBox alert;
    switch (status) {
    case Poker::ClubCommandReply::csSuccess:
        done(0);
        break;
    case Poker::ClubCommandReply::csInvalidName:
        alert.setText(tr("Invalid club name"));
        alert.show();
        break;
    default:
        qDebug() << "unhandled create status" << status;
    }
}
