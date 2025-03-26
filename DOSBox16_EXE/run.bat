@echo off
if not exist %~n1.exe (
echo Nothing to run.
exit
)
echo Running file %~n1.exe in 16-bit DOSBox
%~d1\mnav\_dosbox\dosbox %~n1.exe -noconsole
echo Done!