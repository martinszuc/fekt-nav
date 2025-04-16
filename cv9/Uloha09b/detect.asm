; Autor: Miroslav Balík
; Source code: DLL(OBJ) 32bit Win32 API
; Directs for assembling and linking:
; nasm detect.asm –fobj
; alink detect.obj -oPE -dll -o detect.dll

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



; datový segment
[section .data class=DATA use32 align=16]


; kódový segment
[section .code use32 class=CODE align=16]

..start:

DllMain:
		mov eax,1
		ret 12

;jmeno procesoru
CPUname:
		push dword ebp
       	mov dword ebp, esp

            mov edi,[EBP + 8]

            mov eax,80000000h
			cpuid
			cmp eax,80000004h
			jb not_supp
			
			mov eax,80000002h
			cpuid
			call SaveStrName
		    mov eax,80000003h
			cpuid
			call SaveStrName
			mov eax,80000004h
			cpuid
			call SaveStrName
not_supp:
		mov dword esp,ebp
       	pop dword ebp
ret 4


SaveStrName:
			mov [edi],eax
			mov [edi+4],ebx
			mov [edi+8],ecx
			mov [edi+12],edx
			add edi,16
			ret 0

;signatura procesoru
CPUsign:
		mov eax,1
		cpuid
ret 0

;detekce EM64T
EM64Tsupport:
   		mov eax,80000001h
    	cpuid
    	mov eax,edx
    	shr eax,29
    	and eax,1
ret 0

;detekce MMX
MMXsupport:
   		mov eax,1
    	cpuid
    	mov eax,edx
    	shr eax,23
    	and eax,1
ret 0

;detekce SSE
SSEsupport:
   		mov eax,1
    	cpuid
    	mov eax,edx
    	shr eax,25
    	and eax,1
ret 0

;detekce SSE2
SSE2support:
   		mov eax,1
    	cpuid
    	mov eax,edx
    	shr eax,26
    	and eax,1
ret 0

;detekce SSE3
SSE3support:
   		mov eax,1
    	cpuid
    	mov eax,ecx
    	and eax,1
ret 0

;detekce SSSE3
SSSE3support:
   		mov eax,1
    	cpuid
    	mov eax,ecx
    	shr eax,9
    	and eax,1
ret 0

;detekce SSE41
SSE41support:
   		mov eax,1
    	cpuid
    	mov eax,ecx
    	shr eax,19
    	and eax,1
ret 0

;detekce SSE42
SSE42support:
   		mov eax,1
    	cpuid
    	mov eax,ecx
    	shr eax,20
    	and eax,1
ret 0


;detekce AVX
AVXsupport:
   		mov eax,1
   		cpuid
    	mov eax,ecx
    	shr eax,28
    	and eax,1
ret 0


;detekce AVX2
AVX2support:
   		mov eax,7
   		mov ecx,0
   		cpuid
    	mov eax,ebx
    	shr eax,5
    	and eax,1
ret 0


;detekce FMA
FMA3support:
   		mov eax,1
   		cpuid
    	mov eax,ecx
    	shr eax,12
    	and eax,1
ret 0

;detekce AES
AESsupport:
   		mov eax,1
   		cpuid
    	mov eax,ecx
    	shr eax,25
    	and eax,1
ret 0

;detekce VAES
VAESsupport:
   		mov eax,7
   		mov ecx,0
   		cpuid
    	mov eax,ecx
    	shr eax,9
    	and eax,1
ret 0

;detekce CLMUL
CLMULsupport:
		mov eax,1
   		cpuid
    	mov eax,ecx
    	shr eax,1
    	and eax,1
ret 0

;detekce VCLMUL
VCLMULsupport:
   		mov eax,7
   		mov ecx,0
   		cpuid
    	mov eax,ecx
    	shr eax,10
    	and eax,1
ret 0

;detekce SHA
SHAsupport:
   		mov eax,7
   		mov ecx,0
   		cpuid
    	mov eax,ebx
    	shr eax,29
    	and eax,1
ret 0


;-------------------------------------------------------------------------------
;obecne pro prvni procesory s vicevlaknovym zpracovanim (PIV HTT, PD atd.)
;eax=1, nereflektuje nastaveni BIOSu

;detekce maximálního poètu vláken
cTold:
		mov eax,1
		cpuid
		shr ebx,16
		xor eax,eax
		mov al,bl
ret 0



;-------------------------------------------------------------------------------
;pro novejsi procesory Intel (C2D, C2Q atd.)
;eax=4, nereflektuje nastaveni BIOSu

;detekce maximalního poctu vlaken pro jedno jadro
cTpCintel:
		mov eax,4
		cpuid
		shr eax,14
		and eax,00000000000000000000111111111111b
		inc eax
ret 0

;detekce maximalniho poctu vlaken pro CPU
cTintel:
		mov eax,4
		cpuid
		shr eax,26
ret 0



;-------------------------------------------------------------------------------
;pro nejnovejsi procesory Intel Core iX (nove procesory AMD skrze eax = 0x80000008]
;eax=11, nereflektuje nastaveni BIOSu

;detekce maximalniho poètu vlaken pro jedno jadro
cTpCintelnew:
		mov eax,11
		mov ecx,0
		cpuid
		xor eax,eax
		mov ax,bx
ret 0

;detekce maximalniho poctu vlaken pro CPU
cTintelnew:
		mov eax,11
		mov ecx,1
		cpuid
		xor eax,eax
		mov ax,bx
ret 0



;-------------------------------------------------------------------------------
;detekce cisla vlakna
THRnumber:
		mov eax,1
		cpuid
		shr ebx,24
		xor eax,eax
		mov ax,bx
ret 0