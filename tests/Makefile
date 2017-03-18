test-driver: test-driver.o locking.o funcs.o pokerclient.o
	${CXX} $^ -o $@ -g -lssl -lprotobuf -llua -levent_pthreads -levent -levent_openssl -lprotos
%.o: %.cpp
	${CXX} -c -Wall -g -std=c++1z $< -o $@
%.o: %.cc
	${CXX} -c -Wall -g -std=c++1z $< -o $@
test-driver.o: test-driver.cpp test-driver.h locking.h funcs.h
funcs.o: funcs.cpp funcs.h
pokerclient.o: pokerclient.cpp test-driver.h
install: test-driver
	mkdir -p ${out}/bin
	cp test-driver ${out}/bin/
