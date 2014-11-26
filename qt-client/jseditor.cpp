#include "jseditor.h"
#include "ui_jseditor.h"
#include "table.h"

JsEditor::JsEditor(Table *parent) :
	QMainWindow(0), tbl(parent),
	ui(new Ui::JsEditor)
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
