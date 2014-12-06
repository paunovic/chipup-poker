#include <QPainter>
#include <QNetworkAccessManager>
#include <QNetworkReply>

#include "table/visible_seat.h"
#include "pokermain.h"
#include "table_sit.h"
#include "data/seatinfo.h"
#include "data/user.h"

VisibleSeat::VisibleSeat(TableUi *parent, SeatObject *jsobj)
	: GameObjectUi(parent), jsobj(jsobj), font("Barmeno") {
	font.setPointSize(7);
	font.setBold(true);
	fontMetric = new QFontMetrics(font);
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
VisibleSeat::~VisibleSeat() {
	delete fontMetric;
}
void VisibleSeat::paintEvent(QPaintEvent *) {
	//qDebug() << "seat redraw" << jsobj->getSeat();
	QPainter painter(this);
	painter.setFont(font);
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
	}
	painter.drawPixmap(0,0,width(),height(),pix);
	if (!jsobj->getEmpty()) {
		painter.setPen(QColor(255,0,0)); // FIXME, light grey
		QRect dn = fontMetric->boundingRect(displayname);
		dn.setWidth(dn.width()+5);
		int offset;
		if (keyside == Right) offset = 35;
		else offset = 60;
		offset -= dn.width() / 2;
		dn.translate(offset,15);
		qDebug() << dn << displayname;
		painter.drawText(dn,displayname);

		QString bottomline;
		painter.setPen(QColor(0,255,0)); // FIXME
		switch (status) {
		case Poker::SeatInfo::psOutOfPlay:
			bottomline = tr("Sitting Out");
			break;
		case Poker::SeatInfo::psInHand:
			bottomline = QString("%1").arg((float)chips/100);
		}
		if (bottomline.length() > 0) {
			QRect bb = fontMetric->boundingRect(bottomline);
			bb.setWidth(bb.width()+5);
			if (keyside == Right) offset = 35;
			else offset = 60;
			offset -= bb.width()/2;
			bb.translate(offset,30);
			qDebug() << bb;
			painter.drawText(bb,bottomline);
		}
	}
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
				updateInfo(seat);
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
void SeatObject::updateInfo(Data::SeatInfo *info) {
	seat->updateInfo(info);
}
void VisibleSeat::updateInfo(Data::SeatInfo *info) {
	Data::User *u = static_cast<Data::User*>(info->getUser());
	displayname = u->displayName();
	status = info->rawStatus();
	chips = info->chips();
}
