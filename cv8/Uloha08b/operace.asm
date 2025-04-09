; operace.asm - Implementation of arithmetic functions in a DLL
; 32-bit, __stdcall convention
;
; Build:
;   nasm operace.asm -fobj -o operace.obj
;   alink operace.obj -oPE -dll -subsys windows -o operace.dll

[section .code use32]

GLOBAL _soucet
GLOBAL _fpu_op
GLOBAL _DllMain
EXPORT _soucet
EXPORT _fpu_op
EXPORT _DllMain

; ---------------------------------------------------------------------------
; int __stdcall soucet(int x, int y, int z);
; Returns x + y + z
_soucet:
    push ebp
    mov  ebp, esp

    mov  eax, [ebp+8]    ; x
    add  eax, [ebp+12]   ; y
    add  eax, [ebp+16]   ; z

    mov  esp, ebp
    pop  ebp
    ret  12              ; 3 params * 4 bytes

; ---------------------------------------------------------------------------
; float __stdcall fpu_op(int x, float y);
; Returns x / y as float
_fpu_op:
    push ebp
    mov  ebp, esp

    finit
    fld   dword [ebp+12] ; y (float)
    fild  dword [ebp+8]  ; x (int -> float)
    fdiv  st0, st1       ; st0 = x / y

    mov  esp, ebp
    pop  ebp
    ret  8               ; 2 params * 4 bytes

; ---------------------------------------------------------------------------
; BOOL WINAPI DllMain(...)
_DllMain:
    mov  eax, 1          ; return TRUE
    ret  12              ; 3 params * 4 bytes

