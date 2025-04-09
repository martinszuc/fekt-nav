; aritmetickeoperace_kostra.asm - demonstration of calling operace.dll
; 32-bit GUI exe
;
; Build:
;   nasm aritmetickeoperace_kostra.asm -fobj -o aritmetickeoperace_kostra.obj
;   alink aritmetickeoperace_kostra.obj -oPE -subsys gui -o aritmetickeoperace.exe

%include "WIN32N.inc"

extern ExitProcess
import ExitProcess kernel32.dll
extern MessageBoxA
import MessageBoxA user32.dll
extern wsprintfA
import wsprintfA user32.dll

; We'll import _gcvt from msvcrt.dll to handle float->string
extern _gcvt
import _gcvt msvcrt.dll

; Link to operace.dll
extern _soucet
import _soucet operace.dll
extern _fpu_op
import _fpu_op operace.dll

[section .data class=DATA use32 align=16]
param1 dd 10
param2 dd 20
param3 dd 30

IntCislo dd 100
RealCislo dd 2.5    ; single-precision float

; Strings
title db "Function Results",0

; We'll show the real param and result as strings => two buffers
float_param_str  times 32 db 0
float_result_str times 32 db 0

; Our final format uses 7 placeholders:
;   %d, %d, %d, %d, %d, %s, %s
; to show:
;   soucet(10,20,30)=60
;   fpu_op(100,2.5)=40
result_format db "soucet(%d, %d, %d) = %d", 13,10, "fpu_op(%d, %s) = %s",0
result_buffer times 256 db 0

[section .code use32 class=CODE]
..start:

; 1) Call _soucet( param1, param2, param3 )
push dword [param3]
push dword [param2]
push dword [param1]
call [_soucet]
mov ebx, eax   ; hold the sum

; 2) Convert RealCislo (2.5 float) to ASCII => float_param_str
;    We must load it as a double for _gcvt
finit
fld dword [RealCislo]   ; load single float into ST(0)
sub esp, 8              ; reserve space for a double
fstp qword [esp]        ; store ST(0) as 64-bit double
mov eax, [esp]          ; low 32 bits
mov edx, [esp+4]        ; high 32 bits
add esp, 8
;  call _gcvt( double_value, digits, buffer )
push dword float_param_str
push dword 6            ; precision
push dword eax
push dword edx
call [_gcvt]
add esp, 16

; 3) Call _fpu_op( IntCislo, RealCislo ) => returns float ST(0)
push dword [RealCislo]
push dword [IntCislo]
call [_fpu_op]

; store result as double => call _gcvt => float_result_str
sub esp, 8
fstp qword [esp]
mov eax, [esp]
mov edx, [esp+4]
add esp, 8
push dword float_result_str
push dword 6
push dword eax
push dword edx
call [_gcvt]
add esp, 16

; 4) Use wsprintfA to build final string
; Format string placeholders:
;   %d %d %d %d  = 4 integer placeholders
;   %d %s %s     = integer + string + string
push dword float_result_str  ; 7th => %s
push dword float_param_str   ; 6th => %s
push dword [IntCislo]        ; 5th => %d
push dword ebx               ; 4th => %d (the sum)
push dword [param3]          ; 3rd => %d
push dword [param2]          ; 2nd => %d
push dword [param1]          ; 1st => %d
push dword result_format
push dword result_buffer
call [wsprintfA]
add esp, 36  ; 9 pushes => 36 bytes

; 5) Show a message box with the result
push dword MB_OK
push dword title
push dword result_buffer
push dword NULL
call [MessageBoxA]

; 6) Exit
push dword NULL
call [ExitProcess]

