#include <QPainter>
#include <QNetworkAccessManager>
#include <QNetworkReply>

#include "table/visible_seat.h"
#include "pokermain.h"
#include "table_sit.h"
#include "data/seatinfo.h"
#include "data/user.h"

VisibleSeat::VisibleSeat(TableUi *parent, SeatObject *jsobj)
	: GameObjectUi(parent), jsobj(jsobj), fontMetric(QFont("Barmeno")) {
	sitwindow = NULL;
	//qDebug() << __func__ << "create" << parent;
	seatRight = QPixmap(":/resources/seats/SeatRight.png");
	seatRightEmpty = QPixmap(":/resources/seats/SeatRightEmpty.png");
	seatRightEmptyTournament = QPixmap(":/resources/seats/SeatRightEmptyTournament.png");
	seatLeft = QPixmap(":/resources/seats/SeatLeft.png");
	seatLeftEmpty = QPixmap(":/resources/seats/SeatLeftEmpty.png");
	seatLeftEmptyTournament = QPixmap(":/resources/seats/SeatLeftEmptyTournament.png");
	updateSeat();
}
void VisibleSeat::paintEvent(QPaintEvent *) {
	//qDebug() << "seat redraw" << jsobj->getSeat();
	QPainter painter(this);
	//painter.setPen(Qt::NoPen);
	//painter.setBrush(QColor(127,0,0));
	//if (keyside == Right) painter.drawRect(62,4,23,23);
	if (!jsobj->getEmpty()) {
		if (avatar.width()) {
			int x;
			if (keyside == Right) x = 62;
			else x = 5;
			painter.drawPixmap(x,4,23,23,avatar);
		} else qWarning("avatar missing from a seat");
		QRect dn = fontMetric.boundingRect(displayname);
		qDebug() << dn;
	}
	painter.drawPixmap(0,0,width(),height(),pix);
}
SeatObject::SeatObject(TablePrivate *root) : GameObject(root) {
	pendingReply = 0;
	left_ = false;
	empty = true;
	tournament = false;
	connect(core->manager(), SIGNAL(finished(QNetworkReply*)),this, SLOT(replyFinished(QNetworkReply*)));

	//qDebug() << "table info" << root->getUi()->size() << root->getUi()->pos();
	internal = seat = new VisibleSeat(root->getUi(),this);
	root->getUi()->addElement(internal);
	//qDebug() << "seat info" << internal->size() << internal->pos() << internal->isVisible() << internal->isHidden();
}
void VisibleSeat::mousePressEvent(QMouseEvent *) {
	qDebug() << jsobj->getSeat();
}
void VisibleSeat::mouseReleaseEvent(QMouseEvent *) {
	qDebug() << "release";
	QSharedPointer<Data::TableStatus> ts = jsobj->getTable()->getLastTs();
	sitwindow = new TableSit(jsobj->getTable()->getRawGame(),jsobj->getSeat(),ts);
	sitwindow->show();
}
void VisibleSeat::updateSeat() {
	if (jsobj->getEmpty()) {
		if (jsobj->getTourn()) {
			if (jsobj->left()) pix = seatLeftEmptyTournament;
			else pix = seatRightEmptyTournament;
		} else {
			if (jsobj->left()) pix = seatLeftEmpty;
			else pix = seatRightEmpty;
		}
	} else {
		if (jsobj->left()) pix = seatLeft;
		else pix = seatRight;
		QSharedPointer<Data::TableStatus> ts = jsobj->getTable()->getLastTs();
		QList<Data::SeatInfo*>::Iterator i;
		int seatindex = jsobj->getSeat();
		for (i=ts->seats.begin(); i!=ts->seats.end(); ++i) {
			Data::SeatInfo *seat = *i;
			if (seat->getSeatIndex() == seatindex) {
				qDebug() << "finding self" << jsobj->getSeat() << seat->getSeatIndex();
				Data::User *u = static_cast<Data::User*>(seat->getUser());
				displayname = u->displayName();
			}
		}
	}
	update();
}
void SeatObject::setAvatar(QString in) {
	if (in.length() == 0) in = "default";
	if (in != avatar_) {
		qDebug() << "fetching avatar?" << in << "for seat" << getSeat();
		avatar_ = in;
		pendingReply = core->manager()->get(QNetworkRequest("https://chipuppoker.com/getavatar?id="+in));
	}
}
void SeatObject::replyFinished(QNetworkReply *reply) {
	if (reply == pendingReply) {
		qDebug() << "got reply for seat" << getSeat();
		QByteArray image = reply->readAll();
		seat->avatar.loadFromData(image);
		seat->update();
		pendingReply->deleteLater();
		pendingReply = 0;
	}
}
