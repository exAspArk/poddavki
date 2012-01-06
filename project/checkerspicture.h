#ifndef CHECKERSPICTURE_H
#define CHECKERSPICTURE_H

#include <QWidget>
#include <QPainter>
#include <QDebug>
#include <QResizeEvent>
#include <QPaintEvent>

#include "swi-prolog.h"
#include "swi-cpp.h"

typedef unsigned int uint8;

//перечисление
enum CheckerState{NONE, WHITE,
                  WHITE_KING,
                  BLACK, BLACK_KING};


class CheckersPicture : public QWidget
{
    Q_OBJECT
public:
    CheckersPicture(QWidget * parent = 0);
    ~CheckersPicture();
    void setCheckers(CheckerState ** checkers);
    bool gameStarted;

public slots:
signals:
    void playerMove(int, int, int, int);

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
    int n;                   //количество клеток
    uint8 color;             //цвет шашек противника
    CheckerState ** checkers;//массив с шашками
    int selectedCelli, selectedCellj;   //позици€ выделенной €чейки
    int mouseClickCount;     //количество нажатий
};

#endif // CHECKERSPICTURE_H
