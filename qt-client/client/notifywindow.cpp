#include <QTimer>
#include <QPalette>
#include <QDesktopWidget>

#include "notifywindow.h"
#ifdef Q_OS_MAC
#include <Carbon/Carbon.h>
#endif

#include "ui_NotifyWindow.h"

NotifyWindow::NotifyWindow() : QWidget(0), ui(new Ui::NotifyWindow) {

	ui->setupUi(this);
	setWindowFlags(
	#ifdef Q_OS_MAC
		Qt::SubWindow | // This type flag is the second point
	#else
		Qt::Tool |
	#endif
		Qt::FramelessWindowHint |
		Qt::WindowSystemMenuHint |
		Qt::WindowStaysOnTopHint |
		Qt::WindowDoesNotAcceptFocus
	);
	setAttribute(Qt::WA_TranslucentBackground,false);
	setAttribute(Qt::WA_DeleteOnClose,true);

	// And this conditional block is the third point
/*#ifdef Q_OS_MAC
	winId(); // This call creates the OS window ID itself.
			 // qt_mac_window_for() doesn't

	int setAttr[] = {
		kHIWindowBitDoesNotHide, // Shows window even when app is hidden

		kHIWindowBitDoesNotCycle, // Not sure if required, but not bad

		kHIWindowBitNoShadow, // Keep this if you have your own design
							  // with cross-platform drawn shadows
		0 };
	int clearAttr[] = { 0 };
	HIWindowChangeAttributes(qt_mac_window_for(this), setAttr, clearAttr);
#endif*/
	setGeometry(QStyle::alignedRect(Qt::RightToLeft,Qt::AlignBottom,size(),
									QApplication::desktop()->availableGeometry()));
}
void NotifyWindow::setMessage(QString msg) {
	ui->notification->setText(msg);
	show();
	QTimer *timer = new QTimer();
	timer->setParent(this);
	timer->setSingleShot(true);
	connect(timer,SIGNAL(timeout()),this,SLOT(timeout()));
	timer->start(5000);
}
void NotifyWindow::resizeEvent(QResizeEvent *event) {
	QWidget::resizeEvent(event);
	setGeometry(QStyle::alignedRect(Qt::RightToLeft,Qt::AlignBottom,size(),
									QApplication::desktop()->availableGeometry()));
}
void NotifyWindow::timeout() {
	close();
}
