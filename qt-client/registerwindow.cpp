#include "registerwindow.h"
#include "ui_registerwindow.h"
#include "pokermain.h"

// TODO, enforce regex on user/pass
// catch failure
//

RegisterWindow::RegisterWindow(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::RegisterWindow) {
    ui->setupUi(this);
    ui->edEmail->setValidator(new QRegExpValidator(QRegExp(core->validCharacters.email().c_str()),this));
    QRegExpValidator *pw_validator = new QRegExpValidator(QRegExp(core->validCharacters.password().c_str()),this);
    ui->edPassword->setValidator(pw_validator);
    ui->edConfirmPassword->setValidator(pw_validator);
    ui->edUsername->setValidator(new QRegExpValidator(QRegExp(core->validCharacters.username().c_str()),this));
    connect(core,SIGNAL(register_success()),this,SLOT(register_success()));
}
RegisterWindow::~RegisterWindow() {
    delete ui;
}
void RegisterWindow::on_edEmail_textEdited() {
    QString input = ui->edEmail->text();
    bool valid = ui->edEmail->hasAcceptableInput();
    qDebug() << input << valid;
    checkInputs();
}
void RegisterWindow::on_edPassword_textEdited() {
    QString input = ui->edPassword->text();
    bool valid = ui->edPassword->hasAcceptableInput();
    qDebug() << input << valid;
    checkInputs();
}
void RegisterWindow::on_edConfirmPassword_textEdited() {
    QString input = ui->edConfirmPassword->text();
    bool valid = ui->edConfirmPassword->hasAcceptableInput();
    qDebug() << input << valid;
    checkInputs();
}
void RegisterWindow::on_edUsername_textEdited() {
    QString input = ui->edUsername->text();
    bool valid = ui->edUsername->hasAcceptableInput();
    qDebug() << input << valid;
    checkInputs();
}
void RegisterWindow::checkInputs() {
    if (ui->edEmail->hasAcceptableInput() &&
            ui->edPassword->hasAcceptableInput() &&
            ui->edConfirmPassword->hasAcceptableInput() &&
            ui->edUsername->hasAcceptableInput() &&
            ui->cb18Years->isChecked() &&
            ui->cbTOS->isChecked() &&
            (ui->edPassword->text() == ui->edConfirmPassword->text())) {
        ui->btSignUp->setEnabled(true);
    } else {
        ui->btSignUp->setEnabled(false);
    }
}
void RegisterWindow::on_cb18Years_stateChanged() {
    checkInputs();
}
void RegisterWindow::on_cbTOS_stateChanged() {
    checkInputs();
}
void RegisterWindow::on_btSignUp_clicked() {
    Poker::RegisterParams rp;
    rp.set_email(qPrintable(ui->edEmail->text()));
    rp.set_password(qPrintable(ui->edPassword->text()));
    rp.set_displayname(qPrintable(ui->edUsername->text()));
    core->sendMessage(Poker::scRegister,&rp);
}
void RegisterWindow::register_success() {
    done(0);
}
