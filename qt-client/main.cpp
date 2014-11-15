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

    LoginWindow w;
    w.show();

    return a.exec();
}
