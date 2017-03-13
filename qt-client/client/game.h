#pragma once

#include <QString>
#include <QVariant>
#include <QAbstractListModel>

#include <poker/message.pb.h>
#include "club.h"

class PokerMain;

namespace Data {

class Game {
public:
	Game();
	void update(Poker::Game &in);
	QString typeToString() const;
	QString typeToLongString() const;

	QString gamename;
	QByteArray clubid,gameid,tournamentid;
	Poker::Game::GameType type;
	Poker::Game::GameBlinds blinds;
	Poker::Game::GameState state;
	int sb,bb;
	int sitting,seats;
	int buyin_min,buyin_max;
};
class GameListModel : public QAbstractListModel {
Q_OBJECT
public:
	GameListModel();

	int rowCount(const QModelIndex &parent=QModelIndex()) const {
		Q_UNUSED(parent);
		return m_entries.count();
	}
	int columnCount(const QModelIndex &parent=QModelIndex()) const {
		Q_UNUSED(parent);
		return 6;
	}
	QVariant data(const QModelIndex &index,int role) const;
	QVariant headerData(int row, Qt::Orientation, int role) const;
	void setEntries(const QList<const Game*> &entries) {
		beginResetModel();
		m_entries = entries;
		endResetModel();
	}
	void setFilter(const Club *club);
	const Game *getGame(const QModelIndex &index) const;
private slots:
  void game_added(const Game *g);
  void game_changed(const Game *g);
  void game_removed(const Game *g);

protected:
	QList<const Game*> m_entries;
	const Data::Club *filteredClub;
};
}
