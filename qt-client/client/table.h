#ifndef TABLE_H
#define TABLE_H

//#define JSDEBUG

#include <QMainWindow>

#include "tablestatus.h"

class TablePrivate;
class JsEditor;

namespace Ui {
class Table;
}
namespace Data {
class Game;
class Club;
}

class Table : public QMainWindow
{
	Q_OBJECT

public:
	explicit Table(QWidget *parent = 0);
	~Table();
	bool event(QEvent *event);
	void setGame(const Data::Game *game, const Data::Club *club);
	void editJs(QString newcode);

private slots:
	void table_status(QSharedPointer<Data::TableStatus> ts);
	void on_actionReload_triggered();
	void on_teChatInput_returnPressed();
	void on_btStandUp_clicked();
protected:
	void resizeEvent(QResizeEvent *event);
private:
	Ui::Table *ui;
	TablePrivate *p;
	const Data::Game *game;
	QSharedPointer<Data::TableStatus> lastTableStatus;
#ifdef JSDEBUG
	JsEditor *debuger;
#endif
};

#endif // TABLE_H
