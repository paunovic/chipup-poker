include Makefile.include

all: clean client.exe

clean:
	del client.exe

client.dres: clientResource.rc resources\GameCarpet.png resources\GameTable.wmf
	cgrc.exe -c65001 $< -fo$@

client.exe: client.dpr client.dres
	${GCC} ${CFLAGS} client.dpr -q -DDEBUG
	copy /y client.exe ..\installer\client_files\chipuppoker.exe
	c:/poker/bb/git/bin/scp client.exe buildbotcheckout@c2d.localnet:/home/buildbotcheckout/
