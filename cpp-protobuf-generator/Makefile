CXXFLAGS=-Wall
ifeq ($(OS),Windows_NT)
	LDFLAGS += protobuf.a
else
	LDFLAGS += -lprotoc
endif
all: protoc-gen-delphi
protoc-gen-delphi: main.o
	g++ main.o -o protoc-gen-delphi ${LDFLAGS}
main.o: main.cpp
