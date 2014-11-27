#include <QDebug>
#include <QApplication>

#include "csseditor.h"
#include "ui_csseditor.h"
#include "pokermain.h"

CssEditor::CssEditor(QWidget *parent) :
	QWidget(parent),
	ui(new Ui::CssEditor)
{
	ui->setupUi(this);
	QFile styles(":/stylesheet.css");
	if (!styles.open(QIODevice::ReadOnly | QIODevice::Text)) {
		qDebug() << "failed to load css";
	} else {
		QByteArray buffer;
		while (!styles.atEnd()) {
			buffer.append(styles.readAll());
		}
		QString css(buffer);
		ui->css->setPlainText(css);
	}
}
CssEditor::~CssEditor()
{
	delete ui;
}
void CssEditor::on_css_textChanged() {
	qDebug() << "updating css";
	core->app->setStyleSheet(ui->css->toPlainText());
}
