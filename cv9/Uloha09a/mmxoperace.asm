; Autor: Miroslav Balík
; Source code: EXE(OBJ) 32bit Win32 API
; Directs for assembling and linking:
; nasm mmxoperace.asm -fobj
; alink mmxoperace.obj -oPE -subsys gui


%include 'WIN32N.inc'	;definice struktur a ruznych datovych typu


extern ExitProcess
import ExitProcess kernel32.dll




[section .data class=DATA use32 align=16]

a: db 100,110,120,130
b: db 200,200,200,200
;f: db 127,127,127,127
f: db 128,128,128,128
y: db 0,0,0,0




[section .code use32 class=CODE]
..start:

	;
	; Sem vlozit vypocty
	;



.end:
	push dword NULL
	call [ExitProcess]
	
	