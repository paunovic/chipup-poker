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

	Animation *a;
	foreach (a,animations) {
		a->tick(now);
	}
	if (animations.length() == 0) timer.stop();
}
qint64 AnimateCore::getTime() {
	if (testing) return time;
	else return core->getUptime();
}
void AnimateCore::addAnimation(Animation *ani) {
	animations.append(ani);
	if (!timer.isActive()) timer.start();
}
void AnimateCore::over(Animation *a) {
	animations.removeOne(a);
}
