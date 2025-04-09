; Autor: Martin Szuc (231284)
; Datum: 09.04.2025
; Source code: DLL 32bit Win32 API
; Directs for assembling and linking:
; nasm tictoc.asm -fobj
; alink tictoc.obj -oPE -dll -o tictoc.dll

extern QueryPerformanceCounter
import QueryPerformanceCounter kernel32.dll
extern QueryPerformanceFrequency
import QueryPerformanceFrequency kernel32.dll

[section .data use32 class=DATA]
Qfreq: dd 0, 0    ; 64-bit premenná pre frekvenciu èasovaèa

[section .code use32 class=CODE]

GLOBAL _M_tic
GLOBAL _M_toc
GLOBAL _M_rtoc
GLOBAL _DllMain

_DllMain:
    ; Vstupny bod DLL kniznice
    mov eax, 1      ; Vrati TRUE
    ret 12          ; Vycisti zasobnik (3 parametre * 4 bajty kazdy)

_M_tic:
    ; Funkcia pre zacatie merania casu
    push ebp        ; Zaloha bazy ramca
    mov ebp, esp    ; Nastavenie novej bazy ramca
    
    ; Ziskanie pociatocneho casu pomocou QueryPerformanceCounter
    push dword [ebp+8]   ; Adresa pre ulozenie hodnoty casovaca
    call [QueryPerformanceCounter]
    
    ; Obnovenie registrov a navrat
    mov esp, ebp    ; Obnovenie zasobnika
    pop ebp         ; Obnovenie bazy ramca
    ret 4           ; Vycisti zasobnik (1 parameter * 4 bajty)

_M_toc:
    ; Funkcia pre ukoncenie merania casu a vratenie hodnoty v mikrosekundach (int)
    push ebp        ; Zaloha bazy ramca
    mov ebp, esp    ; Nastavenie novej bazy ramca
    sub esp, 8      ; Rezervacia miesta pre lokalnu premennu (koncovy cas)
    
    ; Ziskanie frekvencie casovaca (ak este nebola zistena)
    cmp dword [Qfreq], 0
    jne .skip_freq
    push Qfreq
    call [QueryPerformanceFrequency]
    
.skip_freq:
    ; Ziskanie koncoveho casu
    lea eax, [ebp-8]     ; Adresa lokalnej premennej pre koncovy cas
    push eax
    call [QueryPerformanceCounter]
    
    ; Vypocet casoveho rozdielu v mikrosekundach
    mov eax, [ebp-8]     ; Koncovy cas (nizsi 32 bitov)
    mov edx, [ebp-4]     ; Koncovy cas (vyssie 32 bitov)
    sub eax, [ebp+8]     ; Odcitanie pociatocneho casu (nizsi 32 bitov)
    sbb edx, [ebp+12]    ; Odcitanie s vypozicanim pre vyssie 32 bitov
    
    ; Konverzia na mikrosekundy (rozdelenie 64-bit cisla cez frekvenciu)
    ; Vynasobime rozdielem 1000000 na ziskanie mikrosekund
    push edx
    push eax
    mov ecx, 1000000
    mul ecx                ; nasobenie spodnych 32 bitov
    mov ebx, eax           ; ulozenie vysledku
    mov eax, edx
    pop edx
    mul ecx                ; nasobenie hornych 32 bitov
    add eax, ebx           ; pridanie spodnych 32 bitov
    adc edx, 0             ; pridanie prenosu
    
    ; Delenie frekvenciou
    div dword [Qfreq]      ; delenie frekvenciou
    
    ; Obnovenie registrov a navrat
    mov esp, ebp    ; Obnovenie zasobnika
    pop ebp         ; Obnovenie bazy ramca
    ret 4           ; Vycisti zasobnik (1 parameter * 4 bajty)

_M_rtoc:
    ; Funkcia pre ukoncenie merania casu a vratenie hodnoty v sekundach (double)
    push ebp        ; Zaloha bazy ramca
    mov ebp, esp    ; Nastavenie novej bazy ramca
    sub esp, 8      ; Rezervacia miesta pre lokalnu premennu (koncovy cas)
    
    ; Ziskanie frekvencie casovaca (ak este nebola zistena)
    cmp dword [Qfreq], 0
    jne .skip_freq
    push Qfreq
    call [QueryPerformanceFrequency]
    
.skip_freq:
    ; Ziskanie koncoveho casu
    lea eax, [ebp-8]     ; Adresa lokalnej premennej pre koncovy cas
    push eax
    call [QueryPerformanceCounter]
    
    ; Vypocet casoveho rozdielu a konverzia na sekundy pomocou FPU
    finit                ; Inicializacia FPU
    
    ; Nacitanie rozdielu casov na FPU zasobnik
    fild qword [ebp-8]   ; Nacitanie koncoveho casu
    fild qword [ebp+8]   ; Nacitanie pociatocneho casu
    fsub                 ; Vypocet rozdielu (ST(0) = koncovy - pociatocny)
    
    ; Delenie frekvenciou pre ziskanie sekund
    fild qword [Qfreq]   ; Nacitanie frekvencie
    fdiv                 ; Delenie (ST(0) = rozdiel / frekvencia = sekundy)
    
    ; Obnovenie registrov a navrat
    mov esp, ebp    ; Obnovenie zasobnika
    pop ebp         ; Obnovenie bazy ramca
    ret 4           ; Vycisti zasobnik (1 parameter * 4 bajty)