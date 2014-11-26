#include <QDebug>
#include <QFile>

#include "table.h"
#include "ui_table.h"
#include "tableprivate.h"
#include "game.h"
#include "pokermain.h"
#include "jseditor.h"

Table::Table(QWidget *parent) :
	QMainWindow(parent),
	ui(new Ui::Table)
{
	ui->setupUi(this);
	p = new TablePrivate;
	p->setupUi(ui->centerWrap,ui->center);
	qDebug() << "table create";
	connect(core,SIGNAL(table_status(QSharedPointer<Data::TableStatus>)),this,SLOT(table_status(QSharedPointer<Data::TableStatus>)));
	debuger = new JsEditor(this);
	debuger->show();
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
void Table::table_status(QSharedPointer<Data::TableStatus> ts) {
	lastTableStatus = ts;
	p->table_status(ts);
}
void Table::setGame(const Data::Game *game) {
	this->game = game;
	p->setGame(game);
	p->loadJsFromResource();
}
void Table::on_actionReload_triggered() {
	QFile input("table.js");
	if (!input.open(QIODevice::ReadOnly | QIODevice::Text)) {
		qDebug() << "failed to load js";
	} else {
		QTextStream stream(&input);
		QString code = stream.readAll();
		input.close();
		p->loadJs(code,"table.js");
	}
}
void Table::on_teChatInput_returnPressed() {
	QString message = ui->teChatInput->text();
	ui->teChatInput->setText("");
	ui->teChat->append(p->eval(message).toString());
	QGridLayout *layout = ui->center;
	qDebug() << layout->cellRect(0,0);
	qDebug() << layout->cellRect(1,0);

}
void Table::resizeEvent(QResizeEvent *event) {
	//qDebug() << height();
	QMainWindow::resizeEvent(event);
}
void Table::editJs(QString newcode) {
	p->editJs(newcode);
}
