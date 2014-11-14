#pragma once

#include <QMainWindow>
#include <QStringListModel>
#include <QHeaderView>

#include "club.h"
#include "game.h"

namespace Ui {
class MainWindow;
}

class MainWindow : public QMainWindow {
Q_OBJECT
public:
	MainWindow(QWidget *parent=0);
	~MainWindow();
private slots:
	void homeGames();
	void tournaments();
	void clubs_changed();
	void private_club_selected(const QItemSelection&, const QItemSelection&);
	void public_club_selected(const QItemSelection&, const QItemSelection&);
	void on_btJoinClub_clicked();
	void on_btCreateClub_clicked();
private:
	Ui::MainWindow *ui;
	QHeaderView private_club_header,game_header;
	Data::GameListModel game_model;
    QItemSelectionModel *public_club_selection_model,*private_club_selection_model, *game_selection_model;
};
