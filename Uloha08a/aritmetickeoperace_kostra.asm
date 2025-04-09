; Autor: Miroslav Balik
; Source code: EXE(OBJ) 32bit Win32 API
; Directs for assembling and linking:
; nasm aritmetickeoperace.asm -fobj
; alink aritmetickeoperace.obj -oPE -subsys gui


%include 'WIN32N.inc'	;definice struktur a ruznych datovych typu

extern ExitProcess
import ExitProcess kernel32.dll
extern soucet
import soucet ../Uloha08b/operace.dll
extern fpu_op
import fpu_op ../Uloha08b/operace.dll

[section .data class=DATA use32 align=16]
param1 dd 1
param2 dd 2
param3 dd 3
IntCislo dd 19
RealCislo dd 1.28e-1

[section .code use32 class=CODE]
..start:

;naplneni zasobniku vstupnimi parametry
;volani funkce soucet

;naplneni zasobniku vstupnimi parametry
;volani funkce fpu_op

.end:
	push dword NULL
	call [ExitProcess]
	
	