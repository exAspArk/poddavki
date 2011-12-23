#include "mainwindow.h"

#define PROLOG_PROGRAM "C:/Sii/project/maryapples.pro"

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

    //������ �����
    putenv("SWI_HOME_DIR=C:\\Program Files (x86)\\pl");
    static char * av []  =  { PROLOG_PROGRAM } ;
    if (!PL_initialise(1 , av))
    {
        PL_halt(1) ;
    }

    try
    {
        PlTermv terms(10);
        PlQuery q ("love" , terms) ;

        if (q.next_solution())
            qDebug() << QString(terms[2]);
        else
            qDebug() << "no solution";
    }
    catch ( PlException & ex )
    {
        QMessageBox::warning ( this , "Prolog Exception" , QString ( "Prolog has thrown an exception:" ) + QString ( ( char * ) ex ) ) ;
    }
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


