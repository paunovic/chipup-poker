#include "selftest.h"

#include "ui_selftest.h"

#if (QT_VERSION <= QT_VERSION_CHECK(5, 0, 0))
#include <QSound>
#endif

SelfTests::SelfTests(): ui(new Ui::SelfTests) {
	ui->setupUi(this);
	ui->lbQtVersion->setText(qVersion());
#if (QT_VERSION >= QT_VERSION_CHECK(5, 0, 0))
	ui->lbAudioHelp->setText("no self-test yet");
#else
	if (QSound::isAvailable()) {
		ui->lbAudioHelp->setText("yes");
	} else {
#ifdef Q_OS_LINUX
		ui->lbAudioHelp->setText("no, check that nasd is running");
#else
		ui->lbAudioHelp->setText("no");
#endif
	}
#endif
}
