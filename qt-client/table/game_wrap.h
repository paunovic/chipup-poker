#pragma once

#include <QObject>

#include "game.h"

class GameWrap : public QObject {
Q_OBJECT
public:
	GameWrap(const Data::Game *root) { g = root; }
	Q_PROPERTY(int seats READ seats);
	int seats() const { return g->seats; }
private:
	const Data::Game *g;
};
