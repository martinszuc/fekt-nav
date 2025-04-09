; Autor: Miroslav Balik
; Source code: EXE(OBJ) 32bit Win32 API
; Directs for assembling and linking:
; nasm dialog.asm -fobj
; alink dialog.obj -oPE -subsys gui


%include 'WIN32N.inc'	;definice struktur a ruznych datovych typu

extern MessageBox
import MessageBox user32.dll MessageBoxA
extern ExitProcess
import ExitProcess kernel32.dll
extern QueryPerformanceCounter
import QueryPerformanceCounter kernel32.dll
extern QueryPerformanceFrequency
import QueryPerformanceFrequency kernel32.dll
extern wsprintf
import wsprintf user32.dll wsprintfA
extern M_tic
import M_tic ../Uloha08b/tictoc.dll
extern M_toc
import M_toc ../Uloha08b/tictoc.dll


[section .data class=DATA use32 align=16]
Qcounter: resb LARGE_INTEGER_size
cas_counter: resb LARGE_INTEGER_size
headline: DB "Jsi rychlejší?",0
title1: DB "Stiskni tlaèítko OK.",0
fzmervykon: DB "Tvùj èas: %lu us",0
zmervykon resb 20


[section .code use32 class=CODE]
..start:

;
; 	zavolej funkci tic, vstupni promena bude Qcounter
;

	push dword MB_OK
	push dword headline
	push dword title1
	push dword NULL
	call [MessageBox]

;
; 	zavolej funkci toc, vstupni promena bude Qcounter,
;		vystup bude v eax (v STO pro rtoc)
;

;Nasledujici kod provede zformatovani text retezce
;	push eax
;	push fzmervykon;
;	push zmervykon
;	call [wsprintf]

	push dword MB_OKCANCEL
	push dword headline
	push dword zmervykon
	push dword NULL
	call [MessageBox]

 
	jmp .end
.end:
	push dword NULL
	call [ExitProcess]