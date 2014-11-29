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
		timer.start();
	}
}
// TODO, delete animations when the window is closed
void AnimateCore::tick() {
	int now;
	if (testing) now = time;
	else now = core->getUptime();

	QList<Animation*>::Iterator i;
	for (i=animations.begin(); i!=animations.end(); ++i) {
		Animation *a = *i;
		a->tick(now);
	}
}
qint64 AnimateCore::getTime() {
	if (testing) return time;
	else return core->getUptime();
}
void AnimateCore::addAnimation(Animation *ani) {
	connect(ani,SIGNAL(destroyed(QObject*)),this,SLOT(over(QObject*)));
	animations.append(ani);
}
void AnimateCore::over(QObject *obj) {
	Animation *a = static_cast<Animation*>(obj);
	animations.removeOne(a);
}
