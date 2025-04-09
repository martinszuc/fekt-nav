; Autor: Martin Szuc (231284)
; Datum: 09.04.2025
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
result1 dd 0
result2 dd 0.0

[section .code use32 class=CODE]
..start:

; Volanie funkcie soucet
push dword [param3]    ; Treti parameter (z)
push dword [param2]    ; Druhy parameter (y)
push dword [param1]    ; Prvy parameter (x)
call [soucet]          ; Volanie funkcie soucet
mov [result1], eax     ; Ulozenie vysledku

; Volanie funkcie fpu_op
push dword [RealCislo] ; Float parameter (y)
push dword [IntCislo]  ; Int parameter (x)
call [fpu_op]          ; Volanie funkcie fpu_op
fstp dword [result2]   ; Ulozenie vysledku z FPU

.end:
	push dword NULL
	call [ExitProcess]
