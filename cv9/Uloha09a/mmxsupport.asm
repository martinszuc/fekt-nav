; Autor: Martin Szuc VUTID:231284
; Datum: 16.04.2025
; Popis: Funkcia pre zistenie podpory MMX na procesore

global _MMXsupport

section .text

_MMXsupport:
    push dword ebp        ; Ulozenie hodnoty EBP na zasobnik
    mov dword ebp, esp    ; Nastavenie zasobnikoveho ramca
    
    ; Pouzitie instrukcie CPUID pre zistenie podpory MMX
    mov eax, 1            ; Nastavenie EAX = 1 pre ziskanie informacii o procesore
    cpuid                 ; Volanie instrukcie CPUID
    mov eax, edx          ; Presun EDX (obsahuje flags) do EAX
    shr eax, 23           ; Posun bitu 23 (MMX flag) do najnizsej pozicie
    and eax, 1            ; Maskovanie vsetkych bitov okrem najnizsieho
    
    mov dword esp, ebp    ; Obnovenie povodnej hodnoty ESP
    pop dword ebp         ; Obnovenie povodnej hodnoty EBP
    ret 0                 ; Navrat z funkcie (bez parametrov na stacku)
