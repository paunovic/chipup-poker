#include "animatecore.h"
#include "pokermain.h"

AnimateCore *animateCore;

AnimateCore::AnimateCore(bool testing) :
	QObject(0), testing(testing)
{
	if (testing) {
		time = 0;
	} else {
		connect(&timer,SIGNAL(timeout()),this,SLOT(tick()));
		timer.setInterval(16);
	}
}
// TODO, delete animations when the window is closed
void AnimateCore::tick() {
	int now = getTime();
	qDebug() << "uptime" << now;

	Animation *a;
	foreach (a,animations) {
		a->tick(now);
	}
	if (animations.length() == 0) timer.stop();
}
qint64 AnimateCore::getTime() {
	if (testing) return time;
	else return core->getUptime()/4;
}
void AnimateCore::addAnimation(Animation *ani) {
	connect(ani,SIGNAL(destroyed(QObject*)),this,SLOT(over(QObject*)));
	animations.append(ani);
	if (!timer.isActive()) timer.start();
}
void AnimateCore::over(QObject *obj) {
	Animation *a = static_cast<Animation*>(obj);
	animations.removeOne(a);
}
