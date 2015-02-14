#pragma once

#include <QDialog>

namespace Ui {
class JoinClub;
}

class JoinClub : public QDialog {
Q_OBJECT
public:
	JoinClub(QWidget *parent=0);
	~JoinClub();
public slots:
	void do_join();
private:
	Ui::JoinClub *ui;
};
