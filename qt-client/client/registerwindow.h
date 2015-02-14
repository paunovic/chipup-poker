#ifndef REGISTERWINDOW_H
#define REGISTERWINDOW_H

#include <QDialog>

namespace Ui {
class RegisterWindow;
}

class RegisterWindow : public QDialog
{
    Q_OBJECT

public:
    explicit RegisterWindow(QWidget *parent = 0);
    ~RegisterWindow();
    void checkInputs();

private slots:
    void on_edEmail_textEdited();
    void on_edPassword_textEdited();
    void on_edConfirmPassword_textEdited();
    void on_edUsername_textEdited();
    void on_cb18Years_stateChanged();
    void on_cbTOS_stateChanged();
    void on_btSignUp_clicked();
    void On_register_success();

private:
    Ui::RegisterWindow *ui;
};

#endif // REGISTERWINDOW_H
