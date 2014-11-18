#-------------------------------------------------
#
# Project created by QtCreator 2014-11-12T02:47:07
#
#-------------------------------------------------

QT       += core gui network

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

TARGET = qt-client
TEMPLATE = app

CONFIG += qt.debug debug
QMAKE_INFO_PLIST = Info.plist

# to compile into a dmg:
# codesign -f -s "Tox CI (jenkins) CSA" qtox.app --deep
# cp -r qt-client.app osx_img
# cd osx_img
# ln -s /Applications Applications
# hdiutil create -format UDBZ -verbose -ov -imagekey zlib-level=9 -volname "ChipUP Poker" -srcfolder . chipuppoker.dmg

SOURCES += main.cpp\
        loginwindow.cpp \
    pokermain.cpp \
    cpp/common.pb.cc \
    cpp/message.pb.cc \
    protobuf-2.5.0/src/google/protobuf/message_lite.cc \
    protobuf-2.5.0/src/google/protobuf/descriptor.pb.cc \
    protobuf-2.5.0/src/google/protobuf/descriptor.cc \
    protobuf-2.5.0/src/google/protobuf/message.cc \
    protobuf-2.5.0/src/google/protobuf/stubs/common.cc \
    protobuf-2.5.0/src/google/protobuf/unknown_field_set.cc \
    protobuf-2.5.0/src/google/protobuf/io/coded_stream.cc \
    protobuf-2.5.0/src/google/protobuf/generated_message_reflection.cc \
    protobuf-2.5.0/src/google/protobuf/wire_format.cc \
    protobuf-2.5.0/src/google/protobuf/reflection_ops.cc \
    protobuf-2.5.0/src/google/protobuf/wire_format_lite.cc \
    protobuf-2.5.0/src/google/protobuf/repeated_field.cc \
    protobuf-2.5.0/src/google/protobuf/extension_set.cc \
    protobuf-2.5.0/src/google/protobuf/text_format.cc \
    protobuf-2.5.0/src/google/protobuf/io/printer.cc \
    protobuf-2.5.0/src/google/protobuf/generated_message_util.cc \
    protobuf-2.5.0/src/google/protobuf/io/zero_copy_stream_impl.cc \
    protobuf-2.5.0/src/google/protobuf/stubs/once.cc \
    protobuf-2.5.0/src/google/protobuf/io/zero_copy_stream_impl_lite.cc \
    protobuf-2.5.0/src/google/protobuf/extension_set_heavy.cc \
    protobuf-2.5.0/src/google/protobuf/stubs/strutil.cc \
    protobuf-2.5.0/src/google/protobuf/io/zero_copy_stream.cc \
    protobuf-2.5.0/src/google/protobuf/stubs/substitute.cc \
    protobuf-2.5.0/src/google/protobuf/io/tokenizer.cc \
    protobuf-2.5.0/src/google/protobuf/dynamic_message.cc \
    protobuf-2.5.0/src/google/protobuf/stubs/atomicops_internals_x86_gcc.cc \
    protobuf-2.5.0/src/google/protobuf/stubs/stringprintf.cc \
    protobuf-2.5.0/src/google/protobuf/descriptor_database.cc \
    protobuf-2.5.0/src/google/protobuf/stubs/structurally_valid.cc \
    main_window.cpp club.cpp game.cpp join_club.cpp createclub.cpp \
    registerwindow.cpp \
    csseditor.cpp \
    table.cpp

HEADERS  += loginwindow.h \
    pokermain.h \
    cpp/common.pb.h \
    cpp/message.pb.h \
    config.h main_window.h club.h game.h join_club.h createclub.h \
    registerwindow.h \
    csseditor.h \
    table.h

FORMS    += loginwindow.ui main_window.ui join_club.ui createclub.ui \
    registerwindow.ui \
    csseditor.ui \
    table.ui

RESOURCES += \
    resources.qrc

OTHER_FILES += \
    resources/login/Background.png
