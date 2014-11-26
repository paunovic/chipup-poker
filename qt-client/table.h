#ifndef TABLE_H
#define TABLE_H

#include <QMainWindow>

#include "tablestatus.h"

class TablePrivate;
class JsEditor;

namespace Ui {
class Table;
}
namespace Data {
class Game;
}

class Table : public QMainWindow
{
	Q_OBJECT

public:
	explicit Table(QWidget *parent = 0);
	~Table();
	bool event(QEvent *event);
	void setGame(const Data::Game *game);
	void editJs(QString newcode);

private slots:
	void table_status(QSharedPointer<Data::TableStatus> ts);
	void on_actionReload_triggered();
	void on_teChatInput_returnPressed();
protected:
	void resizeEvent(QResizeEvent *event);
private:
	Ui::Table *ui;
	TablePrivate *p;
	const Data::Game *game;
	QSharedPointer<Data::TableStatus> lastTableStatus;
	JsEditor *debuger;
};

#endif // TABLE_H
