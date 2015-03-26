#ifndef NOTIFYWINDOW_H
#define NOTIFYWINDOW_H

#include <QWidget>

namespace Ui {
class NotifyWindow;
}

class NotifyWindow : public QWidget
{
	Q_OBJECT
public:
	explicit NotifyWindow();
	void setMessage(QString msg);
signals:

public slots:
	void timeout();
private:
	Ui::NotifyWindow *ui;
};

#endif // NOTIFYWINDOW_H
