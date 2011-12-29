# -------------------------------------------------
# Project created by QtCreator 2009-06-12T15:14:58
# -------------------------------------------------
TARGET = QCheckers
TEMPLATE = app
SOURCES += main.cpp \
    mainwindow.cpp \
    checkerspicture.cpp
HEADERS += mainwindow.h \
    checkerspicture.h
FORMS += mainwindow.ui
RESOURCES += icons.qrc
OTHER_FILES += README \
    COPYING
LIBS += ./swi-prolog/bin/swipl.dll
INCLUDEPATH += ./swi-prolog/include
