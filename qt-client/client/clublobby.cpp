#include "clublobby.h"
#include "ui_clublobby.h"

ClubLobby::ClubLobby(QWidget *parent) :
	QMainWindow(parent),
	ui(new Ui::ClubLobby)
{
	ui->setupUi(this);
}

ClubLobby::~ClubLobby()
{
	delete ui;
}

void ClubLobby::setClub(const Data::Club *club) {
	this->club = club;
}
