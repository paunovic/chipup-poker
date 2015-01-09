#include "animation.h"
#include "animatecore.h"
Animation::Animation(GameObject *obj, float endx, float endy, float duration, QScriptValue callback) :
    QObject(0), duration(duration*1000), endx(endx), endy(endy), obj(obj), callback(callback)
{
	start = animateCore->getTime();
	startx = obj->x();
	starty = obj->y();
	xdiff = endx - startx;
	ydiff = endy - starty;
	qDebug() << "uptime" << this << start;
}
void Animation::tick(int now) {
	qint64 elapsed = now - start;
	if (elapsed > duration) {
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
		deleteLater();
		obj->setPosition(endx,endy);
		return;
	}
	float progress = (float)elapsed / duration;
	float currentx = startx+(xdiff*progress);
	float currenty = starty+(ydiff*progress);
	qDebug() << this << QString("start:%1x%2 current:%3x%4 end:%5x%6 progress:%7 diff:%8x%9 elapsed:%10").arg(startx).arg(starty).arg(currentx).arg(currenty).arg(endx).arg(endy).arg(progress).arg(xdiff).arg(ydiff).arg(elapsed);
	obj->setPosition(startx+(xdiff*progress),starty+(ydiff*progress));
}
