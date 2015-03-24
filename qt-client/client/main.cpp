#include <QApplication>
#include <QFile>
#include <QDebug>
#include <QFontDatabase>
#include <QTranslator>
#include <locale>
#include <QStandardPaths>
#include <QProcess>

#include "loginwindow.h"
#include "pokermain.h"
#include "table/animatecore.h"
#ifdef Q_OS_WIN
# include "client/windows/handler/exception_handler.h"
#elif defined(Q_OS_LINUX)
# include "client/linux/handler/exception_handler.h"
#elif defined(Q_OS_MAC)
# include "client/mac/handler/exception_handler.h"
#endif
#include "version.h"

bool errorFilter(void *context
#ifdef Q_OS_WIN
, EXCEPTION_POINTERS *exinfo, MDRawAssertionInfo *assertions
#endif
) {
	qDebug() << "errorFilter";
	return true;
}
#ifdef Q_OS_WIN
bool dumpMade(const wchar_t* dump_path,
			  const wchar_t* minidump_id,
			  void* context,
			  EXCEPTION_POINTERS* exinfo,
			  MDRawAssertionInfo* assertion,
			  bool succeeded) {
	qDebug() << "dumpMade" << build_number << QString::fromWCharArray(dump_path) << QString::fromWCharArray(minidump_id) << succeeded;
#elif defined(Q_OS_LINUX)
bool dumpMade(const google_breakpad::MinidumpDescriptor& descriptor, void* context, bool succeeded) {
	qDebug() << __func__ << succeeded;
#else
bool dumpMade(const char *dump_dir, const char *minidump_id, void *context, bool succeeded) {
#endif
	QString self = QApplication::applicationFilePath();
	qDebug() << "update ready to restart" << self;
	QProcess::startDetached(self);
	return succeeded;
}

int main(int argc, char *argv[]) {
	QApplication a(argc, argv);
	QDir datadir(QStandardPaths::writableLocation(QStandardPaths::DataLocation));
	if (!datadir.exists("minidumps")) datadir.mkdir("minidumps");
	std::string temp = qPrintable(datadir.absoluteFilePath("minidumps"));
	std::wstring dump_path(temp.begin(), temp.end());
	std::wstring *pipe = 0;
#ifdef Q_OS_WIN
	google_breakpad::ExceptionHandler *handler = new google_breakpad::ExceptionHandler(dump_path,errorFilter,dumpMade,0, google_breakpad::ExceptionHandler::HANDLER_ALL, MiniDumpNormal,pipe,0);
#elif defined(Q_OS_LINUX)
	google_breakpad::ExceptionHandler *handler = new google_breakpad::ExceptionHandler(google_breakpad::MinidumpDescriptor(temp),errorFilter,dumpMade,0,true,-1);
#elif defined(Q_OS_MAC)
	google_breakpad::ExceptionHandler *handler = new google_breakpad::ExceptionHandler(temp,errorFilter,dumpMade,0,true,0);
#endif

	QTranslator translator;
#if 0
	translator.load("chipuppoker_ru");
#else
	QString locale = QLocale::system().name();
	translator.load("chipuppoker_"+locale);
#endif
	a.installTranslator(&translator);

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
	QFontDatabase::addApplicationFont(":/resources/cards/CardCharacters.TTF");
	QFontDatabase::addApplicationFont(":/resources/seats/Barmeno-Bold.ttf");
	core = new PokerMain();
	core->setMinidumpPath(datadir.absoluteFilePath("minidumps"));
	core->app = &a;
	animateCore = new AnimateCore(false);

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
