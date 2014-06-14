CXXFLAGS=-Wall -g
ifeq ($(OS),Windows_NT)
	LDFLAGS += protobuf.a
	EXTENSION = .exe
else
	LDFLAGS += -lprotoc -lprotobuf
endif
all: protoc-gen-delphi${EXTENSION}
protoc-gen-delphi${EXTENSION}: main.o
	g++ main.o -o protoc-gen-delphi ${LDFLAGS}
protoc-gen-pascal${EXTENSION}: protoc-gen-delphi${EXTENSION}
	cp protoc-gen-delphi${EXTENSION} protoc-gen-pascal${EXTENSION}
main.o: main.cpp
	g++ ${CXXFLAGS} -c -o $@ $+
