#include <QPainter>

#include "loginwindow.h"
#include "ui_loginwindow.h"
#include "pokermain.h"
#include "main_window.h"
#include "registerwindow.h"
#include "sound_effects.h"

// TODO, enforce regex on user/pass
// catch login failure
//
LoginWindow::LoginWindow(QWidget *parent) :
    QWidget(parent),
	ui(new Ui::LoginWindow), background(":/resources/login/Background.png")
{
	ui->setupUi(this);
	core->try_connect();
	core->RegisterListener(this);
#ifndef testcase
	qDebug() << "loading config";
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
		On_protocol_ready(true);
	}
#endif
	core->effects()->PlaySound(SoundEffects::Dealing);
}

LoginWindow::~LoginWindow() {
	delete ui;
}
void LoginWindow::On_protocol_ready(bool ready) {
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
	Poker::LoginParams lp;
	lp.set_username(qPrintable(username));
	lp.set_password(qPrintable(password));
	core->sendMessage(Poker::scLogin,&lp);
}
void LoginWindow::on_edLogin_returnPressed() {
	on_btLogin_clicked();
}
void LoginWindow::on_edPassword_returnPressed() {
	on_btLogin_clicked();
}

void LoginWindow::on_btCreateAccount_clicked() {
#ifndef testcase
	RegisterWindow *rw = new RegisterWindow(this);
	rw->exec();
#endif
}
void LoginWindow::On_login_sucess() {
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
#ifndef testcase
	MainWindow *mw = new MainWindow();
	mw->show();
#endif
	close();
	deleteLater();
}
void LoginWindow::paintEvent(QPaintEvent *) {
	QPainter p(this);
	int targetHeight = ((qreal)background.height()*width())/background.width();
	p.drawPixmap(0,0,width(),targetHeight,background);
	QRect extra(0,targetHeight,width(),height()-targetHeight);
	p.setBrush(QColor(0,0,0));
	p.setPen(Qt::NoPen);
	p.drawRect(extra);
}
