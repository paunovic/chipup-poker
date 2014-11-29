#include <QPainter>
#include <QNetworkAccessManager>
#include <QNetworkReply>

#include "table/visible_seat.h"
#include "pokermain.h"

VisibleSeat::VisibleSeat(TableUi *parent, SeatObject *jsobj) : GameObjectUi(parent), jsobj(jsobj) {
	qDebug() << __func__ << "create" << parent;
	seatRight = QPixmap(":/resources/seats/SeatRight.png");
	seatRightEmpty = QPixmap(":/resources/seats/SeatRightEmpty.png");
	seatRightEmptyTournament = QPixmap(":/resources/seats/SeatRightEmptyTournament.png");
	seatLeft = QPixmap(":/resources/seats/SeatLeft.png");
	seatLeftEmpty = QPixmap(":/resources/seats/SeatLeftEmpty.png");
	seatLeftEmptyTournament = QPixmap(":/resources/seats/SeatLeftEmptyTournament.png");
	updateSeat();
}
void VisibleSeat::paintEvent(QPaintEvent *) {
	QPainter painter(this);
	//painter.setPen(Qt::NoPen);
	//painter.setBrush(QColor(127,0,0));
	//painter.drawRect(5,4,23,23);
	if (avatar.width()) {
		painter.drawPixmap(5,4,23,23,avatar);
	}
	painter.drawPixmap(0,0,width(),height(),pix);
}
SeatObject::SeatObject(TablePrivate *root) : GameObject(root) {
	pendingReply = 0;
	left_ = false;
	empty = true;
	tournament = false;
	connect(core->manager(), SIGNAL(finished(QNetworkReply*)),this, SLOT(replyFinished(QNetworkReply*)));

	qDebug() << "table info" << root->getUi()->size() << root->getUi()->pos();
	internal = seat = new VisibleSeat(root->getUi(),this);
	root->getUi()->addElement(internal);
	qDebug() << "seat info" << internal->size() << internal->pos() << internal->isVisible() << internal->isHidden();
}
void VisibleSeat::mousePressEvent(QMouseEvent *) {
	qDebug() << jsobj->getSeat();
}
void VisibleSeat::mouseReleaseEvent(QMouseEvent *) {
	qDebug() << "release";
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
	}
	update();
}
void SeatObject::setAvatar(QString in) {
	if (in.length() == 0) in = "default";
	if (in != avatar_) {
		qDebug() << "fetching avatar?" << in;
		avatar_ = in;
		pendingReply = core->manager()->get(QNetworkRequest("https://chipuppoker.com/getavatar?id="+in));
	}
}
void SeatObject::replyFinished(QNetworkReply *reply) {
	if (reply == pendingReply) {
		qDebug() << "got reply";
		QByteArray image = reply->readAll();
		seat->avatar.loadFromData(image);
		seat->update();
		pendingReply->deleteLater();
		pendingReply = 0;
	}
}
