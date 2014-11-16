#include <QApplication>
#include <QFile>
#include <QDebug>

#include "loginwindow.h"
#include "pokermain.h"

int main(int argc, char *argv[])
{
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
    core = new PokerMain();
	core->app = &a;

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
