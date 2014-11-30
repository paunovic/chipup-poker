#include "animation.h"
#include "animatecore.h"
Animation::Animation(GameObject *obj, float endx, float endy, float duration) :
    QObject(0), duration(duration*1000), endx(endx), endy(endy), obj(obj)
{
	start = animateCore->getTime();
	startx = obj->x();
	starty = obj->y();
	xdiff = endx - startx;
	ydiff = endy = starty;
}
void Animation::tick(int now) {
	qint64 elapsed = now - start;
	if (elapsed > duration) {
		qDebug() << "animation over";
		deleteLater();
		// TODO, fire callback in js
		obj->setPosition(endx,endy);
		return;
	}
	float progress = (float)elapsed / duration;
	obj->setPosition(startx+(xdiff*progress),starty+(ydiff*progress));
}
