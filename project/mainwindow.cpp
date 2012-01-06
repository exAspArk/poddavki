#include "mainwindow.h"

MainWindow::MainWindow(QWidget *parent) : QMainWindow(parent)
{
    setupUi(this);

    //���������
    QTextCodec::setCodecForTr(QTextCodec::codecForName("CP1251"));

    //��������� �����
    checkers = new CheckerState * [8];
    for(int i = 0; i < 8; i++)
        checkers[i] = new CheckerState[8];

    //������� ������ � ������� � ���������
    this->picture->setCheckers(checkers);

    // Signal-Slots
    connect(this->actionExit,           SIGNAL(triggered()), this, SLOT(close()));
    connect(this->actionStartNewGame,   SIGNAL(triggered()), this, SLOT(startNewGame()));
    connect(this->actionEndGame,        SIGNAL(triggered()), this, SLOT(endGame()));
    connect(this->actionAbout,          SIGNAL(triggered()), this, SLOT(about()));
    connect(this->picture,              SIGNAL(playerMove(int,int,int,int)), this, SLOT(player_move(int, int, int, int)));

    setWindowTitle(tr("��������"));
    resize(800,600);

    //������ �����
    putenv("SWI_HOME_DIR=C:\\Program Files (x86)\\pl");
    static char * av []  =  {"libpl.dll", NULL} ;

    if (PL_initialise(1 , av) == 0)
    {
        PL_halt(1);
        qDebug() << "lib initialize error -(";
    }
    else
        qDebug() << "lib initialize ok!";

    //�������� ����� �������
    try
    {
        if(PlCall("call", PlTermv(PlCompound("consult('Anti-checkers.pl')"))))
            qDebug() << "database opening ok!";
        else
            qDebug() << "database opening fail!";
    }
    catch ( PlException & ex )
    {
        QMessageBox::warning ( this , "Prolog Exception" , QString ( "Prolog has thrown an exception:" ) + QString ( ( char * ) ex ) ) ;
    }

    this->actionEndGame->setEnabled(false);
    startNewGame();
}

MainWindow::~MainWindow()
{

}

void MainWindow::startNewGame() {
    //��������� ������ ������ ����� ����
    this->actionStartNewGame->setEnabled(false);

    int i = 0, j = 0;
    ///*
    //�������� �������� �� ����
    for(i = 0; i < 8; i++)
        for(j = 0; j < 8; j++)
            checkers[i][j] = NONE;

    //���������� ������ � ������ � ��������� ���������
    for(j = 0; j < 8; j++)
    {
        for(i = 0; i < 3; i++)
            if((i + j) % 2 == 1)
                checkers[i][j] = BLACK;
        for(i = 5; i < 8; i++)
            if((i + j) % 2 == 1)
                checkers[i][j] = WHITE;
    }//*/
    try
    {
        ///*
        //�������� �������� � �������
        PlCall("retractall", PlTermv(PlCompound("computer_checker(_,_)")));
        PlCall("retractall", PlTermv(PlCompound("player_checker(_,_)")));
        PlCall("retractall", PlTermv(PlCompound("computer_king(_,_)")));
        PlCall("retractall", PlTermv(PlCompound("player_king(_,_)")));

        //�������
        char posi[10] = "";
        char posj[10] = "";
        char assert[30] = "";

        for(i = 0; i < 8; i++)
        {
            for(j = 0; j < 8; j++)
            {
                if((i + j) % 2 == 1)    //����������������)
                {
                    //�������
                    _itoa(i, posi, 10);
                    _itoa(j, posj, 10);

                    //�������
                    if(checkers[i][j] == WHITE)
                       strcpy(assert, "player_checker");
                    else if(checkers[i][j] == BLACK)
                         strcpy(assert, "computer_checker");
                    else
                        continue;

                    strcat(assert, "(");
                    strcat(assert, posi);
                    strcat(assert, ",");
                    strcat(assert, posj);
                    strcat(assert, ")");
                    qDebug() << assert;
                    PlCall("assert", PlTermv(PlCompound(assert)));
                }
            }
        }
        //*/
        char str_i[5];
        char str_j[5];
        //��������� ����� ������ � ������ checkers �� �����(��������).
        for(int i = 0; i < 8; i++)
        {
            for(int j = 0; j < 8; j++)
            {
                if((i + j) % 2 == 1)    //����� ����������������
                {
                    _itoa(i, str_i, 10);
                    _itoa(j, str_j, 10);

                    PlTermv args = PlTermv(PlCompound(str_i), PlCompound(str_j));

                    //�������
                    if(PlCall("player_checker", args))
                        checkers[i][j] = WHITE;
                    else if(PlCall("computer_checker", args))
                        checkers[i][j] = BLACK;
                    else if(PlCall("player_king", args))
                        checkers[i][j] = WHITE_KING;
                    else if(PlCall("computer_king", args))
                        checkers[i][j] = BLACK_KING;
                    else if(PlCall("empty", args))
                        checkers[i][j] = NONE;
                }
            }
        }
    }

    catch ( PlException & ex )
    {
        QMessageBox::warning ( this , "Prolog Exception" , QString ( "Prolog has thrown an exception:" ) + QString ( ( char * ) ex ) ) ;
    }

    //��������� ����
    this->picture->gameStarted = true;
    this->picture->update();

    //�������� ������ ���������� ����
    this->actionEndGame->setEnabled(true);
}

void MainWindow::endGame() {
    //�������� �������� � ��������
    this->actionEndGame->setEnabled(false);
    this->actionStartNewGame->setEnabled(true);

    //�������� �������� �� ����
    for(int i = 0; i < 8; i++)
        for(int j = 0; j < 8; j++)
            checkers[i][j] = NONE;

    this->picture->gameStarted = false;
    this->picture->update();
}

void MainWindow::about() {
    QMessageBox::about(this, tr("� ���������"),
               tr(
"<h3 align=center>��������</h3>"
"<P>������������:"
"<P align=right>������� �����, �� ������� � ������� ����������"
"<P align=center>- �������, ���-460, 2011 -"));
}

void MainWindow::player_move(int from_i, int from_j, int to_i, int to_j)
{
    char str_from_i[5];
    char str_from_j[5];
    char str_to_i[5];
    char str_to_j[5];
    char str_i[5];
    char str_j[5];

    _itoa(from_i, str_from_i, 10);
    _itoa(from_j, str_from_j, 10);
    _itoa(to_i, str_to_i, 10);
    _itoa(to_j, str_to_j, 10);

    try
    {
        if(PlCall("player_move", PlTermv(PlCompound(str_from_i), PlCompound(str_from_j), PlCompound(str_to_i), PlCompound(str_to_j))))
        {
            qDebug() << "can move" << from_i << from_j << to_i << to_j;

            //��������� ����� ������ � ������ checkers
            for(int i = 0; i < 8; i++)
            {
                for(int j = 0; j < 8; j++)
                {
                    if((i + j) % 2 == 1)    //����� ����������������
                    {
                        _itoa(i, str_i, 10);
                        _itoa(j, str_j, 10);

                        PlTermv args = PlTermv(PlCompound(str_i), PlCompound(str_j));

                        //�������
                        if(PlCall("player_checker", args))
                            checkers[i][j] = WHITE;
                        else if(PlCall("computer_checker", args))
                            checkers[i][j] = BLACK;
                        else if(PlCall("player_king", args))
                            checkers[i][j] = WHITE_KING;
                        else if(PlCall("computer_king", args))
                            checkers[i][j] = BLACK_KING;
                        else if(PlCall("empty", args))
                            checkers[i][j] = NONE;
                    }
                }
            }

            for(int i = 0; i < 8; i++)
                    qDebug() << checkers[i][0] << checkers[i][1] << checkers[i][2] << checkers[i][3] << checkers[i][4] << checkers[i][5] << checkers[i][6] << checkers[i][7];

            this->picture->update();

            //���� ���� �� �����������, ������� ���
            if(isComputerWin() == false)
            {
                //������ ������� ��� ���� ����������
                QTimer::singleShot(1000, this, SLOT(computer_move()));
            }
        }
        else
        {
            qDebug() << "cannot move" << from_i << from_j << to_i << to_j;
            this->picture->update();
        }

    }
    catch ( PlException & ex )
    {
        QMessageBox::warning ( this , "Prolog Exception" , QString ( "Prolog has thrown an exception:" ) + QString ( ( char * ) ex ) ) ;
    }
    this->picture->update();
}

void MainWindow::computer_move()
{
    char str_i[5];
    char str_j[5];

    try
    {
        //����� ������ - ��
        //����� ���������
        PlCall("computer_move");

        //��������� ����� ������ � ������ checkers
        for(int i = 0; i < 8; i++)
        {
            for(int j = 0; j < 8; j++)
            {
                if((i + j) % 2 == 1)    //����� ����������������
                {
                    _itoa(i, str_i, 10);
                    _itoa(j, str_j, 10);

                    //�������
                    PlTermv args = PlTermv(PlCompound(str_i), PlCompound(str_j));

                    if(PlCall("player_checker", args))
                        checkers[i][j] = WHITE;
                    else if(PlCall("computer_checker", args))
                        checkers[i][j] = BLACK;
                    else if(PlCall("player_king", args))
                        checkers[i][j] = WHITE_KING;
                    else if(PlCall("computer_king", args))
                        checkers[i][j] = BLACK_KING;
                    else if(PlCall("empty", args))
                        checkers[i][j] = NONE;
                }
            }
        }

        for(int i = 0; i < 8; i++)
                qDebug() << checkers[i][0] << checkers[i][1] << checkers[i][2] << checkers[i][3] << checkers[i][4] << checkers[i][5] << checkers[i][6] << checkers[i][7];

        this->picture->update();

        //���������, ����������� �� ����
        isPlayerWin();
    }
    catch ( PlException & ex )
    {
        QMessageBox::warning ( this , "Prolog Exception" , QString ( "Prolog has thrown an exception:" ) + QString ( ( char * ) ex ) ) ;
    }
}

bool MainWindow::isComputerWin()
{
    if(PlCall("computer_win"))
    {
        QMessageBox::information(this, tr("׸���� ��������!"), tr("׸���� ��������!") );
        return true;
    }
    else
    {
        return false;
    }
}

bool MainWindow::isPlayerWin()
{
    if(PlCall("player_win"))
    {
        QMessageBox::information(this, tr("����� ��������!"), tr("����� ��������!") );
        return true;
    }
    else
    {
        return false;
    }
}
