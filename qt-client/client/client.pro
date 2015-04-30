#-------------------------------------------------
#
# Project created by QtCreator 2014-11-12T02:47:07
#
#-------------------------------------------------

QT       += core gui network script scripttools

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets multimedia

TARGET = client
TEMPLATE = app

#CONFIG += qt.debug debug
QMAKE_INFO_PLIST = Info.plist
QMAKE_CXXFLAGS += -g
INCLUDEPATH += ../protobuf/ ../google-breakpad/
TARGET = chipuppoker

# to compile into a dmg:
# codesign -f -s "Tox CI (jenkins) CSA" qtox.app --deep
# cp -r qt-client.app osx_img
# cd osx_img
# ln -s /Applications Applications
# hdiutil create -format UDBZ -verbose -ov -imagekey zlib-level=9 -volname "ChipUP Poker" -srcfolder . chipuppoker.dmg
win32 {
LIBS += -L../protobuf/release/ -L../protobuf/debug/ -L../google-breakpad/debug/ -L../google-breakpad/release/ -lgoogle-breakpad
DEFINES += BUILDNUM=$(BUILDNUM)
}
unix {
LIBS += -L../protobuf/ -L../google-breakpad/
}
linux {
LIBS += -lgoogle-breakpad
}
mac {
#LIBS +=  -F/Users/clever -framework Breakpad
LIBS += -lgoogle-breakpad -framework CoreFoundation
}
LIBS += -lprotobuf
SOURCES += main.cpp loginwindow.cpp data/chat.cpp \
    pokermain.cpp pokermain_shared.cpp \
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
    table/dealerbutton.cpp \
    table/scriptagent.cpp \
    clublobby.cpp \
    data/clubmember.cpp \
    data/winnerdata.cpp \
    updatehasher.cpp \
    filesaver.cpp \
    version.cpp \
    minidumpuploader.cpp \
    notifywindow.cpp contactus.cpp

HEADERS  += loginwindow.h data/chat.h \
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
    table/dealerbutton.h \
    table/scriptagent.h \
    clublobby.h \
    data/clubmember.h \
    data/winnerdata.h \
    updatehasher.h \
    filesaver.h \
    version.h \
    minidumpuploader.h \
    notifywindow.h contactus.h

SOURCES += sound_effects.cpp selftest.cpp
HEADERS += sound_effects.h selftest.h refholder.h

FORMS    += loginwindow.ui main_window.ui join_club.ui createclub.ui \
    registerwindow.ui \
    csseditor.ui \
    table.ui \
    jseditor.ui \
    table/table_sit.ui selftest.ui \
    clublobby.ui \
    NotifyWindow.ui contactus.ui

RESOURCES += \
    resources.qrc

OTHER_FILES += scripts.qrc \
    table.js

TRANSLATIONS += chipuppoker_ru.ts
