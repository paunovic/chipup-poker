#ifndef ANIMATECORE_H
#define ANIMATECORE_H

#include <QObject>
#include <QTimer>

#include "animation.h"

class AnimateCore : public QObject
{
	Q_OBJECT
public:
	explicit AnimateCore(bool testing);
	void addAnimation(Animation *ani);
	qint64 getTime();
	void setTime(qint64 in) { time = in; }
	int animationCount() { return animations.length(); }
	void over(Animation *obj);

signals:

public slots:
	void tick();

private:
	QList<Animation*> animations;
	qint64 time;
	bool testing;
	QTimer timer;
};

extern AnimateCore *animateCore;

#endif // ANIMATECORE_H
