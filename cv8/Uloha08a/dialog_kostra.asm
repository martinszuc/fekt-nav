; dialog_kostra.asm - demonstration of timing with tictoc.dll
; 32-bit GUI exe
; 
; Build:
;   nasm dialog_kostra.asm -fobj -o dialog_kostra.obj
;   alink dialog_kostra.obj -oPE -subsys gui -o dialog.exe

%include "WIN32N.inc"

extern MessageBox
import MessageBox user32.dll MessageBoxA
extern ExitProcess
import ExitProcess kernel32.dll
extern wsprintf
import wsprintf user32.dll wsprintfA

; Note: static linking with "import" means we must have tictoc.dll accessible
; either in the same folder or in system PATH
extern _M_tic
import _M_tic tictoc.dll
extern _M_toc
import _M_toc tictoc.dll

[section .data class=DATA use32 align=16]
Qcounter:    resb LARGE_INTEGER_size
headline:    db "Rychlostni Test",0
title1:      db "Stiskni tlacitko OK pro start testu.",0
fzmervykon:  db "Tvuj cas: %lu us",0
zmervykon:   resb 20

[section .code use32 class=CODE]
..start:

    ; Start timing
    push dword Qcounter
    call [_M_tic]

    ; Show initial prompt
    push dword MB_OK
    push dword headline
    push dword title1
    push dword NULL
    call [MessageBox]

    ; Compute elapsed time in microseconds
    push dword Qcounter
    call [_M_toc]
    ; => EAX has us

    ; Format "Tvuj cas: <EAX> us"
    push dword eax
    push dword fzmervykon
    push dword zmervykon
    call [wsprintf]
    add esp, 12

    ; Show result
    push dword MB_OKCANCEL
    push dword headline
    push dword zmervykon
    push dword NULL
    call [MessageBox]

    ; Exit
    push dword NULL
    call [ExitProcess]

