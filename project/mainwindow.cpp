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

    setWindowTitle(tr("Поддавки"));
	resize(800,600);

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
    //обнуляем значения в прологе
/*
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
        PlQuery q("call", PlTermv(PlCompound("consult('poddavki.pl')")));
        if(q.next_solution())
            qDebug() << "database opening ok!";
        else
            qDebug() << "database opening fail!";


        PlTermv pt(2);
        PlQuery retrall("retractall", PlTermv(PlCompound("computer_figure")));

        char str_i[3];
        char str_j[3];
        for(int i = 0; i < 8; i++)
            for(j = 0; j < 8; j++)
            {
                _itoa(i, str_i, 10);
                _itoa(j, str_j, 10);
                switch(draughts[i][j])
                {
                    case BLACK:

                    pt[0] = PlCompound("computer_figure", PlTermv(PlTerm(str_i), PlTerm(str_j)));
                    PlQuery q1("assert", pt);
                    qDebug() << i << j;
                    if(q1.next_solution())
                        qDebug() << "assert ok";
                    else
                        qDebug() << "assert fail";
                }
            }
        PlQuery q2("computer_figure", pt);
       // while(q2.next_solution())
         //   qDebug() << (char *)pt[0];
    }
    catch ( PlException & ex )
    {
        QMessageBox::warning ( this , "Prolog Exception" , QString ( "Prolog has thrown an exception:" ) + QString ( ( char * ) ex ) ) ;
    }*/

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

bool MainWindow::retractall(const char * what)
{
    PlQuery q("retractall", PlTermv(PlCompound(what)));
    if(q.next_solution())
        return true;
    else return false;
}
