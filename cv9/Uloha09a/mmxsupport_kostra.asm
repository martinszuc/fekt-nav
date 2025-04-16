; Autor: Martin Szuc VUTID:231284
; Datum: 16.04.2025
; Popis: Funkcia pre zistenie podpory MMX na procesore

global _MMXsupport

section .text

_MMXsupport:
    push dword ebp
    mov dword ebp, esp
    
    ; Pouzitie instrukcie CPUID pre zistenie podpory MMX
    mov eax, 1      ; Nastavenie EAX = 1 pre ziskanie informacii
    cpuid           ; Volanie instrukcie CPUID
    mov eax, edx    ; Presun EDX (obsahuje flags) do EAX
    shr eax, 23     ; Posun bitu 23 (MMX flag) do najnizsej pozicie
    and eax, 1      ; Maskovanie vsetkych bitov okrem najnizsieho
    
    mov dword esp, ebp
    pop dword ebp
    ret 0
