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
private:
	Ui::MainWindow *ui;
	QHeaderView private_club_header,game_header;
	Data::ClubListModel private_club_model;
	Data::GameListModel game_model;
	QItemSelectionModel *private_club_selection_model, *game_selection_model;
};
