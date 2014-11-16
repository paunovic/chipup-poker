#ifndef CSSEDITOR_H
#define CSSEDITOR_H

#include <QWidget>

namespace Ui {
class CssEditor;
}

class CssEditor : public QWidget
{
	Q_OBJECT

public:
	explicit CssEditor(QWidget *parent = 0);
	~CssEditor();

private slots:
	void on_css_textChanged();

private:
	Ui::CssEditor *ui;
};

#endif // CSSEDITOR_H
