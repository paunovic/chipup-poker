CXXFLAGS=-Wall
ifeq ($(OS),Windows_NT)
	LDFLAGS += protobuf.a
	EXTENSION = .exe
else
	LDFLAGS += -lprotoc
endif
all: protoc-gen-delphi${EXTENSION}
protoc-gen-delphi${EXTENSION}: main.o
	g++ main.o -o protoc-gen-delphi ${LDFLAGS}
main.o: main.cpp
