#include "sound_effects.h"

#include <QDebug>
#include <QUrl>

SoundEffects::SoundEffects(QObject *parent): QObject(parent) {
	qDebug() << "loading sound";
#if (QT_VERSION >= QT_VERSION_CHECK(5, 0, 0))
	dealing = new QSoundEffect(this);
	dealing->setSource(QUrl("qrc:/resources/sounds/Dealing.wav"));
	putChipsSmall = new QSoundEffect(this);
	putChipsSmall->setSource(QUrl("qrc:/resources/sounds/PutChipsSmall.wav"));
	timebank = new QSoundEffect(this);
	timebank->setSource(QUrl("qrc:/resources/sounds/Timebank.wav"));
#else
	dealing = new QSound(":/resources/sounds/Dealing.wav",this);
#endif
	qDebug() << "loaded";
}
void SoundEffects::PlaySound(enum SoundId soundId) {
	qDebug() << "starting sound" << ((int)soundId);
	switch (soundId) {
	case Dealing:
		dealing->play();
		break;
	case PutChipsSmall:
		putChipsSmall->play();
		break;
	case TimeBank:
		timebank->play();
		break;
	}
}
