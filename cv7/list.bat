@echo off
echo Assembling file %1
nasm -fobj %1 -l %~n1.txt
if not exist %~n1.txt exit
echo Listing file %~n1.txt
%~n1.txt
del %~n1.txt
del %~n1.obj
echo Done!
