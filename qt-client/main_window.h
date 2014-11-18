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
	void secondary_login();
	void on_actionOpen_Table_triggered();

private:
	Ui::MainWindow *ui;
	QHeaderView private_club_header,game_header;
    QItemSelectionModel *public_club_selection_model,*private_club_selection_model, *game_selection_model;
};
