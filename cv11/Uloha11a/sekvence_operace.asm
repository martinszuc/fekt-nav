; Autor: xszucm00@vutbr.cz, ID: 231284
; Source code: EXE(OBJ) 32bit Win32 API
; Directs for assembling and linking:
; nasm sekvence_operace.asm -fobj
; alink sekvence_operace.obj -oPE -subsys gui
%include 'WIN32N.inc'	;definice struktur a ruznych datovych typu
extern ExitProcess
import ExitProcess kernel32.dll
extern MessageBoxA
import MessageBoxA user32.dll
extern wsprintfA
import wsprintfA user32.dll

[section .data class=DATA use32 align=16]
; Testovaci vstupni vektor 1*4 a matice 4 * 4
y dd 0.0, 0.0, 0.0, 0.0
x dd 1.0, 2.0, 3.0, 4.0
M dd 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0

; Stringy pre vypis vysledkov
szTitle db "Sekvencny vypocet - Vysledok", 0
szFormat db "Vysledny vektor y: %f, %f, %f, %f", 0
szBuffer: times 256 db 0

[section .code use32 class=CODE]
mat_x87_multi:
    ; Implementacia nasobenia vektora s maticou - sekvencne spracovanie
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

..start:
    ; Sekvencny vypocet - volat len jednu operaciu pre celu maticu
    push dword 0           ; posuv - v sekvencnom pripade nie je potrebny
    push dword 4           ; dlzka vystupneho vektora (pole y)
    push dword 4           ; dlzka vstupneho vektora (pole x)
    push dword y           ; ukazatel na pole y
    push dword x           ; ukazatel na pole x
    push dword M           ; ukazatel na pole M
    call mat_x87_multi
    
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
