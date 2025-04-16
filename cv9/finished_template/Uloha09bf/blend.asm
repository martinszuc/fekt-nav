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
	  	; ulozeni hodnot do mm1, mm2, mm3. Vynuluje se mm5
		movd        mm1,[esi]		; mm1 = 0 0 0 0 aA aR aG aB
		movd        mm2,[edi]		; mm2 = 0 0 0 0 bA bR bG bB
		pxor        mm5,mm5			; mm5 = 0 0 0 0 0 0 0 0
		punpcklbw   mm1,mm5			; mm1 = 0 aA 0 aR 0 aG 0 aB
		punpcklbw   mm2,mm5			; mm2 = 0 bA 0 bR 0 bG 0 bB
		movd        mm3,[eax]			; mm3 = 0 0 0 0 faA faR faG faB

		; fa ze zde rozsiri na rozsah [0-256]
		; logika je takova, ze pokud je puvodni fa vetsi nez 127 tak se mu pricte 1
		punpcklbw   mm3,mm5			; mm3 = 0 faA 0 faR 0 faG 0 faB
		movq        mm6,mm3			; mm6 = faA faR faG faB [0 - 255]
		psrlw       mm6,7			; mm6 = faA faR faG faB [0 - 1]
		paddw       mm3,mm6			; mm3 = faA faR faG faB [0 - 256]
		; fb = 256 - fa, fb bude v mm4
		pcmpeqw     mm4,mm4			; mm4 = 0xFFFF 0xFFFF 0xFFFF 0xFFFF
		psrlw       mm4,15			; mm4 =   1   1   1   1
		psllw       mm4,8			; mm4 = 256 256 256 256
		psubw       mm4,mm3			; mm4 = fbA fbR fbG fbB
		; res = (a*fa + b*fb)/256
		pmullw      mm1,mm3			; mm1 = aA aR aG aB
		pmullw      mm2,mm4			; mm2 = bA bR bG bB
		paddw       mm1,mm2			; mm1 = rA rR rG rB
		psrlw       mm1,8			; mm1 = 0 rA 0 rR 0 rG 0 rB
		; pack into output registr
		packuswb    mm1,mm1			; mm1 = 0 0 0 0 rA rR rG rB
		movd       	[edi],mm1		; ebx = rA rR rG rB
									; v knihovne je nutne pouzit vystup do edi
		emms
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

       



         