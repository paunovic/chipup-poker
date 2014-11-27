#include "jseditor.h"
#include "ui_jseditor.h"
#include "table.h"

#ifdef JSDEBUG

JsEditor::JsEditor(Table *parent) :
	QMainWindow(0),
	ui(new Ui::JsEditor), tbl(parent)
{
	ui->setupUi(this);
}

JsEditor::~JsEditor()
{
	delete ui;
}

void JsEditor::on_code_textChanged() {
	tbl->editJs(ui->code->toPlainText());
}

#endif
