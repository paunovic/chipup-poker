#include <QtTest/QtTest>

class TestCase : public QObject {
Q_OBJECT
private slots:
	void testsomething_data();
	void testsomething();
	void rendercards();
	void animate();
};
