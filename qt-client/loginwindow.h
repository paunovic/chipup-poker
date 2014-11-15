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

private:
    Ui::LoginWindow *ui;
private slots:
	void protocol_ready(bool);
    void on_btLogin_clicked();
    void on_btCreateAccount_clicked();
	void login_sucess();
};

#endif // LOGINWINDOW_H
