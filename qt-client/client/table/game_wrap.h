#pragma once

#include <QObject>

#include "game.h"

class GameWrap : public QObject {
Q_OBJECT
public:
	GameWrap(const Data::Game *root) { g = root; }
	Q_PROPERTY(int seats READ seats)
	Q_PROPERTY(bool tournament READ tournament)
	int seats() const { return g->seats; }
	bool tournament() const { return g->tournamentid.length(); }
private:
	const Data::Game *g;
};
