#ifndef CHECKERSPICTURE_H
#define CHECKERSPICTURE_H

#include <QWidget>
#include <QPainter>
#include <QDebug>
#include <QResizeEvent>
#include <QPaintEvent>

typedef unsigned int uint8;

class CheckersPicture : public QWidget
{
    Q_OBJECT
public:
    CheckersPicture(QWidget * parent = 0);
    ~CheckersPicture();
public slots:
signals:
    void mouseClicked(int, int);
protected:
    void mousePressEvent(QMouseEvent *event);
    void mouseMoveEvent(QMouseEvent *event);
    void paintEvent(QPaintEvent *event);
    void resizeEvent (QResizeEvent * event);
private:
    QRect pixelRect(int i, int j) const;

    //CheckersState * curstate;
    //std::vector <point> v;
    QPoint p;
    int side;
    int zoom;
    int n;      //количество клеток

    uint8 color;										// цвет шашек противника
};

#endif // CHECKERSPICTURE_H
