#include <QFontDatabase>
#include <QUiLoader>

#include "test.h"
#include "table.h"
#include "../client/data/seatinfo.h"
#include "../client/data/user.h"
#include "table/animatecore.h"
#include "../client/data/tableevent.h"
#include "../client/loginwindow.h"

#ifndef QFINDTESTDATA
#define QFINDTESTDATA(x) QString("../../qt-client/test/") + x
#endif

// from the simulator-qt project
static void setDpiRecursive(QObject *object, const QSize &dpi) {
	foreach (QObject *child, object->children()) setDpiRecursive(child,dpi);

	object->setProperty("_q_customDpiX",dpi.width());
	object->setProperty("_q_customDpiY",dpi.height());
}
void changeDpi(const QSize &dpi) {
	foreach (QWidget *widget, QApplication::topLevelWidgets()) {
		setDpiRecursive(widget,dpi);
	}
}
// </copy&paste>

int font1,font2;
void TestCase::initTestCase() {
	font1 = QFontDatabase::addApplicationFont(":/resources/cards/CardCharacters.TTF");
	font2 = QFontDatabase::addApplicationFont(":/resources/seats/Barmeno-Bold.ttf");
}
void TestCase::cleanupTestCase() {
	QFontDatabase::removeApplicationFont(font1);
	QFontDatabase::removeApplicationFont(font2);
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
void TestCase::renderChips_data() {
	QTest::addColumn<QString>("value");
	QTest::newRow("one") << "50,100,500,2500,10000,50000,100000";
}
void TestCase::renderChips() {
	int result;
	TablePrivate p;
	PokerMain pm;
	core = &pm;
	QWidget root;
	QGridLayout grid;
	root.setLayout(&grid);
	p.setupUi(&root,&grid,0);
	root.resize(586,300);
	Data::Game g;
	g.seats = 5;
	p.setGame(&g);

	QFETCH(QString,value);
	p.global().setProperty("input_data",value);

	QFile input(QFINDTESTDATA("chips.js"));
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
	image.save("chips.png");

	core = 0;
}
void TestCase::rendercards_data() {
	QTest::addColumn<QString>("name");
	QTest::addColumn<double>("size");
	QTest::newRow("small") << "cards_s.png" << 0.04;
	QTest::newRow("big") << "cards_b.png" << 0.1;
}

void TestCase::rendercards() {
	QFETCH(QString,name);
	QFETCH(double,size);
	int result;
	TablePrivate p;
	PokerMain pm;
	core = &pm;
	QWidget root;
	QGridLayout grid;
	root.setLayout(&grid);
	p.setupUi(&root,&grid,0);
	root.resize(586*2,300*2);
	Data::Game g;
	g.seats = 5;
	p.setGame(&g);
	p.global().setProperty("size",size);
	QFile input(QFINDTESTDATA("cards.js"));
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
	image.save(name);

	core = 0;
}
void TestCase::alignment_data() {
	QTest::addColumn<int>("seats");
	QTest::addColumn<bool>("withDealer");
	QTest::addColumn<bool>("withBet");
	QTest::addColumn<QString>("filename");
	QTest::addColumn<int>("cardCount");
	QTest::newRow("all10") << 10 << true << true << "all10.png" << 2;
	QTest::newRow("all5") << 5 << true << true << "all5.png" << 2;
	QTest::newRow("all5Omahad") << 5 << true << true << "all5omahad.png" << 4;
	QTest::newRow("all5Omaha") << 5 << false << true << "all5omaha.png" << 4;
}
void TestCase::alignment() {
	QFETCH(int,seats);
	QFETCH(bool,withDealer);
	QFETCH(bool,withBet);
	QFETCH(QString,filename);
	QFETCH(int,cardCount);
	int result;
	PokerMain pm;
	pm.setDataDir(QDir("datadir"));
	core = &pm;

	Table tbl;

	QByteArray selfid;
	selfid[0] = 1;
	pm.self()->id = selfid;

	QFile styles(":/stylesheet.css");
	if (!styles.open(QIODevice::ReadOnly | QIODevice::Text)) {
		qDebug() << "failed to load css";
	} else {
		QByteArray buffer;
		while (!styles.atEnd()) {
			buffer.append(styles.readAll());
		}
		QString css(buffer);
		tbl.setStyleSheet(css);
	}

	AnimateCore ac(true);
	animateCore = &ac;
	QSharedPointer<Data::TableStatus> ts(new Data::TableStatus);
	tbl.resize(950,620);
	Data::Game g;
	g.seats = seats;
	QFile input("../../qt-client/client/table.js");
	if (!input.open(QIODevice::ReadOnly | QIODevice::Text)) {
		qDebug() << "failed to load js";
		QVERIFY(false);
	} else {
		QTextStream stream(&input);
		QString code = stream.readAll();
		input.close();
		result = tbl.setGameForTesting(&g,code);
		QVERIFY(result);
	}
	for (int i=0; i<seats; i++) {
		uint8_t cards[] = {0,1,2,3};
		QByteArray id;
		id[0] = i;
		Data::SeatInfo *seat = new Data::SeatInfo(&pm);
		Poker::SeatInfo source;

		source.set_player_mongo_id(id.data(),id.length());
		source.set_seat_index(i);
		source.set_status(Poker::SeatInfo::psInHand);
		source.set_chips(20000);
		source.set_cards(cards,cardCount);
		source.set_card_count(cardCount);
		seat->update(source);
		ts->seats.append(seat);
		Data::User *u = new Data::User(&pm);
		u->id = id;
		u->setDisplayName(QString("seat %1").arg(i));
		pm.users.append(u);
	}
	Poker::TableStatus initial;
	initial.set_current_seat(4);
	initial.set_state(Poker::TableStatus::tsPreFlop);
	for (int i=0; i<seats; i++) {
		if (i == 2) initial.add_bets(300);
		else initial.add_bets(123*(i+1));
	}
	Poker::TableEvent *dealing = initial.add_events();
	dealing->set_event(Poker::TableEvent::teDealing);

	ts->update(initial);
	
	QSharedPointer<Data::TableEvent> flop(new Data::TableEvent);
	flop->event = Poker::TableEvent::teFlop;
	char floparr[3] = { 0x2a,0x13,0x12 };
	std::string flopraw((char*)&floparr,3);
	Data::Hand *flopcards = new Data::Hand(flopraw);
	flop->cards.append(flopcards);
	ts->events.append(flop);

	QSharedPointer<Data::TableEvent> turn(new Data::TableEvent);
	turn->event = Poker::TableEvent::teTurn;
	char turnarr[1] = {0x14};
	std::string turnraw((char*)&turnarr,1);
	Data::Hand *turncards = new Data::Hand(turnraw);
	turn->cards.append(turncards);
	ts->events.append(turn);

	QSharedPointer<Data::TableEvent> river(new Data::TableEvent);
	river->event = Poker::TableEvent::teRiver;
	char riverarr[1] = {0x15};
	std::string riverraw((char*)&riverarr,1);
	Data::Hand *rivercards = new Data::Hand(riverraw);
	river->cards.append(rivercards);
	ts->events.append(river);

	tbl.eval("testcase = true");
	result = tbl.On_table_status(ts);
	QVERIFY(result);
	if (withDealer) tbl.eval("alignment();");
	changeDpi(QSize(121,120));
	for (int i=0; i<50; i++) {
		ac.setTime(i*1000);
		ac.tick();
		QApplication::sendPostedEvents();
		if (i < 30) QTest::qSleep(20);
	}
	QPixmap image(tbl.size());
	tbl.render(&image);
	qDebug() << "saving" << filename;
	image.save(filename);
	
	core = 0;
	animateCore = 0;
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
	p.setupUi(&root,&grid,0);
	root.resize(586,300);
	Data::Game g;
	g.seats = 5;
	p.setGame(&g);
	QFile input(QFINDTESTDATA("animate.js"));
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
	int x = 1;
	for (int time=10; time < 1050; time+=20) {
		root.render(&image);
		ac.setTime(time);
		ac.tick();
		image.save(QString("frame%1.png").arg(x));
		x++;
	}

	QApplication::sendPostedEvents(0, QEvent::DeferredDelete);
	ac.dumpObjectTree();
	QCOMPARE(ac.animationCount(),0);

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
	p.setupUi(&root,&grid,0);
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
	QFile input("../../qt-client/client/table.js");
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
		seat->setCard_count(0);
		QCOMPARE(seat->property("seat_index").isNull(),false);
		QCOMPARE(seat->property("seat_index").toInt(),i);
		ts->seats.append(seat);
		Data::User *u = new Data::User(&pm);
		u->id = id;
		u->setDisplayName(QString("seat %1").arg(i));
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
void TestCase::simplegame() {
	int result;
	PokerMain pm;
	core = &pm;
	Table tbl;

	QByteArray selfid;
	selfid[0] = 1;
	pm.self()->id = selfid;
	
	QFile styles(":/stylesheet.css");
	if (!styles.open(QIODevice::ReadOnly | QIODevice::Text)) {
		qDebug() << "failed to load css";
	} else {
		QByteArray buffer;
		while (!styles.atEnd()) {
			buffer.append(styles.readAll());
		}
		QString css(buffer);
		tbl.setStyleSheet(css);
	}

	AnimateCore ac(true);
	animateCore = &ac;
	QSharedPointer<Data::TableStatus> ts(new Data::TableStatus);
	tbl.resize(tbl.sizeHint());
	Data::Game g;
	g.seats = 6;
#ifdef WIN32
	QFile input("../../qt-client/client/table.js");
#else
	QFile input("../../qt-client/client/table.js");
#endif
	if (!input.open(QIODevice::ReadOnly | QIODevice::Text)) {
		qDebug() << "failed to load js";
		QVERIFY(false);
	} else {
		QTextStream stream(&input);
		QString code = stream.readAll();
		input.close();
		result = tbl.setGameForTesting(&g,code);
		QVERIFY(result);
	}
	for (int i=0; i<2; i++) {
		QByteArray id;
		id[0] = i;
		Data::SeatInfo *seat = new Data::SeatInfo(&pm);
		Poker::SeatInfo source;

		source.set_player_mongo_id(id.data(),id.length());
		if (i == 1) source.set_seat_index(4);
		else source.set_seat_index(0);
		source.set_card_count(0);
		source.set_status(Poker::SeatInfo::psOutOfPlay);
		source.set_chips(20000);
		seat->update(source);
		ts->seats.append(seat);
		Data::User *u = new Data::User(&pm);
		u->id = id;
		u->setDisplayName(QString("seat %1").arg(i));
		pm.users.append(u);
	}
	ts->current_seat = -1;
	result = tbl.On_table_status(ts);
	QVERIFY(result);

	for (int x=0; x<10; x++) {
		QApplication::sendPostedEvents();
		QTest::qSleep(200);
	}

	QPixmap image(tbl.size());
	image.fill(QColor(255,255,255));
	tbl.render(&image);
	image.save("simplegame0.png");

	Poker::TableStatus initial;
	initial.set_current_seat(4);
	initial.set_state(Poker::TableStatus::tsPreFlop);
	initial.add_bets(200);
	initial.add_bets(0);
	initial.add_bets(0);
	initial.add_bets(0);
	initial.add_bets(100);
	QSharedPointer<Data::TableEvent> check(new Data::TableEvent);
	check->event = Poker::TableEvent::teCheck;
	ts->events.append(check);
	ts->update(initial);

	ts->seats[0]->setCard_count(2);
	ts->seats[1]->setCard_count(2);
	ts->seats[0]->setStatus(Poker::SeatInfo::psInHand);
	ts->seats[1]->setStatus(Poker::SeatInfo::psInHand);
	qDebug() << "bets" << ts->bets();
	ts->setMinimumBet(200);
	result = tbl.On_table_status(ts);
	QVERIFY(result);

	tbl.render(&image);
	image.save("simplegame1.png");
	qDebug() << "end of phase 1";

	ts->events.clear();

	QSharedPointer<Data::TableEvent> flop(new Data::TableEvent);
	flop->event = Poker::TableEvent::teFlop;
	char floparr[3] = { 0x2a,0x13,0x12 };
	std::string flopraw((char*)&floparr,3);
	Data::Hand *flopcards = new Data::Hand(flopraw);
	flop->cards.append(flopcards);
	ts->events.append(flop);

	QSharedPointer<Data::TableEvent> turn(new Data::TableEvent);
	turn->event = Poker::TableEvent::teTurn;
	char turnarr[1] = {0x14};
	std::string turnraw((char*)&turnarr,1);
	Data::Hand *turncards = new Data::Hand(turnraw);
	turn->cards.append(turncards);
	ts->events.append(turn);

	QSharedPointer<Data::TableEvent> river(new Data::TableEvent);
	river->event = Poker::TableEvent::teRiver;
	char riverarr[1] = {0x15};
	std::string riverraw((char*)&riverarr,1);
	Data::Hand *rivercards = new Data::Hand(riverraw);
	river->cards.append(rivercards);
	ts->events.append(river);

	result = tbl.On_table_status(ts);
	QVERIFY(result);

	for (int i=0; i<10; i++) {
		ac.setTime(i*1000);
		ac.tick();
		tbl.render(&image);
		image.save(QString("simplegame2.%1.png").arg(i));
	}

	/*root.resize(1000,600);
	QPixmap bigger(root.size());
	root.render(&bigger);
	bigger.save(output+"-bigger.png");*/

	QCOMPARE(5,5);
	core = 0;
	animateCore = 0;
}
void TestCase::render_bare_form_data() {
	QTest::addColumn<QString>("formname");
	QTest::addColumn<QString>("outname");
	QTest::newRow("formname") << "../client/loginwindow.ui" << "loginwindow";
	QTest::newRow("formname") << "../client/table.ui" << "table";
}
void TestCase::render_bare_form() {
	QFETCH(QString,formname);
	QFETCH(QString,outname);
	QUiLoader loader;

	QFile input(QFINDTESTDATA(formname));
	input.open(QFile::ReadOnly);
	QWidget *formWidget = loader.load(&input);
	input.close();
	
	QFile styles(":/stylesheet.css");
	if (!styles.open(QIODevice::ReadOnly | QIODevice::Text)) {
		qDebug() << "failed to load css";
	} else {
		QByteArray buffer;
		while (!styles.atEnd()) {
			buffer.append(styles.readAll());
		}
		QString css(buffer);
		formWidget->setStyleSheet(css);
	}

	QPixmap output(formWidget->size());
	formWidget->render(&output);
	output.save(outname+".png");
}
void TestCase::render_login_form() {
	PokerMain pm;
	core = &pm;

	LoginWindow *lw = new LoginWindow();
	QPixmap output(lw->size());
	lw->render(&output);
	output.save("loginwindow.png");
	core = 0;
}
void TestCase::replayRecording_data() {
	QTest::addColumn<QString>("setname");
	QTest::newRow("demo1") << QFINDTESTDATA("../demo1/");
}
void TestCase::replayRecording() {
	QFETCH(QString,setname);
	qDebug() << setname;
	int result;
	PokerMain pm;
	pm.setDataDir(QDir("datadir"));
	core = &pm;
	Table tbl;
	tbl.resize(tbl.sizeHint());

		Data::User *u = new Data::User(&pm);
		u->id = QByteArray::fromHex("533da8660427a9b039155625");
		u->setDisplayName("set10");
		pm.users.append(u);
		
		u = new Data::User(&pm);
		u->id = QByteArray::fromHex("533d9ea52498bd8331676dc9");
		u->setDisplayName("mike");
		pm.users.append(u);
		pm.self()->id = u->id;
	
	QFile styles(":/stylesheet.css");
	if (!styles.open(QIODevice::ReadOnly | QIODevice::Text)) {
		qDebug() << "failed to load css";
	} else {
		QByteArray buffer;
		while (!styles.atEnd()) {
			buffer.append(styles.readAll());
		}
		QString css(buffer);
		tbl.setStyleSheet(css);
	}
	AnimateCore ac(true);
	animateCore = &ac;

	Data::Game g;
	g.seats = 9;
	g.gameid = QByteArray::fromHex("551c7caad1853f634e80a47f");
#ifdef WIN32
	QFile input("../../qt-client/client/table.js");
#else
	QFile input("../../qt-client/client/table.js");
#endif
	if (!input.open(QIODevice::ReadOnly | QIODevice::Text)) {
		qDebug() << "failed to load js";
		QVERIFY(false);
	} else {
		QTextStream stream(&input);
		QString code = stream.readAll();
		input.close();
		result = tbl.setGameForTesting(&g,code);
		QVERIFY(result);
	}
	tbl.eval("testcase = true");
	QPixmap image(tbl.size());
	int frame = 0;
	saveFrame(tbl,image,frame++,"demo1-%1.png");

	int packet = 0;
	int time = 0;
	while (true) {
		QString filename = QString("%1/recording-%2.proto").arg(setname).arg(packet++);
		QFile fh(filename);
		if (fh.open(QFile::ReadOnly)) {
			QByteArray data = fh.readAll();
			fh.close();
			Poker::TableStatus ts;
			ts.ParseFromArray(data.data(),data.size());
			QSharedPointer<Data::TableStatus> out(new Data::TableStatus);
			out->update(ts);
			qDebug() << ts.seq() << out->gameid.toHex();
			result = tbl.On_table_status(out);
			QVERIFY(result);
			saveFrame(tbl,image,frame++,"demo1-%1.png");
			int remaining = tbl.global().property("actions").property("length").toInt32();
			int limit = 60;
			while (remaining) {
				qDebug() << remaining << "actions in queue" << time;
				remaining = tbl.global().property("actions").property("length").toInt32();
				ac.setTime(time);
				time += 50;
				ac.tick();
				saveFrame(tbl,image,frame++,"demo1-%1.png");
				//if (!limit--) break;
			}
		} else break;
	}

	core = 0;
	animateCore = 0;
}
void TestCase::saveFrame(Table &tbl, QPixmap &img, int frame, QString format) {
	tbl.render(&img);
	img.save(format.arg(frame));
}
