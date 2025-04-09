; tictoc.asm - Provides _M_tic, _M_toc, _M_rtoc for timing
; 32-bit, __stdcall
;
; Build:
;   nasm tictoc.asm -fobj -o tictoc.obj
;   alink tictoc.obj -oPE -dll -subsys windows -o tictoc.dll

%include "WIN32N.inc"

extern QueryPerformanceFrequency
import QueryPerformanceFrequency kernel32.dll

GLOBAL _M_toc
GLOBAL _M_rtoc
GLOBAL _M_tic
GLOBAL _DllMain
EXPORT _M_toc
EXPORT _M_rtoc
EXPORT _M_tic
EXPORT _DllMain

[section .data class=DATA use32 align=16]
; no special data needed

[section .code use32 class=CODE]

; -----------------------------------------------------------------------------
_DllMain:
    mov eax, 1
    ret 12

; -----------------------------------------------------------------------------
; int _stdcall M_toc(long *a);
; Return elapsed time in microseconds (32-bit) since saved timestamp
_M_toc:
    push ebp
    mov ebp, esp
    sub esp, 8

    lea ebx, [ebp - 8]
    push ebx
    call [QueryPerformanceFrequency]

    rdtsc            ; EDX:EAX => TSC
    mov ecx, edx
    mov ebx, [ebp+8]
    sub eax, [ebx]
    sbb ecx, [ebx+4]

    mov ebx, 1000
    mul ebx
    push eax
    push edx

    mov eax, ecx
    mul ebx
    pop ecx
    add ecx, eax

    pop eax
    mov edx, ecx
    mov ecx, [ebp - 8] ; freq
    div ecx

    mov esp, ebp
    pop ebp
    ret 4

; -----------------------------------------------------------------------------
; double _stdcall M_rtoc(long *a);
; Return elapsed time in seconds (double)
_M_rtoc:
    push ebp
    mov ebp, esp
    sub esp, 8

    finit
    mov eax, [ebp+8]
    fild qword [eax]
    rdtsc
    mov [ebp-4], edx
    mov [ebp-8], eax
    fild qword [ebp-8]
    fsub st1

    lea eax, [ebp-8]
    push eax
    call [QueryPerformanceFrequency]
    fild qword [ebp-8]
    fdivr st1

    mov esp, ebp
    pop ebp
    ret 4

; -----------------------------------------------------------------------------
; void _stdcall M_tic(long *a);
; Save current TSC in *a
_M_tic:
    push ebp
    mov ebp, esp

    rdtsc
    mov ebx, [ebp+8]
    mov [ebx], eax
    mov [ebx+4], edx

    mov esp, ebp
    pop ebp
    ret 4

