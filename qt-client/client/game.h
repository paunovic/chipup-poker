#pragma once

#include <QString>
#include <QVariant>
#include <QAbstractListModel>

#include <poker/message.pb.h>
#include "club.h"

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
	GameListModel() {
		filteredClub = NULL;
	}

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
	void updated(const Game *g);
	void add(const Game *g);
	void remove(const Game *g);
	const Game *getGame(const QModelIndex &index) const;

protected:
	QList<const Game*> m_entries;
	const Data::Club *filteredClub;
};
}
