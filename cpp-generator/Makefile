CFLAGS=-Wall
all: protoc-gen-delphi
protoc-gen-delphi: main.o
	g++ main.o -o protoc-gen-delphi -lprotoc
main.o: main.cpp
