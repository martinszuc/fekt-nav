; Autor: Miroslav Balik
; Source code: DLL(OBJ) 32bit Win32 API
; Directs for assembling and linking:
; nasm operace.asm �fobj
; alink operace.obj -oPE -dll -o operace.dll



global soucet          ;globaln� funkce
export soucet          ;extern� funkce
global fpu_op          ;globaln� funkce
export fpu_op          ;extern� funkce

; datov� segment 
[section .data class=DATA use32 align=16] 

; k�dov� segment 
[section .code use32 class=CODE] 

..start:
        
DllMain: 						; Vstupn� bod DLL knihovny
		mov eax,1
ret 12

soucet:
		push ebp
		mov ebp,esp

		;operace souctu tri promennych
		
		mov esp, ebp
		pop ebp
ret 12 ;12 proto�e jsou t�i parametry funkce

fpu_op:
		push ebp
		mov ebp,esp
		
		;fpu operace s jednom celociselnou a jednou FPU hodnotou
		 		
		mov esp, ebp
		pop ebp
ret 8 ;8 proto�e jsou dva parametry funkce