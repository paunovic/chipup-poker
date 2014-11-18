#include <QDebug>

#include "table.h"
#include "ui_table.h"
#include "tableprivate.h"
#include "game.h"
#include "pokermain.h"

Table::Table(QWidget *parent) :
	QMainWindow(parent),
	ui(new Ui::Table)
{
	ui->setupUi(this);
	p = new TablePrivate;
	qDebug() << "table create";
	connect(core,SIGNAL(table_status(const Data::TableStatus&)),this,SLOT(table_status(const Data::TableStatus&)));
}

Table::~Table() {
	delete ui;
	delete p;
	qDebug() << "table destroy";
}
bool Table::event(QEvent *event) {
	if (event->type() == QEvent::Close) {
		qDebug() << "table close detected";
		Poker::Game g;
		g.set__id(game->gameid.data(),game->gameid.length());
		core->sendMessage(Poker::scTableLeave,&g);
		deleteLater();
	}
	return QMainWindow::event(event);
}
void Table::table_status(const Data::TableStatus &ts) {

}
