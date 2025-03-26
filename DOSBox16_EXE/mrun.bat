@echo off
setlocal enabledelayedexpansion

:: Check if a filename was provided
if "%1"=="" (
    echo Usage: %0 ^<filename^>
    exit /b 1
)

:: Assemble the file
echo Assembling %1
nasm %1 -fobj

:: Check if object file was created
if not exist %~n1.obj (
    echo Assembly failed
    if exist %~n1.exe del %~n1.exe
    exit /b 1
)

:: Link the object file
echo Linking
alink %~n1.obj

:: Check if executable was created
if not exist %~n1.exe (
    echo Linking failed
    exit /b 1
)

:: Run the executable in DOSBox
echo Running %~n1.exe in 16-bit DOSBox
%~d1\mnav\_dosbox\dosbox %~n1.exe -noconsole -exit /c

:: Clean up object file
del %~n1.obj

echo Done!