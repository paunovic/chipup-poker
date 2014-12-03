#include <QDebug>

#include "game.h"
#include "pokermain.h"

using namespace Data;
Game::Game() {
	seats = 2;
}
void Game::update(Poker::Game &in) {
	std::string gameid = in._id();
	this->gameid = QByteArray(gameid.data(),gameid.length());

	std::string clubid = in.club_mongoid();
	this->clubid = QByteArray(clubid.data(),clubid.length());

	std::string tournid = in.tournament();
	this->tournamentid = QByteArray(tournid.data(),tournid.length());

	gamename = in.gamename().c_str();
	type = in.game_type();
	blinds = in.blinds();
	switch (blinds) {
	case Poker::Game::gb1x2:
		sb = 1;
		bb = 2;
		break;
	case Poker::Game::gb5x5:
		sb = bb = 5;
		break;
	case Poker::Game::gb5x10:
		sb = 5;
		bb = 10;
		break;
	case Poker::Game::gb10x25:
		sb = 10;
		bb = 25;
		break;
	case Poker::Game::gb25x50:
		sb = 25;
		bb = 50;
		break;
	case Poker::Game::gb50x100:
		sb = 50;
		bb = 100;
		break;
	case Poker::Game::gbOther:
		sb = in.small_blind();
		bb = in.big_blind();
		break;
	}
	sitting = in.sitting();
	seats = in.seats();
	state = in.state();
}

QVariant GameListModel::data(const QModelIndex &index,int role) const {
	if (index.row() < 0 || index.row() >= m_entries.count()) return QVariant();
	if (role == Qt::DisplayRole) {
		const Game &g = *m_entries.at(index.row());
		switch (index.column()) {
		case 0: return g.gamename;
		case 1:
			return g.typeToString();
		case 2: return QString("%1/%2").arg(g.sb).arg(g.bb);
		case 3: return "limits";
		case 4: return QString("%1/%2").arg(g.sitting).arg(g.seats);
		case 5:
			switch (g.state) {
			case Poker::Game::gsActive:
			case Poker::Game::gsEmpty:
				return tr("Open");
			default:
				return (int)g.state;
			}
		}
	}
	return QVariant();
}
QString Game::typeToString() const {
	switch (type) {
	case Poker::Game::gtHoldem: return "NLH";
	case Poker::Game::gtOmaha: return "NLO";
	case Poker::Game::gtRotationNLHPLO: return "Rotation NLH/NLO";
	}
}

QVariant GameListModel::headerData(int row, Qt::Orientation, int role) const {
	if (role == Qt::SizeHintRole) return QVariant(); // QSize
	if (role != Qt::DisplayRole) return QVariant();
	switch (row) {
	case 0: return tr("Table");
	case 1: return tr("Type");
	case 2: return tr("Stakes");
	case 3: return tr("Buy-in Limits");
	case 4: return tr("Players");
	case 5: return tr("Status");
	}

	return QVariant();
}
void GameListModel::setFilter(const Club *club) {
	filteredClub = club;
	if (!club) {
		beginResetModel();
		m_entries.clear();
		endResetModel();
		return;
	}
	QList<const Data::Game*> filtered;
	for (int i=0; i<core->games.size(); i++) {
		if (core->games.at(i)->state == Poker::Game::gsClosed) continue;
		if (core->games.at(i)->clubid == club->clubid) {
			filtered.append(core->games.at(i));
		}
	}
	setEntries(filtered);
}
void GameListModel::updated(const Game *g) {
	if (!filteredClub) return; // filter not set yet
	if (filteredClub->clubid != g->clubid) return; // game not in filter
	for (int i=0; i<m_entries.size(); i++) {
		if (g == m_entries.at(i)) {
			emit dataChanged(createIndex(i,0),createIndex(i,2));
			break;
		}
	}
}
void GameListModel::add(const Game *g) {
	if (!filteredClub) return; // filter not set yet
	if (filteredClub->clubid != g->clubid) return; // game not in filter
	int index = m_entries.size();
	beginInsertRows(QModelIndex(),index,index);
	m_entries.append(g);
	endInsertRows();
}
void GameListModel::remove(const Game *g) {
	if (!filteredClub) return; // filter not set yet
	if (filteredClub->clubid != g->clubid) return; // game not in filter
	for (int i=0; i<m_entries.size(); i++) {
		if (g == m_entries.at(i)) {
			beginRemoveRows(QModelIndex(),i,i);
			m_entries.removeAt(i);
			endRemoveRows();
			break;
		}
	}
}
const Game *GameListModel::getGame(const QModelIndex &index) const {
	int row = index.row();
	return m_entries.at(row);
}
