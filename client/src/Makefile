include Makefile.include

release: all
debug: all
	$(eval FLAGS := -DDEBUG)

all: clean client.exe

clean:
	del client.exe

client.dres: clientResource.rc resources/cashier/Normal.png resources/cashier/Pressed.png resources/table/Background.jpg resources/table/Table.png
	cgrc.exe -c65001 $< -fo$@

client.exe: client.dpr client.dres
	${GCC} ${CFLAGS} -gd client.dpr -q ${FLAGS}
	"c:\Program Files\madCollection\madExcept\Tools\madExceptPatch.exe" client.exe
	copy /y client.exe ..\installer\client_files\chipuppoker.exe

release-upload:
	c:/poker/bb/git/bin/scp client.exe buildbotcheckout@c2d.localnet:/home/buildbotcheckout/release
debug-upload:
	c:/poker/bb/git/bin/scp client.exe buildbotcheckout@c2d.localnet:/home/buildbotcheckout/debug
