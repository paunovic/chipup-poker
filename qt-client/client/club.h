#pragma once

#include <QString>
#include <QAbstractListModel>
#include <QDebug>
#include <poker/message.pb.h>
#include "data/clubmember.h"

namespace Data {

class ClubList;

class Club {
public:
	Club();
	void update(const Poker::Club&);

	enum Role { Owner, Member };
	QByteArray clubid,owner;
	int seq;
	QString name;
	Role role;
	bool is_private;
	ClubMemberList members;
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
  QVariant headerData(int, Qt::Orientation, int) const;
  void modified(Club *item);
  void sort(int column, Qt::SortOrder order = Qt::AscendingOrder);
  Club* getClub(const QModelIndex index) { return m_entries.at(index.row()); }

  friend class ClubList;
protected:
  void clear();
  void append(Club*);
  void remove(const Club *);

  QList<Club*> m_entries;
};

class ClubList : public QObject {
Q_OBJECT
public:
	void add(Club*);
	void clear();
	int size() {
		return clubs.size();
	}
	void modified(Club *item, bool old_private);
	void remove(const Club *item);
	Club *at(int i) {
		return clubs.at(i);
	}
	const Club *getClub(QByteArray clubid) const;

	Data::ClubListModel public_club_model,private_club_model;
private:
	QList<Club*> clubs;
};

}
