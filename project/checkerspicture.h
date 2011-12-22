#ifndef CHECKERSPICTURE_H
#define CHECKERSPICTURE_H

#include <QWidget>
#include <QPainter>
#include <QDebug>
#include <QResizeEvent>
#include <QPaintEvent>

typedef unsigned int uint8;

//������������ - ����� �� �����-�������(���� � �������� ����)
enum CheckerState{NONE, WHITE,
                  WHITE_KING,
                  BLACK, BLACK_KING};


class CheckersPicture : public QWidget
{
    Q_OBJECT
public:
    CheckersPicture(QWidget * parent = 0);
    ~CheckersPicture();
    void setDraughts(CheckerState ** _draughts);

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
    int n;      //���������� ������
    uint8 color;	//���� ����� ����������
    CheckerState ** draughts;//������ � �������
};

#endif // CHECKERSPICTURE_H
