#include "loginwindow.h"
#include "ui_loginwindow.h"
#include "pokermain.h"
#include "main_window.h"


// TODO, enforce regex on user/pass
// catch login failure
//
LoginWindow::LoginWindow(QWidget *parent) :
    QWidget(parent),
    ui(new Ui::LoginWindow)
{
    ui->setupUi(this);
    PokerMain *core = PokerMain::getInstance();
    core->try_connect();
	connect(core,SIGNAL(protocol_ready(bool)),this,SLOT(protocol_ready(bool)));
	connect(ui->btLogin,SIGNAL(clicked()),this,SLOT(do_login()));
	connect(core,SIGNAL(login_sucess()),this,SLOT(login_sucess()));
}

LoginWindow::~LoginWindow() {
	delete ui;
}
void LoginWindow::protocol_ready(bool ready) {
	qDebug() << "ready" << ready;
	ui->btLogin->setEnabled(true);
	ui->btLogin->setText(tr("LOGIN"));
	ui->btLogin->setDefault(true);
	//ui->btCreateAccount->setEnabled(true);
	//ui->btForgotPassword->setEnabled(true);
	do_login();
}
void LoginWindow::do_login() {
	QString username = ui->edLogin->text();
	QString password = ui->edPassword->text();
	qDebug() << "doing login" << username << password;
	Poker::LoginParams lp;
	lp.set_username(qPrintable(username));
	lp.set_password(qPrintable(password));
	PokerMain *core = PokerMain::getInstance();
	core->sendMessage(Poker::scLogin,&lp);
}
void LoginWindow::login_sucess() {
	MainWindow *mw = new MainWindow();
	mw->show();
	close();
}
