#ifndef CLUBLOBBY_H
#define CLUBLOBBY_H

#include <QMainWindow>

#include "club.h"

class QItemSelectionModel;
class QItemSelection;

namespace Ui {
class ClubLobby;
}

class ClubLobby : public QMainWindow
{
	Q_OBJECT

public:
	explicit ClubLobby(QWidget *parent = 0);
	~ClubLobby();
	void setClub(Data::Club *club);
public slots:
	void on_btClubHome_clicked();
	void on_btStats_clicked();
	void on_btTables_clicked();
	void on_btSuspend_clicked();
	void on_btMute_clicked();
	void on_btRemove_clicked();
	void On_club_changed(const Data::Club *club);
	void On_clubLeft(const Data::Club *club);
	void user_selected(const QItemSelection&selected, const QItemSelection&);
private slots:
	void on_btLeaveClub_clicked();

private:
	void refreshSelection();

	Ui::ClubLobby *ui;
	const Data::Club *club;
	QItemSelectionModel *selection_model;
	const Data::ClubMember *currentMember;
};

#endif // CLUBLOBBY_H
