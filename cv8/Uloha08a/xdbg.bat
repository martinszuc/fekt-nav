@echo off
if not exist %~n1.exe (
echo Nothing to debug.
exit
)
echo Debugging file %~n1.exe 
%~d1\mnav\_debuggers\x32\x32dbg.exe  %~d1%~p1%~n1.exe >Nul
echo Done! 


