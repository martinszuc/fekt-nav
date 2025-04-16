; Autor: Miroslav Balík
; Source code: DLL(OBJ) 32bit Win32 API
; Directs for assembling and linking:
; nasm blend.asm -fobj 
; alink blend.obj -oPE -dll -o blend.dll



global blend          ;globalní funkce 
export blend          ;externí funkce 
global MMXsupport          ;globalní funkce 
export MMXsupport          ;externí funkce 

; datový segment 
[section .data class=DATA use32 align=16] 

; kódový segment 
[section .code use32 class=CODE] 

..start:

DllMain:
		mov eax,1
		ret 12

MMXsupport: 
		push dword ebp
       	mov dword ebp,esp

   		mov eax, 1
    	cpuid
    	mov eax, edx
    	shr eax, 23
    	and eax, 1

		mov dword esp,ebp
       	pop dword ebp 
ret 0


blend:                 
		push dword ebp
    	mov dword ebp,esp
	
		; [EBP + 8], ukazatel na 32bit (format ARGB) pole s PNG obrazkem
		; [EBP + 12], ukazatel na na druhy PNG obrazek
		; [EBP + 16], ukazatel na hodnotu prolinani ve formatu faA faR faG faB

		mov esi,[EBP + 8]	
		mov edi,[EBP + 12]
		mov eax,[EBP + 16]
		mov ecx,480000	

		; zaloha registru esi a edi
		push esi
		push edi

		; dekrementace obou ukazatelu v esi a edi o 4byte
		dec esi		
		dec esi
		dec esi
		dec esi
		dec edi
		dec edi
		dec edi
		dec edi
	
	;cyklus for, opakuj pro  1:delka_pole
.for_smycka:
		;inkrementace esi a edi 4byte
		inc esi		
		inc esi
		inc esi
		inc esi
		inc edi
		inc edi
		inc edi
		inc edi

	  	    ; ---------- MMX ------------
			;
			;  Doplnit kod vypoctu pomoci instrukci MMX
			;
		    ; ---------- /MMX ------------

		dec ecx			; dekrementuje ecx, pokud ecx==0 tak se nastavi priznak ZF (zero flag) na 1
		jnz .for_smycka		; JNZ (Jump if Not Zero), skoci na navesti kdyz ZF se rovna 0

		emms

		;obnova edi a esi
		pop edi
		pop esi
		mov dword esp,ebp
       	pop dword ebp 
ret 12

       



         