#ifndef VISIBLE_SEAT_H
#define VISIBLE_SEAT_H

#include <QFontMetrics>

#include "tableprivate.h"

class QNetworkReply;
class TableSit;

class VisibleSeat : public GameObjectUi {
Q_OBJECT
public:
	VisibleSeat(TableUi *parent, SeatObject *jsobj);
	void updateSeat();
	QPixmap avatar;
protected:
	void paintEvent(QPaintEvent *event);
	void mousePressEvent(QMouseEvent *);
	void mouseReleaseEvent(QMouseEvent *);
private:
	QPixmap seatRight,seatRightEmpty,seatRightEmptyTournament;
	QPixmap seatLeft, seatLeftEmpty, seatLeftEmptyTournament;
	SeatObject *jsobj;
	TableSit *sitwindow;
	QFontMetrics fontMetric;
	QString displayname;
};
class SeatObject : public GameObject {
Q_OBJECT
public:
	SeatObject(TablePrivate *parent);

	Q_PROPERTY(int seat READ getSeat WRITE setSeat)
	Q_PROPERTY(bool tournament READ getTourn WRITE setTourn)
	Q_PROPERTY(bool empty READ getEmpty WRITE setEmpty)
	Q_PROPERTY(QString avatar READ avatar WRITE setAvatar)
	Q_PROPERTY(bool left READ left WRITE setLeft)
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
private slots:
	void replyFinished(QNetworkReply *reply);
private:
	VisibleSeat *seat;
	int seatIndex;
	bool tournament,empty,left_;
	QString avatar_;
	QNetworkReply *pendingReply;
};
#endif // VISIBLE_SEAT_H
