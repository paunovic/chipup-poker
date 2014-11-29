#include <QApplication>
#include <QFile>
#include <QDebug>
#include <QResource>
#include <QFontDatabase>

#include "loginwindow.h"
#include "pokermain.h"
#include "table/animatecore.h"

int main(int argc, char *argv[]) {
    QApplication a(argc, argv);
	QFile styles(":/stylesheet.css");
	if (!styles.open(QIODevice::ReadOnly | QIODevice::Text)) {
		qDebug() << "failed to load css";
	} else {
		QByteArray buffer;
		while (!styles.atEnd()) {
			buffer.append(styles.readAll());
		}
		QString css(buffer);
		a.setStyleSheet(css);
	}
	QResource::registerResource("scripts.rcc");
	int fontid = QFontDatabase::addApplicationFont(":/resources/cards/CardCharacters.TTF");
	core = new PokerMain();
	core->app = &a;
	animateCore = new AnimateCore(false);

	LoginWindow *w = new LoginWindow;
	w->show();

	int ret = a.exec();
	while (core->delayQuit) {
		//qDebug() << "delaying quit?" << core->delayQuit;
		a.processEvents(QEventLoop::AllEvents,10000);
	}
	qDebug() << "ret code" << ret;
	return ret;
}
