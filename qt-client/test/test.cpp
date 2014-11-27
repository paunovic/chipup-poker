#include "test.h"
#include "tableprivate.h"
#include "../client/data/seatinfo.h"
#include "../client/data/user.h"

void TestCase::testsomething_data() {
	//QSharedPointer<Data::TableStatus> ts(new Data::TableStatus);
	//QTest::addColumn<Data::TableStatus>("tableStatus");
	QTest::addColumn<int>("seats");
	QTest::newRow("empty") << 0;
	QTest::newRow("one") << 1;
	QTest::newRow("two") << 2;
}
void TestCase::testsomething() {
	int result;
	TablePrivate p;
	PokerMain pm;
	core = &pm;
	QSharedPointer<Data::TableStatus> ts(new Data::TableStatus);
	QWidget root;
	QGridLayout grid;
	root.setLayout(&grid);
	p.setupUi(&root,&grid);
	QFETCH(int,seats);
	Data::Game g;
	p.setGame(&g);
	QFile input("../client/table.js");
	if (!input.open(QIODevice::ReadOnly | QIODevice::Text)) {
		qDebug() << "failed to load js";
		QVERIFY(false);
	} else {
		QTextStream stream(&input);
		QString code = stream.readAll();
		input.close();
		result = p.loadJs(code,"table.js");
		QVERIFY(result);
	}
	for (int i=0; i<seats; i++) {
		Data::SeatInfo *seat = new Data::SeatInfo(&pm);
		seat->seat_index = i;
		QByteArray id;
		id[0] = i;
		seat->userid = id;
		QCOMPARE(seat->property("seat_index").isNull(),false);
		QCOMPARE(seat->property("seat_index").toInt(),i);
		ts->seats.append(seat);
		Data::User *u = new Data::User(&pm);
		u->id = id;
		pm.users.append(u);
	}
	result = p.table_status(ts);
	QVERIFY(result);
	QCOMPARE(5,5);
	core = 0;
}
