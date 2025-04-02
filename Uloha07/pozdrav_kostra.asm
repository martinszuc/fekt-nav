; Autor: Miroslav Balík
; Source code: EXE(OBJ) 32bit Win32 API
; Directs for assembling and linking:
; nasm pozdrav.asm -fobj
; alink pozdrav.obj -oPE -subsys gui

; sablonu je potreba prejmenovat na pozdrav.asm


%include 'WIN32N.inc'	;definice struktur a ruznych datovych typu

extern MessageBox
import MessageBox user32.dll MessageBoxA
extern ExitProcess
import ExitProcess kernel32.dll

[section .data class=DATA use32 align=16]


[section .code use32 class=CODE]
..start:



	push dword NULL
	call [ExitProcess]