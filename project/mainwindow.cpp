#include "mainwindow.h"

MainWindow::MainWindow(QWidget *parent) : QMainWindow(parent)
{
	setupUi(this);

    //���������
    QTextCodec::setCodecForTr(QTextCodec::codecForName("CP1251"));

	// Signal-Slots
    connect(actionExit, SIGNAL(triggered()), this, SLOT(close()));

	connect(actionStartNewGame, SIGNAL(triggered()), this, SLOT(startNewGame()));
	connect(actionEndGame, SIGNAL(triggered()), this, SLOT(endGame()));
    connect(actionAbout, SIGNAL(triggered()), this, SLOT(about()));

    setWindowTitle(tr("��������"));
	resize(800,600);

    actionEndGame->setEnabled(false);
}

MainWindow::~MainWindow()
{

}

void MainWindow::startNewGame() {
    /*QSettings settings("Arceny","QCheckers");
	actionStartNewGame->setEnabled(false);
	int type = settings.value("type",RUSSIAN).toInt();
	int color = settings.value("color",WHITE).toInt();
	int level = settings.value("depth",3).toInt();
	std::cout << type << " " << color << "\n"; std::cout.flush();
	if(color == WHITE)
		color = BLACK;
	else
		color = WHITE;
	game->setGameType(type);
	picture->setComputerColor(color);
	game->setMaxLevel(level);
	game->startNewGame(color);

	actionEndGame->setEnabled(true);
	goFirst->setEnabled(true);
	goLast->setEnabled(true);
	goPrev->setEnabled(true);
    goNext->setEnabled(true);*/
}

void MainWindow::endGame() {
	actionEndGame->setEnabled(false);
    //picture->clear();
	actionStartNewGame->setEnabled(true);
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


