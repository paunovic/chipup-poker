#include "club.h"
#include "pokermain.h"

using namespace Data;

Club::Club() {
	members.setClub(this);
}

QVariant ClubListModel::data(const QModelIndex &index,int role) const {
	if (index.row() < 0 || index.row() >= m_entries.count()) return QVariant();
	if (role == Qt::DisplayRole) {
		switch (index.column()) {
		case 0:
			return m_entries.at(index.row())->seq;
		case 1:
			return m_entries.at(index.row())->name;
		case 2:
			if (m_entries.at(index.row())->owner == core->self()->id) return tr("Owner");
			else return tr("Member");
		}
	}
	return QVariant();
}
void Club::update(const Poker::Club &in) {
  int i,j;
  QList<QByteArray> toFetch;

  seq = in.seq();
  name = in.name().c_str();
  qDebug() << "updating club" << name;
  std::string clubid = in._id();
  this->clubid = QByteArray(clubid.data(),clubid.length());
  is_private = in.is_private();
  std::string ownerid = in.owner();
  owner = QByteArray(ownerid.data(),ownerid.length());
  assert(ownerid.length() == 12);
  const Data::User *userTest = core->findUser(owner);
  if (!userTest) toFetch.append(owner);
  QList<QByteArray> valid_members;
  for (i=0; i<in.members_size(); i++) {
    Poker::ClubMember member = in.members(i);
    Data::ClubMember *out = 0;

    std::string temp = member._id();
    QByteArray temp2(temp.data(),temp.length());

    for (j=0; j<members.length(); j++) {
      //qDebug() << members.at(j)->_id.toHex() << temp2.toHex();
      if (members.at(j)->_id == temp2) {
        out = members.at(j);
        break;
      }
    }
    bool append = false;
    if (out == 0) {
      out = new Data::ClubMember();
      append = true;
      //qDebug() << "creating new member row";
    }
    out->update(member);
    if (append) members.append(out);
    else members.modified(out);
    valid_members.append(temp2);
    userTest = core->findUser(out->_id);
    if (!userTest) toFetch.append(out->_id);
  }
  members.checkMissing(valid_members);
  if (toFetch.size()) core->GetPlayers(toFetch);
}
void ClubList::clear() {
	public_club_model.beginResetModel();
	private_club_model.beginResetModel();
	clubs.clear();
	public_club_model.clear();
	private_club_model.clear();
	public_club_model.endResetModel();
	private_club_model.endResetModel();
}
void ClubListModel::clear() {
	m_entries.clear();
}
void ClubList::add(Data::Club *input) {
	clubs.append(input);
	if (input->is_private) private_club_model.append(input);
	else public_club_model.append(input);
}
void ClubListModel::append(Data::Club *item) {
	int index = m_entries.size();
	beginInsertRows(QModelIndex(),index,index);
	m_entries.append(item);
	endInsertRows();
}
void ClubList::modified(Club *item, bool old_private) {
	if (old_private == item->is_private) {
		if (item->is_private) private_club_model.modified(item);
		else public_club_model.modified(item);
	} else {
		if (old_private) private_club_model.remove(item);
		else public_club_model.remove(item);

		if (item->is_private) private_club_model.append(item);
		else public_club_model.append(item);
	}
}
void ClubListModel::modified(Club *item) {
	for (int i=0; i< m_entries.size(); i++) {
		if (m_entries.at(i) == item) {
			emit dataChanged(createIndex(i,0),createIndex(i,2));
			break;
		}
	}
}
void ClubListModel::remove(const Data::Club *item) {
	for (int i=0; i< m_entries.size(); i++) {
		if (m_entries.at(i) == item) {
			beginRemoveRows(QModelIndex(),i,i);
			m_entries.removeAt(i);
			endRemoveRows();
			break;
		}
	}
}
QVariant ClubListModel::headerData(int row, Qt::Orientation, int role) const {
	if (role != Qt::DisplayRole) return QVariant();
	switch (row) {
	case 0: return "Club ID";
	case 1: return "Club name";
	case 2: return "Status";
	}

	return QVariant();
}
void ClubListModel::sort(int, Qt::SortOrder) {

}
const Club *ClubList::getClub(QByteArray clubid) const {
	foreach (Club *c, private_club_model.m_entries) {
		if (c->clubid == clubid) return c;
	}
	foreach (Club *c, public_club_model.m_entries) {
		if (c->clubid == clubid) return c;
	}
	return 0;
}
void ClubList::remove(const Club *item) {
	private_club_model.remove(item);
	public_club_model.remove(item);
}
