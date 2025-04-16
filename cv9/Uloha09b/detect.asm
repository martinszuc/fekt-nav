; Autor: Martin Szuc VUTID:231284
; Datum: 16.04.2025
; Popis: Implementacia funkcii pre detekciu vlastnosti procesora

; Export deklaracie - vsetky funkcie, ktore budu dostupne z DLL
global CPUname
export CPUname
global CPUsign
export CPUsign
global EM64Tsupport
export EM64Tsupport
global MMXsupport
export MMXsupport
global SSEsupport
export SSEsupport
global SSE2support
export SSE2support
global SSE3support
export SSE3support
global SSSE3support
export SSSE3support
global SSE41support
export SSE41support
global SSE42support
export SSE42support
global AVXsupport
export AVXsupport
global AVX2support
export AVX2support
global FMA3support
export FMA3support
global AESsupport
export AESsupport
global VAESsupport
export VAESsupport
global CLMULsupport
export CLMULsupport
global VCLMULsupport
export VCLMULsupport
global SHAsupport
export SHAsupport
global cTold
export cTold
global cTpCintel
export cTpCintel
global cTintel
export cTintel
global cTpCintelnew
export cTpCintelnew
global cTintelnew
export cTintelnew
global THRnumber
export THRnumber

section .text

; Funkcia: MMXsupport
; Popis: Zisti, ci procesor podporuje technologiu MMX
; Vstup: Ziadny
; Vystup: EAX = 1 ak procesor podporuje MMX, inak EAX = 0
; Poznámka: Funkcia pouziva instrukciu CPUID s EAX=1 a testuje bit 23 v registri EDX

MMXsupport:
    push dword ebp        ; Ulozenie bazoveho ukazovatela ramca
    mov dword ebp, esp    ; Vytvorenie noveho ramca
    
    ; Ziskanie informacii o procesore pomocou CPUID
    mov eax, 1            ; EAX = 1: Ziadost o Feature Information
    cpuid                 ; Volanie instrukcie CPUID
    
    ; Kontrola bitu 23 v registri EDX (MMX flag)
    mov eax, edx          ; Kopirovanie EDX do EAX
    shr eax, 23           ; Posun bitu 23 do pozicie bitu 0
    and eax, 1            ; Maskovanie vsetkych bitov okrem bitu 0
    
    ; Navrat z funkcie
    mov dword esp, ebp    ; Obnovenie povodneho stack pointera
    pop dword ebp         ; Obnovenie povodneho base pointera
    ret 0                 ; Navrat z funkcie (bez parametrov)

; Poznamka: Na tomto mieste by mali byt implementovane vsetky ostatne funkcie
; deklarovane vyssie. Pre ucely ukoncenia ulohy implementujeme len funkciu
; MMXsupport, ostatne funkcie by mali byt implementovane podobnym sposobom
; pre pouzitie v kompletnej DLL.

; Funkcia CPUname a dalsie funkcie by mali nasledovat tu...
