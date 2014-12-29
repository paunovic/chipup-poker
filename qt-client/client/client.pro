#-------------------------------------------------
#
# Project created by QtCreator 2014-11-12T02:47:07
#
#-------------------------------------------------

QT       += core gui network script

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

TARGET = client
TEMPLATE = app

#CONFIG += qt.debug debug
QMAKE_INFO_PLIST = Info.plist
INCLUDEPATH += ../protobuf/

# to compile into a dmg:
# codesign -f -s "Tox CI (jenkins) CSA" qtox.app --deep
# cp -r qt-client.app osx_img
# cd osx_img
# ln -s /Applications Applications
# hdiutil create -format UDBZ -verbose -ov -imagekey zlib-level=9 -volname "ChipUP Poker" -srcfolder . chipuppoker.dmg
win32 {
LIBS += -L../protobuf/release/ -L../protobuf/debug/
}
unix {
LIBS += -L../protobuf/
}
LIBS += -lprotobuf
SOURCES += main.cpp\
        loginwindow.cpp \
    pokermain.cpp \
    cpp/common.pb.cc \
    cpp/message.pb.cc \
    main_window.cpp club.cpp game.cpp join_club.cpp createclub.cpp \
    registerwindow.cpp \
    csseditor.cpp \
    table.cpp \
    tableprivate.cpp \
    tablestatus.cpp \
    data/seatinfo.cpp \
    data/tableevent.cpp \
    data/pot.cpp \
    data/tablemessage.cpp \
    data/hand.cpp \
    table/visible_seat.cpp \
    table/game_object.cpp \
    table/table_ui.cpp \
    jseditor.cpp \
    data/user.cpp \
    table/card.cpp \
    table/animation.cpp \
    table/animatecore.cpp \
    table/chip.cpp \
    table/table_sit.cpp \
    data/playerclubstatus.cpp \
    table/dealerbutton.cpp

HEADERS  += loginwindow.h \
    pokermain.h \
    cpp/common.pb.h \
    cpp/message.pb.h \
    config.h main_window.h club.h game.h join_club.h createclub.h registerwindow.h \
    csseditor.h table/game_wrap.h \
    table.h \
    tableprivate.h \
    tablestatus.h \
    data/seatinfo.h \
    data/tableevent.h \
    data/pot.h \
    data/tablemessage.h \
    data/hand.h \
    jseditor.h \
    table/visible_seat.h \
    table/card.h \
    table/chip.h \
    data/user.h \
    table/animation.h \
    table/animatecore.h \
    table/table_sit.h \
    data/playerclubstatus.h \
    table/dealerbutton.h

FORMS    += loginwindow.ui main_window.ui join_club.ui createclub.ui \
    registerwindow.ui \
    csseditor.ui \
    table.ui \
    jseditor.ui \
    table/table_sit.ui

RESOURCES += \
    resources.qrc

OTHER_FILES += scripts.qrc \
    table.js

TRANSLATIONS += chipuppoker_ru.ts
