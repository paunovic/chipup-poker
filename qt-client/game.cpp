#include "game.h"

using namespace Data;

QVariant GameListModel::data(const QModelIndex &index,int role) const {
	if (index.row() < 0 || index.row() >= m_entries.count()) return QVariant();
	if (role == Qt::DisplayRole) {
		switch (index.column()) {
		case 0: return m_entries.at(index.row()).gamename;
		case 1: return "type";
		case 2: return "stakes";
		case 3: return "blinds";
		case 4: return "limits";
		case 5: return "players";
		case 6: return "status";
		}
	}
	return QVariant();
}
