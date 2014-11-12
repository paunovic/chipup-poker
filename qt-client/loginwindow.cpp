#include "loginwindow.h"
#include "ui_loginwindow.h"
#include "pokermain.h"

LoginWindow::LoginWindow(QWidget *parent) :
    QWidget(parent),
    ui(new Ui::LoginWindow)
{
    ui->setupUi(this);
    PokerMain *core = PokerMain::getInstance();
    core->try_connect();
}

LoginWindow::~LoginWindow()
{
    delete ui;
}
