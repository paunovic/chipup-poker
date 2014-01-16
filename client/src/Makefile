include Makefile.include

all: client.exe


client.dres: clientResource.rc
	cgrc.exe -c65001 $< -fo$@

client.exe: client.dpr client.dres client.res
	${GCC} ${CFLAGS} client.dpr -q