#include <QObject>

#if (QT_VERSION >= QT_VERSION_CHECK(5, 0, 0))
#include <QSoundEffect>
#define SOUND_TYPE QSoundEffect
#else
#include <QSound>
#define SOUND_TYPE QSound
#endif

class SoundEffects : public QObject {
Q_OBJECT
public:
	SoundEffects(QObject *parent);

	enum SoundId {
		Dealing=0,
		PutChipsSmall,
		TimeBank
	};

	void PlaySound(enum SoundId soundId);

private:
	SOUND_TYPE *dealing,*putChipsSmall,*timebank;
};
