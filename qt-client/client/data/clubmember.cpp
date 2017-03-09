#include "clubmember.h"

#include <poker/message.pb.h>
#include "pokermain.h"
#include "club.h"

namespace Data {

ClubMember::ClubMember()
{
}

void ClubMember::update(Poker::ClubMember &in) {
  std::string temp = in._id();
  _id = QByteArray(temp.data(),temp.length());

  if (in.has_status()) {
    suspended = in.status() == Poker::ClubMember::msSuspended;
  } else {
    suspended = false;
  }

	if (in.has_balance_limit()) {
		balance_limit = in.balance_limit();
	}

	if (in.has_club_balance()) {
		club_balance = in.club_balance();
	}

	if (in.has_unlimited_limit()) {
		unlimited_limit = in.unlimited_limit();
	}

	if (in.has_muted()) muted = in.muted();
	else muted = false;

	if (in.has_manager()) manager = in.manager();
	else manager = false;
}
QString ClubMember::getDisplayName() const {
	const Data::User * self = core->findUser(_id);
	if (self) return self->displayName();
	else return "ERROR";
}

void ClubMemberList::append(ClubMember *item) {
	int index = m_entries.size();
	beginInsertRows(QModelIndex(),index,index);
	m_entries.append(item);
	endInsertRows();
}
void ClubMemberList::modified(ClubMember *item) {
	for (int i=0; i< m_entries.size(); i++) {
		if (m_entries.at(i) == item) {
			emit dataChanged(createIndex(i,0),createIndex(i,2));
			break;
		}
	}
}
QVariant ClubMemberList::data(const QModelIndex &index,int role) const {
	const ClubMember *row;
	if (index.row() < 0 || index.row() >= m_entries.count()) return QVariant();
	row = m_entries.at(index.row());
	if (role == Qt::DisplayRole) {
		if (this->parent->owner == core->self()->id) {
			switch (index.column()) {
			case 0:
				return row->getDisplayName();
			case 1:
				return QString("%1").arg(row->club_balance);
			case 2:
				if (row->unlimited_limit) return "Unlimited";
				else {
					double balance = row->balance_limit;
					balance *= -1;
					balance /= 100;
					return QString("%1").arg(balance);
				}
			case 3:
				row = m_entries.at(index.row());
				return getStatus(row);
			}
		} else {
			switch (index.column()) {
			case 0:
				return row->getDisplayName();
			case 1:
				return getStatus(row);
			}
		}
	}
	return QVariant();
}
QString ClubMemberList::getStatus(const ClubMember *row) const {
	QString status;
	if (row->suspended) return tr("Suspended");

	if (row->isOwner(parent)) status = tr("Owner");
	else if (row->manager) status = tr("Manager");
	else status = tr("Member");

	if (row->muted) status = QString(tr("%1 (Muted)")).arg(status);

	return status;
}

bool ClubMember::isOwner(const Club *club) const {
	return club->owner == _id;
}
QVariant ClubMemberList::headerData(int row, Qt::Orientation, int role) const {
	if (role != Qt::DisplayRole) return QVariant();
	if (this->parent->owner == core->self()->id) {
		switch (row) {
		case 0: return "Name";
		case 1: return "Balance";
		case 2: return "Limit";
		case 3: return "Status";
		}
	} else {
		switch (row) {
		case 0: return "Name";
		case 1: return "Status";
		}
	}

	return QVariant();
}
void ClubMemberList::sort(int, Qt::SortOrder) {

}
int ClubMemberList::columnCount(const QModelIndex &parent) const {
	Q_UNUSED(parent);
	if (this->parent->owner == core->self()->id) return 4;
	return 2;
}
void ClubMemberList::checkMissing(QList<QByteArray> validMembers) {
	QList<ClubMember*>::Iterator i;
	for (i=m_entries.begin(); i<m_entries.end(); ++i) {
		ClubMember *row = *i;
		if (validMembers.contains(row->_id)) continue;
		int index = m_entries.indexOf(row);
		beginRemoveRows(QModelIndex(),index,index);
		m_entries.removeOne(row);
		endRemoveRows();
	}
}
} // namespace Data
