#include <QApplication>
#include <QFile>
#include <QDebug>
#include <QFontDatabase>
#include <QTranslator>

#include "loginwindow.h"
#include "pokermain.h"
#include "table/animatecore.h"

int main(int argc, char *argv[]) {
	QApplication a(argc, argv);
	
	QTranslator translator;
#if 0
	translator.load("chipuppoker_ru");
#else
	QString locale = QLocale::system().name();
	translator.load("chipuppoker_"+locale);
#endif
	a.installTranslator(&translator);

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
	QFontDatabase::addApplicationFont(":/resources/cards/CardCharacters.TTF");
	QFontDatabase::addApplicationFont(":/resources/seats/Barmeno-Bold.ttf");
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
