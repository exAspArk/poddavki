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

    //обновляем поле
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


