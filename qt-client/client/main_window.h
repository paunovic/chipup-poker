#pragma once

#include <QMainWindow>
#include <QStringListModel>
#include <QHeaderView>

#include "club.h"
#include "game.h"
#include "data/chat.h"

namespace Ui {
class MainWindow;
}

class MainWindow : public QMainWindow {
Q_OBJECT
public:
	MainWindow(QWidget *parent=0);
	~MainWindow();
	bool event(QEvent *event);

private slots:
	void homeGames();
	void tournaments();
	void private_club_selected(const QItemSelection&, const QItemSelection&);
	void public_club_selected(const QItemSelection&, const QItemSelection&);
	void on_btJoinClub_clicked();
	void on_btCreateClub_clicked();
	void on_actionLogout_triggered();
	void on_actionCSS_Editor_triggered();
	void on_actionDisconnect_triggered();
	void on_actionSelf_Tests_triggered();
	void On_secondary_login();
	void On_chat_event(Data::Chat packet);
	void on_gridGames_doubleClicked(const QModelIndex &index);
	void on_gridPrivateClubs_doubleClicked(const QModelIndex &index);
	void on_gridPublicClubs_doubleClicked(const QModelIndex &index);
	void on_btOpenClubLobby_clicked();
	void on_actionCrash_triggered();
	void on_actionAlways_Run_it_Twice_toggled(bool arg1);
	void on_actionConfirmation_on_fold_toggled(bool arg1);
	void on_actionAlways_Check_Fold_toggled(bool arg1);
	void on_actionContact_Us_triggered();

protected:
	void resizeEvent(QResizeEvent *event);
private:
	void clubTriggered(Data::Club *club);

	Ui::MainWindow *ui;
	QItemSelectionModel *public_club_selection_model,*private_club_selection_model, *game_selection_model;
	Data::Club *currentClub;
  Data::GameListModel game_model;
};
