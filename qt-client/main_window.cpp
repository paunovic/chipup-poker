#include "main_window.h"
#include "ui_main_window.h"
#include "pokermain.h"
#include "join_club.h"
#include "createclub.h"
#include "loginwindow.h"

#include <QDebug>
#include <QAbstractItemView>

MainWindow::MainWindow(QWidget *parent) : QMainWindow(parent),ui(new Ui::MainWindow), private_club_header(Qt::Horizontal), game_header(Qt::Horizontal) {
	qDebug() << "doing setup";
	ui->setupUi(this);
	connect(ui->btHomeGames,SIGNAL(clicked()),this,SLOT(homeGames()));
	connect(ui->btTournaments,SIGNAL(clicked()),this,SLOT(tournaments()));
	
	public_club_selection_model = new QItemSelectionModel(&core->clubs.public_club_model);
	connect(public_club_selection_model,SIGNAL(selectionChanged(QItemSelection,QItemSelection)),this,SLOT(public_club_selected(QItemSelection,QItemSelection)));
	ui->gridPublicClubs->setModel(&core->clubs.public_club_model);
	ui->gridPublicClubs->setSelectionBehavior(QAbstractItemView::SelectRows);
	ui->gridPublicClubs->setSelectionModel(public_club_selection_model);
	ui->gridPublicClubs->setRootIsDecorated(false);
	ui->gridPublicClubs->hideColumn(0);
	ui->gridPublicClubs->hideColumn(2);
	
	private_club_selection_model = new QItemSelectionModel(&core->clubs.private_club_model);
	connect(core,SIGNAL(clubs_changed()),this,SLOT(clubs_changed()));
	connect(private_club_selection_model,SIGNAL(selectionChanged(const QItemSelection&,const QItemSelection&)),this,SLOT(private_club_selected(const QItemSelection&,const QItemSelection&)));
	ui->gridPrivateClubs->setModel(&core->clubs.private_club_model);
	ui->gridPrivateClubs->setSelectionBehavior(QAbstractItemView::SelectRows);
	ui->gridPrivateClubs->setSelectionModel(private_club_selection_model);
	ui->gridPrivateClubs->setRootIsDecorated(false);
	ui->gridPrivateClubs->setSortingEnabled(true);

	game_selection_model = new QItemSelectionModel(&game_model);
	connect(core,SIGNAL(games_changed()),this,SLOT(games_changed()));
	connect(game_selection_model,SIGNAL(selectionChanged(const QItemSelection&,const QItemSelection&)),this,SLOT(game_selected(const QItemSelection&,const QItemSelection&)));
	ui->gridGames->setModel(&game_model);
	ui->gridGames->setHeader(&game_header);
	ui->gridGames->setSelectionBehavior(QAbstractItemView::SelectRows);
	ui->gridGames->setSelectionModel(game_selection_model);
	ui->gridGames->setRootIsDecorated(false);
}
MainWindow::~MainWindow() {
	delete ui;
}
void MainWindow::homeGames() {
	ui->stackedWidget->setCurrentIndex(0);
}
void MainWindow::tournaments() {
	ui->stackedWidget->setCurrentIndex(1);
}
void MainWindow::clubs_changed() {
	qDebug() << "club list changing";
}
void MainWindow::private_club_selected(const QItemSelection &selected, const QItemSelection &) {
	if (selected.indexes().length() == 0) return;
	ui->gridPublicClubs->clearSelection();
	int row = selected.indexes().at(0).row();
	const Data::Club *club = core->private_clubs().at(row);
	qDebug() << "selected:" << club->name << club->clubid.toHex();
	QList<Data::Game> filtered;
	for (int i=0; i<core->games.size(); i++) {
		qDebug() << i << core->games.at(i).clubid.toHex();
		if (core->games.at(i).clubid == club->clubid) {
			qDebug() << "match";
			filtered.append(core->games.at(i));
		}
	}
	game_model.setEntries(filtered);
}
void MainWindow::public_club_selected(const QItemSelection &selected, const QItemSelection &) {
	if (selected.indexes().length() == 0) return;
    ui->gridPrivateClubs->clearSelection();
    int row = selected.indexes().at(0).row();
	const Data::Club *club = core->public_clubs().at(row);
	qDebug() << "selected:" << club->name << club->clubid.toHex();
    QList<Data::Game> filtered;
    for (int i=0; i<core->games.size(); i++) {
        qDebug() << i << core->games.at(i).clubid.toHex();
		if (core->games.at(i).clubid == club->clubid) {
            qDebug() << "match";
            filtered.append(core->games.at(i));
        }
    }
    game_model.setEntries(filtered);
}
void MainWindow::on_btJoinClub_clicked() {
	JoinClub *jc = new JoinClub(this);
	jc->show();
}
void MainWindow::on_btCreateClub_clicked() {
	CreateClub *cc = new CreateClub(this);
	cc->show();
}
void MainWindow::on_actionLogout_triggered() {
	core->sendMessage(Poker::scLogout);
	LoginWindow *lw = new LoginWindow;
	lw->show();
	close();
}
