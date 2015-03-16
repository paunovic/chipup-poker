#ifndef DATA_CLUBMEMBER_H
#define DATA_CLUBMEMBER_H

#include <stdint.h>
#include <QByteArray>
#include <QAbstractListModel>

namespace Poker {
class ClubMember;
}
namespace Data {
class Club;

class ClubMember
{
public:
	ClubMember();
	void update(Poker::ClubMember&in);
	QString getDisplayName() const;
	bool isOwner(const Club *club) const;

	QByteArray _id;
	bool suspended,unlimited_limit,muted,manager;
	uint32_t balance_limit;
	int32_t club_balance;
};

class ClubMemberList : public QAbstractListModel {
public:
	int rowCount(const QModelIndex &parent=QModelIndex()) const {
		Q_UNUSED(parent);
		return m_entries.count();
	}
	int columnCount(const QModelIndex &parent=QModelIndex()) const;
	int length() const { return m_entries.count(); }
	QVariant data(const QModelIndex &index,int role) const;
	QVariant headerData(int, Qt::Orientation, int) const;
	void modified(ClubMember *item);
	void sort(int column, Qt::SortOrder order = Qt::AscendingOrder);
	const ClubMember* getmember(const QModelIndex index) { return m_entries.at(index.row()); }
	ClubMember* at(int index) const { return m_entries.at(index); }
	void append(ClubMember*);
	void checkMissing(QList<QByteArray> validMembers);

	friend class ClubList;
	friend class Club;
protected:
	void setClub(Club *club) { parent = club; }
	void clear();
	void remove(ClubMember*);
	QString getStatus(const ClubMember *row) const;

	QList<ClubMember*> m_entries;
	Club *parent;
};

} // namespace Data

#endif // DATA_CLUBMEMBER_H
