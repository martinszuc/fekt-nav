; Autor: xszucm00@vutbr.cz, ID: 231284
; Source code: EXE(OBJ) 32bit Win32 API
; Directs for assembling and linking:
; nasm paralelni_operace.asm -fobj
; alink paralelni_operace.obj -oPE -subsys gui
%include 'WIN32N.inc'	;definice struktur a ruznych datovych typu
extern CreateThread
import CreateThread kernel32.dll
extern ExitProcess
import ExitProcess kernel32.dll
extern MessageBoxA
import MessageBoxA user32.dll
extern wsprintfA
import wsprintfA user32.dll

STRUC PTRS
    .x RESD 1          ; Ukazatel vstupneho vektora x
    .M RESD 1          ; Ukazatel matice M
    .y RESD 1          ; Ukazatel vystupneho vektora y
    .length_x RESD 1   ; Dlzka vektora x
    .length_y RESD 1   ; Dlzka vektora y
    .posuv RESD 1      ; Velkost posuvu v bajtoch
    .DONE RESB 1       ; Priznak ukoncenia vypoctu: 0-prebieha, 1-dokoncene
ENDSTRUC

[section .data class=DATA use32 align=16]
; Testovaci vstupni vektor 1*4 a matice 4 * 4
y dd 0.0, 0.0, 0.0, 0.0
x dd 1.0, 2.0, 3.0, 4.0
M dd 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0

ptrs1: resb PTRS_size
ptrs2: resb PTRS_size

; Stringy pre vypis vysledkov
szTitle db "Paralelny vypocet - Vysledok", 0
szFormat db "Vysledny vektor y: %f, %f, %f, %f", 0
szBuffer: times 256 db 0

[section .code use32 class=CODE]
mat_x87_multi:
    ; Implementacia nasobenia vektora s maticou
    push ebp
    mov ebp, esp
    mov esi, [ebp + 12]    ; ukazatel na pole x
    mov ecx, [ebp + 20]    ; dlzka vstupneho vektora
    mov edx, [ebp + 8]     ; ukazatel na pole M
    finit                  ; inicializacia koprocesora
    
    .invec:
        mov edi, [ebp + 16]    ; ukazatel na pole y
        mov ebx, [ebp + 24]    ; dlzka vystupneho vektora
        
        .radmat:
            fld dword [esi]    ; nacitanie prvku z pola x
            fld dword [edx]    ; nacitanie prvku z matice M
            add edx, 4
            fmul st1           ; nasobenie
            fld dword [edi]    ; nacitanie vystupneho prvku
            fadd st1           ; pripocitanie vysledku
            fst dword [edi]    ; ulozenie do vystupneho vektora
            add edi, 4
            fstp st0
            fstp st0
            fstp st0
            dec ebx
            jnz .radmat
            
        add esi, 4
        add edx, [ebp + 28]    ; posun o velkost posuvu
        dec ecx
        jnz .invec
        
    mov esp, ebp
    pop ebp
ret 24

mat_x87_ptrs:
    ; Funkcia volana vlaknom
    push ebp
    mov ebp, esp
    mov eax, [ebp + 8]     ; ukazatel na strukturu PTRS
    push eax               ; zaloha eax
    
    ; Priprava parametrov pre volanie mat_x87_multi
    push dword [eax + PTRS.posuv]
    push dword [eax + PTRS.length_y]
    push dword [eax + PTRS.length_x]
    push dword [eax + PTRS.y]
    push dword [eax + PTRS.x]
    push dword [eax + PTRS.M]
    call mat_x87_multi
    
    pop eax                ; obnova eax
    mov byte [eax + PTRS.DONE], 1   ; oznacenie ukoncenia vypoctu
    mov eax, 1             ; navratova hodnota
    
    mov esp, ebp
    pop ebp
ret 4

..start:
    ; Inicializacia struktur
    ; Prva struktura - pre prvu polovicu vypoctu
    mov eax, ptrs1
    mov dword [eax + PTRS.x], x
    mov dword [eax + PTRS.y], y
    mov dword [eax + PTRS.M], M
    mov dword [eax + PTRS.length_x], 4
    mov dword [eax + PTRS.length_y], 2  ; polovica vystupneho vektora
    mov dword [eax + PTRS.posuv], 8     ; velkost posuvu (2*4 bajty)
    mov byte [eax + PTRS.DONE], 0
    
    ; Druha struktura - pre druhu polovicu vypoctu
    mov eax, ptrs2
    mov dword [eax + PTRS.x], x
    mov dword [eax + PTRS.y], y+8       ; druha polovica vystupneho vektora
    mov dword [eax + PTRS.M], M+8       ; druha polovica matice
    mov dword [eax + PTRS.length_x], 4
    mov dword [eax + PTRS.length_y], 2  ; polovica vystupneho vektora
    mov dword [eax + PTRS.posuv], 8     ; velkost posuvu (2*4 bajty)
    mov byte [eax + PTRS.DONE], 0
    
    ; Vytvorenie a spustenie vlakna
    push dword NULL
    push dword 0
    push dword ptrs2
    push dword mat_x87_ptrs
    push dword 0
    push dword 0
    call [CreateThread]
    
    ; Spustenie polovice vypoctu v hlavnom procese
    push ptrs1
    call mat_x87_ptrs
    
    ; Cakanie na ukoncenie behu vlakna
    .wait_for_thr:
        cmp byte [ptrs2 + PTRS.DONE], 1
        jnz .wait_for_thr
    
    ; Zobrazenie vysledku pomocou MessageBox
    push dword [y+12]      ; stvrty prvok
    push dword [y+8]       ; treti prvok
    push dword [y+4]       ; druhy prvok 
    push dword [y]         ; prvy prvok
    push dword szFormat
    push dword szBuffer
    call [wsprintfA]
    add esp, 24
    
    push dword MB_OK
    push dword szTitle
    push dword szBuffer
    push dword NULL
    call [MessageBoxA]
    
.end:
    push dword NULL
    call [ExitProcess]
