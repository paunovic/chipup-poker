include Makefile.include

release: all
debug: all
FLAGS=-DDEBUG

all: clean client.exe

clean:
	del client.exe

client.dres: clientResource.rc resources\GameCarpet.png resources\GameTable.wmf
	cgrc.exe -c65001 $< -fo$@

client.exe: client.dpr client.dres
	${GCC} ${CFLAGS} client.dpr -q ${FLAGS}
	copy /y client.exe ..\installer\client_files\chipuppoker.exe

release-upload:
	c:/poker/bb/git/bin/scp client.exe buildbotcheckout@c2d.localnet:/home/buildbotcheckout/release
debug-upload:
	c:/poker/bb/git/bin/scp client.exe buildbotcheckout@c2d.localnet:/home/buildbotcheckout/debug
