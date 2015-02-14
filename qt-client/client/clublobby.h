#ifndef CLUBLOBBY_H
#define CLUBLOBBY_H

#include <QMainWindow>

#include "club.h"

namespace Ui {
class ClubLobby;
}

class ClubLobby : public QMainWindow
{
	Q_OBJECT

public:
	explicit ClubLobby(QWidget *parent = 0);
	~ClubLobby();
	void setClub(const Data::Club *club);

private:
	Ui::ClubLobby *ui;
	const Data::Club *club;
};

#endif // CLUBLOBBY_H
