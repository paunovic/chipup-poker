#include <QtTest/QtTest>

class TestCase : public QObject {
Q_OBJECT
private slots:
	void initTestCase();
	void cleanupTestCase();
	void testsomething_data();
	void testsomething();
	void rendercards();
	void animate();
	void renderChips_data();
	void renderChips();
};
