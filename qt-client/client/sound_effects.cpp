#include "sound_effects.h"

#include <QDebug>

SoundEffects::SoundEffects(QObject *parent): QObject(parent) {
	qDebug() << "loading sound";
	dealing = new SOUND_TYPE(":/resources/sounds/Dealing.wav",this);
	qDebug() << "loaded";
	dealing->setLoops(-1);
}
void SoundEffects::PlaySound(enum SoundId soundId) {
	qDebug() << "starting sound";
	switch (soundId) {
	case Dealing:
		dealing->play();
		qDebug() << "started";
		break;
	}
}
