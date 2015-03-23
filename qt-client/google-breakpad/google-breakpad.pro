#-------------------------------------------------
#
# Project created by QtCreator 2015-03-23T10:50:25
#
#-------------------------------------------------

QT       -= core gui

TARGET = google-breakpad
TEMPLATE = lib
CONFIG += staticlib
LIBS += -lwininet

SOURCES += \
    common/windows/guid_string.cc \
    common/windows/http_upload.cc \
    common/windows/string_utils.cc \
    client/windows/handler/exception_handler.cc \
    client/windows/crash_generation/crash_generation_client.cc

HEADERS += \
    common/windows/string_utils-inl.h \
    common/windows/guid_string.h \
    common/windows/http_upload.h \
    client/windows/handler/exception_handler.h \
    client/windows/common/ipc_protocol.h \
    google_breakpad/common/minidump_format.h \
    client/windows/crash_generation/crash_generation_client.h
unix {
    target.path = /usr/lib
    INSTALLS += target
}
