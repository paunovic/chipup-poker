#include <QApplication>
#include <QFile>
#include <QDebug>
#include <QFontDatabase>
#include <QTranslator>
#include <locale>

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

bool errorFilter(void *context, EXCEPTION_POINTERS *exinfo, MDRawAssertionInfo *assertions) {
	qDebug() << __func__ << exinfo << assertions;
	return true;
}
bool dumpMade(const wchar_t* dump_path,
			  const wchar_t* minidump_id,
			  void* context,
			  EXCEPTION_POINTERS* exinfo,
			  MDRawAssertionInfo* assertion,
			  bool succeeded) {
	qDebug() << __func__ << build_number << QString::fromWCharArray(dump_path) << QString::fromWCharArray(minidump_id) << succeeded;
	return succeeded;
}

int main(int argc, char *argv[]) {
	QApplication a(argc, argv);
	std::string temp = "e:\\";
	std::wstring dump_path(temp.begin(), temp.end());
	std::wstring *pipe = 0;
	google_breakpad::ExceptionHandler *handler =
		new google_breakpad::ExceptionHandler(dump_path,errorFilter,dumpMade,0,
								google_breakpad::ExceptionHandler::HANDLER_ALL,	MiniDumpNormal,pipe,0);

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
