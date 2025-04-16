; Autor: Martin Szuc VUTID:231284
; Datum: 16.04.2025
; Popis: Demonstracia jednoduchych MMX operacii na poliach dat
; Directives pre assemblovanie a linkovanie:
; nasm mmxoperace.asm -fobj
; alink mmxoperace.obj -oPE -subsys gui

%include 'WIN32N.inc'    ; Definicie struktur a datovych typov pre Win32 API

extern ExitProcess       ; Importovana funkcia pre ukoncenie processu
import ExitProcess kernel32.dll

[section .data class=DATA use32 align=16]  ; Datova sekcia, 16-bytove zarovnanie pre MMX

; Testovacie polia hodnot
a: db 100,110,120,130    ; Pole A - 4 bajty reprezentujuce pixely prveho obrazka
b: db 200,200,200,200    ; Pole B - 4 bajty reprezentujuce pixely druheho obrazka
f: db 128,128,128,128    ; Faktor prelinu - hodnota 128 znamena 50% mix (stred rozsahu 0-255)
y: db 0,0,0,0            ; Vystupne pole pre vysledky - inicializovane na nuly

[section .code use32 class=CODE]  ; Kodova sekcia
..start:
    ; *** KONTROLA PODPORY MMX INSTRUKCII ***
    ; Tento kod kontroluje, ci procesor podporuje MMX instrukcie
    mov eax, 1            ; Nastavenie EAX = 1 pre CPUID
    cpuid                 ; Volanie CPUID - vracia informacie o procesore
    test edx, 0x800000    ; Test bitu 23 (MMX flag) v EDX
    jz .end               ; Ak procesor nepodporuje MMX, preskoc na koniec

    ; *** IMPLEMENTACIA MMX VYPOCTU PRE ZMIESNANIE HODNOT ***
    ; Tento kod implementuje rovnicu: y = (a*f + b*(255-f))/255
    
    ; 1. INICIALIZACIA
    pxor mm0, mm0         ; Vynulovanie registra mm0 pre pouzitie pri rozbaleni bajtov
    
    ; 2. NACITANIE DAT DO MMX REGISTROV
    ; - Nacitanie do MMX registrov a rozsirenie z 8-bit na 16-bit format
    movd mm1, [a]         ; Nacitanie dat z pola A: mm1 = 0 0 0 0 a3 a2 a1 a0
    punpcklbw mm1, mm0    ; Rozsirenie na slova: mm1 = 0 a3 0 a2 0 a1 0 a0
    
    movd mm2, [b]         ; Nacitanie dat z pola B: mm2 = 0 0 0 0 b3 b2 b1 b0
    punpcklbw mm2, mm0    ; Rozsirenie na slova: mm2 = 0 b3 0 b2 0 b1 0 b0
    
    movd mm3, [f]         ; Nacitanie faktoru: mm3 = 0 0 0 0 f3 f2 f1 f0
    punpcklbw mm3, mm0    ; Rozsirenie na slova: mm3 = 0 f3 0 f2 0 f1 0 f0
    
    ; 3. UPRAVA ROZSAHU FAKTORU [0-255] -> [0-256]
    ; - Toto je nutne pre aproximaciu delenia 255 pomocou delenia 256 (posun o 8 bitov)
    movq mm6, mm3         ; Kopia faktoru: mm6 = f
    psrlw mm6, 7          ; Delenie 128: mm6 = f/128 (priblizne 0 alebo 1)
    paddw mm3, mm6        ; mm3 = f + (f/128) ~ f * (1 + 1/128) ~ f * 256/255
    
    ; 4. VYPOCET KOMPLEMENTARNEHO FAKTORU (256 - f)
    pcmpeqw mm4, mm4      ; Vsetky bity na 1: mm4 = 0xFFFF pre kazde slovo
    psrlw mm4, 15         ; Iba najnizsi bit 1: mm4 = 0x0001 pre kazde slovo
    psllw mm4, 8          ; Posun o 8 bitov: mm4 = 0x0100 (256) pre kazde slovo
    psubw mm4, mm3        ; mm4 = 256 - f (komplementarny faktor)
    
    ; 5. NASOBENIE A SCITANIE
    pmullw mm1, mm3       ; mm1 = a * f (nasobenie po slovach)
    pmullw mm2, mm4       ; mm2 = b * (256-f) (nasobenie po slovach)
    paddw mm1, mm2        ; mm1 = a*f + b*(256-f) (scitanie po slovach)
    
    ; 6. DELENIE 256 (APROXIMACIA DELENIA 255)
    psrlw mm1, 8          ; mm1 = (a*f + b*(256-f))/256 (posun o 8 bitov = delenie 256)
    
    ; 7. ZABALENIE A ULOZENIE VYSLEDKU
    packuswb mm1, mm0     ; Zabalenie 16-bit hodnot spat na 8-bit: mm1 = 0 0 0 0 y3 y2 y1 y0
    movd [y], mm1         ; Ulozenie vysledku do pola y
    
    ; 8. UKONCENIE PRACE S MMX
    emms                  ; Empty MMX State - povinne ukoncenie prace s MMX registrami

.end:
    ; Ukoncenie programu
    push dword NULL       ; Parameter pre ExitProcess (navratovy kod 0)
    call [ExitProcess]    ; Volanie Windows API funkcie pre ukoncenie programu
