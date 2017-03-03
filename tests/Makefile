test-driver: message.pb.o test-driver.o locking.o common.pb.o extra.pb.o
	${CXX} $^ -o $@ -Wall -g -lssl -lprotobuf
%.o: %.cpp
	${CXX} -c $^ -o $@ -Wall -g -std=c++1z
install: test-driver
	mkdir -p ${out}/bin
	cp test-driver ${out}/bin/
