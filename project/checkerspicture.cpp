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
    setMinimumSize(zoom*(n+1),zoom*(n+1));
}

CheckersPicture::~CheckersPicture()
{

}

void CheckersPicture::setDraughts(CheckerState ** _draughts)
{
    this->draughts = _draughts;
}

void CheckersPicture::mousePressEvent(QMouseEvent *event)
{
    /*
    //qDebug() << side << " " << x << " " << event->pos().x() << " " << event->pos().y();
    //if (event->buttons() && Qt::LeftButton && mouseClickFlag) {
    if (event->buttons() && Qt::LeftButton) {
        qreal i = (event->pos().x() - p.x() + side/(2*n+2))*(n+1)/side - 1.0;
        qreal j = (double)n - (event->pos().y() - p.y() + side/(2*n+2))*(n+1)/side;
        //qDebug() << (int)i << " " << (int)j;
        if(color==BLACK)
            emit mouseClicked((int)i,(int)j);
        else
            emit mouseClicked(n -1 - (int)i, n - 1 - (int)j);
    }
    */
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

    for(int i=0; i<n; i++) {
        for(int j=0; j<n; j++) {
            QRect rect = pixelRect(i, j);
            if( !((i+j%2)%2) ) {
                    painter.fillRect(rect, dark);
            } else {
                painter.fillRect(rect, Qt::white);
            }
        }
    }

    int ix = 0, jx = 0;  //???
    QColor endColor(0x90,0x00,0x90);
    QColor startColor(0x33,0xff,0x00);
    QColor capturedColor(0xff,0x33,0x33);
    QColor normalColor(0x4c,0x4c,0xcc);

    int s = zoom*0.4;
    int sd = zoom*0.2;
    int i = 0, j = 0;

    //белые
    painter.setPen(QPen(Qt::black,zoom*0.1));
    painter.setBrush(QBrush(Qt::white));
    for(i = 0; i < n; i++) {
        for(j = 0; j < n; j++) {
            //на нужной клетке
            if((i + j) % 2 == 0)
            {
                if(draughts[i][j] == WHITE)
                {
                    jx = j + 1;
                    ix = n - i;
                    painter.drawEllipse(QPoint(zoom*(ix),zoom*(jx)), s, s);
                    qDebug() << "White: " << i << " " << j;
                }
                if(draughts[i][j] == WHITE_KING)
                {
                    jx = n - j;
                    ix = i + 1;
                    painter.drawEllipse(QPoint(zoom*(ix),zoom*(jx)), s, s);
                    painter.drawEllipse(QPoint(zoom*(ix),zoom*(jx)), sd, sd);
                }
            }
        }
    }

    //чёрные
    painter.setBrush(QBrush(Qt::black));
    for(i = 0; i < n; i++) {
        for(j = 0; j < n; j++) {
            //на нужной клетке
            if((i + j) % 2 == 0)
            {
                if(draughts[i][j] == BLACK)
                {
                    jx = j + 1;
                    ix = n - i;
                    painter.drawEllipse(QPoint(zoom*(ix),zoom*(jx)), s, s);
                    qDebug() << "Black: " << i << " " << j;
                }
                if(draughts[i][j] == BLACK_KING) {
                    jx = n - j;
                    ix = i + 1;
                    painter.drawEllipse(QPoint(zoom*(ix),zoom*(jx)), s, s);
                    painter.setPen(QPen(Qt::white,zoom*0.1));
                    painter.drawEllipse(QPoint(zoom*(ix),zoom*(jx)), sd, sd);
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
    return QRect(zoom * i + zoom*0.5, zoom*(n-0.5) - zoom * j, zoom, zoom);
}


