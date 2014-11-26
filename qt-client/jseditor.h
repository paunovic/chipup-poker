#ifndef JSEDITOR_H
#define JSEDITOR_H

#include <QMainWindow>

namespace Ui {
class JsEditor;
}
class Table;

class JsEditor : public QMainWindow
{
	Q_OBJECT

public:
	explicit JsEditor(Table *parent = 0);
	~JsEditor();

private slots:
	void on_code_textChanged();
private:
	Ui::JsEditor *ui;
	Table *tbl;
};

#endif // JSEDITOR_H
