#ifndef VISIBLE_SEAT_H
#define VISIBLE_SEAT_H

#include <QFontMetrics>
#include <QTimer>
#include <QByteArray>

#include "tableprivate.h"

class QNetworkReply;
class TableSit;

class VisibleSeat : public GameObjectUi {
Q_OBJECT
public:
	VisibleSeat(TableUi *parent, SeatObject *jsobj);
	~VisibleSeat();
	void updateSeat();
	void updateInfo(Data::SeatInfo *info);
	QSize sizeHint() const;
	
	QPixmap avatar;
	bool active;
private slots:
	void tick();
protected:
	void paintEvent(QPaintEvent *event);
	void mousePressEvent(QMouseEvent *);
	void mouseReleaseEvent(QMouseEvent *);
private:
	float timebarHeight(int w) const;
	QPixmap seatRight,seatRightEmpty,seatRightEmptyTournament,seatRightActive,seatRightReserved;
	QPixmap seatLeft, seatLeftEmpty, seatLeftEmptyTournament,seatLeftActive,seatLeftReserved;
	QPixmap timebar,timebank;
	SeatObject *jsobj;
	TableSit *sitwindow;
	QFontMetrics *fontMetric;

	// cached from SeatInfo/User
	QByteArray userid;
	QString displayname;
	int chips;
	Poker::SeatInfo::PlayerStatus status;
	QFont font;
	QTimer ticker;
	qint64 keytime,maxtimebank;
	float timebarPercent;
	enum Timebarmode { tbmIdle,tbmTimebar,tbmTimebank };
	Timebarmode lastTimebarMode;
};
class SeatObject : public GameObject {
Q_OBJECT
public:
	SeatObject(TablePrivate *parent);
	bool active() { return seat->active; }
	void setActive(bool in) { seat->active = in; seat->updateSeat(); }
	bool reserved() { return _reserved; }
	void setReserved(bool in) { _reserved = in; seat->updateSeat(); }

	Q_PROPERTY(int seat READ getSeat WRITE setSeat)
	Q_PROPERTY(bool tournament READ getTourn WRITE setTourn)
	Q_PROPERTY(bool empty READ getEmpty WRITE setEmpty)
	Q_PROPERTY(QString avatar READ avatar WRITE setAvatar)
	Q_PROPERTY(bool left READ left WRITE setLeft)
	Q_PROPERTY(bool active READ active WRITE setActive)
	Q_PROPERTY(bool reserved READ reserved WRITE setReserved)
	int getSeat() { return seatIndex; }
	void setSeat(int in) { seatIndex = in; }
	bool getTourn() { return tournament; }
	void setTourn(bool in) { tournament = in; seat->updateSeat(); }
	bool getEmpty() { return empty; }
	void setEmpty(bool in) { empty = in; seat->updateSeat(); }
	void setAvatar(QString in);
	QString avatar() { return avatar_; }
	bool left() { return left_; }
	void setLeft(bool in) { left_ = in; seat->updateSeat(); }
	VisibleSeat *getSeatUi() { return seat; }
public slots:
	void updateInfo(Data::SeatInfo *info);
private slots:
	void replyFinished(QNetworkReply *reply);
private:
	VisibleSeat *seat;
	int seatIndex;
	bool tournament,empty,left_,_reserved;
	QString avatar_;
	QNetworkReply *pendingReply;
};
#endif // VISIBLE_SEAT_H
