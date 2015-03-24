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

win32 {
SOURCES += \
    common/windows/guid_string.cc \
    common/windows/http_upload.cc \
    common/windows/string_utils.cc \
    client/windows/handler/exception_handler.cc \
    client/windows/crash_generation/crash_generation_client.cc
}
linux {
SOURCES += client/linux/handler/exception_handler.cc client/linux/log/log.cc common/linux/linux_libc_support.cc client/linux/handler/minidump_descriptor.cc common/linux/guid_creator.cc \
	client/linux/crash_generation/crash_generation_client.cc client/linux/microdump_writer/microdump_writer.cc client/linux/minidump_writer/linux_ptrace_dumper.cc \
	client/linux/minidump_writer/linux_dumper.cc common/linux/memory_mapped_file.cc common/linux/elfutils.cc common/linux/file_id.cc client/linux/dump_writer_common/ucontext_reader.cc \
	common/linux/safe_readlink.cc client/linux/minidump_writer/minidump_writer.cc client/linux/minidump_writer/minidump_writer.cc client/minidump_file_writer.cc common/string_conversion.cc \
	client/linux/dump_writer_common/seccomp_unwinder.cc common/convert_UTF.c client/linux/dump_writer_common/thread_info.cc
}
mac {
INCLUDEPATH += client/mac/
SOURCES += client/mac/handler/exception_handler.cc client/mac/handler/minidump_generator.cc client/mac/crash_generation/crash_generation_client.cc common/md5.cc \
	common/mac/macho_id.cc common/mac/macho_walker.cc common/mac/macho_utilities.cc common/mac/string_utilities.cc common/mac/MachIPC.mm common/mac/bootstrap_compat.cc \
	common/mac/file_id.cc client/minidump_file_writer.cc client/mac/dynamic_images.cc client/mac/handler/dynamic_images.cc client/mac/handler/breakpad_nlist_64.cc \
	common/string_conversion.cc common/convert_UTF.c
}

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
