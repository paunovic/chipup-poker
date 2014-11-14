#pragma once

#include <QDialog>

namespace Ui {
class CreateClub;
}

class CreateClub : public QDialog {
Q_OBJECT
public:
	CreateClub(QWidget *parent=0);
	~CreateClub();
private slots:
	void do_create();
private:
	Ui::CreateClub *ui;
};
