#include "main_window.h"
#include "ui_main_window.h"
#include "pokermain.h"
#include "join_club.h"
#include "createclub.h"
#include "loginwindow.h"
#include "csseditor.h"
#include "clublobby.h"

#include <QDebug>
#include <QAbstractItemView>

#include "table.h"
#include "selftest.h"

MainWindow::MainWindow(QWidget *parent) : QMainWindow(parent),ui(new Ui::MainWindow), private_club_header(Qt::Horizontal), game_header(Qt::Horizontal) {
	currentClub = 0;

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
	connect(private_club_selection_model,SIGNAL(selectionChanged(const QItemSelection&,const QItemSelection&)),this,SLOT(private_club_selected(const QItemSelection&,const QItemSelection&)));
	ui->gridPrivateClubs->setModel(&core->clubs.private_club_model);
	ui->gridPrivateClubs->setSelectionBehavior(QAbstractItemView::SelectRows);
	ui->gridPrivateClubs->setSelectionModel(private_club_selection_model);
	ui->gridPrivateClubs->setRootIsDecorated(false);
	//ui->gridPrivateClubs->setSortingEnabled(true);

	core->game_model.setFilter(NULL);

	game_selection_model = new QItemSelectionModel(&core->game_model);
	connect(game_selection_model,SIGNAL(selectionChanged(const QItemSelection&,const QItemSelection&)),this,SLOT(game_selected(const QItemSelection&,const QItemSelection&)));
	ui->gridGames->setModel(&core->game_model);
	ui->gridGames->setHeader(&game_header);
	ui->gridGames->setSelectionBehavior(QAbstractItemView::SelectRows);
	ui->gridGames->setSelectionModel(game_selection_model);
	ui->gridGames->setRootIsDecorated(false);
	core->RegisterListener(this);
	int em = ui->gridPrivateClubs->fontMetrics().boundingRect("M").width();
	ui->gridPublicClubs->setMinimumWidth(em*31);
	ui->gridPrivateClubs->setMinimumWidth(em*31);
	ui->gridPrivateClubs->setMinimumHeight(em*18);
	ui->gridGames->setMinimumHeight(em*18);
	for (int i=0; i<6; i++) {
		ui->gridGames->resizeColumnToContents(i);
	}
	//setFixedSize(size());
}
MainWindow::~MainWindow() {
	delete ui;
}
void MainWindow::homeGames() {
	ui->stackedWidget->setCurrentIndex(0);
	ui->btTournaments->setChecked(false);
	ui->btTournamentsDummy->setChecked(false);
	ui->btHomeGames->setChecked(true);
	ui->btHomeGamesDummy->setChecked(true);
}
void MainWindow::tournaments() {
	ui->stackedWidget->setCurrentIndex(1);
	ui->btTournaments->setChecked(true);
	ui->btTournamentsDummy->setChecked(true);
	ui->btHomeGames->setChecked(false);
	ui->btHomeGamesDummy->setChecked(false);
}
void MainWindow::private_club_selected(const QItemSelection &selected, const QItemSelection &) {
	if (selected.indexes().length() == 0) return;
	ui->gridPublicClubs->clearSelection();
	ui->btOpenClubLobby->setEnabled(true);
	int row = selected.indexes().at(0).row();
	currentClub = core->private_clubs().at(row);
	qDebug() << "selected:" << currentClub->name << currentClub->clubid.toHex();

	core->game_model.setFilter(currentClub);
	for (int i=0; i<6; i++) {
		ui->gridGames->resizeColumnToContents(i);
	}
}
void MainWindow::public_club_selected(const QItemSelection &selected, const QItemSelection &) {
	if (selected.indexes().length() == 0) return;
	ui->gridPrivateClubs->clearSelection();
	ui->btOpenClubLobby->setEnabled(false);
	int row = selected.indexes().at(0).row();
	currentClub = core->public_clubs().at(row);
	qDebug() << "selected:" << currentClub->name << currentClub->clubid.toHex();

	core->game_model.setFilter(currentClub);
	for (int i=0; i<6; i++) {
		ui->gridGames->resizeColumnToContents(i);
	}
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
	deleteLater();
	core->delayQuit = false; // FIXME
}
void MainWindow::On_secondary_login() {
	LoginWindow *lw = new LoginWindow;
	lw->show();
	close();
	deleteLater();
	core->delayQuit = false; // FIXME
}

bool MainWindow::event(QEvent *event) {
	if (event->type() == QEvent::Close) {
		qDebug() << "close detected";
		core->delayQuit = true;
		core->sendMessage(Poker::scLogout);
		return true;
	} else {
		return QMainWindow::event(event);
	}
}
void MainWindow::on_actionCSS_Editor_triggered() {
	CssEditor *css = new CssEditor;
	css->show();
}
void MainWindow::on_actionSelf_Tests_triggered() {
	SelfTests *st = new SelfTests;
	st->show();
}
void MainWindow::on_gridGames_doubleClicked(const QModelIndex &index) {
	qDebug() << "double click" << index.row();
	const Data::Game *game = core->game_model.getGame(index);
	Poker::Game g;
	g.set__id(game->gameid.data(),game->gameid.length());
	core->sendMessage(Poker::scTableJoin,&g);
	Table *t = new Table();
	t->setGame(game,currentClub);
	t->show();
}
void MainWindow::on_gridPrivateClubs_doubleClicked(const QModelIndex &index) {
	qDebug() << "priv club click" << index.row();
	Data::Club *club = core->clubs.private_club_model.getClub(index);
	qDebug() << club->name;
	clubTriggered(club);
}
void MainWindow::on_gridPublicClubs_doubleClicked(const QModelIndex &index) {
	qDebug() << "priv club click" << index.row();
	Data::Club *club = core->clubs.public_club_model.getClub(index);
	qDebug() << club->name;
	clubTriggered(club);
}
void MainWindow::on_btOpenClubLobby_clicked() {
	clubTriggered(currentClub);
}
void MainWindow::clubTriggered(Data::Club *club) {
	// TODO, if its a public club, dont let you open the lobby for some reason??
	ClubLobby *cl = new ClubLobby();
	cl->setClub(club);
	cl->show();
}
void MainWindow::on_actionDisconnect_triggered() {
	core->testDisconnect();
}
void MainWindow::resizeEvent(QResizeEvent *event) {
	int em = ui->gridPrivateClubs->fontMetrics().boundingRect("M").width();
	QSize priv = ui->gridPrivateClubs->size();
	qDebug() << "root size" << size() << "private size" << priv << (priv/em);
}
