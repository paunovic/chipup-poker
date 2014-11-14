#include "club.h"

using namespace Data;

QVariant ClubListModel::data(const QModelIndex &index,int role) const {
	if (index.row() < 0 || index.row() >= m_entries.count()) return QVariant();
	if (role == Qt::DisplayRole) {
		switch (index.column()) {
		case 0:
			return m_entries.at(index.row()).seq;
		case 1:
			return m_entries.at(index.row()).name;
		case 2:
			return "status";
		}
	}
	return QVariant();
}
