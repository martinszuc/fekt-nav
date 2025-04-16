; Autor: Martin Szuc (231284)
; Datum: 09.04.2025
; Source code: DLL 32bit Win32 API
; Directs for assembling and linking:
; nasm operace.asm -fobj
; alink operace.obj -oPE -dll -o operace.dll

[section .code use32 class=CODE]

; Export these symbols without name decoration
GLOBAL soucet
GLOBAL fpu_op
GLOBAL DllMain

DllMain:
    ; Vstupny bod DLL kniznice
    mov eax, 1      ; Vrati TRUE
    ret 12          ; Vycisti zasobnik (3 parametre * 4 bajty kazdy)

soucet:
    ; Funkcia na scitanie troch cisel
    push ebp        ; Zaloha bazy ramca
    mov ebp, esp    ; Nastavenie novej bazy ramca
    
    ; Ziskanie parametrov
    mov eax, [ebp+8]    ; Prvy parameter (x)
    add eax, [ebp+12]   ; Pridanie druheho parametra (y)
    add eax, [ebp+16]   ; Pridanie tretieho parametra (z)
    
    ; Obnovenie registrov a navrat
    mov esp, ebp    ; Obnovenie zasobnika
    pop ebp         ; Obnovenie bazy ramca
    ret 12          ; Vycisti zasobnik (3 parametre * 4 bajty kazdy)

fpu_op:
    ; Funkcia na nasobenie int a float pomocou FPU
    push ebp        ; Zaloha bazy ramca
    mov ebp, esp    ; Nastavenie novej bazy ramca
    
    ; Operacia s FPU
    finit               ; Inicializacia FPU
    fild dword [ebp+8]  ; Nacita int parameter (x) na FPU zasobnik
    fld dword [ebp+12]  ; Nacita float parameter (y) na FPU zasobnik
    fmul                ; Vykona nasobenie ST(0) * ST(1) a ulozi ho do ST(0)
    
    ; Obnovenie registrov a navrat
    mov esp, ebp    ; Obnovenie zasobnika
    pop ebp         ; Obnovenie bazy ramca
    ret 8           ; Vycisti zasobnik (2 parametre * 4 bajty kazdy)
