#ifndef LOGINWINDOW_H
#define LOGINWINDOW_H

#include <QWidget>

namespace Ui {
class LoginWindow;
}

class LoginWindow : public QWidget
{
    Q_OBJECT

public:
    explicit LoginWindow(QWidget *parent = 0);
    ~LoginWindow();
protected:
	void paintEvent(QPaintEvent *e);
private:
    Ui::LoginWindow *ui;
	QPixmap background;
private slots:
	void On_protocol_ready(bool);
    void on_btLogin_clicked();
    void on_btCreateAccount_clicked();
	void on_edLogin_returnPressed();
	void on_edPassword_returnPressed();
	void On_login_sucess();
	void On_login_failure();
};

#endif // LOGINWINDOW_H
