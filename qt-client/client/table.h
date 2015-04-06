#ifndef TABLE_H
#define TABLE_H

//#define JSDEBUG

#include <QMainWindow>

#include "tablestatus.h"
#include "game.h"
#include "data/chat.h"

class TablePrivate;
class JsEditor;
class TableSit;
class QScriptValue;

namespace Ui {
class Table;
}
namespace Data {
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
	void renderWinning(QString msg);
	QByteArray getGameId() const { return game->gameid; }
	QSize sizeHint() const;
	void clearCheckBoxes();
	bool autoCheck();
	bool autoCheckFold();
	bool autoCall();
	bool autoCallAny();
	bool AutoFoldVisible();
	void SetAutoFoldVisible(bool in);
	bool AutoCheckFoldVisible() { return _AutoCheckFoldVisible; }
	void SetAutoCheckFoldVisible(bool in);
	bool AutoCallVisible() { return _AutoCallVisible; }
	void SetAutoCallVisible(bool in);
	int findMySeatIndex();
	QScriptValue global();

	Q_PROPERTY(bool AutoFoldVisible READ AutoFoldVisible WRITE SetAutoFoldVisible)
	Q_PROPERTY(bool AutoCheckFoldVisible READ AutoCheckFoldVisible WRITE SetAutoCheckFoldVisible)
	Q_PROPERTY(bool AutoCallVisible READ AutoCallVisible WRITE SetAutoCallVisible)
	Q_PROPERTY(int MySeatIndex READ findMySeatIndex)

protected:
	void resizeEvent(QResizeEvent *event);
public slots:
	bool On_table_status(QSharedPointer<Data::TableStatus> ts);
	void On_sit_ok(QByteArray gameid);
	void On_reserved_seat_free(QByteArray gameid, quint32 seat_index);
	void On_chat_event(Data::Chat packet);
	void tryAutoAction();
	bool canFold();
	bool canCheck();
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
	void on_btDouble_stateChanged(int state);
	void on_btJoinWaitingList_clicked();
	void on_cbAutoCall_stateChanged(int state);
	void on_cbAutoCallAny_stateChanged(int state);
	void on_cbAutoCheck_stateChanged(int state);
	void on_cbAutoCheckFold_stateChanged(int state);
private:
	Ui::Table *ui;
	TablePrivate *p;
	const Data::Game *game;
	QSharedPointer<Data::TableStatus> lastTableStatus;
	TableSit *sitwindow;
#ifdef JSDEBUG
	JsEditor *debuger;
#endif
	bool _AutoFoldVisible,_AutoCheckFoldVisible,_AutoCallVisible;
};

#endif // TABLE_H
