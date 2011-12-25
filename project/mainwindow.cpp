#include "mainwindow.h"

MainWindow::MainWindow(QWidget *parent) : QMainWindow(parent)
{
	setupUi(this);

    //кодировка
    QTextCodec::setCodecForTr(QTextCodec::codecForName("CP1251"));

    //обнуление шашек
    draughts = new CheckerState * [8];
    for(int i = 0; i < 8; i++)
        draughts[i] = new CheckerState[8];

    //передаём шашки в отрисовку
    this->picture->setDraughts(this->draughts);

	// Signal-Slots
    connect(actionExit, SIGNAL(triggered()), this, SLOT(close()));

	connect(actionStartNewGame, SIGNAL(triggered()), this, SLOT(startNewGame()));
	connect(actionEndGame, SIGNAL(triggered()), this, SLOT(endGame()));
    connect(actionAbout, SIGNAL(triggered()), this, SLOT(about()));
    connect(this->picture, SIGNAL(playerMove(int,int,int,int)), this, SLOT(move(int, int, int, int)));

    setWindowTitle(tr("Поддавки"));
	resize(800,600);

    //инклуд файла
    putenv("SWI_HOME_DIR=C:\\Program Files (x86)\\pl");
    static char * av []  =  {"libpl.dll", NULL} ;

    if (PL_initialise(1 , av) == 0)
    {
        PL_halt(1);
        qDebug() << "lib initialize error -(";
    }
    else
        qDebug() << "lib initialize ok!";

    //открытие файла пролога
    try
    {
        if(PlCall("call", PlTermv(PlCompound("consult('poddavki.pl')"))))
            qDebug() << "database opening ok!";
        else
            qDebug() << "database opening fail!";
    }
    catch ( PlException & ex )
    {
        QMessageBox::warning ( this , "Prolog Exception" , QString ( "Prolog has thrown an exception:" ) + QString ( ( char * ) ex ) ) ;
    }

    actionEndGame->setEnabled(false);
    startNewGame();
}

MainWindow::~MainWindow()
{

}

void MainWindow::startNewGame() {
    //выключаем кнопку начала новой игры
    actionStartNewGame->setEnabled(false);

    int i = 0, j = 0;
    //обнуляем значения из базы
    for(i = 0; i < 8; i++)
        for(j = 0; j < 8; j++)
            draughts[i][j] = NONE;

    //записываем данные о пешках в начальном состоянии
    for(j = 0; j < 8; j++)
    {
        for(i = 0; i < 3; i++)
            if((i + j) % 2 == 1)
                draughts[i][j] = BLACK;
        for(i = 5; i < 8; i++)
            if((i + j) % 2 == 1)
                draughts[i][j] = WHITE;
    }
    try
    {
        //обнуляем значения в прологе
        PlCall("retractall", PlTermv(PlCompound("computer_figure(_,_)")));
        PlCall("retractall", PlTermv(PlCompound("player_figure(_,_)")));
        PlCall("retractall", PlTermv(PlCompound("computer_king(_,_)")));
        PlCall("retractall", PlTermv(PlCompound("player_king(_,_)")));

        //позиции
        char posi[10] = "";
        char posj[10] = "";
        char assert[30] = "";

        for(i = 0; i < 8; i++)
        {
            for(j = 0; j < 8; j++)
            {
                if((i + j) % 2 == 1)    //микрооптимизация)
                {
                    //позиция
                    _itoa(i, posi, 10);
                    _itoa(j, posj, 10);

                    //запросы
                    if(draughts[i][j] == WHITE)
                       strcpy(assert, "player_figure");
                    else if(draughts[i][j] == BLACK)
                         strcpy(assert, "computer_figure");
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
    }

    catch ( PlException & ex )
    {
        QMessageBox::warning ( this , "Prolog Exception" , QString ( "Prolog has thrown an exception:" ) + QString ( ( char * ) ex ) ) ;
    }

    //обновляем поле
    this->picture->gameStarted = true;
    this->picture->update();

    //включаем кнопку выключения игры
    actionEndGame->setEnabled(true);
}

void MainWindow::endGame() {
    //обратные действия с кнопками
	actionEndGame->setEnabled(false);
    actionStartNewGame->setEnabled(true);

    //обнуляем значения из базы
    for(int i = 0; i < 8; i++)
        for(int j = 0; j < 8; j++)
            draughts[i][j] = NONE;

    this->picture->gameStarted = false;
    this->picture->update();
}

void MainWindow::gameEnded(uint8 status) {
    if(status == 0)
        QMessageBox::information(this, tr("Белые победили!"),
        tr("Чёрные победили!") );
    if(status == 1)
        QMessageBox::information(this, tr("Чёрные победили!"),
        tr("Чёрные победили!") );
}

void MainWindow::about() {
    QMessageBox::about(this, tr("О программе"),
               tr(
"<h3 align=center>Поддавки</h3>"
"<P>Разработчики:"
"<P align=right>Ермолов Роман, Евгений Ли и Константин Сухарев"
"<P align=center>- ВолгГТУ, ИВТ-460, 2011 -"));
}

void MainWindow::move(int from_i, int from_j, int to_i, int to_j)
{
    char str_from_i[5];
    char str_from_j[5];
    char str_to_i[5];
    char str_to_j[5];

    _itoa(from_i, str_from_i, 10);
    _itoa(from_j, str_from_j, 10);
    _itoa(to_i, str_to_i, 10);
    _itoa(to_j, str_to_j, 10);

    try
    {
        if(PlCall("player_move", PlTermv(PlCompound(str_from_i), PlCompound(str_from_j), PlCompound(str_to_i), PlCompound(str_to_j))))
        {


            qDebug() << "can move" << from_i << from_j << to_i << to_j;








            //сбрасывем новые данные в массив draughts
            for(int i = 0; i < 8; i++)
            {
                for(int j = 0; j < 8; j++)
                {
                    if((i + j) % 2 == 1)    //опять микрооптимизация
                    {
                        _itoa(i, str_from_i, 10);
                        _itoa(j, str_from_j, 10);
                        //qDebug() << "cell:" << i << j;
                        //запросы
                        if(PlCall("player_figure", PlTermv(PlCompound(str_from_i), PlCompound(str_from_j))))
                            draughts[i][j] = WHITE;
                        else if(PlCall("computer_figure", PlTermv(PlCompound(str_from_i), PlCompound(str_from_j))))
                            draughts[i][j] = BLACK;
                        else if(PlCall("player_king", PlTermv(PlCompound(str_from_i), PlCompound(str_from_j))))
                            draughts[i][j] = WHITE_KING;
                        else if(PlCall("computer_king", PlTermv(PlCompound(str_from_i), PlCompound(str_from_j))))
                            draughts[i][j] = BLACK_KING;
                        else if(PlCall("empty", PlTermv(PlCompound(str_from_i), PlCompound(str_from_j))))
                            draughts[i][j] = NONE;
                    }
                }
            }

            for(int i = 0; i < 8; i++)
                    qDebug() << draughts[i][0] << draughts[i][1] << draughts[i][2] << draughts[i][3] << draughts[i][4] << draughts[i][5] << draughts[i][6] << draughts[i][7];












            //можно ходить - ок
            //ходит компьютер
            PlCall("computer_move");

            //сбрасывем новые данные в массив draughts
            for(int i = 0; i < 8; i++)
            {
                for(int j = 0; j < 8; j++)
                {
                    if((i + j) % 2 == 1)    //опять микрооптимизация
                    {
                        _itoa(i, str_from_i, 10);
                        _itoa(j, str_from_j, 10);
                        //qDebug() << "cell:" << i << j;
                        //запросы
                        if(PlCall("player_figure", PlTermv(PlCompound(str_from_i), PlCompound(str_from_j))))
                            draughts[i][j] = WHITE;
                        else if(PlCall("computer_figure", PlTermv(PlCompound(str_from_i), PlCompound(str_from_j))))
                            draughts[i][j] = BLACK;
                        else if(PlCall("player_king", PlTermv(PlCompound(str_from_i), PlCompound(str_from_j))))
                            draughts[i][j] = WHITE_KING;
                        else if(PlCall("computer_king", PlTermv(PlCompound(str_from_i), PlCompound(str_from_j))))
                            draughts[i][j] = BLACK_KING;
                        else if(PlCall("empty", PlTermv(PlCompound(str_from_i), PlCompound(str_from_j))))
                            draughts[i][j] = NONE;
                    }
                }
            }

            for(int i = 0; i < 8; i++)
                    qDebug() << draughts[i][0] << draughts[i][1] << draughts[i][2] << draughts[i][3] << draughts[i][4] << draughts[i][5] << draughts[i][6] << draughts[i][7];
        }
        else
            qDebug() << "cannot move" << from_i << from_j << to_i << to_j;

    }
    catch ( PlException & ex )
    {
        QMessageBox::warning ( this , "Prolog Exception" , QString ( "Prolog has thrown an exception:" ) + QString ( ( char * ) ex ) ) ;
    }
    this->picture->update();
}
