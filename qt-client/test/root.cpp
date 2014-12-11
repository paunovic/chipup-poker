#include "test.h"

//#define QApplication QCoreApplication

#if 1
QTEST_MAIN(TestCase)
#else
int main(int argc, char *argv[]) {
	QApplication app(argc, argv);
	QFile styles(":/stylesheet.css");
	if (!styles.open(QIODevice::ReadOnly | QIODevice::Text)) {
		qDebug() << "failed to load css";
	} else {
		QByteArray buffer;
		while (!styles.atEnd()) {
			buffer.append(styles.readAll());
		}
		QString css(buffer);
		qDebug() << css;
		app.setStyleSheet(css);
	}
	app.setAttribute(Qt::AA_Use96Dpi, true);
	QTEST_DISABLE_KEYPAD_NAVIGATION
	TestCase tc;
	return QTest::qExec(&tc, argc, argv);
}
#endif
