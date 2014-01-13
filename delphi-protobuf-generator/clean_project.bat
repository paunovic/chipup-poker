for /d /r . %%d in (__history,Win32,Win64) do @if exist "%%d" rd /s/q "%%d"
del /S *.dcu *.dof *.ddp *.fbl7