#include <QPainter>
#include <QNetworkAccessManager>
#include <QNetworkReply>

#include "table/visible_seat.h"
#include "pokermain.h"
#include "table_sit.h"
#include "data/seatinfo.h"
#include "data/user.h"
#include "sound_effects.h"

VisibleSeat::VisibleSeat(TableUi *parent, SeatObject *jsobj)
	: GameObjectUi(parent), active(false), jsobj(jsobj), font("Barmeno") {
	font.setPointSize(7);
	font.setBold(true);
	fontMetric = new QFontMetrics(font);
	sitwindow = NULL;
	//qDebug() << __func__ << "create" << parent;
	seatRight = QPixmap(":/resources/seats/SeatRight.png");
	seatRightActive = QPixmap(":/resources/seats/SeatRightActive.png");
	seatRightEmpty = QPixmap(":/resources/seats/SeatRightEmpty.png");
	seatRightEmptyTournament = QPixmap(":/resources/seats/SeatRightEmptyTournament.png");
	seatRightReserved = QPixmap(":/resources/seats/SeatRightReserved.png");
	seatLeft = QPixmap(":/resources/seats/SeatLeft.png");
	seatLeftActive = QPixmap(":/resources/seats/SeatLeftActive.png");
	seatLeftEmpty = QPixmap(":/resources/seats/SeatLeftEmpty.png");
	seatLeftEmptyTournament = QPixmap(":/resources/seats/SeatLeftEmptyTournament.png");
	seatLeftReserved = QPixmap(":/resources/seats/SeatLeftReserved.png");
	timebar = QPixmap(":/resources/table/Timebar.png");
	timebank = QPixmap(":/resources/table/Timebank.png");
	updateSeat();
	ticker.setSingleShot(false);
	ticker.setInterval(100);
	connect(&ticker,SIGNAL(timeout()),this,SLOT(tick()));
	lastTimebarMode = tbmIdle;
}
VisibleSeat::~VisibleSeat() {
	delete fontMetric;
}
void VisibleSeat::paintEvent(QPaintEvent *) {
	//qDebug() << "seat redraw" << jsobj->getSeat();
	QPainter painter(this);
	painter.setFont(font);
	painter.setRenderHints(QPainter::SmoothPixmapTransform);
	//painter.setPen(Qt::NoPen);
	//painter.setBrush(QColor(127,0,0));
	//if (keyside == Right) painter.drawRect(62,4,23,23);
	int targetheight = heightForWidth(width());
	float avatar_x = 0;
	float avatar_width = 0;
	if (!jsobj->getEmpty()) {
		if (avatar.width()) {
			if (keyside == Right) avatar_x = width() * 0.69;
			else avatar_x = width() * 0.05;
			float y = targetheight * 0.13;
			avatar_width = width() * 0.26;
			float avatar_height = ((qreal)avatar.height()*avatar_width)/avatar.width();
			QRectF corner(avatar_x,y,avatar_width,avatar_height);
			painter.drawPixmap(corner,avatar,QRectF());
		} else qWarning("avatar missing from a seat");
	}
	painter.drawPixmap(0,0,width(),targetheight,pix);
	if (!jsobj->getEmpty()) {
		painter.setPen(QColor(255,0,0)); // FIXME, light grey
		QRect dn = fontMetric->boundingRect(displayname);
		dn.setWidth(dn.width()+5);
		int offset;
		if (keyside == Right) offset = 35;
		else offset = width() - avatar_width;
		offset -= dn.width() / 2;
		dn.translate(offset,15);
		//qDebug() << dn << displayname;
		painter.drawText(dn,displayname);

		QString bottomline;
		painter.setPen(QColor(0,255,0)); // FIXME
		switch (status) {
		case Poker::SeatInfo::psOutOfPlay:
			bottomline = tr("Sitting Out");
			break;
		case Poker::SeatInfo::psInHand:
		case Poker::SeatInfo::psOutOfHand:
		case Poker::SeatInfo::psFolded:
		case Poker::SeatInfo::psAllIn:
			bottomline = QString("%1").arg((double)chips/100);
		}
		if (bottomline.length() > 0) {
			QRect bb = fontMetric->boundingRect(bottomline);
			bb.setWidth(bb.width()+5);
			if (keyside == Right) offset = 35;
			else offset = width() - avatar_width;
			offset -= bb.width()/2;
			bb.translate(offset,30);
			//qDebug() << bb;
			painter.drawText(bb,bottomline);
		}
	}
	painter.setPen(QColor(255,0,0));
	painter.setBrush(QColor(0,255,0));
	QRectF timebarSize(0,targetheight-1,width(),timebarHeight(width()));
	QRectF source(0,0,timebar.width(),timebar.height());
	if (timebarPercent > 0) {
		timebarSize.setWidth(timebarSize.width() * timebarPercent);
		source.setWidth(source.width() * timebarPercent);
		painter.drawPixmap(timebarSize,timebar,source);
		lastTimebarMode = tbmTimebar;
	} else if (timebarPercent < 0) {
		if (lastTimebarMode == tbmTimebar) {
			if (core->self()->id == userid) {
				core->effects()->PlaySound(SoundEffects::TimeBank);
			}
		}
		float newpercent = timebarPercent + 1;
		if (newpercent < 0) newpercent = 0;
		timebarSize.setWidth(timebarSize.width() * newpercent);
		source.setWidth(source.width() * newpercent);
		painter.drawPixmap(timebarSize,timebank,source);
		lastTimebarMode = tbmTimebank;
	} else {
		lastTimebarMode = tbmIdle;
	}
	//painter.drawRect(timebarSize);
}
QSize VisibleSeat::sizeHint() const {
	QSize oldsize = GameObjectUi::sizeHint();
	oldsize.setHeight(oldsize.height() + timebarHeight(oldsize.width()));
	return oldsize;
}
float VisibleSeat::timebarHeight(int w) const {
	//qDebug() << timebar.height() << w << timebar.width();
	return ((float)timebar.height()*w)/timebar.width();
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
	//qDebug() << __func__ << jsobj->getSeat();
}
void VisibleSeat::mouseReleaseEvent(QMouseEvent *) {
	qDebug() << "release" << jsobj->getSeat();
	Data::SeatInfo *my_seat = jsobj->getTable()->findMySeat();
	if (my_seat) {
		if (my_seat->seat_index != jsobj->getSeat()) { // you clicked a seat thats not yours, while sitting
			return;
		} else {
			qDebug() << "TODO, add-on";
		}
	} else {
		QSharedPointer<Data::TableStatus> ts = jsobj->getTable()->getLastTs();
		sitwindow = new TableSit(jsobj->getTable()->getRawGame(),jsobj->getSeat(),ts);
		sitwindow->show();
	}
}
void VisibleSeat::updateSeat() {
	Q_ASSERT(jsobj);
	if (jsobj->getEmpty()) {
		ticker.stop();
		keytime = 0;
		timebarPercent = 0;
		userid.clear();
		if (jsobj->getTourn()) {
			if (jsobj->left()) pix = seatLeftEmptyTournament;
			else pix = seatRightEmptyTournament;
		} else {
			if (jsobj->reserved()) {
				if (jsobj->left()) pix = seatLeftReserved;
				else pix = seatRightReserved;
			} else {
				if (jsobj->left()) pix = seatLeftEmpty;
				else pix = seatRightEmpty;
			}
		}
	} else {
		if (active) {
			if (jsobj->left()) pix = seatLeftActive;
			else pix = seatRightActive;
		} else {
			if (jsobj->left()) pix = seatLeft;
			else pix = seatRight;
		}
		QSharedPointer<Data::TableStatus> ts = jsobj->getTable()->getLastTs();
		QList<Data::SeatInfo*>::Iterator i;
		int seatindex = jsobj->getSeat();
		for (i=ts->seats.begin(); i!=ts->seats.end(); ++i) {
			Data::SeatInfo *seat = *i;
			if (seat->getSeatIndex() == seatindex) {
				//qDebug() << "finding self" << jsobj->getSeat() << seat->getSeatIndex();
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
		pendingReply = core->manager()->get(QNetworkRequest(QString("https://%1/getavatar?id=%2").arg(core->serverAddress).arg(in)));
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
void VisibleSeat::tick() {
	int diff = keytime - core->getServerTime();
	if (diff > 0) {
		timebarPercent = (float)diff / (core->max_play_time*1000);
		if (timebarPercent > 1) timebarPercent = 1;
		update();
	} else {
		timebarPercent = (float)diff / maxtimebank;
		qDebug() << "timebank debug" << diff << timebarPercent;
		update();
	}
}
void VisibleSeat::updateInfo(Data::SeatInfo *info) {
	QSharedPointer<Data::TableStatus> ts = jsobj->getTable()->getLastTs();
	if (ts->current_seat == info->seat_index) {
		keytime = ts->time;
		maxtimebank = info->timebank();
		ticker.start();
	} else {
		ticker.stop();
		keytime = 0;
		timebarPercent = 0;
	}
	Data::User *u = static_cast<Data::User*>(info->getUser());
	if (u) {
		displayname = u->displayName();
	}
	status = info->rawStatus();
	chips = info->chips();
	userid = info->userid;
	update();
}
