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

class Table : public QMainWindow {
	Q_OBJECT
public:
	explicit Table(QWidget *parent = 0);
	~Table();
	bool event(QEvent *event);
	void setGame(const Data::Game *game, const Data::Club *club);
	bool setGameForTesting(const Data::Game *game, QString jscode);
	void editJs(QString newcode);
	void eval(QString code);
public slots:
	bool On_table_status(QSharedPointer<Data::TableStatus> ts);
	void On_sit_ok(QByteArray gameid);
private slots:
	void on_actionReload_triggered();
	void on_teChatInput_returnPressed();
	void on_btStandUp_clicked();
	void on_btPlayNow_clicked();
	void on_btCheck_clicked();
	void on_btFold_clicked();
	void on_raiseSlider_valueChanged(int value);
	void on_btRaise_clicked();
	void on_btMin_clicked();
	void on_btMax_clicked();
	void on_bt3BB_clicked();
	void on_btPot_clicked();
	void on_btSitOut_stateChanged(int state);
	void on_cbSitOutBB_stateChanged(int state);
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
