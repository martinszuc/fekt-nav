; Autor: Martin Szuc, VUTID:231284
; Datum: 16.04.2025
; Funkcia na detekciu podpory MMX instrukci pomocou instrukcie CPUID

[section .code use32 class=CODE]

global _MMXsupport
_MMXsupport:
    ; Ulozenie registrov podla Windows 32-bit ABI
    push dword ebp
    mov dword ebp, esp
    
    ; Nastavenie EAX=1 pre volanie CPUID (ziskanie informacii o procesore)
    mov eax, 1
    cpuid
    
    ; Ziskanie vysledku z EDX, bit 23 obsahuje informaciu o podpore MMX
    mov eax, edx    ; Presun hodnoty EDX do EAX
    shr eax, 23     ; Posun o 23 bitov doprava (bit 23 bude na pozicii 0)
    and eax, 1      ; Bitovy AND s 1 - vysledok bude 1 ak je MMX podporovane, inak 0
    
    ; Obnova registrov a navrat z funkcie
    mov dword esp, ebp
    pop dword ebp
    ret
