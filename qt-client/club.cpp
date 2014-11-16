#include "club.h"

using namespace Data;

QVariant ClubListModel::data(const QModelIndex &index,int role) const {
	if (index.row() < 0 || index.row() >= m_entries.count()) return QVariant();
	if (role == Qt::DisplayRole) {
		switch (index.column()) {
		case 0:
			return m_entries.at(index.row())->seq;
		case 1:
			return m_entries.at(index.row())->name;
		case 2:
			return "status";
		}
	}
	return QVariant();
}
void Club::update(const Poker::Club &in) {
	seq = in.seq();
	name = in.name().c_str();
	std::string clubid = in._id();
	this->clubid = QByteArray(clubid.data(),clubid.length());
	is_private = in.is_private();
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
void ClubListModel::remove(Data::Club *item) {
	for (int i=0; i< m_entries.size(); i++) {
		if (m_entries.at(i) == item) {
			beginRemoveRows(QModelIndex(),i,i);
			m_entries.removeAt(i);
			endRemoveRows();
			break;
		}
	}
}
QVariant ClubListModel::headerData(int row, Qt::Orientation b, int role) const {
	if (role != Qt::DisplayRole) return QVariant();
	switch (row) {
	case 0: return "Club ID";
	case 1: return "Club name";
	case 2: return "Status";
	}

	return QVariant();
}
