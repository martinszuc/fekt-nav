@echo off
echo Assembling file %1
nasm %1 -fobj
if not exist %~n1.obj (
if exist %~n1.exe del %~n1.exe
exit
)
echo Done!
alink %~n1.obj -oPE -subsys gui
echo Done!
del %~n1.obj
echo Running file %~n1.exe
%~n1.exe
echo Done!