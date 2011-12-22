#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QtGui/QMainWindow>
#include <QMessageBox>
#include <QTextCodec>
#include "checkerspicture.h"
#include "ui_mainwindow.h"

class MainWindow : public QMainWindow, public Ui::MainWindow
{
    Q_OBJECT

public:
    MainWindow(QWidget *parent = 0);
    ~MainWindow();
private slots:
	void startNewGame();
	void endGame();
    void about();
	void gameEnded(uint8 status);
private:
    CheckerState ** draughts;     //массив с расположением фигур
};

#endif // MAINWINDOW_H
