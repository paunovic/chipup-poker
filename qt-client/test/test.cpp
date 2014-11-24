#include "test.h"
#include "tableprivate.h"

void TestCase::testsomething_data() {
	//QSharedPointer<Data::TableStatus> ts(new Data::TableStatus);
	//QTest::addColumn<Data::TableStatus>("tableStatus");
	QTest::addColumn<int>("seats");
	QTest::newRow("empty") << 0;
	QTest::newRow("one") << 1;
	QTest::newRow("two") << 2;
}
void TestCase::testsomething() {
	TablePrivate p;
	QSharedPointer<Data::TableStatus> ts(new Data::TableStatus);
	QFETCH(int,seats);
	QFile input("../table.js");
	if (!input.open(QIODevice::ReadOnly | QIODevice::Text)) {
		qDebug() << "failed to load js";
	} else {
		QTextStream stream(&input);
		QString code = stream.readAll();
		input.close();
		p.loadJs(code,"table.js");
	}
	for (int i=0; i<seats; i++) {
		Data::SeatInfo *seat = new Data::SeatInfo;
		seat->seat_index = i;
		QCOMPARE(seat->property("seat_index").isNull(),false);
		QCOMPARE(seat->property("seat_index").toInt(),i);
		ts->seats.append(seat);
	}
	p.table_status(ts);
	QVERIFY(true);
	QCOMPARE(5,5);
}
