@echo off
if not exist %~n1.exe (
echo Nothing to run.
exit
)
echo Running file %~n1.exe
%~n1.exe
echo Done!