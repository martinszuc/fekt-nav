; Autor: Martin Szuc VUTID:231284
; Datum: 16.04.2025
; Popis: Implementacia funkcie pre prolnutie dvoch obrazkov pomocou MMX instrukcii

; Export deklaracia - funkcia, ktora bude dostupna z DLL
global blend
export blend

section .text

; Funkcia: blend
; Popis: Prolina dva obrazky pomocou blending faktoru
; Vstup: 
;   [ebp+8]  - ukazovatel na prvy obrazok (a)
;   [ebp+12] - ukazovatel na druhy obrazok (b)
;   [ebp+16] - ukazovatel na blending faktor (c)
; Vystup: Vysledok sa zapise do pamate na adrese druheho obrazka (b)
; Rovnica: res = (a*fa + b*(255-fa))/255
; Format: 32-bit ARGB (Alpha, Red, Green, Blue)

blend:
    push dword ebp           ; Ulozenie bazoveho ukazovatela ramca
    mov dword ebp, esp       ; Vytvorenie noveho ramca
    
    ; Ziskanie parametrov funkcie
    mov esi, [ebp+8]         ; ESI = ukazovatel na prvy obrazok (a)
    mov edi, [ebp+12]        ; EDI = ukazovatel na druhy obrazok (b)
    mov eax, [ebp+16]        ; EAX = ukazovatel na blending faktor (c)
    
    ; *** KROKY ALGORITMU ***
    ; 1. Nacitanie a expanzia dat z 32-bit na 64-bit format
    movd mm1, [esi]          ; Nacitanie dat prveho obrazka: mm1 = 0 0 0 0 aA aR aG aB
    movd mm2, [edi]          ; Nacitanie dat druheho obrazka: mm2 = 0 0 0 0 bA bR bG bB
    pxor mm5, mm5            ; Vynulovanie registra mm5 pre pouzitie na rozprestieranie
    punpcklbw mm1, mm5       ; Rozsirenie bajtov na slova: mm1 = 0 aA 0 aR 0 aG 0 aB
    punpcklbw mm2, mm5       ; Rozsirenie bajtov na slova: mm2 = 0 bA 0 bR 0 bG 0 bB
    movd mm3, [eax]          ; Nacitanie blending faktoru: mm3 = 0 0 0 0 faA faR faG faB
    
    ; 2. Spracovanie blending faktoru
    punpcklbw mm3, mm5       ; Rozsirenie blending faktoru: mm3 = 0 faA 0 faR 0 faG 0 faB
    
    ; 3. Uprava rozsahu blending faktoru z [0-255] na [0-256]
    ; - Toto je nutne, pretoze MMX nema instrukciu pre delenie, ale mozeme pouzit posun o 8 bitov (delenie 256)
    movq mm6, mm3            ; Kopirovanie blending faktoru
    psrlw mm6, 7             ; Delenie faktorom 128 (priblizne 0 alebo 1)
    paddw mm3, mm6           ; mm3 = faktor + faktor/128 ~ faktor * (1 + 1/128) ~ faktor * 256/255
    
    ; 4. Vypocet komplementarneho faktoru (256 - fa)
    pcmpeqw mm4, mm4         ; Vsetky bity nastavene na 1
    psrlw mm4, 15            ; Vsetky slova maju hodnotu 1
    psllw mm4, 8             ; Vsetky slova maju hodnotu 256
    psubw mm4, mm3           ; mm4 = 256 - fa = komplementarny faktor
    
    ; 5. Vypocet vazenych priemerov
    pmullw mm1, mm3          ; mm1 = a * fa (nasobenie prvkov po slovach)
    pmullw mm2, mm4          ; mm2 = b * (256-fa) (nasobenie prvkov po slovach)
    
    ; 6. Scitanie a delenie
    paddw mm1, mm2           ; mm1 = a*fa + b*(256-fa)
    psrlw mm1, 8             ; mm1 = (a*fa + b*(256-fa))/256 ~ (a*fa + b*(255-fa))/255
    
    ; 7. Zabalenie vysledku spat do bajtov a ulozenie
    packuswb mm1, mm1        ; Zabalenie slov spat do bajtov: mm1 = 0 0 0 0 rA rR rG rB
    movd [edi], mm1          ; Ulozenie vysledku na adresu druheho obrazka (b)
    
    ; 8. Vycistenie MMX stavu
    emms                     ; Empty MMX State - vymazanie MMX stavu pred vratenim z funkcie
    
    ; Navrat z funkcie
    mov dword esp, ebp       ; Obnovenie povodneho stack pointera
    pop dword ebp            ; Obnovenie povodneho base pointera
    ret 12                   ; Navrat z funkcie (3 parametre po 4 bajtoch = 12 bajtov)
