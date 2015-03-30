#include "animation.h"
#include "animatecore.h"
Animation::Animation(GameObject *obj, float endx, float endy, float duration, QScriptValue callback) :
	QObject(0), duration(duration*1000), endx(endx), endy(endy), obj(obj), callback(callback)
{
	start = animateCore->getTime();
	Q_ASSERT(obj);
	startx = obj->x();
	starty = obj->y();
	xdiff = endx - startx;
	ydiff = endy - starty;
	Q_ASSERT(startx >= 0);
	Q_ASSERT(startx + xdiff >= 0);
	qDebug() << "starting animation" << this << "at" << start << "with delay" << duration;
	connect(obj,SIGNAL(destroyed(QObject*)),this,SLOT(object_deleted(QObject*)));
}
void Animation::tick(int now) {
	qint64 elapsed = now - start;
	if (elapsed < 0) elapsed = 0;
	if (elapsed > duration) {
		qDebug() << this << "animation done";
		obj->setPosition(endx,endy);
		if (callback.isFunction()) {
			QScriptValueList args;
			callback.call(callback.engine()->globalObject(),args);
			if (callback.engine()->hasUncaughtException()) {
				qDebug() << callback.engine()->uncaughtExceptionBacktrace();
				qDebug() << callback.engine()->uncaughtException().toString();
				callback.engine()->clearExceptions();
			}
		} else {
			qWarning("no callback supplied");
		}
		animateCore->over(this);
		deleteLater();
		return;
	}
	float progress = (float)elapsed / duration;
	//float currentx = startx+(xdiff*progress);
	//float currenty = starty+(ydiff*progress);
	//qDebug() << this << QString("start:%1x%2 current:%3x%4 end:%5x%6 progress:%7 diff:%8x%9 elapsed:%10").arg(startx).arg(starty).arg(currentx).arg(currenty).arg(endx).arg(endy).arg(progress).arg(xdiff).arg(ydiff).arg(elapsed);
	obj->setPosition(startx+(xdiff*progress),starty+(ydiff*progress));
}
void Animation::object_deleted(QObject *) {
	if (animateCore) animateCore->over(this);
	deleteLater();
}
