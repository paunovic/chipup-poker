test-driver: message.pb.o test-driver.o locking.o common.pb.o extra.pb.o funcs.o
	${CXX} $^ -o $@ -Wall -g -lssl -lprotobuf -llua
%.o: %.cpp
	${CXX} -c $< -o $@ -Wall -g -std=c++1z
test-driver.o: test-driver.cpp test-driver.h locking.h funcs.h
funcs.o: funcs.cpp funcs.h
install: test-driver
	mkdir -p ${out}/bin
	cp test-driver ${out}/bin/
