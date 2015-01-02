#include "sound_effects.h"

#include <QDebug>
#include <QUrl>

SoundEffects::SoundEffects(QObject *parent): QObject(parent) {
	qDebug() << "loading sound";
#if (QT_VERSION >= QT_VERSION_CHECK(5, 0, 0))
	dealing = new QSoundEffect(this);
	dealing->setSource(QUrl("qrc:/resources/sounds/Dealing.wav"));
#else
	dealing = new QSound(":/resources/sounds/Dealing.wav",this);
#endif
	qDebug() << "loaded";
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
