#ifndef ANIMATION_H
#define ANIMATION_H

#include <QObject>

#include "tableprivate.h"

class AnimateCore;

class Animation : public QObject
{
	Q_OBJECT
public:
	explicit Animation(GameObject *obj, float endx, float endy, float duration);

signals:

public slots:
	void tick(int now);
private:
	qint64 start;
	int duration;
	float startx,starty, endx,endy, xdiff,ydiff;
	GameObject *obj;
};

#endif // ANIMATION_H
