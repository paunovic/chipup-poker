#pragma once

#include <QDialog>

#include <poker/message.pb.h>

namespace Ui {
class CreateClub;
}

class CreateClub : public QDialog {
Q_OBJECT
public:
	CreateClub(QWidget *parent=0);
	~CreateClub();
private slots:
    void on_btOk_clicked();
    void on_btCancel_clicked();
    void On_club_create_reply(Poker::ClubCommandReply::ClubStatus status);

private:
	Ui::CreateClub *ui;
};
