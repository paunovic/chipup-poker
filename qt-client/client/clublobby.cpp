#include <QItemSelectionModel>

#include "clublobby.h"
#include "ui_clublobby.h"
#include "pokermain.h"

ClubLobby::ClubLobby(QWidget *parent) : QMainWindow(parent), ui(new Ui::ClubLobby) {
  ui->setupUi(this);
  core->RegisterListener(this);
  setAttribute(Qt::WA_DeleteOnClose,true);
}

ClubLobby::~ClubLobby() {
  delete ui;
}

void ClubLobby::setClub(Data::Club *club) {
  currentMember = 0;

  this->club = club;
  ui->lbClubName->setText(club->name);
  const Data::User *owner = core->findUser(club->owner);
  Q_ASSERT(owner);
  if (owner) {
    ui->lbOwner->setText(QString(tr("Owner:%1")).arg(owner->displayName()));
  } else ui->lbOwner->setText("Loading...");
  ui->lbMembers->setText(QString(tr("Members: %1")).arg(club->members.length()));
  ui->lbClubSeq->setText(QString(tr("Club ID: %1")).arg(club->seq));
  ui->lbClubName->setText(club->name);

  selection_model = new QItemSelectionModel(&club->members);
  connect(selection_model,SIGNAL(selectionChanged(const QItemSelection&,const QItemSelection&)),this,SLOT(user_selected(const QItemSelection&,const QItemSelection&)));
  ui->gridMembers->setModel(&club->members);
  ui->gridMembers->setSelectionBehavior(QAbstractItemView::SelectRows);
  ui->gridMembers->setSelectionModel(selection_model);

  game_model.setFilter(club);
  ui->gridTables->setModel(&game_model);

  bool visible = core->self()->id == club->owner;
  ui->btResetBalances->setVisible(visible);
  ui->btResetPlayerBalance->setVisible(visible);
  ui->btGiveOwnership->setVisible(visible);
  ui->btPromoteToManager->setVisible(visible);

  ui->btSuspend->setVisible(visible);
  ui->btRemove->setVisible(visible);
  ui->btSetLimit->setVisible(visible);
  ui->btMute->setVisible(visible);

  if (club->owner == core->self()->id) ui->stackOwner->setCurrentIndex(0);
  else ui->stackOwner->setCurrentIndex(1);
  on_btClubHome_clicked();
}

void ClubLobby::on_btClubHome_clicked() {
  ui->stackedWidget->setCurrentIndex(0);
  ui->btClubHome->setChecked(true);
  ui->btTables->setChecked(false);
  ui->btStats->setChecked(false);
}

void ClubLobby::on_btTables_clicked() {
  ui->stackedWidget->setCurrentIndex(1);
  ui->btClubHome->setChecked(false);
  ui->btTables->setChecked(true);
  ui->btStats->setChecked(false);
}

void ClubLobby::on_btStats_clicked() {
  ui->stackedWidget->setCurrentIndex(2);
  ui->btClubHome->setChecked(false);
  ui->btTables->setChecked(false);
  ui->btStats->setChecked(true);
}

void ClubLobby::user_selected(const QItemSelection &selected, const QItemSelection &) {
	if (selected.indexes().length() == 0) return;

	int row = selected.indexes().at(0).row();
	currentMember = club->members.at(row);
	qDebug() << "selected:" << currentMember << currentMember->_id.toHex();
	ui->btResetPlayerBalance->setEnabled(true);
	ui->btSetLimit->setEnabled(true);

	refreshSelection();
}

void ClubLobby::On_club_changed(const Data::Club *club) {
  if (club != this->club) return;
  refreshSelection();
  const Data::User *owner = core->findUser(club->owner);
  Q_ASSERT(owner);
  ui->lbOwner->setText(QString(tr("Owner:%1")).arg(owner->displayName()));
  ui->lbMembers->setText(QString(tr("Members: %1")).arg(club->members.length()));
}

void ClubLobby::refreshSelection() {
	// TODO, handle null caused by kick
	if (currentMember->suspended) ui->btSuspend->setText(tr("Reinstate"));
	else ui->btSuspend->setText(tr("Suspend"));
	if (currentMember->isOwner(club)) {
		ui->btSuspend->setEnabled(false);
		ui->btRemove->setEnabled(false);
	} else {
		ui->btSuspend->setEnabled(true);
		ui->btRemove->setEnabled(true);
	}

	ui->btMute->setEnabled(true);
	if (currentMember->muted) ui->btMute->setText(tr("Unmute"));
	else ui->btMute->setText(tr("Mute"));
}
void ClubLobby::on_btSuspend_clicked() {
	Poker::ChangeClubPlayerFlag ccpf;
	ccpf.set_club_mongo_id(club->clubid.data(),club->clubid.length());
	ccpf.set_player_mongo_id(currentMember->_id.data(),currentMember->_id.length());
	ccpf.set_flag(!currentMember->suspended);
	core->sendMessage(Poker::scSuspendPlayer,&ccpf);
}
void ClubLobby::on_btMute_clicked() {
	Poker::ChangeClubPlayerFlag ccpf;
	ccpf.set_club_mongo_id(club->clubid.data(),club->clubid.length());
	ccpf.set_player_mongo_id(currentMember->_id.data(),currentMember->_id.length());
	ccpf.set_flag(!currentMember->muted);
	core->sendMessage(Poker::scMutePlayer,&ccpf);
}
void ClubLobby::on_btRemove_clicked() {
	Poker::KickPlayerParams kpp;
	kpp.set_club_mongo_id(club->clubid.data(),club->clubid.length());
	kpp.set_player_mongo_id(currentMember->_id.data(),currentMember->_id.length());
	core->sendMessage(Poker::scKickPlayer,&kpp);
	currentMember = 0;
	refreshSelection();
}
void ClubLobby::on_btLeaveClub_clicked() {
	Poker::Club c;
	c.set__id(club->clubid);
	core->sendMessage(Poker::scLeaveClub,&c);
}
void ClubLobby::On_clubLeft(const Data::Club *club) {
	if (club == this->club) close();
}
