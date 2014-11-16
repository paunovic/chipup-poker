#include "loginwindow.h"
#include "ui_loginwindow.h"
#include "pokermain.h"
#include "main_window.h"
#include "registerwindow.h"

// TODO, enforce regex on user/pass
// catch login failure
//
LoginWindow::LoginWindow(QWidget *parent) :
    QWidget(parent),
    ui(new Ui::LoginWindow)
{
    ui->setupUi(this);
    core->try_connect();
	connect(core,SIGNAL(protocol_ready(bool)),this,SLOT(protocol_ready(bool)));
	connect(core,SIGNAL(login_sucess()),this,SLOT(login_sucess()));
    QString username = core->config().value("login/username").toString();
    if (username.size()>0) {
        ui->edLogin->setText(username);
        ui->cbRememberLogin->setChecked(true);
        QString password = core->config().value("login/password").toString();
        if (password.size() > 0) {
            ui->edPassword->setText(password);
            ui->cbRememberPassword->setChecked(true);
        }
    }
	if (core->socketState() == QAbstractSocket::ConnectedState) {
		protocol_ready(true);
	}
}

LoginWindow::~LoginWindow() {
	delete ui;
}
void LoginWindow::protocol_ready(bool ready) {
	qDebug() << "ready" << ready;
	ui->btLogin->setEnabled(true);
	ui->btLogin->setText(tr("LOGIN"));
	ui->btLogin->setDefault(true);
    ui->btCreateAccount->setEnabled(true);
	//ui->btForgotPassword->setEnabled(true);
    //do_login();
}
void LoginWindow::on_btLogin_clicked() {
	QString username = ui->edLogin->text();
	QString password = ui->edPassword->text();
	qDebug() << "doing login" << username << password;
	Poker::LoginParams lp;
	lp.set_username(qPrintable(username));
	lp.set_password(qPrintable(password));
	core->sendMessage(Poker::scLogin,&lp);
}
void LoginWindow::on_btCreateAccount_clicked() {
    RegisterWindow *rw = new RegisterWindow(this);
    rw->exec();
}
void LoginWindow::login_sucess() {
    QString username = ui->edLogin->text();
    QString password = ui->edPassword->text();
    bool saveuser = ui->cbRememberLogin->isChecked();
    bool savepassword = ui->cbRememberPassword->isChecked();
    if (saveuser) {
        core->config().setValue("login/username",username);
        if (savepassword) core->config().setValue("login/password",password);
        else core->config().remove("login/password");
    } else {
        core->config().remove("login/username");
        core->config().remove("login/password");
    }
    MainWindow *mw = new MainWindow();
	mw->show();
	close();
	deleteLater();
}
