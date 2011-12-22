#include "mainwindow.h"

MainWindow::MainWindow(QWidget *parent) : QMainWindow(parent)
{
	setupUi(this);

    //���������
    QTextCodec::setCodecForTr(QTextCodec::codecForName("CP1251"));

    //��������� �����
    draughts = new CheckerState * [8];
    for(int i = 0; i < 8; i++)
        draughts[i] = new CheckerState[8];

    //������� ����� � ���������
    this->picture->setDraughts(this->draughts);

	// Signal-Slots
    connect(actionExit, SIGNAL(triggered()), this, SLOT(close()));

	connect(actionStartNewGame, SIGNAL(triggered()), this, SLOT(startNewGame()));
	connect(actionEndGame, SIGNAL(triggered()), this, SLOT(endGame()));
    connect(actionAbout, SIGNAL(triggered()), this, SLOT(about()));

    setWindowTitle(tr("��������"));
	resize(800,600);

    actionEndGame->setEnabled(false);
    startNewGame();
}

MainWindow::~MainWindow()
{

}

void MainWindow::startNewGame() {
    //��������� ������ ������ ����� ����
    actionStartNewGame->setEnabled(false);

    int i = 0, j = 0;
    //�������� �������� �� ����
    for(i = 0; i < 8; i++)
        for(j = 0; j < 8; j++)
            draughts[i][j] = NONE;

    //���������� ������ � ������ � ��������� ���������
    for(j = 0; j < 8; j++)
    {
        for(i = 0; i < 3; i++)
            if((i + j) % 2 == 1)
                draughts[i][j] = BLACK;
        for(i = 5; i < 8; i++)
            if((i + j) % 2 == 1)
                draughts[i][j] = WHITE;
    }

    //��������� ����
    this->picture->update();

    //�������� ������ ���������� ����
    actionEndGame->setEnabled(true);
}

void MainWindow::endGame() {
    //�������� �������� � ��������
	actionEndGame->setEnabled(false);
    actionStartNewGame->setEnabled(true);

    //�������� �������� �� ����
    for(int i = 0; i < 8; i++)
        for(int j = 0; j < 8; j++)
            draughts[i][j] = NONE;

    this->picture->update();
}

void MainWindow::gameEnded(uint8 status) {
    if(status == 0)
        QMessageBox::information(this, tr("����� ��������!"),
        tr("׸���� ��������!") );
    if(status == 1)
        QMessageBox::information(this, tr("׸���� ��������!"),
        tr("׸���� ��������!") );
}

void MainWindow::about() {
    QMessageBox::about(this, tr("� ���������"),
               tr(
"<h3 align=center>��������</h3>"
"<P>������������:"
"<P align=right>������� �����, ������� �� � ���������� �������"
"<P align=center>- �������, ���-460, 2011 -"));
}


