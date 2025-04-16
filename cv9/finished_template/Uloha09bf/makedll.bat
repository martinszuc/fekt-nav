@echo off
echo Assembling file %1
nasm %1 -fobj
if not exist %~n1.obj (
if exist %~n1.dll del %~n1.dll
exit
)
echo Done.
alink %~n1.obj -oPE -dll -o %~n1.dll
del %~n1.obj
echo Done.
