#pragma once

#include <QDialog>

namespace Ui {
	class SelfTests;
}

class SelfTests : public QDialog {
Q_OBJECT
public:
	SelfTests();
private:
	Ui::SelfTests *ui;
};
