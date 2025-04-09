; Autor: Miroslav Balik
; Source code: DLL(OBJ) 32bit Win32 API
; Directs for assembling and linking:
; nasm operace.asm –fobj
; alink operace.obj -oPE -dll -o operace.dll



global soucet          ;globalní funkce
export soucet          ;externí funkce
global fpu_op          ;globalní funkce
export fpu_op          ;externí funkce

; datový segment 
[section .data class=DATA use32 align=16] 

; kódový segment 
[section .code use32 class=CODE] 

..start:
        
DllMain: 						; Vstupní bod DLL knihovny
		mov eax,1
ret 12

soucet:
		push ebp
		mov ebp,esp

		;operace souctu tri promennych
		
		mov esp, ebp
		pop ebp
ret 12 ;12 protože jsou tøi parametry funkce

fpu_op:
		push ebp
		mov ebp,esp
		
		;fpu operace s jednom celociselnou a jednou FPU hodnotou
		 		
		mov esp, ebp
		pop ebp
ret 8 ;8 protože jsou dva parametry funkce