@echo off
if not exist %~n1.exe (
echo Nothing to debug.
exit
)
echo Debugging file %~n1.exe 
%~d1\mnav\_dosbox\dosbox -c "mount c %~d1\mnav\_debuggers\x16" -c "mount d %~d1%~p1." -c "c:\td.exe d:\%~n1.exe" -c "exit" -noconsole >nul
echo Done!