#include <QFontDatabase>

#include "test.h"
#include "tableprivate.h"
#include "../client/data/seatinfo.h"
#include "../client/data/user.h"
#include "table/animatecore.h"

int fontid;
void TestCase::initTestCase() {
	fontid = QFontDatabase::addApplicationFont(":/resources/cards/CardCharacters.TTF");
}
void TestCase::cleanupTestCase() {
	QFontDatabase::removeApplicationFont(fontid);
	QApplication::sendPostedEvents(0, QEvent::DeferredDelete);
}
void TestCase::testsomething_data() {
	//QSharedPointer<Data::TableStatus> ts(new Data::TableStatus);
	//QTest::addColumn<Data::TableStatus>("tableStatus");
	QTest::addColumn<int>("filled");
	QTest::addColumn<QString>("output");
	QTest::addColumn<int>("seats");
	QTest::newRow("empty") << 0 << "zero" << 15;
	QTest::newRow("one") << 1 << "one" << 2;
	QTest::newRow("two") << 2 << "two" << 2;
	QTest::newRow("five") << 2 << "five" << 5;
	QTest::newRow("ten") << 2 << "ten" << 10;
}
void TestCase::rendercards() {
	int result;
	TablePrivate p;
	PokerMain pm;
	core = &pm;
	QWidget root;
	QGridLayout grid;
	root.setLayout(&grid);
	p.setupUi(&root,&grid);
	root.resize(586,300);
	Data::Game g;
	g.seats = 5;
	p.setGame(&g);
#ifdef WIN32
	QFile input("../../qt-client/test/cards.js");
#else
	QFile input("../test/cards.js");
#endif
	if (!input.open(QIODevice::ReadOnly | QIODevice::Text)) {
		qDebug() << "failed to load js";
		QVERIFY(false);
	} else {
		QTextStream stream(&input);
		QString code = stream.readAll();
		input.close();
		result = p.loadJs(code,"cards.js");
		QVERIFY(result);
	}

	QPixmap image(root.size());
	root.render(&image);
	image.save("cards.png");

	core = 0;
}
void TestCase::animate() {
	int result;
	TablePrivate p;
	PokerMain pm;
	core = &pm;
	AnimateCore ac(true);
	animateCore = &ac;
	QWidget root;
	QGridLayout grid;
	root.setLayout(&grid);
	p.setupUi(&root,&grid);
	root.resize(586,300);
	Data::Game g;
	g.seats = 5;
	p.setGame(&g);
#ifdef WIN32
	QFile input("../../qt-client/test/animate.js");
#else
	QFile input("../test/animate.js");
#endif
	if (!input.open(QIODevice::ReadOnly | QIODevice::Text)) {
		qDebug() << "failed to load js";
		QVERIFY(false);
	} else {
		QTextStream stream(&input);
		QString code = stream.readAll();
		input.close();
		result = p.loadJs(code,"cards.js");
		QVERIFY(result);
	}

	QPixmap image(root.size());
	root.render(&image);
	image.save("frame0.png");

	ac.setTime(100);
	ac.tick();
	root.render(&image);
	image.save("frame1.png");

	ac.setTime(1001);
	ac.tick();
	root.render(&image);
	image.save("frame2.png");
	
	QApplication::sendPostedEvents(0, QEvent::DeferredDelete);
	QCOMPARE(0,ac.animationCount());

	core = 0;
	animateCore = 0;
}
void TestCase::testsomething() {
	int result;
	TablePrivate p;
	PokerMain pm;
	core = &pm;
	AnimateCore ac(true);
	animateCore = &ac;
	QSharedPointer<Data::TableStatus> ts(new Data::TableStatus);
	QWidget root;
	QGridLayout grid;
	root.setLayout(&grid);
	p.setupUi(&root,&grid);
	root.resize(586,300);
	QFETCH(int,filled);
	QFETCH(QString,output);
	QFETCH(int,seats);
	Data::Game g;
	g.seats = seats;
	p.setGame(&g);
#ifdef WIN32
	QFile input("../../qt-client/client/table.js");
#else
	QFile input("../client/table.js");
#endif
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
	for (int i=0; i<filled; i++) {
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

	QPixmap image(root.size());
	root.render(&image);
	image.save(output+".png");

	/*root.resize(1000,600);
	QPixmap bigger(root.size());
	root.render(&bigger);
	bigger.save(output+"-bigger.png");*/

	QCOMPARE(5,5);
	core = 0;
	animateCore = 0;
}
