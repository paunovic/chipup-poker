#pragma once

#include <QString>
#include <QVariant>
#include <QAbstractListModel>

namespace Data {
class Game {
public:
	QString gamename;
	QByteArray clubid;
};
class GameListModel : public QAbstractListModel {
Q_OBJECT
public:
	int rowCount(const QModelIndex &parent=QModelIndex()) const {
		Q_UNUSED(parent);
		return m_entries.count();
	}
	int columnCount(const QModelIndex &parent=QModelIndex()) const {
		Q_UNUSED(parent);
		return 6;
	}
	QVariant data(const QModelIndex &index,int role) const;
	void setEntries(const QList<Game> &entries) {
        this->beginResetModel();
		m_entries = entries;
        this->endResetModel();
	}
protected:
	QList<Game> m_entries;
};
}
