#include "checkerspicture.h"

CheckersPicture::CheckersPicture(QWidget *parent) : QWidget(parent)
{
    QPalette palette;
    palette.setColor(QPalette::Light,QColor(0x87,0xa1,0xc0));
    setPalette(palette);
    setBackgroundRole(QPalette::Light);
    setAutoFillBackground(true);

    setSizePolicy(QSizePolicy::Minimum, QSizePolicy::Minimum);
    setAttribute(Qt::WA_StaticContents);

    zoom = 32;
    n = 8;
    selectedCelli = -1;
    selectedCellj = -1;
    mouseClickCount = 0;
    gameStarted = false;
    setMinimumSize(zoom*(n+1),zoom*(n+1));
}

CheckersPicture::~CheckersPicture()
{

}

void CheckersPicture::setCheckers(CheckerState ** _checkers)
{
    this->checkers = _checkers;
}

void CheckersPicture::mousePressEvent(QMouseEvent *event)
{
    if(this->gameStarted == false)
        return;

    if (event->buttons() && Qt::LeftButton)
    {
        qreal i_d = (event->pos().x() - p.x() + side/(2*n+2))*(n+1)/side - 1.0;
        qreal j_d = (double)n - (event->pos().y() - p.y() + side/(2*n+2))*(n+1)/side;
        //перемудрено с i и j конечно..
        int i = n - (int)j_d - 1, j = (int)i_d;
        qDebug() << "pressed on " << i << " " << j;

        //если опять нажимают на ту же клетку - выходим
        if(selectedCelli == i && selectedCellj == j)
            return;

        //если нажато не на белую клетку
        if((i + j) % 2 == 1)
        {
            //и по белой пешке, дамке
            if((checkers[i][j] == WHITE || checkers[i][j] == WHITE_KING))
            {
                selectedCelli = i;
                selectedCellj = j;
                mouseClickCount++;
                qDebug() << "first";
                this->update();
            }
            else if(mouseClickCount == 1 && checkers[i][j] == NONE)//на пустой клетке
            {
                //сигнал о перемещении c selectedcelli, selectedcellj на i, j
                //enum CheckerState state = this->checkers[selectedCelli][selectedCellj];
                //this->checkers[selectedCelli][selectedCellj] = NONE;
                //this->checkers[i][j] = state;

                qDebug() << "second";
                qDebug() << "emit" << selectedCelli << selectedCellj << i << j;
                emit playerMove(selectedCelli, selectedCellj, i, j);
                selectedCelli = -1;
                selectedCellj = -1;
                mouseClickCount = 0;
            }
        }
        else
        {
            //нажатие на белую клетку
            selectedCelli = -1;
            selectedCellj = -1;
            mouseClickCount = 0;
            qDebug() << "empty";

            this->update();
        }
        /*
        if(color==BLACK)
            emit mouseClicked((int)i,(int)j);
        else
            emit mouseClicked(n - 1 - (int)i, n - 1 - (int)j);*/
    }
}

void CheckersPicture::mouseMoveEvent(QMouseEvent *event)
{

}

void CheckersPicture::paintEvent(QPaintEvent *event)
{
    qDebug() << "CheckersPicture::paintEvent()";

    QPainter painter(this);
    painter.setRenderHint(QPainter::Antialiasing, true);
    painter.setViewport(p.x(),p.y(),side,side);
    painter.setWindow(0, 0, zoom*(n+1.0), zoom*(n+1.0));

    QColor border(0xce,0x5c,0x00);
    painter.fillRect(QRect(0,0,zoom*(n+1.0),zoom*0.5), border);
    painter.fillRect(QRect(0,zoom*(n+0.5),zoom*(n+1.0),zoom*0.5), border);
    painter.fillRect(QRect(0,0,zoom*(0.5),zoom*(n+1.0)), border);
    painter.fillRect(QRect(zoom*(n+0.5),0,zoom*0.5,zoom*(n+1.0)), border);

    QColor dark(0xcc,0xcc,0xcc);

    for(int i = 0; i < n; i++) {
        for(int j = 0; j < n; j++) {
            QRect rect = pixelRect(i, j);
            if((i + j)%2 == 1) {
                    painter.fillRect(rect, dark);
            } else {
                painter.fillRect(rect, Qt::white);
            }
        }
    }

    QColor endColor(0x90,0x00,0x90);
    QColor startColor(0x33,0xff,0x00);
    QColor capturedColor(0xff,0x33,0x33);
    QColor normalColor(0x4c,0x4c,0xcc);

    int s = zoom*0.4;
    int sd = zoom*0.2;
    int i = 0, j = 0;

    //выделение
    if(selectedCelli != -1 && selectedCellj != -1)
    {
        QRect rect = pixelRect(selectedCelli, selectedCellj);
        painter.fillRect(rect, startColor);
    }

    //белые
    painter.setPen(QPen(Qt::black,zoom*0.1));
    painter.setBrush(QBrush(Qt::white));
    for(i = 0; i < n; i++) {
        for(j = 0; j < n; j++) {
            //на нужной клетке
            if((i + j) % 2 == 1)
            {
                if(checkers[i][j] == WHITE)
                {
                    painter.drawEllipse(QPoint(zoom * (j + 1), zoom * (i + 1)), s, s);
                }
                if(checkers[i][j] == WHITE_KING)
                {
                    painter.drawEllipse(QPoint(zoom * (j + 1), zoom * (i + 1)), s, s);
                    painter.drawEllipse(QPoint(zoom * (j + 1), zoom * (i + 1)), sd, sd);
                }
            }
        }
    }

    //чёрные
    painter.setBrush(QBrush(Qt::black));
    for(i = 0; i < n; i++) {
        for(j = 0; j < n; j++) {
            //на нужной клетке
            if((i + j) % 2 == 1)
            {
                if(checkers[i][j] == BLACK)
                {
                    painter.drawEllipse(QPoint(zoom * (j + 1), zoom * (i + 1)), s, s);
                }
                if(checkers[i][j] == BLACK_KING) {
                    painter.drawEllipse(QPoint(zoom * (j + 1), zoom * (i + 1)), s, s);
                    painter.setPen(QPen(Qt::white,zoom*0.1));
                    painter.drawEllipse(QPoint(zoom * (j + 1), zoom * (i + 1)), sd, sd);
                    painter.setPen(QPen(Qt::black,zoom*0.1));
                }
            }
        }
    }
}

void CheckersPicture::resizeEvent (QResizeEvent * event) {
    if(event->oldSize()!=event->size()) {
        update();
        side = qMin(width(), height());
        p = QPoint((width() - side) / 2, (height() - side) / 2);
    } else {
        event->ignore();
    }
}

QRect CheckersPicture::pixelRect(int i, int j) const
{
    return QRect(zoom * (j + 0.5), zoom * (i + 0.5), zoom, zoom);
}


