#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QtGui/QMainWindow>
#include <QMessageBox>
#include <QTextCodec>
#include <QTimer>
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
    void player_move(int from_i, int from_j, int to_i, int to_j);
    void computer_move();
private:
    bool isGameEnded();
    CheckerState ** draughts;   //массив с расположением фигур
};

#endif // MAINWINDOW_H
