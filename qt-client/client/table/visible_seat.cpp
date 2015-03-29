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
	font.setBold(false);
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
void VisibleSeat::setAvatar(QPixmap in) {
	avatar = in;
	resizeEvent(0);
	update();
}
void VisibleSeat::resizeEvent(QResizeEvent*) {
	int targetheight = heightForWidth(width());
	float width = this->width() * 0.27;
	float height;
	if (avatar.width()) {
		height = ((qreal)avatar.height()*width)/avatar.width();
	} else {
		height = width;
		qWarning("avatar missing from a seat");
	}
	float x,y;
	if (jsobj->left()) x = this->width() * 0.68;
	else x = this->width() * 0.05;
	y = targetheight * 0.13;
	avatarLocation = QRectF(x,y,width,height);

	// top line
	if (jsobj->left()) x = this->width() * 0.05;
	else x = this->width() * 0.4;
	y = this->height() * 0.05;
	width = this->width() * 0.5;
	height = targetheight * 0.4;
	line1 = QRectF(x,y,width,height);
	
	// bottom line
	if (jsobj->left()) x = this->width() * 0.05;
	else x = this->width() * 0.4;
	y = this->height() * 0.45;
	width = this->width() * 0.5;
	height = targetheight * 0.4;
	line2 = QRectF(x,y,width,height);
	
	int pixelsize = (qreal)this->width() * 0.11;
	font.setPixelSize(pixelsize);
	delete fontMetric;
	fontMetric = new QFontMetrics(font);
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
	if (!jsobj->getEmpty()) {
		if (avatar.width()) painter.drawPixmap(avatarLocation,avatar,QRectF());
		else qWarning("avatar missing from a seat");
	}
	painter.drawPixmap(0,0,width(),targetheight,pix);
	if (!jsobj->getEmpty()) {
		painter.setPen(QColor(198,198,198));
		QRect dn = fontMetric->boundingRect(displayname);
		//qDebug() << dn << displayname << line1;
		dn.translate(line1.x() + ((line1.width() - dn.width())/2),line1.y() + (dn.y()*-1));
		//qDebug() << dn << displayname << line1;
		painter.drawText(dn.bottomLeft(),displayname);

		QString bottomline;
		painter.setPen(QColor(138,194,62));
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
			bb.translate(line2.x() + ((line2.width() - bb.width())/2),line2.y() + (bb.y()*-1));
			//qDebug() << bb << line2;
			painter.drawText(bb.bottomLeft(),bottomline);
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
		if (jsobj->reserved()) {
			qDebug() << "that seat is reserved!";
			return;
		}
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
		QPixmap cache;
		if (core->loadCachedAvatar(in,&cache)) {
			seat->setAvatar(cache);
		} else {
			pendingReply = core->manager()->get(QNetworkRequest(QString("https://%1/getavatar?id=%2").arg(core->serverAddress).arg(in)));
		}
	}
}
void SeatObject::replyFinished(QNetworkReply *reply) {
	if (reply == pendingReply) {
		qDebug() << "got reply for seat" << getSeat();
		QByteArray image = reply->readAll();
		QPixmap loader;
		loader.loadFromData(image);
		seat->setAvatar(loader);
		pendingReply->deleteLater();
		pendingReply = 0;
		core->saveAvatar(avatar_,image);
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
