#include "sound_effects.h"

#include <QDebug>
#include <QUrl>
#include <QDir>
#include <QDesktopServices>

SoundEffects::SoundEffects(QObject *parent): QObject(parent) {
	//qDebug() << "loading sound";
#if (QT_VERSION >= QT_VERSION_CHECK(5, 0, 0))
	dealing = new QSoundEffect(this);
	dealing->setSource(QUrl("qrc:/resources/sounds/Dealing.wav"));
	putChipsSmall = new QSoundEffect(this);
	putChipsSmall->setSource(QUrl("qrc:/resources/sounds/PutChipsSmall.wav"));
	timebank = new QSoundEffect(this);
	timebank->setSource(QUrl("qrc:/resources/sounds/Timebank.wav"));
#else
	qDebug() << "sound available?" << QSound::isAvailable();
	QDir tempdir(QDesktopServices::storageLocation(QDesktopServices::TempLocation));
	if (!tempdir.exists("chipuppoker")) tempdir.mkpath("chipuppoker");
	tempdir.cd("chipuppoker");
	QDir sourceDir(":/resources/sounds/");
	QStringList files = sourceDir.entryList();
	// TODO, check that the size matches atleast
	foreach (QString file , files) {
		QFile input(sourceDir.absoluteFilePath(file));
		if (tempdir.exists(file)) continue;
		qDebug() << "not found, creating" << file;
		if (!input.open(QIODevice::ReadOnly)) {
			qDebug() << "failed to read sound resource";
			continue;
		} else {
			QFile output(tempdir.absoluteFilePath(file));
			if (!output.open(QIODevice::WriteOnly)) {
				qDebug() << "failed to open sound output" << tempdir.absoluteFilePath(file);
				continue;
			} else {
				output.write(input.readAll());
			}
		}
	}
	//qDebug() << tempdir;
	dealing = new QSound(tempdir.absoluteFilePath("Dealing.wav"),this);
	putChipsSmall = new QSound(tempdir.absoluteFilePath("PutChipsSmall.wav"),this);
	timebank = new QSound(tempdir.absoluteFilePath("Timebank.wav"),this);
#endif
	//qDebug() << "loaded";
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
