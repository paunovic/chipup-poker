#pragma once

#include <QString>
#include <QAbstractListModel>
#include <QDebug>

namespace Data {

class Club {
public:
	enum Role { Owner, Member };
	QByteArray clubid;
	int seq;
	QString name;
	Role role;
    bool is_private;
};

class ClubListModel : public QAbstractListModel {
Q_OBJECT
public:
	enum Column {
		clubId,
		clubName,
		clubStatus
	};
	ClubListModel(QObject *parent=0) : QAbstractListModel(parent) {
	}

	int rowCount(const QModelIndex &parent=QModelIndex()) const {
		Q_UNUSED(parent);
		return m_entries.count();
	}
	int columnCount(const QModelIndex &parent=QModelIndex()) const {
		Q_UNUSED(parent);
		return 3;
	}
	QVariant data(const QModelIndex &index,int role) const;
	QVariant headerData(int section, Qt::Orientation p, int role) const {
		return QVariant();
	}
	void setEntries(const QList<Club> &entries) {
		m_entries = entries;
		reset();
	}
protected:
	QList<Club> m_entries;
};
}
