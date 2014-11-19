#include "test.h"

QTEST_MAIN(TestCase)

void TestCase::testsomething() {
	QVERIFY(true);
	QCOMPARE(5,5);
}