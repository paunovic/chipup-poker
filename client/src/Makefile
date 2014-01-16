include Makefile.include

all: clean client.exe

clean:
	del client.exe

client.dres: clientResource.rc resources\GameCarpet.png resources\GameTable.wmf
	cgrc.exe -c65001 $< -fo$@

client.exe: client.dpr client.dres
	${GCC} ${CFLAGS} client.dpr -q
