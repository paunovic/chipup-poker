#include <QDebug>

#include "contactus.h"
#include "ui_contactus.h"
#include "pokermain.h"

ContactUs::ContactUs(QWidget *parent) :
	QWidget(parent),
	ui(new Ui::ContactUs)
{
	ui->setupUi(this);
}

ContactUs::~ContactUs()
{
	delete ui;
}
void ContactUs::on_btSend_clicked() {
	Poker::ContactMessage cu;
	cu.set_message(qPrintable(ui->message->toPlainText()));
	cu.set_reason((Poker::ContactMessage_ContactReason)ui->comboBox->currentIndex());
	core->sendMessage(Poker::scContactUs,&cu);
}
