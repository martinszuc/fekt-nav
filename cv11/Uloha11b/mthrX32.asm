; Autor: Miroslav Balík
; Source code: DLL(OBJ) 32bit Win32 API
; Directs for assembling and linking:
; nasm mthrX32.asm –fobj
; alink mthrX32.obj -oPE -dll -o mthrX32.dll


extern CreateThread
import CreateThread kernel32.dll
extern Sleep
import Sleep kernel32.dll
global cTpCintelnew
export cTpCintelnew
global cTintelnew
export cTintelnew
global cCintelnew
export cCintelnew

global vxm_x1_x87_sp
export vxm_x1_x87_sp
global vxm_x1_x87_dp
export vxm_x1_x87_dp
global vxm_x1_sse_sp
export vxm_x1_sse_sp
global vxm_x1_sse_dp
export vxm_x1_sse_dp
global vxm_x1_avx_sp
export vxm_x1_avx_sp
global vxm_x1_avx_dp
export vxm_x1_avx_dp

global vxm_x2_x87_sp
export vxm_x2_x87_sp
global vxm_x2_x87_dp
export vxm_x2_x87_dp
global vxm_x2_sse_sp
export vxm_x2_sse_sp
global vxm_x2_sse_dp
export vxm_x2_sse_dp
global vxm_x2_avx_sp
export vxm_x2_avx_sp
global vxm_x2_avx_dp
export vxm_x2_avx_dp

global vxm_x4_x87_sp
export vxm_x4_x87_sp
global vxm_x4_x87_dp
export vxm_x4_x87_dp
global vxm_x4_sse_sp
export vxm_x4_sse_sp
global vxm_x4_sse_dp
export vxm_x4_sse_dp
global vxm_x4_avx_sp
export vxm_x4_avx_sp
global vxm_x4_avx_dp
export vxm_x4_avx_dp

global vxm_x8_x87_sp
export vxm_x8_x87_sp
global vxm_x8_x87_dp
export vxm_x8_x87_dp
global vxm_x8_sse_sp
export vxm_x8_sse_sp
global vxm_x8_sse_dp
export vxm_x8_sse_dp


global vxm_x3_sse_sp
export vxm_x3_sse_sp
global vxm_x3_sse_dp
export vxm_x3_sse_dp
global vxm_x3_avx_sp
export vxm_x3_avx_sp
global vxm_x3_avx_dp
export vxm_x3_avx_dp

global vxm_x6_x87_sp
export vxm_x6_x87_sp
global vxm_x6_x87_dp
export vxm_x6_x87_dp
global vxm_x6_sse_sp
export vxm_x6_sse_sp
global vxm_x6_sse_dp
export vxm_x6_sse_dp
global vxm_x6_avx_sp
export vxm_x6_avx_sp
global vxm_x6_avx_dp
export vxm_x6_avx_dp


%include 'WIN32N.inc'	;definice struktur a ruznych datovych typu
; Definice Ptrs struktury
struc Ptrs
.M resd 1
.x resd 1
.y resd 1
.lengthx resd 1
.lengthy resd 1
.thread resd 1
.done resb 1
endstruc

; datový segment 
[section .data class=DATA use32 align=16] 
Ptrs1: 	resb 	Ptrs_size
Ptrs2: 	resb 	Ptrs_size
Ptrs3: 	resb 	Ptrs_size
Ptrs4: 	resb 	Ptrs_size
Ptrs5: 	resb 	Ptrs_size
Ptrs6: 	resb 	Ptrs_size
Ptrs7: 	resb 	Ptrs_size
Ptrs8: 	resb 	Ptrs_size

; kódový segment 
[section .code use32 class=CODE align=16] 

..start:      

DllMain:
		mov eax,1
ret 12

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

;detekce maximalniho poctu aktivních jader pro CPU
cCintelnew:
		call cTpCintelnew
		mov ecx,eax
		push ecx
		call cTintelnew
		pop ecx
		dec ecx
		shr eax,cl
ret 0

vxm_x1_x87_sp:
		push dword ebp
       	mov dword ebp,esp

        mov eax, [ebp+8]				; ukazatel na M ->
       	mov dword [Ptrs1 + 0],eax		; -> ukazatel na M pro 1. vlakno
 		mov eax, [ebp+12]				; ukazatel na x ->
		mov dword [Ptrs1 + 4],eax       ; -> ukazatel na x pro 1. vlakno
		mov eax, [ebp+16]				; ukazatel na y ->
		mov dword [Ptrs1 + 8],eax		; -> ukazatel na y pro 1. vlakno
       	mov eax, [ebp+20]				; delka vstupu ->
		mov dword [Ptrs1 + 12],eax		; -> delka vstupu pro 1. vlakno
		mov eax, [ebp+24]				; delka vystupu ->
		mov dword [Ptrs1 + 16],eax		; -> delka vystupu pro 1. vlakno
		mov dword [Ptrs1 + 20],1		; pocet vlaken
		mov byte [Ptrs1 + 21],0		; semafor pro 1. vlakno

		push dword Ptrs1
		call vxm_x87_ptrs_sp

		mov dword esp, ebp
       	pop dword ebp
ret 20

vxm_x1_x87_dp:
		push dword ebp
       	mov dword ebp,esp

        mov eax, [ebp+8]				; ukazatel na M ->
       	mov dword [Ptrs1 + 0],eax		; -> ukazatel na M pro 1. vlakno
 		mov eax, [ebp+12]				; ukazatel na x ->
		mov dword [Ptrs1 + 4],eax       ; -> ukazatel na x pro 1. vlakno
		mov eax, [ebp+16]				; ukazatel na y ->
		mov dword [Ptrs1 + 8],eax		; -> ukazatel na y pro 1. vlakno
       	mov eax, [ebp+20]				; delka vstupu ->
		mov dword [Ptrs1 + 12],eax		; -> delka vstupu pro 1. vlakno
		mov eax, [ebp+24]				; delka vystupu ->
		mov dword [Ptrs1 + 16],eax		; -> delka vystupu pro 1. vlakno
		mov dword [Ptrs1 + 20],1		; pocet vlaken
		mov byte [Ptrs1 + 21],0		; semafor pro 1. vlakno

		push dword Ptrs1
		call vxm_x87_ptrs_dp

		mov dword esp, ebp
       	pop dword ebp
ret 20

vxm_x1_sse_sp:
		push dword ebp
       	mov dword ebp,esp

        mov eax, [ebp+8]				; ukazatel na M ->
       	mov dword [Ptrs1 + 0],eax		; -> ukazatel na M pro 1. vlakno
 		mov eax, [ebp+12]				; ukazatel na x ->
		mov dword [Ptrs1 + 4],eax       ; -> ukazatel na x pro 1. vlakno
		mov eax, [ebp+16]				; ukazatel na y ->
		mov dword [Ptrs1 + 8],eax		; -> ukazatel na y pro 1. vlakno
       	mov eax, [ebp+20]				; delka vstupu ->
		mov dword [Ptrs1 + 12],eax		; -> delka vstupu pro 1. vlakno
		mov eax, [ebp+24]				; delka vystupu ->
		mov dword [Ptrs1 + 16],eax		; -> delka vystupu pro 1. vlakno
		mov dword [Ptrs1 + 20],1		; pocet vlaken
		mov byte [Ptrs1 + 21],0		; semafor pro 1. vlakno

		push dword Ptrs1
		call vxm_sse_ptrs_sp

		mov dword esp, ebp
       	pop dword ebp
ret 20

vxm_x1_sse_dp:
		push dword ebp
       	mov dword ebp,esp

        mov eax, [ebp+8]				; ukazatel na M ->
       	mov dword [Ptrs1 + 0],eax		; -> ukazatel na M pro 1. vlakno
 		mov eax, [ebp+12]				; ukazatel na x ->
		mov dword [Ptrs1 + 4],eax       ; -> ukazatel na x pro 1. vlakno
		mov eax, [ebp+16]				; ukazatel na y ->
		mov dword [Ptrs1 + 8],eax		; -> ukazatel na y pro 1. vlakno
       	mov eax, [ebp+20]				; delka vstupu ->
		mov dword [Ptrs1 + 12],eax		; -> delka vstupu pro 1. vlakno
		mov eax, [ebp+24]				; delka vystupu ->
		mov dword [Ptrs1 + 16],eax		; -> delka vystupu pro 1. vlakno
		mov dword [Ptrs1 + 20],1		; pocet vlaken
		mov byte [Ptrs1 + 21],0		; semafor pro 1. vlakno

		push dword Ptrs1
		call vxm_sse_ptrs_dp

		mov dword esp, ebp
       	pop dword ebp
ret 20

vxm_x1_avx_sp:
		push dword ebp
       	mov dword ebp,esp

        mov eax, [ebp+8]				; ukazatel na M ->
       	mov dword [Ptrs1 + 0],eax		; -> ukazatel na M pro 1. vlakno
 		mov eax, [ebp+12]				; ukazatel na x ->
		mov dword [Ptrs1 + 4],eax       ; -> ukazatel na x pro 1. vlakno
		mov eax, [ebp+16]				; ukazatel na y ->
		mov dword [Ptrs1 + 8],eax		; -> ukazatel na y pro 1. vlakno
       	mov eax, [ebp+20]				; delka vstupu ->
		mov dword [Ptrs1 + 12],eax		; -> delka vstupu pro 1. vlakno
		mov eax, [ebp+24]				; delka vystupu ->
		mov dword [Ptrs1 + 16],eax		; -> delka vystupu pro 1. vlakno
		mov dword [Ptrs1 + 20],1		; pocet vlaken
		mov byte [Ptrs1 + 21],0		; semafor pro 1. vlakno

		push dword Ptrs1
		call vxm_avx_ptrs_sp

		mov dword esp, ebp
       	pop dword ebp
ret 20

vxm_x1_avx_dp:
		push dword ebp
       	mov dword ebp,esp

        mov eax, [ebp+8]				; ukazatel na M ->
       	mov dword [Ptrs1 + 0],eax		; -> ukazatel na M pro 1. vlakno
 		mov eax, [ebp+12]				; ukazatel na x ->
		mov dword [Ptrs1 + 4],eax       ; -> ukazatel na x pro 1. vlakno
		mov eax, [ebp+16]				; ukazatel na y ->
		mov dword [Ptrs1 + 8],eax		; -> ukazatel na y pro 1. vlakno
       	mov eax, [ebp+20]				; delka vstupu ->
		mov dword [Ptrs1 + 12],eax		; -> delka vstupu pro 1. vlakno
		mov eax, [ebp+24]				; delka vystupu ->
		mov dword [Ptrs1 + 16],eax		; -> delka vystupu pro 1. vlakno
		mov dword [Ptrs1 + 20],1		; pocet vlaken
		mov byte [Ptrs1 + 21],0		; semafor pro 1. vlakno

		push dword Ptrs1
		call vxm_avx_ptrs_dp

		mov dword esp, ebp
       	pop dword ebp
ret 20


vxm_x2_x87_sp:
		push dword ebp
       	mov dword ebp,esp

		mov eax, [ebp+12]				; ukazatel na x ->
		mov dword [Ptrs1 + 4],eax		; -> ukazatel na x pro 1. vlakno
		mov dword [Ptrs2 + 4],eax		; -> ukazatel na x pro 2. vlakno

		mov eax, [ebp+20]				; delka vstupu ->
		mov dword [Ptrs1 + 12],eax		; -> delka vstupu pro 1. vlakno
		mov dword [Ptrs2 + 12],eax		; -> delka vstupu pro 2. vlakno

		mov ebx, [ebp+24]				; delka vystupu ->
        shr ebx,1						; pro 2 vlakna (delka vystupu)/2
		mov dword [Ptrs1 + 16],ebx		; -> delka vystupu pro 1. vlakno
		mov dword [Ptrs2 + 16],ebx 		; -> delka vystupu pro 2. vlakno


        mov ecx, [ebp+8]				; ukazatel na M ->
       	mov dword [Ptrs1 + 0],ecx		; -> ukazatel na M pro 1. vlakno
        shl ebx,2						; x4 pro jednoduchou presnost
        add ecx,ebx						; posun na polovinu prvniho radku matice M
        mov dword [Ptrs2 + 0],ecx		; -> ukazatel na M pro 2. vlakno

		mov eax, [ebp+16]				; ukazatel na y ->
		mov dword [Ptrs1 + 8],eax       ; -> ukazatel na y pro 1. vlakno
		add eax,ebx                     ; posun na druhou polovinu vektoru y
		mov dword [Ptrs2 + 8],eax		; -> ukazatel na y pro 2. vlakno

		mov dword [Ptrs1 + 20],2		; pocet vlaken
		mov dword [Ptrs2 + 20],2		; pocet vlaken
		mov byte [Ptrs1 + 21],0		; semafor pro 1. vlakno
		mov byte [Ptrs2 + 21],0		; semafor pro 2. vlakno

		push dword NULL
		push dword 0
		push dword Ptrs1
		push dword vxm_x87_ptrs_sp
		push dword 0
		push dword 0
		call [CreateThread]

       	push dword Ptrs2
      	call vxm_x87_ptrs_sp

		.wait_for_thr1:
			cmp byte [Ptrs1 + 21],1
	        jnz .wait_for_thr1

		mov dword esp, ebp
       	pop dword ebp
ret 20

vxm_x2_sse_sp:
		push dword ebp
       	mov dword ebp,esp

		mov eax, [ebp+12]				; ukazatel na x ->
		mov dword [Ptrs1 + 4],eax		; -> ukazatel na x pro 1. vlakno
		mov dword [Ptrs2 + 4],eax		; -> ukazatel na x pro 2. vlakno

		mov eax, [ebp+20]				; delka vstupu ->
		mov dword [Ptrs1 + 12],eax		; -> delka vstupu pro 1. vlakno
		mov dword [Ptrs2 + 12],eax		; -> delka vstupu pro 2. vlakno

		mov ebx, [ebp+24]				; delka vystupu ->
        shr ebx,1						; pro 2 vlakna (delka vystupu)/2
		mov dword [Ptrs1 + 16],ebx		; -> delka vystupu pro 1. vlakno
		mov dword [Ptrs2 + 16],ebx 		; -> delka vystupu pro 2. vlakno


        mov ecx, [ebp+8]				; ukazatel na M ->
       	mov dword [Ptrs1 + 0],ecx		; -> ukazatel na M pro 1. vlakno
        shl ebx,2						; x4 pro jednoduchou presnost
        add ecx,ebx						; posun na polovinu prvniho radku matice M
        mov dword [Ptrs2 + 0],ecx		; -> ukazatel na M pro 2. vlakno

		mov eax, [ebp+16]				; ukazatel na y ->
		mov dword [Ptrs1 + 8],eax       ; -> ukazatel na y pro 1. vlakno
		add eax,ebx                     ; posun na druhou polovinu vektoru y
		mov dword [Ptrs2 + 8],eax		; -> ukazatel na y pro 2. vlakno

		mov dword [Ptrs1 + 20],2		; pocet vlaken
		mov dword [Ptrs2 + 20],2		; pocet vlaken
		mov byte [Ptrs1 + 21],0		; semafor pro 1. vlakno
		mov byte [Ptrs2 + 21],0		; semafor pro 2. vlakno

		push dword NULL
		push dword 0
		push dword Ptrs1
		push dword vxm_sse_ptrs_sp
		push dword 0
		push dword 0
		call [CreateThread]

       	push dword Ptrs2
      	call vxm_sse_ptrs_sp

		.wait_for_thr1:
			cmp byte [Ptrs1 + 21],1
	        jnz .wait_for_thr1

		mov dword esp, ebp
       	pop dword ebp
ret 20

vxm_x2_avx_sp:
		push dword ebp
       	mov dword ebp,esp

		mov eax, [ebp+12]				; ukazatel na x ->
		mov dword [Ptrs1 + 4],eax		; -> ukazatel na x pro 1. vlakno
		mov dword [Ptrs2 + 4],eax		; -> ukazatel na x pro 2. vlakno

		mov eax, [ebp+20]				; delka vstupu ->
		mov dword [Ptrs1 + 12],eax		; -> delka vstupu pro 1. vlakno
		mov dword [Ptrs2 + 12],eax		; -> delka vstupu pro 2. vlakno

		mov ebx, [ebp+24]				; delka vystupu ->
        shr ebx,1						; pro 2 vlakna (delka vystupu)/2
		mov dword [Ptrs1 + 16],ebx		; -> delka vystupu pro 1. vlakno
		mov dword [Ptrs2 + 16],ebx 		; -> delka vystupu pro 2. vlakno


        mov ecx, [ebp+8]				; ukazatel na M ->
       	mov dword [Ptrs1 + 0],ecx		; -> ukazatel na M pro 1. vlakno
        shl ebx,2						; x4 pro jednoduchou presnost
        add ecx,ebx						; posun na polovinu prvniho radku matice M
        mov dword [Ptrs2 + 0],ecx		; -> ukazatel na M pro 2. vlakno

		mov eax, [ebp+16]				; ukazatel na y ->
		mov dword [Ptrs1 + 8],eax       ; -> ukazatel na y pro 1. vlakno
		add eax,ebx                     ; posun na druhou polovinu vektoru y
		mov dword [Ptrs2 + 8],eax		; -> ukazatel na y pro 2. vlakno

		mov dword [Ptrs1 + 20],2		; pocet vlaken
		mov dword [Ptrs2 + 20],2		; pocet vlaken
		mov byte [Ptrs1 + 21],0		; semafor pro 1. vlakno
		mov byte [Ptrs2 + 21],0		; semafor pro 2. vlakno

		push dword NULL
		push dword 0
		push dword Ptrs1
		push dword vxm_avx_ptrs_sp
		push dword 0
		push dword 0
		call [CreateThread]

       	push dword Ptrs2
      	call vxm_avx_ptrs_sp

		.wait_for_thr1:
			cmp byte [Ptrs1 + 21],1
	        jnz .wait_for_thr1

		mov dword esp, ebp
       	pop dword ebp
ret 20


vxm_x2_x87_dp:
		push dword ebp
       	mov dword ebp,esp

		mov eax, [ebp+12]				; ukazatel na x ->
		mov dword [Ptrs1 + 4],eax		; -> ukazatel na x pro 1. vlakno
		mov dword [Ptrs2 + 4],eax		; -> ukazatel na x pro 2. vlakno

		mov eax, [ebp+20]				; delka vstupu ->
		mov dword [Ptrs1 + 12],eax		; -> delka vstupu pro 1. vlakno
		mov dword [Ptrs2 + 12],eax		; -> delka vstupu pro 2. vlakno

		mov ebx, [ebp+24]				; delka vystupu ->
        shr ebx,1						; pro 2 vlakna (delka vystupu)/2
		mov dword [Ptrs1 + 16],ebx		; -> delka vystupu pro 1. vlakno
		mov dword [Ptrs2 + 16],ebx 		; -> delka vystupu pro 2. vlakno


        mov ecx, [ebp+8]				; ukazatel na M ->
       	mov dword [Ptrs1 + 0],ecx		; -> ukazatel na M pro 1. vlakno
        shl ebx,3						; x8 pro dvojitou presnost
        add ecx,ebx						; posun na polovinu prvniho radku matice M
        mov dword [Ptrs2 + 0],ecx		; -> ukazatel na M pro 2. vlakno

		mov eax, [ebp+16]				; ukazatel na y ->
		mov dword [Ptrs1 + 8],eax       ; -> ukazatel na y pro 1. vlakno
		add eax,ebx                     ; posun na druhou polovinu vektoru y
		mov dword [Ptrs2 + 8],eax		; -> ukazatel na y pro 2. vlakno

		mov dword [Ptrs1 + 20],2		; pocet vlaken
		mov dword [Ptrs2 + 20],2		; pocet vlaken
		mov byte [Ptrs1 + 21],0		; semafor pro 1. vlakno
		mov byte [Ptrs2 + 21],0		; semafor pro 2. vlakno

		push dword NULL
		push dword 0
		push dword Ptrs1
		push dword vxm_x87_ptrs_dp
		push dword 0
		push dword 0
		call [CreateThread]

       	push dword Ptrs2
      	call vxm_x87_ptrs_dp

		.wait_for_thr1:
			cmp byte [Ptrs1 + 21],1
	        jnz .wait_for_thr1

		mov dword esp, ebp
       	pop dword ebp
ret 20

vxm_x2_sse_dp:
		push dword ebp
       	mov dword ebp,esp

		mov eax, [ebp+12]				; ukazatel na x ->
		mov dword [Ptrs1 + 4],eax		; -> ukazatel na x pro 1. vlakno
		mov dword [Ptrs2 + 4],eax		; -> ukazatel na x pro 2. vlakno

		mov eax, [ebp+20]				; delka vstupu ->
		mov dword [Ptrs1 + 12],eax		; -> delka vstupu pro 1. vlakno
		mov dword [Ptrs2 + 12],eax		; -> delka vstupu pro 2. vlakno

		mov ebx, [ebp+24]				; delka vystupu ->
        shr ebx,1						; pro 2 vlakna (delka vystupu)/2
		mov dword [Ptrs1 + 16],ebx		; -> delka vystupu pro 1. vlakno
		mov dword [Ptrs2 + 16],ebx 		; -> delka vystupu pro 2. vlakno


        mov ecx, [ebp+8]				; ukazatel na M ->
       	mov dword [Ptrs1 + 0],ecx		; -> ukazatel na M pro 1. vlakno
        shl ebx,3						; x8 pro dvojitou presnost
        add ecx,ebx						; posun na polovinu prvniho radku matice M
        mov dword [Ptrs2 + 0],ecx		; -> ukazatel na M pro 2. vlakno

		mov eax, [ebp+16]				; ukazatel na y ->
		mov dword [Ptrs1 + 8],eax       ; -> ukazatel na y pro 1. vlakno
		add eax,ebx                     ; posun na druhou polovinu vektoru y
		mov dword [Ptrs2 + 8],eax		; -> ukazatel na y pro 2. vlakno

		mov byte [Ptrs1 + 20],2		; pocet vlaken
		mov byte [Ptrs2 + 20],2		; pocet vlaken
		mov byte [Ptrs1 + 21],0		; semafor pro 1. vlakno
		mov byte [Ptrs2 + 21],0		; semafor pro 2. vlakno


		push dword NULL
		push dword 0
		push dword Ptrs1
		push dword vxm_sse_ptrs_dp
		push dword 0
		push dword 0
		call [CreateThread]


       	push dword Ptrs2
      	call vxm_sse_ptrs_dp

		.wait_for_thr1:
			cmp byte [Ptrs1 + 21],1
	        jnz .wait_for_thr1



		mov dword esp, ebp
       	pop dword ebp
ret 20

vxm_x2_avx_dp:
		push dword ebp
       	mov dword ebp,esp

		mov eax, [ebp+12]				; ukazatel na x ->
		mov dword [Ptrs1 + 4],eax		; -> ukazatel na x pro 1. vlakno
		mov dword [Ptrs2 + 4],eax		; -> ukazatel na x pro 2. vlakno

		mov eax, [ebp+20]				; delka vstupu ->
		mov dword [Ptrs1 + 12],eax		; -> delka vstupu pro 1. vlakno
		mov dword [Ptrs2 + 12],eax		; -> delka vstupu pro 2. vlakno

		mov ebx, [ebp+24]				; delka vystupu ->
        shr ebx,1						; pro 2 vlakna (delka vystupu)/2
		mov dword [Ptrs1 + 16],ebx		; -> delka vystupu pro 1. vlakno
		mov dword [Ptrs2 + 16],ebx 		; -> delka vystupu pro 2. vlakno


        mov ecx, [ebp+8]				; ukazatel na M ->
       	mov dword [Ptrs1 + 0],ecx		; -> ukazatel na M pro 1. vlakno
        shl ebx,3						; x8 pro dvojitou presnost
        add ecx,ebx						; posun na polovinu prvniho radku matice M
        mov dword [Ptrs2 + 0],ecx		; -> ukazatel na M pro 2. vlakno

		mov eax, [ebp+16]				; ukazatel na y ->
		mov dword [Ptrs1 + 8],eax       ; -> ukazatel na y pro 1. vlakno
		add eax,ebx                     ; posun na druhou polovinu vektoru y
		mov dword [Ptrs2 + 8],eax		; -> ukazatel na y pro 2. vlakno

		mov byte [Ptrs1 + 20],2		; pocet vlaken
		mov byte [Ptrs2 + 20],2		; pocet vlaken
		mov byte [Ptrs1 + 21],0		; semafor pro 1. vlakno
		mov byte [Ptrs2 + 21],0		; semafor pro 2. vlakno


		push dword NULL
		push dword 0
		push dword Ptrs1
		push dword vxm_avx_ptrs_dp
		push dword 0
		push dword 0
		call [CreateThread]


       	push dword Ptrs2
      	call vxm_avx_ptrs_dp

		.wait_for_thr1:
			cmp byte [Ptrs1 + 21],1
	        jnz .wait_for_thr1



		mov dword esp, ebp
       	pop dword ebp
ret 20


vxm_x4_x87_sp:
		push dword ebp
       	mov dword ebp,esp

		mov eax, [ebp+12]				; ukazatel na x ->
		mov dword [Ptrs1 + 4],eax		; -> ukazatel na x pro 1. vlakno
		mov dword [Ptrs2 + 4],eax		; -> ukazatel na x pro 2. vlakno
  		mov dword [Ptrs3 + 4],eax		; -> ukazatel na x pro 3. vlakno
		mov dword [Ptrs4 + 4],eax		; -> ukazatel na x pro 4. vlakno


		mov eax, [ebp+20]				; delka vstupu ->
		mov dword [Ptrs1 + 12],eax		; -> delka vstupu pro 1. vlakno
		mov dword [Ptrs2 + 12],eax		; -> delka vstupu pro 2. vlakno
		mov dword [Ptrs3 + 12],eax		; -> delka vstupu pro 3. vlakno
		mov dword [Ptrs4 + 12],eax		; -> delka vstupu pro 4. vlakno

		mov ebx, [ebp+24]				; delka vystupu ->
        shr ebx,2						; pro 4 vlakna (delka vystupu)/4
		mov dword [Ptrs1 + 16],ebx		; -> delka vystupu pro 1. vlakno
		mov dword [Ptrs2 + 16],ebx 		; -> delka vystupu pro 2. vlakno
		mov dword [Ptrs3 + 16],ebx		; -> delka vystupu pro 3. vlakno
		mov dword [Ptrs4 + 16],ebx 		; -> delka vystupu pro 4. vlakno

        mov ecx, [ebp+8]				; ukazatel na M ->
       	mov dword [Ptrs1 + 0],ecx		; -> ukazatel na M pro 1. vlakno
        shl ebx,2						; x4 pro jednoduchou presnost
        add ecx,ebx						; posun na prvniho ctvrtinu radku matice M
        mov dword [Ptrs2 + 0],ecx		; -> ukazatel na M pro 2. vlakno
        add ecx,ebx						; posun na druhou ctvrtinu radku matice M
        mov dword [Ptrs3 + 0],ecx		; -> ukazatel na M pro 3. vlakno
        add ecx,ebx						; posun na treti ctvrtinu radku matice M
        mov dword [Ptrs4 + 0],ecx		; -> ukazatel na M pro 4. vlakno

		mov eax, [ebp+16]				; ukazatel na y ->
		mov dword [Ptrs1 + 8],eax       ; -> ukazatel na y pro 1. vlakno
		add eax,ebx                     ; posun na prvni ctvrtinu vektoru y
		mov dword [Ptrs2 + 8],eax		; -> ukazatel na y pro 2. vlakno
		add eax,ebx                     ; posun na druhou ctvrtinu vektoru y
		mov dword [Ptrs3 + 8],eax		; -> ukazatel na y pro 3. vlakno
		add eax,ebx                     ; posun na treti ctvrtinu vektoru y
		mov dword [Ptrs4 + 8],eax		; -> ukazatel na y pro 4. vlakno

		mov dword [Ptrs1 + 20],4		; pocet vlaken
		mov dword [Ptrs2 + 20],4		; pocet vlaken
		mov dword [Ptrs3 + 20],4		; pocet vlaken
		mov dword [Ptrs4 + 20],4		; pocet vlaken

		mov byte [Ptrs1 + 21],0		; semafor pro 1. vlakno
		mov byte [Ptrs2 + 21],0		; semafor pro 2. vlakno
		mov byte [Ptrs3 + 21],0		; semafor pro 3. vlakno
		mov byte [Ptrs4 + 21],0		; semafor pro 4. vlakno

       	push dword NULL
		push dword 0
		push dword Ptrs1
		push dword vxm_x87_ptrs_sp
		push dword 0
		push dword 0
		call [CreateThread]

		push dword NULL
		push dword 0
		push dword Ptrs2
		push dword vxm_x87_ptrs_sp
		push dword 0
		push dword 0
		call [CreateThread]

		push dword NULL
		push dword 0
		push dword Ptrs3
		push dword vxm_x87_ptrs_sp
		push dword 0
		push dword 0
		call [CreateThread]

       	push dword Ptrs4
      	call vxm_x87_ptrs_sp

		.wait_for_thr1:
			cmp byte [Ptrs1 + 21],1
	        jnz .wait_for_thr1
   		.wait_for_thr2:
			cmp byte [Ptrs2 + 21],1
	        jnz .wait_for_thr2
   		.wait_for_thr3:
			cmp byte [Ptrs3 + 21],1
	        jnz .wait_for_thr3

		mov dword esp, ebp
       	pop dword ebp
ret 20

vxm_x4_sse_sp:
		push dword ebp
       	mov dword ebp,esp

		mov eax, [ebp+12]				; ukazatel na x ->
		mov dword [Ptrs1 + 4],eax		; -> ukazatel na x pro 1. vlakno
		mov dword [Ptrs2 + 4],eax		; -> ukazatel na x pro 2. vlakno
  		mov dword [Ptrs3 + 4],eax		; -> ukazatel na x pro 3. vlakno
		mov dword [Ptrs4 + 4],eax		; -> ukazatel na x pro 4. vlakno


		mov eax, [ebp+20]				; delka vstupu ->
		mov dword [Ptrs1 + 12],eax		; -> delka vstupu pro 1. vlakno
		mov dword [Ptrs2 + 12],eax		; -> delka vstupu pro 2. vlakno
		mov dword [Ptrs3 + 12],eax		; -> delka vstupu pro 3. vlakno
		mov dword [Ptrs4 + 12],eax		; -> delka vstupu pro 4. vlakno

		mov ebx, [ebp+24]				; delka vystupu ->
        shr ebx,2						; pro 4 vlakna (delka vystupu)/4
		mov dword [Ptrs1 + 16],ebx		; -> delka vystupu pro 1. vlakno
		mov dword [Ptrs2 + 16],ebx 		; -> delka vystupu pro 2. vlakno
		mov dword [Ptrs3 + 16],ebx		; -> delka vystupu pro 3. vlakno
		mov dword [Ptrs4 + 16],ebx 		; -> delka vystupu pro 4. vlakno

        mov ecx, [ebp+8]				; ukazatel na M ->
       	mov dword [Ptrs1 + 0],ecx		; -> ukazatel na M pro 1. vlakno
        shl ebx,2						; x4 pro jednoduchou presnost
        add ecx,ebx						; posun na prvniho ctvrtinu radku matice M
        mov dword [Ptrs2 + 0],ecx		; -> ukazatel na M pro 2. vlakno
        add ecx,ebx						; posun na druhou ctvrtinu radku matice M
        mov dword [Ptrs3 + 0],ecx		; -> ukazatel na M pro 3. vlakno
        add ecx,ebx						; posun na treti ctvrtinu radku matice M
        mov dword [Ptrs4 + 0],ecx		; -> ukazatel na M pro 4. vlakno

		mov eax, [ebp+16]				; ukazatel na y ->
		mov dword [Ptrs1 + 8],eax       ; -> ukazatel na y pro 1. vlakno
		add eax,ebx                     ; posun na prvni ctvrtinu vektoru y
		mov dword [Ptrs2 + 8],eax		; -> ukazatel na y pro 2. vlakno
		add eax,ebx                     ; posun na druhou ctvrtinu vektoru y
		mov dword [Ptrs3 + 8],eax		; -> ukazatel na y pro 3. vlakno
		add eax,ebx                     ; posun na treti ctvrtinu vektoru y
		mov dword [Ptrs4 + 8],eax		; -> ukazatel na y pro 4. vlakno

		mov dword [Ptrs1 + 20],4		; pocet vlaken
		mov dword [Ptrs2 + 20],4		; pocet vlaken
		mov dword [Ptrs3 + 20],4		; pocet vlaken
		mov dword [Ptrs4 + 20],4		; pocet vlaken

		mov byte [Ptrs1 + 21],0		; semafor pro 1. vlakno
		mov byte [Ptrs2 + 21],0		; semafor pro 2. vlakno
		mov byte [Ptrs3 + 21],0		; semafor pro 3. vlakno
		mov byte [Ptrs4 + 21],0		; semafor pro 4. vlakno

       	push dword NULL
		push dword 0
		push dword Ptrs1
		push dword vxm_sse_ptrs_sp
		push dword 0
		push dword 0
		call [CreateThread]

		push dword NULL
		push dword 0
		push dword Ptrs2
		push dword vxm_sse_ptrs_sp
		push dword 0
		push dword 0
		call [CreateThread]

		push dword NULL
		push dword 0
		push dword Ptrs3
		push dword vxm_sse_ptrs_sp
		push dword 0
		push dword 0
		call [CreateThread]

       	push dword Ptrs4
      	call vxm_sse_ptrs_sp

		.wait_for_thr1:
			cmp byte [Ptrs1 + 21],1
	        jnz .wait_for_thr1
   		.wait_for_thr2:
			cmp byte [Ptrs2 + 21],1
	        jnz .wait_for_thr2
   		.wait_for_thr3:
			cmp byte [Ptrs3 + 21],1
	        jnz .wait_for_thr3

		mov dword esp, ebp
       	pop dword ebp
ret 20

vxm_x4_avx_sp:
		push dword ebp
       	mov dword ebp,esp

		mov eax, [ebp+12]				; ukazatel na x ->
		mov dword [Ptrs1 + 4],eax		; -> ukazatel na x pro 1. vlakno
		mov dword [Ptrs2 + 4],eax		; -> ukazatel na x pro 2. vlakno
  		mov dword [Ptrs3 + 4],eax		; -> ukazatel na x pro 3. vlakno
		mov dword [Ptrs4 + 4],eax		; -> ukazatel na x pro 4. vlakno


		mov eax, [ebp+20]				; delka vstupu ->
		mov dword [Ptrs1 + 12],eax		; -> delka vstupu pro 1. vlakno
		mov dword [Ptrs2 + 12],eax		; -> delka vstupu pro 2. vlakno
		mov dword [Ptrs3 + 12],eax		; -> delka vstupu pro 3. vlakno
		mov dword [Ptrs4 + 12],eax		; -> delka vstupu pro 4. vlakno

		mov ebx, [ebp+24]				; delka vystupu ->
        shr ebx,2						; pro 4 vlakna (delka vystupu)/4
		mov dword [Ptrs1 + 16],ebx		; -> delka vystupu pro 1. vlakno
		mov dword [Ptrs2 + 16],ebx 		; -> delka vystupu pro 2. vlakno
		mov dword [Ptrs3 + 16],ebx		; -> delka vystupu pro 3. vlakno
		mov dword [Ptrs4 + 16],ebx 		; -> delka vystupu pro 4. vlakno

        mov ecx, [ebp+8]				; ukazatel na M ->
       	mov dword [Ptrs1 + 0],ecx		; -> ukazatel na M pro 1. vlakno
        shl ebx,2						; x4 pro jednoduchou presnost
        add ecx,ebx						; posun na prvniho ctvrtinu radku matice M
        mov dword [Ptrs2 + 0],ecx		; -> ukazatel na M pro 2. vlakno
        add ecx,ebx						; posun na druhou ctvrtinu radku matice M
        mov dword [Ptrs3 + 0],ecx		; -> ukazatel na M pro 3. vlakno
        add ecx,ebx						; posun na treti ctvrtinu radku matice M
        mov dword [Ptrs4 + 0],ecx		; -> ukazatel na M pro 4. vlakno

		mov eax, [ebp+16]				; ukazatel na y ->
		mov dword [Ptrs1 + 8],eax       ; -> ukazatel na y pro 1. vlakno
		add eax,ebx                     ; posun na prvni ctvrtinu vektoru y
		mov dword [Ptrs2 + 8],eax		; -> ukazatel na y pro 2. vlakno
		add eax,ebx                     ; posun na druhou ctvrtinu vektoru y
		mov dword [Ptrs3 + 8],eax		; -> ukazatel na y pro 3. vlakno
		add eax,ebx                     ; posun na treti ctvrtinu vektoru y
		mov dword [Ptrs4 + 8],eax		; -> ukazatel na y pro 4. vlakno

		mov dword [Ptrs1 + 20],4		; pocet vlaken
		mov dword [Ptrs2 + 20],4		; pocet vlaken
		mov dword [Ptrs3 + 20],4		; pocet vlaken
		mov dword [Ptrs4 + 20],4		; pocet vlaken

		mov byte [Ptrs1 + 21],0		; semafor pro 1. vlakno
		mov byte [Ptrs2 + 21],0		; semafor pro 2. vlakno
		mov byte [Ptrs3 + 21],0		; semafor pro 3. vlakno
		mov byte [Ptrs4 + 21],0		; semafor pro 4. vlakno

       	push dword NULL
		push dword 0
		push dword Ptrs1
		push dword vxm_avx_ptrs_sp
		push dword 0
		push dword 0
		call [CreateThread]

		push dword NULL
		push dword 0
		push dword Ptrs2
		push dword vxm_avx_ptrs_sp
		push dword 0
		push dword 0
		call [CreateThread]

		push dword NULL
		push dword 0
		push dword Ptrs3
		push dword vxm_avx_ptrs_sp
		push dword 0
		push dword 0
		call [CreateThread]

       	push dword Ptrs4
      	call vxm_avx_ptrs_sp

		.wait_for_thr1:
			cmp byte [Ptrs1 + 21],1
	        jnz .wait_for_thr1
   		.wait_for_thr2:
			cmp byte [Ptrs2 + 21],1
	        jnz .wait_for_thr2
   		.wait_for_thr3:
			cmp byte [Ptrs3 + 21],1
	        jnz .wait_for_thr3

		mov dword esp, ebp
       	pop dword ebp
ret 20


vxm_x4_x87_dp:
		push dword ebp
       	mov dword ebp,esp

		mov eax, [ebp+12]				; ukazatel na x ->
		mov dword [Ptrs1 + 4],eax		; -> ukazatel na x pro 1. vlakno
		mov dword [Ptrs2 + 4],eax		; -> ukazatel na x pro 2. vlakno
  		mov dword [Ptrs3 + 4],eax		; -> ukazatel na x pro 3. vlakno
		mov dword [Ptrs4 + 4],eax		; -> ukazatel na x pro 4. vlakno


		mov eax, [ebp+20]				; delka vstupu ->
		mov dword [Ptrs1 + 12],eax		; -> delka vstupu pro 1. vlakno
		mov dword [Ptrs2 + 12],eax		; -> delka vstupu pro 2. vlakno
		mov dword [Ptrs3 + 12],eax		; -> delka vstupu pro 3. vlakno
		mov dword [Ptrs4 + 12],eax		; -> delka vstupu pro 4. vlakno

		mov ebx, [ebp+24]				; delka vystupu ->
        shr ebx,2						; pro 4 vlakna (delka vystupu)/4
		mov dword [Ptrs1 + 16],ebx		; -> delka vystupu pro 1. vlakno
		mov dword [Ptrs2 + 16],ebx 		; -> delka vystupu pro 2. vlakno
		mov dword [Ptrs3 + 16],ebx		; -> delka vystupu pro 3. vlakno
		mov dword [Ptrs4 + 16],ebx 		; -> delka vystupu pro 4. vlakno

        mov ecx, [ebp+8]				; ukazatel na M ->
       	mov dword [Ptrs1 + 0],ecx		; -> ukazatel na M pro 1. vlakno
        shl ebx,3						; x8 pro dvojitou presnost
        add ecx,ebx						; posun na prvniho ctvrtinu radku matice M
        mov dword [Ptrs2 + 0],ecx		; -> ukazatel na M pro 2. vlakno
        add ecx,ebx						; posun na druhou ctvrtinu radku matice M
        mov dword [Ptrs3 + 0],ecx		; -> ukazatel na M pro 3. vlakno
        add ecx,ebx						; posun na treti ctvrtinu radku matice M
        mov dword [Ptrs4 + 0],ecx		; -> ukazatel na M pro 4. vlakno

		mov eax, [ebp+16]				; ukazatel na y ->
		mov dword [Ptrs1 + 8],eax       ; -> ukazatel na y pro 1. vlakno
		add eax,ebx                     ; posun na prvni ctvrtinu vektoru y
		mov dword [Ptrs2 + 8],eax		; -> ukazatel na y pro 2. vlakno
		add eax,ebx                     ; posun na druhou ctvrtinu vektoru y
		mov dword [Ptrs3 + 8],eax		; -> ukazatel na y pro 3. vlakno
		add eax,ebx                     ; posun na treti ctvrtinu vektoru y
		mov dword [Ptrs4 + 8],eax		; -> ukazatel na y pro 4. vlakno

		mov dword [Ptrs1 + 20],4		; pocet vlaken
		mov dword [Ptrs2 + 20],4		; pocet vlaken
		mov dword [Ptrs3 + 20],4		; pocet vlaken
		mov dword [Ptrs4 + 20],4		; pocet vlaken

		mov byte [Ptrs1 + 21],0		; semafor pro 1. vlakno
		mov byte [Ptrs2 + 21],0		; semafor pro 2. vlakno
		mov byte [Ptrs3 + 21],0		; semafor pro 3. vlakno
		mov byte [Ptrs4 + 21],0		; semafor pro 4. vlakno

       	push dword NULL
		push dword 0
		push dword Ptrs1
		push dword vxm_x87_ptrs_dp
		push dword 0
		push dword 0
		call [CreateThread]

		push dword NULL
		push dword 0
		push dword Ptrs2
		push dword vxm_x87_ptrs_dp
		push dword 0
		push dword 0
		call [CreateThread]

		push dword NULL
		push dword 0
		push dword Ptrs3
		push dword vxm_x87_ptrs_dp
		push dword 0
		push dword 0
		call [CreateThread]

       	push dword Ptrs4
      	call vxm_x87_ptrs_dp

		.wait_for_thr1:
			cmp byte [Ptrs1 + 21],1
	        jnz .wait_for_thr1
   		.wait_for_thr2:
			cmp byte [Ptrs2 + 21],1
	        jnz .wait_for_thr2
   		.wait_for_thr3:
			cmp byte [Ptrs3 + 21],1
	        jnz .wait_for_thr3

		mov dword esp, ebp
       	pop dword ebp
ret 20

vxm_x4_sse_dp:
		push dword ebp
       	mov dword ebp,esp

		mov eax, [ebp+12]				; ukazatel na x ->
		mov dword [Ptrs1 + 4],eax		; -> ukazatel na x pro 1. vlakno
		mov dword [Ptrs2 + 4],eax		; -> ukazatel na x pro 2. vlakno
  		mov dword [Ptrs3 + 4],eax		; -> ukazatel na x pro 3. vlakno
		mov dword [Ptrs4 + 4],eax		; -> ukazatel na x pro 4. vlakno


		mov eax, [ebp+20]				; delka vstupu ->
		mov dword [Ptrs1 + 12],eax		; -> delka vstupu pro 1. vlakno
		mov dword [Ptrs2 + 12],eax		; -> delka vstupu pro 2. vlakno
		mov dword [Ptrs3 + 12],eax		; -> delka vstupu pro 3. vlakno
		mov dword [Ptrs4 + 12],eax		; -> delka vstupu pro 4. vlakno

		mov ebx, [ebp+24]				; delka vystupu ->
        shr ebx,2						; pro 4 vlakna (delka vystupu)/4
		mov dword [Ptrs1 + 16],ebx		; -> delka vystupu pro 1. vlakno
		mov dword [Ptrs2 + 16],ebx 		; -> delka vystupu pro 2. vlakno
		mov dword [Ptrs3 + 16],ebx		; -> delka vystupu pro 3. vlakno
		mov dword [Ptrs4 + 16],ebx 		; -> delka vystupu pro 4. vlakno

        mov ecx, [ebp+8]				; ukazatel na M ->
       	mov dword [Ptrs1 + 0],ecx		; -> ukazatel na M pro 1. vlakno
        shl ebx,3						; x8 pro dvojitou presnost
        add ecx,ebx						; posun na prvniho ctvrtinu radku matice M
        mov dword [Ptrs2 + 0],ecx		; -> ukazatel na M pro 2. vlakno
        add ecx,ebx						; posun na druhou ctvrtinu radku matice M
        mov dword [Ptrs3 + 0],ecx		; -> ukazatel na M pro 3. vlakno
        add ecx,ebx						; posun na treti ctvrtinu radku matice M
        mov dword [Ptrs4 + 0],ecx		; -> ukazatel na M pro 4. vlakno

		mov eax, [ebp+16]				; ukazatel na y ->
		mov dword [Ptrs1 + 8],eax       ; -> ukazatel na y pro 1. vlakno
		add eax,ebx                     ; posun na prvni ctvrtinu vektoru y
		mov dword [Ptrs2 + 8],eax		; -> ukazatel na y pro 2. vlakno
		add eax,ebx                     ; posun na druhou ctvrtinu vektoru y
		mov dword [Ptrs3 + 8],eax		; -> ukazatel na y pro 3. vlakno
		add eax,ebx                     ; posun na treti ctvrtinu vektoru y
		mov dword [Ptrs4 + 8],eax		; -> ukazatel na y pro 4. vlakno

		mov dword [Ptrs1 + 20],4		; pocet vlaken
		mov dword [Ptrs2 + 20],4		; pocet vlaken
		mov dword [Ptrs3 + 20],4		; pocet vlaken
		mov dword [Ptrs4 + 20],4		; pocet vlaken

		mov byte [Ptrs1 + 21],0		; semafor pro 1. vlakno
		mov byte [Ptrs2 + 21],0		; semafor pro 2. vlakno
		mov byte [Ptrs3 + 21],0		; semafor pro 3. vlakno
		mov byte [Ptrs4 + 21],0		; semafor pro 4. vlakno

       	push dword NULL
		push dword 0
		push dword Ptrs1
		push dword vxm_sse_ptrs_dp
		push dword 0
		push dword 0
		call [CreateThread]

		push dword NULL
		push dword 0
		push dword Ptrs2
		push dword vxm_sse_ptrs_dp
		push dword 0
		push dword 0
		call [CreateThread]

		push dword NULL
		push dword 0
		push dword Ptrs3
		push dword vxm_sse_ptrs_dp
		push dword 0
		push dword 0
		call [CreateThread]

       	push dword Ptrs4
      	call vxm_sse_ptrs_dp

		.wait_for_thr1:
			cmp byte [Ptrs1 + 21],1
	        jnz .wait_for_thr1
   		.wait_for_thr2:
			cmp byte [Ptrs2 + 21],1
	        jnz .wait_for_thr2
   		.wait_for_thr3:
			cmp byte [Ptrs3 + 21],1
	        jnz .wait_for_thr3

		mov dword esp, ebp
       	pop dword ebp
ret 20

vxm_x4_avx_dp:
		push dword ebp
       	mov dword ebp,esp

		mov eax, [ebp+12]				; ukazatel na x ->
		mov dword [Ptrs1 + 4],eax		; -> ukazatel na x pro 1. vlakno
		mov dword [Ptrs2 + 4],eax		; -> ukazatel na x pro 2. vlakno
  		mov dword [Ptrs3 + 4],eax		; -> ukazatel na x pro 3. vlakno
		mov dword [Ptrs4 + 4],eax		; -> ukazatel na x pro 4. vlakno


		mov eax, [ebp+20]				; delka vstupu ->
		mov dword [Ptrs1 + 12],eax		; -> delka vstupu pro 1. vlakno
		mov dword [Ptrs2 + 12],eax		; -> delka vstupu pro 2. vlakno
		mov dword [Ptrs3 + 12],eax		; -> delka vstupu pro 3. vlakno
		mov dword [Ptrs4 + 12],eax		; -> delka vstupu pro 4. vlakno

		mov ebx, [ebp+24]				; delka vystupu ->
        shr ebx,2						; pro 4 vlakna (delka vystupu)/4
		mov dword [Ptrs1 + 16],ebx		; -> delka vystupu pro 1. vlakno
		mov dword [Ptrs2 + 16],ebx 		; -> delka vystupu pro 2. vlakno
		mov dword [Ptrs3 + 16],ebx		; -> delka vystupu pro 3. vlakno
		mov dword [Ptrs4 + 16],ebx 		; -> delka vystupu pro 4. vlakno

        mov ecx, [ebp+8]				; ukazatel na M ->
       	mov dword [Ptrs1 + 0],ecx		; -> ukazatel na M pro 1. vlakno
        shl ebx,3						; x8 pro dvojitou presnost
        add ecx,ebx						; posun na prvniho ctvrtinu radku matice M
        mov dword [Ptrs2 + 0],ecx		; -> ukazatel na M pro 2. vlakno
        add ecx,ebx						; posun na druhou ctvrtinu radku matice M
        mov dword [Ptrs3 + 0],ecx		; -> ukazatel na M pro 3. vlakno
        add ecx,ebx						; posun na treti ctvrtinu radku matice M
        mov dword [Ptrs4 + 0],ecx		; -> ukazatel na M pro 4. vlakno

		mov eax, [ebp+16]				; ukazatel na y ->
		mov dword [Ptrs1 + 8],eax       ; -> ukazatel na y pro 1. vlakno
		add eax,ebx                     ; posun na prvni ctvrtinu vektoru y
		mov dword [Ptrs2 + 8],eax		; -> ukazatel na y pro 2. vlakno
		add eax,ebx                     ; posun na druhou ctvrtinu vektoru y
		mov dword [Ptrs3 + 8],eax		; -> ukazatel na y pro 3. vlakno
		add eax,ebx                     ; posun na treti ctvrtinu vektoru y
		mov dword [Ptrs4 + 8],eax		; -> ukazatel na y pro 4. vlakno

		mov dword [Ptrs1 + 20],4		; pocet vlaken
		mov dword [Ptrs2 + 20],4		; pocet vlaken
		mov dword [Ptrs3 + 20],4		; pocet vlaken
		mov dword [Ptrs4 + 20],4		; pocet vlaken

		mov byte [Ptrs1 + 21],0		; semafor pro 1. vlakno
		mov byte [Ptrs2 + 21],0		; semafor pro 2. vlakno
		mov byte [Ptrs3 + 21],0		; semafor pro 3. vlakno
		mov byte [Ptrs4 + 21],0		; semafor pro 4. vlakno

       	push dword NULL
		push dword 0
		push dword Ptrs1
		push dword vxm_avx_ptrs_dp
		push dword 0
		push dword 0
		call [CreateThread]

		push dword NULL
		push dword 0
		push dword Ptrs2
		push dword vxm_avx_ptrs_dp
		push dword 0
		push dword 0
		call [CreateThread]

		push dword NULL
		push dword 0
		push dword Ptrs3
		push dword vxm_avx_ptrs_dp
		push dword 0
		push dword 0
		call [CreateThread]

       	push dword Ptrs4
      	call vxm_avx_ptrs_dp

		.wait_for_thr1:
			cmp byte [Ptrs1 + 21],1
	        jnz .wait_for_thr1
   		.wait_for_thr2:
			cmp byte [Ptrs2 + 21],1
	        jnz .wait_for_thr2
   		.wait_for_thr3:
			cmp byte [Ptrs3 + 21],1
	        jnz .wait_for_thr3

		mov dword esp, ebp
       	pop dword ebp
ret 20



vxm_x8_x87_sp:
		push dword ebp
       	mov dword ebp,esp

		mov eax, [ebp+12]				; ukazatel na x ->
		mov dword [Ptrs1 + 4],eax		; -> ukazatel na x pro 1. vlakno
		mov dword [Ptrs2 + 4],eax		; -> ukazatel na x pro 2. vlakno
  		mov dword [Ptrs3 + 4],eax		; -> ukazatel na x pro 3. vlakno
		mov dword [Ptrs4 + 4],eax		; -> ukazatel na x pro 4. vlakno
		mov dword [Ptrs5 + 4],eax		; -> ukazatel na x pro 5. vlakno
		mov dword [Ptrs6 + 4],eax		; -> ukazatel na x pro 6. vlakno
  		mov dword [Ptrs7 + 4],eax		; -> ukazatel na x pro 7. vlakno
		mov dword [Ptrs8 + 4],eax		; -> ukazatel na x pro 8. vlakno


		mov eax, [ebp+20]				; delka vstupu ->
		mov dword [Ptrs1 + 12],eax		; -> delka vstupu pro 1. vlakno
		mov dword [Ptrs2 + 12],eax		; -> delka vstupu pro 2. vlakno
		mov dword [Ptrs3 + 12],eax		; -> delka vstupu pro 3. vlakno
		mov dword [Ptrs4 + 12],eax		; -> delka vstupu pro 4. vlakno
		mov dword [Ptrs5 + 12],eax		; -> delka vstupu pro 5. vlakno
		mov dword [Ptrs6 + 12],eax		; -> delka vstupu pro 6. vlakno
		mov dword [Ptrs7 + 12],eax		; -> delka vstupu pro 7. vlakno
		mov dword [Ptrs8 + 12],eax		; -> delka vstupu pro 8. vlakno

		mov ebx, [ebp+24]				; delka vystupu ->
        shr ebx,3						; pro 8 vlaken (delka vystupu)/8
		mov dword [Ptrs1 + 16],ebx		; -> delka vystupu pro 1. vlakno
		mov dword [Ptrs2 + 16],ebx 		; -> delka vystupu pro 2. vlakno
		mov dword [Ptrs3 + 16],ebx		; -> delka vystupu pro 3. vlakno
		mov dword [Ptrs4 + 16],ebx 		; -> delka vystupu pro 4. vlakno
		mov dword [Ptrs5 + 16],ebx		; -> delka vystupu pro 5. vlakno
		mov dword [Ptrs6 + 16],ebx		; -> delka vystupu pro 6. vlakno
		mov dword [Ptrs7 + 16],ebx		; -> delka vystupu pro 7. vlakno
		mov dword [Ptrs8 + 16],ebx		; -> delka vystupu pro 8. vlakno

        mov ecx, [ebp+8]				; ukazatel na M ->
       	mov dword [Ptrs1 + 0],ecx		; -> ukazatel na M pro 1. vlakno
        shl ebx,2						; x4 pro jednoduchou presnost
        add ecx,ebx						; posun na prvniho osminu radku matice M
        mov dword [Ptrs2 + 0],ecx		; -> ukazatel na M pro 2. vlakno
        add ecx,ebx						; posun na druhoy osminu radku matice M
        mov dword [Ptrs3 + 0],ecx		; -> ukazatel na M pro 3. vlakno
        add ecx,ebx						; posun na treti osminu radku matice M
        mov dword [Ptrs4 + 0],ecx		; -> ukazatel na M pro 4. vlakno
        add ecx,ebx						; posun na ctvrtou osminu radku matice M
        mov dword [Ptrs5 + 0],ecx		; -> ukazatel na M pro 5. vlakno
        add ecx,ebx						; posun na patou osminu radku matice M
        mov dword [Ptrs6 + 0],ecx		; -> ukazatel na M pro 6. vlakno
        add ecx,ebx						; posun na sestou osminu radku matice M
        mov dword [Ptrs7 + 0],ecx		; -> ukazatel na M pro 7. vlakno
        add ecx,ebx						; posun na sedmou osminu radku matice M
        mov dword [Ptrs8 + 0],ecx		; -> ukazatel na M pro 8. vlakno

		mov eax, [ebp+16]				; ukazatel na y ->
		mov dword [Ptrs1 + 8],eax       ; -> ukazatel na y pro 1. vlakno
		add eax,ebx                     ; posun na prvni osminu vektoru y
		mov dword [Ptrs2 + 8],eax		; -> ukazatel na y pro 2. vlakno
		add eax,ebx                     ; posun na druhou osminu vektoru y
		mov dword [Ptrs3 + 8],eax		; -> ukazatel na y pro 3. vlakno
		add eax,ebx                     ; posun na treti osminu vektoru y
		mov dword [Ptrs4 + 8],eax		; -> ukazatel na y pro 4. vlakno
		add eax,ebx                     ; posun na ctvrtou osminu vektoru y
		mov dword [Ptrs5 + 8],eax		; -> ukazatel na y pro 5. vlakno
		add eax,ebx                     ; posun na patou osminu vektoru y
		mov dword [Ptrs6 + 8],eax		; -> ukazatel na y pro 6. vlakno
		add eax,ebx                     ; posun na sestou osminu vektoru y
		mov dword [Ptrs7 + 8],eax		; -> ukazatel na y pro 7. vlakno
		add eax,ebx                     ; posun na sedmou osminu vektoru y
		mov dword [Ptrs8 + 8],eax		; -> ukazatel na y pro 8. vlakno

		mov dword [Ptrs1 + 20],8		; pocet vlaken
		mov dword [Ptrs2 + 20],8		; pocet vlaken
		mov dword [Ptrs3 + 20],8		; pocet vlaken
		mov dword [Ptrs4 + 20],8		; pocet vlaken
		mov dword [Ptrs5 + 20],8		; pocet vlaken
		mov dword [Ptrs6 + 20],8		; pocet vlaken
		mov dword [Ptrs7 + 20],8		; pocet vlaken
		mov dword [Ptrs8 + 20],8		; pocet vlaken

		mov byte [Ptrs1 + 21],0		; semafor pro 1. vlakno
		mov byte [Ptrs2 + 21],0		; semafor pro 2. vlakno
		mov byte [Ptrs3 + 21],0		; semafor pro 3. vlakno
		mov byte [Ptrs4 + 21],0		; semafor pro 4. vlakno
		mov byte [Ptrs5 + 21],0		; semafor pro 5. vlakno
		mov byte [Ptrs6 + 21],0		; semafor pro 6. vlakno
		mov byte [Ptrs7 + 21],0		; semafor pro 7. vlakno
		mov byte [Ptrs8 + 21],0		; semafor pro 8. vlakno

       	push dword NULL
		push dword 0
		push dword Ptrs1
		push dword vxm_x87_ptrs_sp
		push dword 0
		push dword 0
		call [CreateThread]

		push dword NULL
		push dword 0
		push dword Ptrs2
		push dword vxm_x87_ptrs_sp
		push dword 0
		push dword 0
		call [CreateThread]

		push dword NULL
		push dword 0
		push dword Ptrs3
		push dword vxm_x87_ptrs_sp
		push dword 0
		push dword 0
		call [CreateThread]

       	push dword NULL
		push dword 0
		push dword Ptrs4
		push dword vxm_x87_ptrs_sp
		push dword 0
		push dword 0
		call [CreateThread]

		push dword NULL
		push dword 0
		push dword Ptrs5
		push dword vxm_x87_ptrs_sp
		push dword 0
		push dword 0
		call [CreateThread]

		push dword NULL
		push dword 0
		push dword Ptrs6
		push dword vxm_x87_ptrs_sp
		push dword 0
		push dword 0
		call [CreateThread]

		push dword NULL
		push dword 0
		push dword Ptrs7
		push dword vxm_x87_ptrs_sp
		push dword 0
		push dword 0
		call [CreateThread]

       	push dword Ptrs8
      	call vxm_x87_ptrs_sp

		.wait_for_thr1:
			cmp byte [Ptrs1 + 21],1
	        jnz .wait_for_thr1
   		.wait_for_thr2:
			cmp byte [Ptrs2 + 21],1
	        jnz .wait_for_thr2
   		.wait_for_thr3:
			cmp byte [Ptrs3 + 21],1
	        jnz .wait_for_thr3
   		.wait_for_thr4:
			cmp byte [Ptrs4 + 21],1
	        jnz .wait_for_thr4
   		.wait_for_thr5:
			cmp byte [Ptrs5 + 21],1
	        jnz .wait_for_thr5
   		.wait_for_thr6:
			cmp byte [Ptrs6 + 21],1
	        jnz .wait_for_thr6
 		.wait_for_thr7:
			cmp byte [Ptrs7 + 21],1
	        jnz .wait_for_thr7

		mov dword esp, ebp
       	pop dword ebp
ret 20

vxm_x8_x87_dp:
		push dword ebp
       	mov dword ebp,esp

		mov eax, [ebp+12]				; ukazatel na x ->
		mov dword [Ptrs1 + 4],eax		; -> ukazatel na x pro 1. vlakno
		mov dword [Ptrs2 + 4],eax		; -> ukazatel na x pro 2. vlakno
  		mov dword [Ptrs3 + 4],eax		; -> ukazatel na x pro 3. vlakno
		mov dword [Ptrs4 + 4],eax		; -> ukazatel na x pro 4. vlakno
		mov dword [Ptrs5 + 4],eax		; -> ukazatel na x pro 5. vlakno
		mov dword [Ptrs6 + 4],eax		; -> ukazatel na x pro 6. vlakno
  		mov dword [Ptrs7 + 4],eax		; -> ukazatel na x pro 7. vlakno
		mov dword [Ptrs8 + 4],eax		; -> ukazatel na x pro 8. vlakno


		mov eax, [ebp+20]				; delka vstupu ->
		mov dword [Ptrs1 + 12],eax		; -> delka vstupu pro 1. vlakno
		mov dword [Ptrs2 + 12],eax		; -> delka vstupu pro 2. vlakno
		mov dword [Ptrs3 + 12],eax		; -> delka vstupu pro 3. vlakno
		mov dword [Ptrs4 + 12],eax		; -> delka vstupu pro 4. vlakno
		mov dword [Ptrs5 + 12],eax		; -> delka vstupu pro 5. vlakno
		mov dword [Ptrs6 + 12],eax		; -> delka vstupu pro 6. vlakno
		mov dword [Ptrs7 + 12],eax		; -> delka vstupu pro 7. vlakno
		mov dword [Ptrs8 + 12],eax		; -> delka vstupu pro 8. vlakno

		mov ebx, [ebp+24]				; delka vystupu ->
        shr ebx,3						; pro 8 vlaken (delka vystupu)/8
		mov dword [Ptrs1 + 16],ebx		; -> delka vystupu pro 1. vlakno
		mov dword [Ptrs2 + 16],ebx 		; -> delka vystupu pro 2. vlakno
		mov dword [Ptrs3 + 16],ebx		; -> delka vystupu pro 3. vlakno
		mov dword [Ptrs4 + 16],ebx 		; -> delka vystupu pro 4. vlakno
		mov dword [Ptrs5 + 16],ebx		; -> delka vystupu pro 5. vlakno
		mov dword [Ptrs6 + 16],ebx		; -> delka vystupu pro 6. vlakno
		mov dword [Ptrs7 + 16],ebx		; -> delka vystupu pro 7. vlakno
		mov dword [Ptrs8 + 16],ebx		; -> delka vystupu pro 8. vlakno

        mov ecx, [ebp+8]				; ukazatel na M ->
       	mov dword [Ptrs1 + 0],ecx		; -> ukazatel na M pro 1. vlakno
        shl ebx,3						; x8 pro dvojitou presnost
        add ecx,ebx						; posun na prvniho osminu radku matice M
        mov dword [Ptrs2 + 0],ecx		; -> ukazatel na M pro 2. vlakno
        add ecx,ebx						; posun na druhoy osminu radku matice M
        mov dword [Ptrs3 + 0],ecx		; -> ukazatel na M pro 3. vlakno
        add ecx,ebx						; posun na treti osminu radku matice M
        mov dword [Ptrs4 + 0],ecx		; -> ukazatel na M pro 4. vlakno
        add ecx,ebx						; posun na ctvrtou osminu radku matice M
        mov dword [Ptrs5 + 0],ecx		; -> ukazatel na M pro 5. vlakno
        add ecx,ebx						; posun na patou osminu radku matice M
        mov dword [Ptrs6 + 0],ecx		; -> ukazatel na M pro 6. vlakno
        add ecx,ebx						; posun na sestou osminu radku matice M
        mov dword [Ptrs7 + 0],ecx		; -> ukazatel na M pro 7. vlakno
        add ecx,ebx						; posun na sedmou osminu radku matice M
        mov dword [Ptrs8 + 0],ecx		; -> ukazatel na M pro 8. vlakno

		mov eax, [ebp+16]				; ukazatel na y ->
		mov dword [Ptrs1 + 8],eax       ; -> ukazatel na y pro 1. vlakno
		add eax,ebx                     ; posun na prvni osminu vektoru y
		mov dword [Ptrs2 + 8],eax		; -> ukazatel na y pro 2. vlakno
		add eax,ebx                     ; posun na druhou osminu vektoru y
		mov dword [Ptrs3 + 8],eax		; -> ukazatel na y pro 3. vlakno
		add eax,ebx                     ; posun na treti osminu vektoru y
		mov dword [Ptrs4 + 8],eax		; -> ukazatel na y pro 4. vlakno
		add eax,ebx                     ; posun na ctvrtou osminu vektoru y
		mov dword [Ptrs5 + 8],eax		; -> ukazatel na y pro 5. vlakno
		add eax,ebx                     ; posun na patou osminu vektoru y
		mov dword [Ptrs6 + 8],eax		; -> ukazatel na y pro 6. vlakno
		add eax,ebx                     ; posun na sestou osminu vektoru y
		mov dword [Ptrs7 + 8],eax		; -> ukazatel na y pro 7. vlakno
		add eax,ebx                     ; posun na sedmou osminu vektoru y
		mov dword [Ptrs8 + 8],eax		; -> ukazatel na y pro 8. vlakno

		mov dword [Ptrs1 + 20],8		; pocet vlaken
		mov dword [Ptrs2 + 20],8		; pocet vlaken
		mov dword [Ptrs3 + 20],8		; pocet vlaken
		mov dword [Ptrs4 + 20],8		; pocet vlaken
		mov dword [Ptrs5 + 20],8		; pocet vlaken
		mov dword [Ptrs6 + 20],8		; pocet vlaken
		mov dword [Ptrs7 + 20],8		; pocet vlaken
		mov dword [Ptrs8 + 20],8		; pocet vlaken

		mov byte [Ptrs1 + 21],0		; semafor pro 1. vlakno
		mov byte [Ptrs2 + 21],0		; semafor pro 2. vlakno
		mov byte [Ptrs3 + 21],0		; semafor pro 3. vlakno
		mov byte [Ptrs4 + 21],0		; semafor pro 4. vlakno
		mov byte [Ptrs5 + 21],0		; semafor pro 5. vlakno
		mov byte [Ptrs6 + 21],0		; semafor pro 6. vlakno
		mov byte [Ptrs7 + 21],0		; semafor pro 7. vlakno
		mov byte [Ptrs8 + 21],0		; semafor pro 8. vlakno

       	push dword NULL
		push dword 0
		push dword Ptrs1
		push dword vxm_x87_ptrs_dp
		push dword 0
		push dword 0
		call [CreateThread]

		push dword NULL
		push dword 0
		push dword Ptrs2
		push dword vxm_x87_ptrs_dp
		push dword 0
		push dword 0
		call [CreateThread]

		push dword NULL
		push dword 0
		push dword Ptrs3
		push dword vxm_x87_ptrs_dp
		push dword 0
		push dword 0
		call [CreateThread]

       	push dword NULL
		push dword 0
		push dword Ptrs4
		push dword vxm_x87_ptrs_dp
		push dword 0
		push dword 0
		call [CreateThread]

		push dword NULL
		push dword 0
		push dword Ptrs5
		push dword vxm_x87_ptrs_dp
		push dword 0
		push dword 0
		call [CreateThread]

		push dword NULL
		push dword 0
		push dword Ptrs6
		push dword vxm_x87_ptrs_dp
		push dword 0
		push dword 0
		call [CreateThread]

		push dword NULL
		push dword 0
		push dword Ptrs7
		push dword vxm_x87_ptrs_dp
		push dword 0
		push dword 0
		call [CreateThread]

       	push dword Ptrs8
      	call vxm_x87_ptrs_dp

		.wait_for_thr1:
			cmp byte [Ptrs1 + 21],1
	        jnz .wait_for_thr1
   		.wait_for_thr2:
			cmp byte [Ptrs2 + 21],1
	        jnz .wait_for_thr2
   		.wait_for_thr3:
			cmp byte [Ptrs3 + 21],1
	        jnz .wait_for_thr3
   		.wait_for_thr4:
			cmp byte [Ptrs4 + 21],1
	        jnz .wait_for_thr4
   		.wait_for_thr5:
			cmp byte [Ptrs5 + 21],1
	        jnz .wait_for_thr5
   		.wait_for_thr6:
			cmp byte [Ptrs6 + 21],1
	        jnz .wait_for_thr6
 		.wait_for_thr7:
			cmp byte [Ptrs7 + 21],1
	        jnz .wait_for_thr7

		mov dword esp, ebp
       	pop dword ebp
ret 20

vxm_x8_sse_sp:
		push dword ebp
       	mov dword ebp,esp

		mov eax, [ebp+12]				; ukazatel na x ->
		mov dword [Ptrs1 + 4],eax		; -> ukazatel na x pro 1. vlakno
		mov dword [Ptrs2 + 4],eax		; -> ukazatel na x pro 2. vlakno
  		mov dword [Ptrs3 + 4],eax		; -> ukazatel na x pro 3. vlakno
		mov dword [Ptrs4 + 4],eax		; -> ukazatel na x pro 4. vlakno
		mov dword [Ptrs5 + 4],eax		; -> ukazatel na x pro 5. vlakno
		mov dword [Ptrs6 + 4],eax		; -> ukazatel na x pro 6. vlakno
  		mov dword [Ptrs7 + 4],eax		; -> ukazatel na x pro 7. vlakno
		mov dword [Ptrs8 + 4],eax		; -> ukazatel na x pro 8. vlakno


		mov eax, [ebp+20]				; delka vstupu ->
		mov dword [Ptrs1 + 12],eax		; -> delka vstupu pro 1. vlakno
		mov dword [Ptrs2 + 12],eax		; -> delka vstupu pro 2. vlakno
		mov dword [Ptrs3 + 12],eax		; -> delka vstupu pro 3. vlakno
		mov dword [Ptrs4 + 12],eax		; -> delka vstupu pro 4. vlakno
		mov dword [Ptrs5 + 12],eax		; -> delka vstupu pro 5. vlakno
		mov dword [Ptrs6 + 12],eax		; -> delka vstupu pro 6. vlakno
		mov dword [Ptrs7 + 12],eax		; -> delka vstupu pro 7. vlakno
		mov dword [Ptrs8 + 12],eax		; -> delka vstupu pro 8. vlakno

		mov ebx, [ebp+24]				; delka vystupu ->
        shr ebx,3						; pro 8 vlaken (delka vystupu)/8
		mov dword [Ptrs1 + 16],ebx		; -> delka vystupu pro 1. vlakno
		mov dword [Ptrs2 + 16],ebx 		; -> delka vystupu pro 2. vlakno
		mov dword [Ptrs3 + 16],ebx		; -> delka vystupu pro 3. vlakno
		mov dword [Ptrs4 + 16],ebx 		; -> delka vystupu pro 4. vlakno
		mov dword [Ptrs5 + 16],ebx		; -> delka vystupu pro 5. vlakno
		mov dword [Ptrs6 + 16],ebx		; -> delka vystupu pro 6. vlakno
		mov dword [Ptrs7 + 16],ebx		; -> delka vystupu pro 7. vlakno
		mov dword [Ptrs8 + 16],ebx		; -> delka vystupu pro 8. vlakno

        mov ecx, [ebp+8]				; ukazatel na M ->
       	mov dword [Ptrs1 + 0],ecx		; -> ukazatel na M pro 1. vlakno
        shl ebx,2						; x4 pro jednoduchou presnost
        add ecx,ebx						; posun na prvniho osminu radku matice M
        mov dword [Ptrs2 + 0],ecx		; -> ukazatel na M pro 2. vlakno
        add ecx,ebx						; posun na druhoy osminu radku matice M
        mov dword [Ptrs3 + 0],ecx		; -> ukazatel na M pro 3. vlakno
        add ecx,ebx						; posun na treti osminu radku matice M
        mov dword [Ptrs4 + 0],ecx		; -> ukazatel na M pro 4. vlakno
        add ecx,ebx						; posun na ctvrtou osminu radku matice M
        mov dword [Ptrs5 + 0],ecx		; -> ukazatel na M pro 5. vlakno
        add ecx,ebx						; posun na patou osminu radku matice M
        mov dword [Ptrs6 + 0],ecx		; -> ukazatel na M pro 6. vlakno
        add ecx,ebx						; posun na sestou osminu radku matice M
        mov dword [Ptrs7 + 0],ecx		; -> ukazatel na M pro 7. vlakno
        add ecx,ebx						; posun na sedmou osminu radku matice M
        mov dword [Ptrs8 + 0],ecx		; -> ukazatel na M pro 8. vlakno

		mov eax, [ebp+16]				; ukazatel na y ->
		mov dword [Ptrs1 + 8],eax       ; -> ukazatel na y pro 1. vlakno
		add eax,ebx                     ; posun na prvni osminu vektoru y
		mov dword [Ptrs2 + 8],eax		; -> ukazatel na y pro 2. vlakno
		add eax,ebx                     ; posun na druhou osminu vektoru y
		mov dword [Ptrs3 + 8],eax		; -> ukazatel na y pro 3. vlakno
		add eax,ebx                     ; posun na treti osminu vektoru y
		mov dword [Ptrs4 + 8],eax		; -> ukazatel na y pro 4. vlakno
		add eax,ebx                     ; posun na ctvrtou osminu vektoru y
		mov dword [Ptrs5 + 8],eax		; -> ukazatel na y pro 5. vlakno
		add eax,ebx                     ; posun na patou osminu vektoru y
		mov dword [Ptrs6 + 8],eax		; -> ukazatel na y pro 6. vlakno
		add eax,ebx                     ; posun na sestou osminu vektoru y
		mov dword [Ptrs7 + 8],eax		; -> ukazatel na y pro 7. vlakno
		add eax,ebx                     ; posun na sedmou osminu vektoru y
		mov dword [Ptrs8 + 8],eax		; -> ukazatel na y pro 8. vlakno

		mov dword [Ptrs1 + 20],8		; pocet vlaken
		mov dword [Ptrs2 + 20],8		; pocet vlaken
		mov dword [Ptrs3 + 20],8		; pocet vlaken
		mov dword [Ptrs4 + 20],8		; pocet vlaken
		mov dword [Ptrs5 + 20],8		; pocet vlaken
		mov dword [Ptrs6 + 20],8		; pocet vlaken
		mov dword [Ptrs7 + 20],8		; pocet vlaken
		mov dword [Ptrs8 + 20],8		; pocet vlaken

		mov byte [Ptrs1 + 21],0		; semafor pro 1. vlakno
		mov byte [Ptrs2 + 21],0		; semafor pro 2. vlakno
		mov byte [Ptrs3 + 21],0		; semafor pro 3. vlakno
		mov byte [Ptrs4 + 21],0		; semafor pro 4. vlakno
		mov byte [Ptrs5 + 21],0		; semafor pro 5. vlakno
		mov byte [Ptrs6 + 21],0		; semafor pro 6. vlakno
		mov byte [Ptrs7 + 21],0		; semafor pro 7. vlakno
		mov byte [Ptrs8 + 21],0		; semafor pro 8. vlakno

       	push dword NULL
		push dword 0
		push dword Ptrs1
		push dword vxm_sse_ptrs_sp
		push dword 0
		push dword 0
		call [CreateThread]

		push dword NULL
		push dword 0
		push dword Ptrs2
		push dword vxm_sse_ptrs_sp
		push dword 0
		push dword 0
		call [CreateThread]

		push dword NULL
		push dword 0
		push dword Ptrs3
		push dword vxm_sse_ptrs_sp
		push dword 0
		push dword 0
		call [CreateThread]

       	push dword NULL
		push dword 0
		push dword Ptrs4
		push dword vxm_sse_ptrs_sp
		push dword 0
		push dword 0
		call [CreateThread]

		push dword NULL
		push dword 0
		push dword Ptrs5
		push dword vxm_sse_ptrs_sp
		push dword 0
		push dword 0
		call [CreateThread]

		push dword NULL
		push dword 0
		push dword Ptrs6
		push dword vxm_sse_ptrs_sp
		push dword 0
		push dword 0
		call [CreateThread]

		push dword NULL
		push dword 0
		push dword Ptrs7
		push dword vxm_sse_ptrs_sp
		push dword 0
		push dword 0
		call [CreateThread]

       	push dword Ptrs8
      	call vxm_sse_ptrs_sp

		.wait_for_thr1:
			cmp byte [Ptrs1 + 21],1
	        jnz .wait_for_thr1
   		.wait_for_thr2:
			cmp byte [Ptrs2 + 21],1
	        jnz .wait_for_thr2
   		.wait_for_thr3:
			cmp byte [Ptrs3 + 21],1
	        jnz .wait_for_thr3
   		.wait_for_thr4:
			cmp byte [Ptrs4 + 21],1
	        jnz .wait_for_thr4
   		.wait_for_thr5:
			cmp byte [Ptrs5 + 21],1
	        jnz .wait_for_thr5
   		.wait_for_thr6:
			cmp byte [Ptrs6 + 21],1
	        jnz .wait_for_thr6
 		.wait_for_thr7:
			cmp byte [Ptrs7 + 21],1
	        jnz .wait_for_thr7

		mov dword esp, ebp
       	pop dword ebp
ret 20

vxm_x8_sse_dp:
		push dword ebp
       	mov dword ebp,esp

		mov eax, [ebp+12]				; ukazatel na x ->
		mov dword [Ptrs1 + 4],eax		; -> ukazatel na x pro 1. vlakno
		mov dword [Ptrs2 + 4],eax		; -> ukazatel na x pro 2. vlakno
  		mov dword [Ptrs3 + 4],eax		; -> ukazatel na x pro 3. vlakno
		mov dword [Ptrs4 + 4],eax		; -> ukazatel na x pro 4. vlakno
		mov dword [Ptrs5 + 4],eax		; -> ukazatel na x pro 5. vlakno
		mov dword [Ptrs6 + 4],eax		; -> ukazatel na x pro 6. vlakno
  		mov dword [Ptrs7 + 4],eax		; -> ukazatel na x pro 7. vlakno
		mov dword [Ptrs8 + 4],eax		; -> ukazatel na x pro 8. vlakno


		mov eax, [ebp+20]				; delka vstupu ->
		mov dword [Ptrs1 + 12],eax		; -> delka vstupu pro 1. vlakno
		mov dword [Ptrs2 + 12],eax		; -> delka vstupu pro 2. vlakno
		mov dword [Ptrs3 + 12],eax		; -> delka vstupu pro 3. vlakno
		mov dword [Ptrs4 + 12],eax		; -> delka vstupu pro 4. vlakno
		mov dword [Ptrs5 + 12],eax		; -> delka vstupu pro 5. vlakno
		mov dword [Ptrs6 + 12],eax		; -> delka vstupu pro 6. vlakno
		mov dword [Ptrs7 + 12],eax		; -> delka vstupu pro 7. vlakno
		mov dword [Ptrs8 + 12],eax		; -> delka vstupu pro 8. vlakno

		mov ebx, [ebp+24]				; delka vystupu ->
        shr ebx,3						; pro 8 vlaken (delka vystupu)/8
		mov dword [Ptrs1 + 16],ebx		; -> delka vystupu pro 1. vlakno
		mov dword [Ptrs2 + 16],ebx 		; -> delka vystupu pro 2. vlakno
		mov dword [Ptrs3 + 16],ebx		; -> delka vystupu pro 3. vlakno
		mov dword [Ptrs4 + 16],ebx 		; -> delka vystupu pro 4. vlakno
		mov dword [Ptrs5 + 16],ebx		; -> delka vystupu pro 5. vlakno
		mov dword [Ptrs6 + 16],ebx		; -> delka vystupu pro 6. vlakno
		mov dword [Ptrs7 + 16],ebx		; -> delka vystupu pro 7. vlakno
		mov dword [Ptrs8 + 16],ebx		; -> delka vystupu pro 8. vlakno

        mov ecx, [ebp+8]				; ukazatel na M ->
       	mov dword [Ptrs1 + 0],ecx		; -> ukazatel na M pro 1. vlakno
        shl ebx,3						; x8 pro dvojitou presnost
        add ecx,ebx						; posun na prvniho osminu radku matice M
        mov dword [Ptrs2 + 0],ecx		; -> ukazatel na M pro 2. vlakno
        add ecx,ebx						; posun na druhoy osminu radku matice M
        mov dword [Ptrs3 + 0],ecx		; -> ukazatel na M pro 3. vlakno
        add ecx,ebx						; posun na treti osminu radku matice M
        mov dword [Ptrs4 + 0],ecx		; -> ukazatel na M pro 4. vlakno
        add ecx,ebx						; posun na ctvrtou osminu radku matice M
        mov dword [Ptrs5 + 0],ecx		; -> ukazatel na M pro 5. vlakno
        add ecx,ebx						; posun na patou osminu radku matice M
        mov dword [Ptrs6 + 0],ecx		; -> ukazatel na M pro 6. vlakno
        add ecx,ebx						; posun na sestou osminu radku matice M
        mov dword [Ptrs7 + 0],ecx		; -> ukazatel na M pro 7. vlakno
        add ecx,ebx						; posun na sedmou osminu radku matice M
        mov dword [Ptrs8 + 0],ecx		; -> ukazatel na M pro 8. vlakno

		mov eax, [ebp+16]				; ukazatel na y ->
		mov dword [Ptrs1 + 8],eax       ; -> ukazatel na y pro 1. vlakno
		add eax,ebx                     ; posun na prvni osminu vektoru y
		mov dword [Ptrs2 + 8],eax		; -> ukazatel na y pro 2. vlakno
		add eax,ebx                     ; posun na druhou osminu vektoru y
		mov dword [Ptrs3 + 8],eax		; -> ukazatel na y pro 3. vlakno
		add eax,ebx                     ; posun na treti osminu vektoru y
		mov dword [Ptrs4 + 8],eax		; -> ukazatel na y pro 4. vlakno
		add eax,ebx                     ; posun na ctvrtou osminu vektoru y
		mov dword [Ptrs5 + 8],eax		; -> ukazatel na y pro 5. vlakno
		add eax,ebx                     ; posun na patou osminu vektoru y
		mov dword [Ptrs6 + 8],eax		; -> ukazatel na y pro 6. vlakno
		add eax,ebx                     ; posun na sestou osminu vektoru y
		mov dword [Ptrs7 + 8],eax		; -> ukazatel na y pro 7. vlakno
		add eax,ebx                     ; posun na sedmou osminu vektoru y
		mov dword [Ptrs8 + 8],eax		; -> ukazatel na y pro 8. vlakno

		mov dword [Ptrs1 + 20],8		; pocet vlaken
		mov dword [Ptrs2 + 20],8		; pocet vlaken
		mov dword [Ptrs3 + 20],8		; pocet vlaken
		mov dword [Ptrs4 + 20],8		; pocet vlaken
		mov dword [Ptrs5 + 20],8		; pocet vlaken
		mov dword [Ptrs6 + 20],8		; pocet vlaken
		mov dword [Ptrs7 + 20],8		; pocet vlaken
		mov dword [Ptrs8 + 20],8		; pocet vlaken

		mov byte [Ptrs1 + 21],0		; semafor pro 1. vlakno
		mov byte [Ptrs2 + 21],0		; semafor pro 2. vlakno
		mov byte [Ptrs3 + 21],0		; semafor pro 3. vlakno
		mov byte [Ptrs4 + 21],0		; semafor pro 4. vlakno
		mov byte [Ptrs5 + 21],0		; semafor pro 5. vlakno
		mov byte [Ptrs6 + 21],0		; semafor pro 6. vlakno
		mov byte [Ptrs7 + 21],0		; semafor pro 7. vlakno
		mov byte [Ptrs8 + 21],0		; semafor pro 8. vlakno

       	push dword NULL
		push dword 0
		push dword Ptrs1
		push dword vxm_sse_ptrs_dp
		push dword 0
		push dword 0
		call [CreateThread]

		push dword NULL
		push dword 0
		push dword Ptrs2
		push dword vxm_sse_ptrs_dp
		push dword 0
		push dword 0
		call [CreateThread]

		push dword NULL
		push dword 0
		push dword Ptrs3
		push dword vxm_sse_ptrs_dp
		push dword 0
		push dword 0
		call [CreateThread]

       	push dword NULL
		push dword 0
		push dword Ptrs4
		push dword vxm_sse_ptrs_dp
		push dword 0
		push dword 0
		call [CreateThread]

		push dword NULL
		push dword 0
		push dword Ptrs5
		push dword vxm_sse_ptrs_dp
		push dword 0
		push dword 0
		call [CreateThread]

		push dword NULL
		push dword 0
		push dword Ptrs6
		push dword vxm_sse_ptrs_dp
		push dword 0
		push dword 0
		call [CreateThread]

		push dword NULL
		push dword 0
		push dword Ptrs7
		push dword vxm_sse_ptrs_dp
		push dword 0
		push dword 0
		call [CreateThread]

       	push dword Ptrs8
      	call vxm_sse_ptrs_dp

		.wait_for_thr1:
			cmp byte [Ptrs1 + 21],1
	        jnz .wait_for_thr1
   		.wait_for_thr2:
			cmp byte [Ptrs2 + 21],1
	        jnz .wait_for_thr2
   		.wait_for_thr3:
			cmp byte [Ptrs3 + 21],1
	        jnz .wait_for_thr3
   		.wait_for_thr4:
			cmp byte [Ptrs4 + 21],1
	        jnz .wait_for_thr4
   		.wait_for_thr5:
			cmp byte [Ptrs5 + 21],1
	        jnz .wait_for_thr5
   		.wait_for_thr6:
			cmp byte [Ptrs6 + 21],1
	        jnz .wait_for_thr6
 		.wait_for_thr7:
			cmp byte [Ptrs7 + 21],1
	        jnz .wait_for_thr7

		mov dword esp, ebp
       	pop dword ebp
ret 20



vxm_x6_x87_sp:
		push dword ebp
       	mov dword ebp,esp

		mov eax, [ebp+12]				; ukazatel na x ->
		mov dword [Ptrs1 + 4],eax		; -> ukazatel na x pro 1. vlakno
		mov dword [Ptrs2 + 4],eax		; -> ukazatel na x pro 2. vlakno
  		mov dword [Ptrs3 + 4],eax		; -> ukazatel na x pro 3. vlakno
		mov dword [Ptrs4 + 4],eax		; -> ukazatel na x pro 4. vlakno
		mov dword [Ptrs5 + 4],eax		; -> ukazatel na x pro 5. vlakno
		mov dword [Ptrs6 + 4],eax		; -> ukazatel na x pro 6. vlakno

		mov eax, [ebp+20]				; delka vstupu ->
		mov dword [Ptrs1 + 12],eax		; -> delka vstupu pro 1. vlakno
		mov dword [Ptrs2 + 12],eax		; -> delka vstupu pro 2. vlakno
		mov dword [Ptrs3 + 12],eax		; -> delka vstupu pro 3. vlakno
		mov dword [Ptrs4 + 12],eax		; -> delka vstupu pro 4. vlakno
		mov dword [Ptrs5 + 12],eax		; -> delka vstupu pro 5. vlakno
		mov dword [Ptrs6 + 12],eax		; -> delka vstupu pro 6. vlakno

		mov eax, [ebp+24]				; delka vystupu ->
        xor edx,edx
        mov ebx,6
        div ebx							; pro 6 vlaken (delka vystupu)/6
		mov ebx,eax
		mov dword [Ptrs1 + 16],ebx		; -> delka vystupu pro 1. vlakno
		mov dword [Ptrs2 + 16],ebx 		; -> delka vystupu pro 2. vlakno
		mov dword [Ptrs3 + 16],ebx		; -> delka vystupu pro 3. vlakno
		mov dword [Ptrs4 + 16],ebx 		; -> delka vystupu pro 4. vlakno
		mov dword [Ptrs5 + 16],ebx		; -> delka vystupu pro 5. vlakno
		mov dword [Ptrs6 + 16],ebx		; -> delka vystupu pro 6. vlakno


        mov ecx, [ebp+8]				; ukazatel na M ->
       	mov dword [Ptrs1 + 0],ecx		; -> ukazatel na M pro 1. vlakno
        shl ebx,2						; x4 pro jednoduchou presnost
        add ecx,ebx						; posun na prvniho osminu radku matice M
        mov dword [Ptrs2 + 0],ecx		; -> ukazatel na M pro 2. vlakno
        add ecx,ebx						; posun na druhoy osminu radku matice M
        mov dword [Ptrs3 + 0],ecx		; -> ukazatel na M pro 3. vlakno
        add ecx,ebx						; posun na treti osminu radku matice M
        mov dword [Ptrs4 + 0],ecx		; -> ukazatel na M pro 4. vlakno
        add ecx,ebx						; posun na ctvrtou osminu radku matice M
        mov dword [Ptrs5 + 0],ecx		; -> ukazatel na M pro 5. vlakno
        add ecx,ebx						; posun na patou osminu radku matice M
        mov dword [Ptrs6 + 0],ecx		; -> ukazatel na M pro 6. vlakno


		mov eax, [ebp+16]				; ukazatel na y ->
		mov dword [Ptrs1 + 8],eax       ; -> ukazatel na y pro 1. vlakno
		add eax,ebx                     ; posun na prvni osminu vektoru y
		mov dword [Ptrs2 + 8],eax		; -> ukazatel na y pro 2. vlakno
		add eax,ebx                     ; posun na druhou osminu vektoru y
		mov dword [Ptrs3 + 8],eax		; -> ukazatel na y pro 3. vlakno
		add eax,ebx                     ; posun na treti osminu vektoru y
		mov dword [Ptrs4 + 8],eax		; -> ukazatel na y pro 4. vlakno
		add eax,ebx                     ; posun na ctvrtou osminu vektoru y
		mov dword [Ptrs5 + 8],eax		; -> ukazatel na y pro 5. vlakno
		add eax,ebx                     ; posun na patou osminu vektoru y
		mov dword [Ptrs6 + 8],eax		; -> ukazatel na y pro 6. vlakno


		mov dword [Ptrs1 + 20],6		; pocet vlaken
		mov dword [Ptrs2 + 20],6		; pocet vlaken
		mov dword [Ptrs3 + 20],6		; pocet vlaken
		mov dword [Ptrs4 + 20],6		; pocet vlaken
		mov dword [Ptrs5 + 20],6		; pocet vlaken
		mov dword [Ptrs6 + 20],6		; pocet vlaken


		mov byte [Ptrs1 + 21],0		; semafor pro 1. vlakno
		mov byte [Ptrs2 + 21],0		; semafor pro 2. vlakno
		mov byte [Ptrs3 + 21],0		; semafor pro 3. vlakno
		mov byte [Ptrs4 + 21],0		; semafor pro 4. vlakno
		mov byte [Ptrs5 + 21],0		; semafor pro 5. vlakno
		mov byte [Ptrs6 + 21],0		; semafor pro 6. vlakno


       	push dword NULL
		push dword 0
		push dword Ptrs1
		push dword vxm_x87_ptrs_sp
		push dword 0
		push dword 0
		call [CreateThread]

		push dword NULL
		push dword 0
		push dword Ptrs2
		push dword vxm_x87_ptrs_sp
		push dword 0
		push dword 0
		call [CreateThread]

		push dword NULL
		push dword 0
		push dword Ptrs3
		push dword vxm_x87_ptrs_sp
		push dword 0
		push dword 0
		call [CreateThread]

       	push dword NULL
		push dword 0
		push dword Ptrs4
		push dword vxm_x87_ptrs_sp
		push dword 0
		push dword 0
		call [CreateThread]

		push dword NULL
		push dword 0
		push dword Ptrs5
		push dword vxm_x87_ptrs_sp
		push dword 0
		push dword 0
		call [CreateThread]


       	push dword Ptrs6
      	call vxm_x87_ptrs_sp

		.wait_for_thr1:
			cmp byte [Ptrs1 + 21],1
	        jnz .wait_for_thr1
   		.wait_for_thr2:
			cmp byte [Ptrs2 + 21],1
	        jnz .wait_for_thr2
   		.wait_for_thr3:
			cmp byte [Ptrs3 + 21],1
	        jnz .wait_for_thr3
   		.wait_for_thr4:
			cmp byte [Ptrs4 + 21],1
	        jnz .wait_for_thr4
   		.wait_for_thr5:
			cmp byte [Ptrs5 + 21],1
	        jnz .wait_for_thr5

		mov dword esp, ebp
       	pop dword ebp
ret 20

vxm_x6_x87_dp:
		push dword ebp
       	mov dword ebp,esp

		mov eax, [ebp+12]				; ukazatel na x ->
		mov dword [Ptrs1 + 4],eax		; -> ukazatel na x pro 1. vlakno
		mov dword [Ptrs2 + 4],eax		; -> ukazatel na x pro 2. vlakno
  		mov dword [Ptrs3 + 4],eax		; -> ukazatel na x pro 3. vlakno
		mov dword [Ptrs4 + 4],eax		; -> ukazatel na x pro 4. vlakno
		mov dword [Ptrs5 + 4],eax		; -> ukazatel na x pro 5. vlakno
		mov dword [Ptrs6 + 4],eax		; -> ukazatel na x pro 6. vlakno

		mov eax, [ebp+20]				; delka vstupu ->
		mov dword [Ptrs1 + 12],eax		; -> delka vstupu pro 1. vlakno
		mov dword [Ptrs2 + 12],eax		; -> delka vstupu pro 2. vlakno
		mov dword [Ptrs3 + 12],eax		; -> delka vstupu pro 3. vlakno
		mov dword [Ptrs4 + 12],eax		; -> delka vstupu pro 4. vlakno
		mov dword [Ptrs5 + 12],eax		; -> delka vstupu pro 5. vlakno
		mov dword [Ptrs6 + 12],eax		; -> delka vstupu pro 6. vlakno

		mov eax, [ebp+24]				; delka vystupu ->
        xor edx,edx
        mov ebx,6
        div ebx							; pro 6 vlaken (delka vystupu)/6
		mov ebx,eax
		mov dword [Ptrs1 + 16],ebx		; -> delka vystupu pro 1. vlakno
		mov dword [Ptrs2 + 16],ebx 		; -> delka vystupu pro 2. vlakno
		mov dword [Ptrs3 + 16],ebx		; -> delka vystupu pro 3. vlakno
		mov dword [Ptrs4 + 16],ebx 		; -> delka vystupu pro 4. vlakno
		mov dword [Ptrs5 + 16],ebx		; -> delka vystupu pro 5. vlakno
		mov dword [Ptrs6 + 16],ebx		; -> delka vystupu pro 6. vlakno


        mov ecx, [ebp+8]				; ukazatel na M ->
       	mov dword [Ptrs1 + 0],ecx		; -> ukazatel na M pro 1. vlakno
        shl ebx,3						; x8 pro dvojitou presnost
        add ecx,ebx						; posun na prvniho osminu radku matice M
        mov dword [Ptrs2 + 0],ecx		; -> ukazatel na M pro 2. vlakno
        add ecx,ebx						; posun na druhoy osminu radku matice M
        mov dword [Ptrs3 + 0],ecx		; -> ukazatel na M pro 3. vlakno
        add ecx,ebx						; posun na treti osminu radku matice M
        mov dword [Ptrs4 + 0],ecx		; -> ukazatel na M pro 4. vlakno
        add ecx,ebx						; posun na ctvrtou osminu radku matice M
        mov dword [Ptrs5 + 0],ecx		; -> ukazatel na M pro 5. vlakno
        add ecx,ebx						; posun na patou osminu radku matice M
        mov dword [Ptrs6 + 0],ecx		; -> ukazatel na M pro 6. vlakno


		mov eax, [ebp+16]				; ukazatel na y ->
		mov dword [Ptrs1 + 8],eax       ; -> ukazatel na y pro 1. vlakno
		add eax,ebx                     ; posun na prvni osminu vektoru y
		mov dword [Ptrs2 + 8],eax		; -> ukazatel na y pro 2. vlakno
		add eax,ebx                     ; posun na druhou osminu vektoru y
		mov dword [Ptrs3 + 8],eax		; -> ukazatel na y pro 3. vlakno
		add eax,ebx                     ; posun na treti osminu vektoru y
		mov dword [Ptrs4 + 8],eax		; -> ukazatel na y pro 4. vlakno
		add eax,ebx                     ; posun na ctvrtou osminu vektoru y
		mov dword [Ptrs5 + 8],eax		; -> ukazatel na y pro 5. vlakno
		add eax,ebx                     ; posun na patou osminu vektoru y
		mov dword [Ptrs6 + 8],eax		; -> ukazatel na y pro 6. vlakno


		mov dword [Ptrs1 + 20],6		; pocet vlaken
		mov dword [Ptrs2 + 20],6		; pocet vlaken
		mov dword [Ptrs3 + 20],6		; pocet vlaken
		mov dword [Ptrs4 + 20],6		; pocet vlaken
		mov dword [Ptrs5 + 20],6		; pocet vlaken
		mov dword [Ptrs6 + 20],6		; pocet vlaken


		mov byte [Ptrs1 + 21],0		; semafor pro 1. vlakno
		mov byte [Ptrs2 + 21],0		; semafor pro 2. vlakno
		mov byte [Ptrs3 + 21],0		; semafor pro 3. vlakno
		mov byte [Ptrs4 + 21],0		; semafor pro 4. vlakno
		mov byte [Ptrs5 + 21],0		; semafor pro 5. vlakno
		mov byte [Ptrs6 + 21],0		; semafor pro 6. vlakno


       	push dword NULL
		push dword 0
		push dword Ptrs1
		push dword vxm_x87_ptrs_dp
		push dword 0
		push dword 0
		call [CreateThread]

		push dword NULL
		push dword 0
		push dword Ptrs2
		push dword vxm_x87_ptrs_dp
		push dword 0
		push dword 0
		call [CreateThread]

		push dword NULL
		push dword 0
		push dword Ptrs3
		push dword vxm_x87_ptrs_dp
		push dword 0
		push dword 0
		call [CreateThread]

       	push dword NULL
		push dword 0
		push dword Ptrs4
		push dword vxm_x87_ptrs_dp
		push dword 0
		push dword 0
		call [CreateThread]

		push dword NULL
		push dword 0
		push dword Ptrs5
		push dword vxm_x87_ptrs_dp
		push dword 0
		push dword 0
		call [CreateThread]


       	push dword Ptrs6
      	call vxm_x87_ptrs_dp

		.wait_for_thr1:
			cmp byte [Ptrs1 + 21],1
	        jnz .wait_for_thr1
   		.wait_for_thr2:
			cmp byte [Ptrs2 + 21],1
	        jnz .wait_for_thr2
   		.wait_for_thr3:
			cmp byte [Ptrs3 + 21],1
	        jnz .wait_for_thr3
   		.wait_for_thr4:
			cmp byte [Ptrs4 + 21],1
	        jnz .wait_for_thr4
   		.wait_for_thr5:
			cmp byte [Ptrs5 + 21],1
	        jnz .wait_for_thr5

		mov dword esp, ebp
       	pop dword ebp
ret 20

vxm_x3_sse_sp:
		push dword ebp
       	mov dword ebp,esp

		mov eax, [ebp+12]				; ukazatel na x ->
		mov dword [Ptrs1 + 4],eax		; -> ukazatel na x pro 1. vlakno
		mov dword [Ptrs2 + 4],eax		; -> ukazatel na x pro 2. vlakno
  		mov dword [Ptrs3 + 4],eax		; -> ukazatel na x pro 3. vlakno

		mov eax, [ebp+20]				; delka vstupu ->
		mov dword [Ptrs1 + 12],eax		; -> delka vstupu pro 1. vlakno
		mov dword [Ptrs2 + 12],eax		; -> delka vstupu pro 2. vlakno
		mov dword [Ptrs3 + 12],eax		; -> delka vstupu pro 3. vlakno

		mov eax, [ebp+24]				; delka vystupu ->
        xor edx,edx
        mov ebx,3
        div ebx							; pro 3 vlaken (delka vystupu)/3
		mov ebx,eax
		mov dword [Ptrs1 + 16],ebx		; -> delka vystupu pro 1. vlakno
		mov dword [Ptrs2 + 16],ebx 		; -> delka vystupu pro 2. vlakno
		mov dword [Ptrs3 + 16],ebx		; -> delka vystupu pro 3. vlakno

        mov ecx, [ebp+8]				; ukazatel na M ->
       	mov dword [Ptrs1 + 0],ecx		; -> ukazatel na M pro 1. vlakno
        shl ebx,2						; x4 pro jednoduchou presnost
        add ecx,ebx						; posun na prvniho osminu radku matice M
        mov dword [Ptrs2 + 0],ecx		; -> ukazatel na M pro 2. vlakno
        add ecx,ebx						; posun na druhoy osminu radku matice M
        mov dword [Ptrs3 + 0],ecx		; -> ukazatel na M pro 3. vlakno

		mov eax, [ebp+16]				; ukazatel na y ->
		mov dword [Ptrs1 + 8],eax       ; -> ukazatel na y pro 1. vlakno
		add eax,ebx                     ; posun na prvni osminu vektoru y
		mov dword [Ptrs2 + 8],eax		; -> ukazatel na y pro 2. vlakno
		add eax,ebx                     ; posun na druhou osminu vektoru y
		mov dword [Ptrs3 + 8],eax		; -> ukazatel na y pro 3. vlakno

		mov dword [Ptrs1 + 20],3		; pocet vlaken
		mov dword [Ptrs2 + 20],3		; pocet vlaken
		mov dword [Ptrs3 + 20],3		; pocet vlaken

		mov byte [Ptrs1 + 21],0		; semafor pro 1. vlakno
		mov byte [Ptrs2 + 21],0		; semafor pro 2. vlakno
		mov byte [Ptrs3 + 21],0		; semafor pro 3. vlakno

       	push dword NULL
		push dword 0
		push dword Ptrs1
		push dword vxm_sse_ptrs_sp
		push dword 0
		push dword 0
		call [CreateThread]

		push dword NULL
		push dword 0
		push dword Ptrs2
		push dword vxm_sse_ptrs_sp
		push dword 0
		push dword 0
		call [CreateThread]

       	push dword Ptrs3
      	call vxm_sse_ptrs_sp

		.wait_for_thr1:
			cmp byte [Ptrs1 + 21],1
	        jnz .wait_for_thr1
   		.wait_for_thr2:
			cmp byte [Ptrs2 + 21],1
	        jnz .wait_for_thr2


		mov dword esp, ebp
       	pop dword ebp
ret 20


vxm_x6_sse_sp:
		push dword ebp
       	mov dword ebp,esp

		mov eax, [ebp+12]				; ukazatel na x ->
		mov dword [Ptrs1 + 4],eax		; -> ukazatel na x pro 1. vlakno
		mov dword [Ptrs2 + 4],eax		; -> ukazatel na x pro 2. vlakno
  		mov dword [Ptrs3 + 4],eax		; -> ukazatel na x pro 3. vlakno
		mov dword [Ptrs4 + 4],eax		; -> ukazatel na x pro 4. vlakno
		mov dword [Ptrs5 + 4],eax		; -> ukazatel na x pro 5. vlakno
		mov dword [Ptrs6 + 4],eax		; -> ukazatel na x pro 6. vlakno

		mov eax, [ebp+20]				; delka vstupu ->
		mov dword [Ptrs1 + 12],eax		; -> delka vstupu pro 1. vlakno
		mov dword [Ptrs2 + 12],eax		; -> delka vstupu pro 2. vlakno
		mov dword [Ptrs3 + 12],eax		; -> delka vstupu pro 3. vlakno
		mov dword [Ptrs4 + 12],eax		; -> delka vstupu pro 4. vlakno
		mov dword [Ptrs5 + 12],eax		; -> delka vstupu pro 5. vlakno
		mov dword [Ptrs6 + 12],eax		; -> delka vstupu pro 6. vlakno

		mov eax, [ebp+24]				; delka vystupu ->
        xor edx,edx
        mov ebx,6
        div ebx							; pro 6 vlaken (delka vystupu)/6
		mov ebx,eax
		mov dword [Ptrs1 + 16],ebx		; -> delka vystupu pro 1. vlakno
		mov dword [Ptrs2 + 16],ebx 		; -> delka vystupu pro 2. vlakno
		mov dword [Ptrs3 + 16],ebx		; -> delka vystupu pro 3. vlakno
		mov dword [Ptrs4 + 16],ebx 		; -> delka vystupu pro 4. vlakno
		mov dword [Ptrs5 + 16],ebx		; -> delka vystupu pro 5. vlakno
		mov dword [Ptrs6 + 16],ebx		; -> delka vystupu pro 6. vlakno


        mov ecx, [ebp+8]				; ukazatel na M ->
       	mov dword [Ptrs1 + 0],ecx		; -> ukazatel na M pro 1. vlakno
        shl ebx,2						; x4 pro jednoduchou presnost
        add ecx,ebx						; posun na prvniho osminu radku matice M
        mov dword [Ptrs2 + 0],ecx		; -> ukazatel na M pro 2. vlakno
        add ecx,ebx						; posun na druhoy osminu radku matice M
        mov dword [Ptrs3 + 0],ecx		; -> ukazatel na M pro 3. vlakno
        add ecx,ebx						; posun na treti osminu radku matice M
        mov dword [Ptrs4 + 0],ecx		; -> ukazatel na M pro 4. vlakno
        add ecx,ebx						; posun na ctvrtou osminu radku matice M
        mov dword [Ptrs5 + 0],ecx		; -> ukazatel na M pro 5. vlakno
        add ecx,ebx						; posun na patou osminu radku matice M
        mov dword [Ptrs6 + 0],ecx		; -> ukazatel na M pro 6. vlakno


		mov eax, [ebp+16]				; ukazatel na y ->
		mov dword [Ptrs1 + 8],eax       ; -> ukazatel na y pro 1. vlakno
		add eax,ebx                     ; posun na prvni osminu vektoru y
		mov dword [Ptrs2 + 8],eax		; -> ukazatel na y pro 2. vlakno
		add eax,ebx                     ; posun na druhou osminu vektoru y
		mov dword [Ptrs3 + 8],eax		; -> ukazatel na y pro 3. vlakno
		add eax,ebx                     ; posun na treti osminu vektoru y
		mov dword [Ptrs4 + 8],eax		; -> ukazatel na y pro 4. vlakno
		add eax,ebx                     ; posun na ctvrtou osminu vektoru y
		mov dword [Ptrs5 + 8],eax		; -> ukazatel na y pro 5. vlakno
		add eax,ebx                     ; posun na patou osminu vektoru y
		mov dword [Ptrs6 + 8],eax		; -> ukazatel na y pro 6. vlakno


		mov dword [Ptrs1 + 20],6		; pocet vlaken
		mov dword [Ptrs2 + 20],6		; pocet vlaken
		mov dword [Ptrs3 + 20],6		; pocet vlaken
		mov dword [Ptrs4 + 20],6		; pocet vlaken
		mov dword [Ptrs5 + 20],6		; pocet vlaken
		mov dword [Ptrs6 + 20],6		; pocet vlaken


		mov byte [Ptrs1 + 21],0		; semafor pro 1. vlakno
		mov byte [Ptrs2 + 21],0		; semafor pro 2. vlakno
		mov byte [Ptrs3 + 21],0		; semafor pro 3. vlakno
		mov byte [Ptrs4 + 21],0		; semafor pro 4. vlakno
		mov byte [Ptrs5 + 21],0		; semafor pro 5. vlakno
		mov byte [Ptrs6 + 21],0		; semafor pro 6. vlakno


       	push dword NULL
		push dword 0
		push dword Ptrs1
		push dword vxm_sse_ptrs_sp
		push dword 0
		push dword 0
		call [CreateThread]

		push dword NULL
		push dword 0
		push dword Ptrs2
		push dword vxm_sse_ptrs_sp
		push dword 0
		push dword 0
		call [CreateThread]

		push dword NULL
		push dword 0
		push dword Ptrs3
		push dword vxm_sse_ptrs_sp
		push dword 0
		push dword 0
		call [CreateThread]

       	push dword NULL
		push dword 0
		push dword Ptrs4
		push dword vxm_sse_ptrs_sp
		push dword 0
		push dword 0
		call [CreateThread]

		push dword NULL
		push dword 0
		push dword Ptrs5
		push dword vxm_sse_ptrs_sp
		push dword 0
		push dword 0
		call [CreateThread]


       	push dword Ptrs6
      	call vxm_sse_ptrs_sp

		.wait_for_thr1:
			cmp byte [Ptrs1 + 21],1
	        jnz .wait_for_thr1
   		.wait_for_thr2:
			cmp byte [Ptrs2 + 21],1
	        jnz .wait_for_thr2
   		.wait_for_thr3:
			cmp byte [Ptrs3 + 21],1
	        jnz .wait_for_thr3
   		.wait_for_thr4:
			cmp byte [Ptrs4 + 21],1
	        jnz .wait_for_thr4
   		.wait_for_thr5:
			cmp byte [Ptrs5 + 21],1
	        jnz .wait_for_thr5

		mov dword esp, ebp
       	pop dword ebp
ret 20

vxm_x3_sse_dp:
		push dword ebp
       	mov dword ebp,esp

		mov eax, [ebp+12]				; ukazatel na x ->
		mov dword [Ptrs1 + 4],eax		; -> ukazatel na x pro 1. vlakno
		mov dword [Ptrs2 + 4],eax		; -> ukazatel na x pro 2. vlakno
  		mov dword [Ptrs3 + 4],eax		; -> ukazatel na x pro 3. vlakno

		mov eax, [ebp+20]				; delka vstupu ->
		mov dword [Ptrs1 + 12],eax		; -> delka vstupu pro 1. vlakno
		mov dword [Ptrs2 + 12],eax		; -> delka vstupu pro 2. vlakno
		mov dword [Ptrs3 + 12],eax		; -> delka vstupu pro 3. vlakno

		mov eax, [ebp+24]				; delka vystupu ->
        xor edx,edx
        mov ebx,3
        div ebx							; pro 3 vlaken (delka vystupu)/3
		mov ebx,eax
		mov dword [Ptrs1 + 16],ebx		; -> delka vystupu pro 1. vlakno
		mov dword [Ptrs2 + 16],ebx 		; -> delka vystupu pro 2. vlakno
		mov dword [Ptrs3 + 16],ebx		; -> delka vystupu pro 3. vlakno

        mov ecx, [ebp+8]				; ukazatel na M ->
       	mov dword [Ptrs1 + 0],ecx		; -> ukazatel na M pro 1. vlakno
        shl ebx,3						; x8 pro dvojitou presnost
        add ecx,ebx						; posun na prvniho osminu radku matice M
        mov dword [Ptrs2 + 0],ecx		; -> ukazatel na M pro 2. vlakno
        add ecx,ebx						; posun na druhoy osminu radku matice M
        mov dword [Ptrs3 + 0],ecx		; -> ukazatel na M pro 3. vlakno

		mov eax, [ebp+16]				; ukazatel na y ->
		mov dword [Ptrs1 + 8],eax       ; -> ukazatel na y pro 1. vlakno
		add eax,ebx                     ; posun na prvni osminu vektoru y
		mov dword [Ptrs2 + 8],eax		; -> ukazatel na y pro 2. vlakno
		add eax,ebx                     ; posun na druhou osminu vektoru y
		mov dword [Ptrs3 + 8],eax		; -> ukazatel na y pro 3. vlakno

		mov dword [Ptrs1 + 20],3		; pocet vlaken
		mov dword [Ptrs2 + 20],3		; pocet vlaken
		mov dword [Ptrs3 + 20],3		; pocet vlaken

		mov byte [Ptrs1 + 21],0		; semafor pro 1. vlakno
		mov byte [Ptrs2 + 21],0		; semafor pro 2. vlakno
		mov byte [Ptrs3 + 21],0		; semafor pro 3. vlakno

       	push dword NULL
		push dword 0
		push dword Ptrs1
		push dword vxm_sse_ptrs_dp
		push dword 0
		push dword 0
		call [CreateThread]

		push dword NULL
		push dword 0
		push dword Ptrs2
		push dword vxm_sse_ptrs_dp
		push dword 0
		push dword 0
		call [CreateThread]

       	push dword Ptrs3
      	call vxm_sse_ptrs_dp

		.wait_for_thr1:
			cmp byte [Ptrs1 + 21],1
	        jnz .wait_for_thr1
   		.wait_for_thr2:
			cmp byte [Ptrs2 + 21],1
	        jnz .wait_for_thr2

		mov dword esp, ebp
       	pop dword ebp
ret 20


vxm_x6_sse_dp:
		push dword ebp
       	mov dword ebp,esp

		mov eax, [ebp+12]				; ukazatel na x ->
		mov dword [Ptrs1 + 4],eax		; -> ukazatel na x pro 1. vlakno
		mov dword [Ptrs2 + 4],eax		; -> ukazatel na x pro 2. vlakno
  		mov dword [Ptrs3 + 4],eax		; -> ukazatel na x pro 3. vlakno
		mov dword [Ptrs4 + 4],eax		; -> ukazatel na x pro 4. vlakno
		mov dword [Ptrs5 + 4],eax		; -> ukazatel na x pro 5. vlakno
		mov dword [Ptrs6 + 4],eax		; -> ukazatel na x pro 6. vlakno

		mov eax, [ebp+20]				; delka vstupu ->
		mov dword [Ptrs1 + 12],eax		; -> delka vstupu pro 1. vlakno
		mov dword [Ptrs2 + 12],eax		; -> delka vstupu pro 2. vlakno
		mov dword [Ptrs3 + 12],eax		; -> delka vstupu pro 3. vlakno
		mov dword [Ptrs4 + 12],eax		; -> delka vstupu pro 4. vlakno
		mov dword [Ptrs5 + 12],eax		; -> delka vstupu pro 5. vlakno
		mov dword [Ptrs6 + 12],eax		; -> delka vstupu pro 6. vlakno

		mov eax, [ebp+24]				; delka vystupu ->
        xor edx,edx
        mov ebx,6
        div ebx							; pro 6 vlaken (delka vystupu)/6
		mov ebx,eax
		mov dword [Ptrs1 + 16],ebx		; -> delka vystupu pro 1. vlakno
		mov dword [Ptrs2 + 16],ebx 		; -> delka vystupu pro 2. vlakno
		mov dword [Ptrs3 + 16],ebx		; -> delka vystupu pro 3. vlakno
		mov dword [Ptrs4 + 16],ebx 		; -> delka vystupu pro 4. vlakno
		mov dword [Ptrs5 + 16],ebx		; -> delka vystupu pro 5. vlakno
		mov dword [Ptrs6 + 16],ebx		; -> delka vystupu pro 6. vlakno


        mov ecx, [ebp+8]				; ukazatel na M ->
       	mov dword [Ptrs1 + 0],ecx		; -> ukazatel na M pro 1. vlakno
        shl ebx,3						; x8 pro dvojitou presnost
        add ecx,ebx						; posun na prvniho osminu radku matice M
        mov dword [Ptrs2 + 0],ecx		; -> ukazatel na M pro 2. vlakno
        add ecx,ebx						; posun na druhoy osminu radku matice M
        mov dword [Ptrs3 + 0],ecx		; -> ukazatel na M pro 3. vlakno
        add ecx,ebx						; posun na treti osminu radku matice M
        mov dword [Ptrs4 + 0],ecx		; -> ukazatel na M pro 4. vlakno
        add ecx,ebx						; posun na ctvrtou osminu radku matice M
        mov dword [Ptrs5 + 0],ecx		; -> ukazatel na M pro 5. vlakno
        add ecx,ebx						; posun na patou osminu radku matice M
        mov dword [Ptrs6 + 0],ecx		; -> ukazatel na M pro 6. vlakno


		mov eax, [ebp+16]				; ukazatel na y ->
		mov dword [Ptrs1 + 8],eax       ; -> ukazatel na y pro 1. vlakno
		add eax,ebx                     ; posun na prvni osminu vektoru y
		mov dword [Ptrs2 + 8],eax		; -> ukazatel na y pro 2. vlakno
		add eax,ebx                     ; posun na druhou osminu vektoru y
		mov dword [Ptrs3 + 8],eax		; -> ukazatel na y pro 3. vlakno
		add eax,ebx                     ; posun na treti osminu vektoru y
		mov dword [Ptrs4 + 8],eax		; -> ukazatel na y pro 4. vlakno
		add eax,ebx                     ; posun na ctvrtou osminu vektoru y
		mov dword [Ptrs5 + 8],eax		; -> ukazatel na y pro 5. vlakno
		add eax,ebx                     ; posun na patou osminu vektoru y
		mov dword [Ptrs6 + 8],eax		; -> ukazatel na y pro 6. vlakno


		mov dword [Ptrs1 + 20],6		; pocet vlaken
		mov dword [Ptrs2 + 20],6		; pocet vlaken
		mov dword [Ptrs3 + 20],6		; pocet vlaken
		mov dword [Ptrs4 + 20],6		; pocet vlaken
		mov dword [Ptrs5 + 20],6		; pocet vlaken
		mov dword [Ptrs6 + 20],6		; pocet vlaken


		mov byte [Ptrs1 + 21],0		; semafor pro 1. vlakno
		mov byte [Ptrs2 + 21],0		; semafor pro 2. vlakno
		mov byte [Ptrs3 + 21],0		; semafor pro 3. vlakno
		mov byte [Ptrs4 + 21],0		; semafor pro 4. vlakno
		mov byte [Ptrs5 + 21],0		; semafor pro 5. vlakno
		mov byte [Ptrs6 + 21],0		; semafor pro 6. vlakno


       	push dword NULL
		push dword 0
		push dword Ptrs1
		push dword vxm_sse_ptrs_dp
		push dword 0
		push dword 0
		call [CreateThread]

		push dword NULL
		push dword 0
		push dword Ptrs2
		push dword vxm_sse_ptrs_dp
		push dword 0
		push dword 0
		call [CreateThread]

		push dword NULL
		push dword 0
		push dword Ptrs3
		push dword vxm_sse_ptrs_dp
		push dword 0
		push dword 0
		call [CreateThread]

       	push dword NULL
		push dword 0
		push dword Ptrs4
		push dword vxm_sse_ptrs_dp
		push dword 0
		push dword 0
		call [CreateThread]

		push dword NULL
		push dword 0
		push dword Ptrs5
		push dword vxm_sse_ptrs_dp
		push dword 0
		push dword 0
		call [CreateThread]


       	push dword Ptrs6
      	call vxm_sse_ptrs_dp

		.wait_for_thr1:
			cmp byte [Ptrs1 + 21],1
	        jnz .wait_for_thr1
   		.wait_for_thr2:
			cmp byte [Ptrs2 + 21],1
	        jnz .wait_for_thr2
   		.wait_for_thr3:
			cmp byte [Ptrs3 + 21],1
	        jnz .wait_for_thr3
   		.wait_for_thr4:
			cmp byte [Ptrs4 + 21],1
	        jnz .wait_for_thr4
   		.wait_for_thr5:
			cmp byte [Ptrs5 + 21],1
	        jnz .wait_for_thr5

		mov dword esp, ebp
       	pop dword ebp
ret 20

vxm_x3_avx_sp:
		push dword ebp
       	mov dword ebp,esp

		mov eax, [ebp+12]				; ukazatel na x ->
		mov dword [Ptrs1 + 4],eax		; -> ukazatel na x pro 1. vlakno
		mov dword [Ptrs2 + 4],eax		; -> ukazatel na x pro 2. vlakno
  		mov dword [Ptrs3 + 4],eax		; -> ukazatel na x pro 3. vlakno

		mov eax, [ebp+20]				; delka vstupu ->
		mov dword [Ptrs1 + 12],eax		; -> delka vstupu pro 1. vlakno
		mov dword [Ptrs2 + 12],eax		; -> delka vstupu pro 2. vlakno
		mov dword [Ptrs3 + 12],eax		; -> delka vstupu pro 3. vlakno

		mov eax, [ebp+24]				; delka vystupu ->
        xor edx,edx
        mov ebx,3
        div ebx							; pro 3 vlaken (delka vystupu)/3
		mov ebx,eax
		mov dword [Ptrs1 + 16],ebx		; -> delka vystupu pro 1. vlakno
		mov dword [Ptrs2 + 16],ebx 		; -> delka vystupu pro 2. vlakno
		mov dword [Ptrs3 + 16],ebx		; -> delka vystupu pro 3. vlakno

        mov ecx, [ebp+8]				; ukazatel na M ->
       	mov dword [Ptrs1 + 0],ecx		; -> ukazatel na M pro 1. vlakno
        shl ebx,2						; x4 pro jednoduchou presnost
        add ecx,ebx						; posun na prvniho osminu radku matice M
        mov dword [Ptrs2 + 0],ecx		; -> ukazatel na M pro 2. vlakno
        add ecx,ebx						; posun na druhoy osminu radku matice M
        mov dword [Ptrs3 + 0],ecx		; -> ukazatel na M pro 3. vlakno

		mov eax, [ebp+16]				; ukazatel na y ->
		mov dword [Ptrs1 + 8],eax       ; -> ukazatel na y pro 1. vlakno
		add eax,ebx                     ; posun na prvni osminu vektoru y
		mov dword [Ptrs2 + 8],eax		; -> ukazatel na y pro 2. vlakno
		add eax,ebx                     ; posun na druhou osminu vektoru y
		mov dword [Ptrs3 + 8],eax		; -> ukazatel na y pro 3. vlakno

		mov dword [Ptrs1 + 20],3		; pocet vlaken
		mov dword [Ptrs2 + 20],3		; pocet vlaken
		mov dword [Ptrs3 + 20],3		; pocet vlaken

		mov byte [Ptrs1 + 21],0		; semafor pro 1. vlakno
		mov byte [Ptrs2 + 21],0		; semafor pro 2. vlakno
		mov byte [Ptrs3 + 21],0		; semafor pro 3. vlakno

       	push dword NULL
		push dword 0
		push dword Ptrs1
		push dword vxm_avx_ptrs_sp
		push dword 0
		push dword 0
		call [CreateThread]

		push dword NULL
		push dword 0
		push dword Ptrs2
		push dword vxm_avx_ptrs_sp
		push dword 0
		push dword 0
		call [CreateThread]

       	push dword Ptrs3
      	call vxm_avx_ptrs_sp

		.wait_for_thr1:
			cmp byte [Ptrs1 + 21],1
	        jnz .wait_for_thr1
   		.wait_for_thr2:
			cmp byte [Ptrs2 + 21],1
	        jnz .wait_for_thr2


		mov dword esp, ebp
       	pop dword ebp
ret 20


vxm_x6_avx_sp:
		push dword ebp
       	mov dword ebp,esp

		mov eax, [ebp+12]				; ukazatel na x ->
		mov dword [Ptrs1 + 4],eax		; -> ukazatel na x pro 1. vlakno
		mov dword [Ptrs2 + 4],eax		; -> ukazatel na x pro 2. vlakno
  		mov dword [Ptrs3 + 4],eax		; -> ukazatel na x pro 3. vlakno
		mov dword [Ptrs4 + 4],eax		; -> ukazatel na x pro 4. vlakno
		mov dword [Ptrs5 + 4],eax		; -> ukazatel na x pro 5. vlakno
		mov dword [Ptrs6 + 4],eax		; -> ukazatel na x pro 6. vlakno

		mov eax, [ebp+20]				; delka vstupu ->
		mov dword [Ptrs1 + 12],eax		; -> delka vstupu pro 1. vlakno
		mov dword [Ptrs2 + 12],eax		; -> delka vstupu pro 2. vlakno
		mov dword [Ptrs3 + 12],eax		; -> delka vstupu pro 3. vlakno
		mov dword [Ptrs4 + 12],eax		; -> delka vstupu pro 4. vlakno
		mov dword [Ptrs5 + 12],eax		; -> delka vstupu pro 5. vlakno
		mov dword [Ptrs6 + 12],eax		; -> delka vstupu pro 6. vlakno

		mov eax, [ebp+24]				; delka vystupu ->
        xor edx,edx
        mov ebx,6
        div ebx							; pro 6 vlaken (delka vystupu)/6
		mov ebx,eax
		mov dword [Ptrs1 + 16],ebx		; -> delka vystupu pro 1. vlakno
		mov dword [Ptrs2 + 16],ebx 		; -> delka vystupu pro 2. vlakno
		mov dword [Ptrs3 + 16],ebx		; -> delka vystupu pro 3. vlakno
		mov dword [Ptrs4 + 16],ebx 		; -> delka vystupu pro 4. vlakno
		mov dword [Ptrs5 + 16],ebx		; -> delka vystupu pro 5. vlakno
		mov dword [Ptrs6 + 16],ebx		; -> delka vystupu pro 6. vlakno


        mov ecx, [ebp+8]				; ukazatel na M ->
       	mov dword [Ptrs1 + 0],ecx		; -> ukazatel na M pro 1. vlakno
        shl ebx,2						; x4 pro jednoduchou presnost
        add ecx,ebx						; posun na prvniho osminu radku matice M
        mov dword [Ptrs2 + 0],ecx		; -> ukazatel na M pro 2. vlakno
        add ecx,ebx						; posun na druhoy osminu radku matice M
        mov dword [Ptrs3 + 0],ecx		; -> ukazatel na M pro 3. vlakno
        add ecx,ebx						; posun na treti osminu radku matice M
        mov dword [Ptrs4 + 0],ecx		; -> ukazatel na M pro 4. vlakno
        add ecx,ebx						; posun na ctvrtou osminu radku matice M
        mov dword [Ptrs5 + 0],ecx		; -> ukazatel na M pro 5. vlakno
        add ecx,ebx						; posun na patou osminu radku matice M
        mov dword [Ptrs6 + 0],ecx		; -> ukazatel na M pro 6. vlakno


		mov eax, [ebp+16]				; ukazatel na y ->
		mov dword [Ptrs1 + 8],eax       ; -> ukazatel na y pro 1. vlakno
		add eax,ebx                     ; posun na prvni osminu vektoru y
		mov dword [Ptrs2 + 8],eax		; -> ukazatel na y pro 2. vlakno
		add eax,ebx                     ; posun na druhou osminu vektoru y
		mov dword [Ptrs3 + 8],eax		; -> ukazatel na y pro 3. vlakno
		add eax,ebx                     ; posun na treti osminu vektoru y
		mov dword [Ptrs4 + 8],eax		; -> ukazatel na y pro 4. vlakno
		add eax,ebx                     ; posun na ctvrtou osminu vektoru y
		mov dword [Ptrs5 + 8],eax		; -> ukazatel na y pro 5. vlakno
		add eax,ebx                     ; posun na patou osminu vektoru y
		mov dword [Ptrs6 + 8],eax		; -> ukazatel na y pro 6. vlakno


		mov dword [Ptrs1 + 20],6		; pocet vlaken
		mov dword [Ptrs2 + 20],6		; pocet vlaken
		mov dword [Ptrs3 + 20],6		; pocet vlaken
		mov dword [Ptrs4 + 20],6		; pocet vlaken
		mov dword [Ptrs5 + 20],6		; pocet vlaken
		mov dword [Ptrs6 + 20],6		; pocet vlaken


		mov byte [Ptrs1 + 21],0		; semafor pro 1. vlakno
		mov byte [Ptrs2 + 21],0		; semafor pro 2. vlakno
		mov byte [Ptrs3 + 21],0		; semafor pro 3. vlakno
		mov byte [Ptrs4 + 21],0		; semafor pro 4. vlakno
		mov byte [Ptrs5 + 21],0		; semafor pro 5. vlakno
		mov byte [Ptrs6 + 21],0		; semafor pro 6. vlakno


       	push dword NULL
		push dword 0
		push dword Ptrs1
		push dword vxm_avx_ptrs_sp
		push dword 0
		push dword 0
		call [CreateThread]

		push dword NULL
		push dword 0
		push dword Ptrs2
		push dword vxm_avx_ptrs_sp
		push dword 0
		push dword 0
		call [CreateThread]

		push dword NULL
		push dword 0
		push dword Ptrs3
		push dword vxm_avx_ptrs_sp
		push dword 0
		push dword 0
		call [CreateThread]

       	push dword NULL
		push dword 0
		push dword Ptrs4
		push dword vxm_avx_ptrs_sp
		push dword 0
		push dword 0
		call [CreateThread]

		push dword NULL
		push dword 0
		push dword Ptrs5
		push dword vxm_avx_ptrs_sp
		push dword 0
		push dword 0
		call [CreateThread]


       	push dword Ptrs6
      	call vxm_avx_ptrs_sp

		.wait_for_thr1:
			cmp byte [Ptrs1 + 21],1
	        jnz .wait_for_thr1
   		.wait_for_thr2:
			cmp byte [Ptrs2 + 21],1
	        jnz .wait_for_thr2
   		.wait_for_thr3:
			cmp byte [Ptrs3 + 21],1
	        jnz .wait_for_thr3
   		.wait_for_thr4:
			cmp byte [Ptrs4 + 21],1
	        jnz .wait_for_thr4
   		.wait_for_thr5:
			cmp byte [Ptrs5 + 21],1
	        jnz .wait_for_thr5

		mov dword esp, ebp
       	pop dword ebp
ret 20

vxm_x3_avx_dp:
		push dword ebp
       	mov dword ebp,esp

		mov eax, [ebp+12]				; ukazatel na x ->
		mov dword [Ptrs1 + 4],eax		; -> ukazatel na x pro 1. vlakno
		mov dword [Ptrs2 + 4],eax		; -> ukazatel na x pro 2. vlakno
  		mov dword [Ptrs3 + 4],eax		; -> ukazatel na x pro 3. vlakno

		mov eax, [ebp+20]				; delka vstupu ->
		mov dword [Ptrs1 + 12],eax		; -> delka vstupu pro 1. vlakno
		mov dword [Ptrs2 + 12],eax		; -> delka vstupu pro 2. vlakno
		mov dword [Ptrs3 + 12],eax		; -> delka vstupu pro 3. vlakno

		mov eax, [ebp+24]				; delka vystupu ->
        xor edx,edx
        mov ebx,3
        div ebx							; pro 3 vlaken (delka vystupu)/3
		mov ebx,eax
		mov dword [Ptrs1 + 16],ebx		; -> delka vystupu pro 1. vlakno
		mov dword [Ptrs2 + 16],ebx 		; -> delka vystupu pro 2. vlakno
		mov dword [Ptrs3 + 16],ebx		; -> delka vystupu pro 3. vlakno

        mov ecx, [ebp+8]				; ukazatel na M ->
       	mov dword [Ptrs1 + 0],ecx		; -> ukazatel na M pro 1. vlakno
        shl ebx,3						; x8 pro dvojitou presnost
        add ecx,ebx						; posun na prvniho osminu radku matice M
        mov dword [Ptrs2 + 0],ecx		; -> ukazatel na M pro 2. vlakno
        add ecx,ebx						; posun na druhoy osminu radku matice M
        mov dword [Ptrs3 + 0],ecx		; -> ukazatel na M pro 3. vlakno

		mov eax, [ebp+16]				; ukazatel na y ->
		mov dword [Ptrs1 + 8],eax       ; -> ukazatel na y pro 1. vlakno
		add eax,ebx                     ; posun na prvni osminu vektoru y
		mov dword [Ptrs2 + 8],eax		; -> ukazatel na y pro 2. vlakno
		add eax,ebx                     ; posun na druhou osminu vektoru y
		mov dword [Ptrs3 + 8],eax		; -> ukazatel na y pro 3. vlakno

		mov dword [Ptrs1 + 20],3		; pocet vlaken
		mov dword [Ptrs2 + 20],3		; pocet vlaken
		mov dword [Ptrs3 + 20],3		; pocet vlaken

		mov byte [Ptrs1 + 21],0		; semafor pro 1. vlakno
		mov byte [Ptrs2 + 21],0		; semafor pro 2. vlakno
		mov byte [Ptrs3 + 21],0		; semafor pro 3. vlakno

       	push dword NULL
		push dword 0
		push dword Ptrs1
		push dword vxm_avx_ptrs_dp
		push dword 0
		push dword 0
		call [CreateThread]

		push dword NULL
		push dword 0
		push dword Ptrs2
		push dword vxm_avx_ptrs_dp
		push dword 0
		push dword 0
		call [CreateThread]

       	push dword Ptrs3
      	call vxm_avx_ptrs_dp

		.wait_for_thr1:
			cmp byte [Ptrs1 + 21],1
	        jnz .wait_for_thr1
   		.wait_for_thr2:
			cmp byte [Ptrs2 + 21],1
	        jnz .wait_for_thr2

		mov dword esp, ebp
       	pop dword ebp
ret 20


vxm_x6_avx_dp:
		push dword ebp
       	mov dword ebp,esp

		mov eax, [ebp+12]				; ukazatel na x ->
		mov dword [Ptrs1 + 4],eax		; -> ukazatel na x pro 1. vlakno
		mov dword [Ptrs2 + 4],eax		; -> ukazatel na x pro 2. vlakno
  		mov dword [Ptrs3 + 4],eax		; -> ukazatel na x pro 3. vlakno
		mov dword [Ptrs4 + 4],eax		; -> ukazatel na x pro 4. vlakno
		mov dword [Ptrs5 + 4],eax		; -> ukazatel na x pro 5. vlakno
		mov dword [Ptrs6 + 4],eax		; -> ukazatel na x pro 6. vlakno

		mov eax, [ebp+20]				; delka vstupu ->
		mov dword [Ptrs1 + 12],eax		; -> delka vstupu pro 1. vlakno
		mov dword [Ptrs2 + 12],eax		; -> delka vstupu pro 2. vlakno
		mov dword [Ptrs3 + 12],eax		; -> delka vstupu pro 3. vlakno
		mov dword [Ptrs4 + 12],eax		; -> delka vstupu pro 4. vlakno
		mov dword [Ptrs5 + 12],eax		; -> delka vstupu pro 5. vlakno
		mov dword [Ptrs6 + 12],eax		; -> delka vstupu pro 6. vlakno

		mov eax, [ebp+24]				; delka vystupu ->
        xor edx,edx
        mov ebx,6
        div ebx							; pro 6 vlaken (delka vystupu)/6
		mov ebx,eax
		mov dword [Ptrs1 + 16],ebx		; -> delka vystupu pro 1. vlakno
		mov dword [Ptrs2 + 16],ebx 		; -> delka vystupu pro 2. vlakno
		mov dword [Ptrs3 + 16],ebx		; -> delka vystupu pro 3. vlakno
		mov dword [Ptrs4 + 16],ebx 		; -> delka vystupu pro 4. vlakno
		mov dword [Ptrs5 + 16],ebx		; -> delka vystupu pro 5. vlakno
		mov dword [Ptrs6 + 16],ebx		; -> delka vystupu pro 6. vlakno


        mov ecx, [ebp+8]				; ukazatel na M ->
       	mov dword [Ptrs1 + 0],ecx		; -> ukazatel na M pro 1. vlakno
        shl ebx,3						; x8 pro dvojitou presnost
        add ecx,ebx						; posun na prvniho osminu radku matice M
        mov dword [Ptrs2 + 0],ecx		; -> ukazatel na M pro 2. vlakno
        add ecx,ebx						; posun na druhoy osminu radku matice M
        mov dword [Ptrs3 + 0],ecx		; -> ukazatel na M pro 3. vlakno
        add ecx,ebx						; posun na treti osminu radku matice M
        mov dword [Ptrs4 + 0],ecx		; -> ukazatel na M pro 4. vlakno
        add ecx,ebx						; posun na ctvrtou osminu radku matice M
        mov dword [Ptrs5 + 0],ecx		; -> ukazatel na M pro 5. vlakno
        add ecx,ebx						; posun na patou osminu radku matice M
        mov dword [Ptrs6 + 0],ecx		; -> ukazatel na M pro 6. vlakno


		mov eax, [ebp+16]				; ukazatel na y ->
		mov dword [Ptrs1 + 8],eax       ; -> ukazatel na y pro 1. vlakno
		add eax,ebx                     ; posun na prvni osminu vektoru y
		mov dword [Ptrs2 + 8],eax		; -> ukazatel na y pro 2. vlakno
		add eax,ebx                     ; posun na druhou osminu vektoru y
		mov dword [Ptrs3 + 8],eax		; -> ukazatel na y pro 3. vlakno
		add eax,ebx                     ; posun na treti osminu vektoru y
		mov dword [Ptrs4 + 8],eax		; -> ukazatel na y pro 4. vlakno
		add eax,ebx                     ; posun na ctvrtou osminu vektoru y
		mov dword [Ptrs5 + 8],eax		; -> ukazatel na y pro 5. vlakno
		add eax,ebx                     ; posun na patou osminu vektoru y
		mov dword [Ptrs6 + 8],eax		; -> ukazatel na y pro 6. vlakno


		mov dword [Ptrs1 + 20],6		; pocet vlaken
		mov dword [Ptrs2 + 20],6		; pocet vlaken
		mov dword [Ptrs3 + 20],6		; pocet vlaken
		mov dword [Ptrs4 + 20],6		; pocet vlaken
		mov dword [Ptrs5 + 20],6		; pocet vlaken
		mov dword [Ptrs6 + 20],6		; pocet vlaken


		mov byte [Ptrs1 + 21],0		; semafor pro 1. vlakno
		mov byte [Ptrs2 + 21],0		; semafor pro 2. vlakno
		mov byte [Ptrs3 + 21],0		; semafor pro 3. vlakno
		mov byte [Ptrs4 + 21],0		; semafor pro 4. vlakno
		mov byte [Ptrs5 + 21],0		; semafor pro 5. vlakno
		mov byte [Ptrs6 + 21],0		; semafor pro 6. vlakno


       	push dword NULL
		push dword 0
		push dword Ptrs1
		push dword vxm_avx_ptrs_dp
		push dword 0
		push dword 0
		call [CreateThread]

		push dword NULL
		push dword 0
		push dword Ptrs2
		push dword vxm_avx_ptrs_dp
		push dword 0
		push dword 0
		call [CreateThread]

		push dword NULL
		push dword 0
		push dword Ptrs3
		push dword vxm_avx_ptrs_dp
		push dword 0
		push dword 0
		call [CreateThread]

       	push dword NULL
		push dword 0
		push dword Ptrs4
		push dword vxm_avx_ptrs_dp
		push dword 0
		push dword 0
		call [CreateThread]

		push dword NULL
		push dword 0
		push dword Ptrs5
		push dword vxm_avx_ptrs_dp
		push dword 0
		push dword 0
		call [CreateThread]


       	push dword Ptrs6
      	call vxm_avx_ptrs_dp

		.wait_for_thr1:
			cmp byte [Ptrs1 + 21],1
	        jnz .wait_for_thr1
   		.wait_for_thr2:
			cmp byte [Ptrs2 + 21],1
	        jnz .wait_for_thr2
   		.wait_for_thr3:
			cmp byte [Ptrs3 + 21],1
	        jnz .wait_for_thr3
   		.wait_for_thr4:
			cmp byte [Ptrs4 + 21],1
	        jnz .wait_for_thr4
   		.wait_for_thr5:
			cmp byte [Ptrs5 + 21],1
	        jnz .wait_for_thr5

		mov dword esp, ebp
       	pop dword ebp
ret 20


vxm_x87_ptrs_sp:
		push dword ebp
       	mov dword ebp,esp
        sub esp,4
		mov eax,[ebp + 8]       ; ukazatel na PRTS
      	mov esi,[eax + 12]		; delka vstupniho vektoru (pole x)
      	mov ecx,[eax + 20]      ; pocet vlaken
        push eax
        mov eax,[eax + 16]
        mov edi,eax             ; delka vystupniho vektoru (pole y) vzhledem k poctu vlaken
        mul ecx                 ; delka celeho vystupniho vektoru (pole y)
        sub eax,edi             ; pocet vlaken x delka vystupu vzhledem k poctu vlaken - delka vystupu vzhledem k poctu vlaken
        shl eax,2               ; x4 pro jednoduchou presnost
        mov dword [ebp-4],eax   ; posun v matici podle poctu vlaken
       	pop eax
       	mov ecx,[eax + 0]		; ukazatel na pole M
		mov edx,[eax + 4]		; ukazatel na pole x
       	finit					; incializace registru koprocesoru x87

  .invec:
      	mov ebx,[eax + 8]		; ukazatel na pole y
      	mov edi,[eax + 16]		; delka vystupniho vektoru (pole y)
			.radmat:
				fld dword [edx]	; nacteni prvku z pole x
		        fld dword [ecx]	; nacteni prvku z matice M
				add	ecx, 4      ; posun na dalsi prvek M
				fmul st1
		        fld dword [ebx]  ; nacteni stareho prvku z pole y
				fadd st1
				fst dword [ebx]  ; ulozeni noveho prvku do pole y
		      	add ebx, 4       ; posun na dalsi prvek y
				fstp st0
				fstp st0
				fstp st0

				dec edi
			jnz .radmat
		add	edx,4                ; posun na dalsi prvek x
		add ecx,[ebp-4]          ; posun v matici pro jednotliva vlakna
		dec esi
	jnz .invec
        mov byte [eax + 21],1	 ; nastaveni semaforu na hotovo
		mov dword esp, ebp
       	pop dword ebp
ret 4


vxm_x87_ptrs_dp:
		push dword ebp
       	mov dword ebp,esp
        sub esp,4
		mov eax,[ebp + 8]       ; ukazatel na PRTS
      	mov esi,[eax + 12]		; delka vstupniho vektoru (pole x)
      	mov ecx,[eax + 20]      ; pocet vlaken
        push eax
        mov eax,[eax + 16]
        mov edi,eax             ; delka vystupniho vektoru (pole y) vzhledem k poctu vlaken
        mul ecx                 ; delka celeho vystupniho vektoru (pole y)
        sub eax,edi             ; pocet vlaken x delka vystupu vzhledem k poctu vlaken - delka vystupu vzhledem k poctu vlaken
        shl eax,3               ; x8 pro dvojitou presnost
        mov dword [ebp-4],eax   ; posun v matici podle poctu vlaken
       	pop eax
       	mov ecx,[eax + 0]		; ukazatel na pole M
		mov edx,[eax + 4]		; ukazatel na pole x
       	finit					; incializace registru koprocesoru x87

  .invec:
      	mov ebx,[eax + 8]		; ukazatel na pole y
      	mov edi,[eax + 16]		; delka vystupniho vektoru (pole y)
			.radmat:
				fld qword [edx]	; nacteni prvku z pole x
		        fld qword [ecx]	; nacteni prvku z matice M
				add	ecx, 8      ; posun na dalsi prvek M
				fmul st1
		        fld qword [ebx]  ; nacteni stareho prvku z pole y
				fadd st1
				fst qword [ebx]  ; ulozeni noveho prvku do pole y
		      	add ebx, 8       ; posun na dalsi prvek y
				fstp st0
				fstp st0
				fstp st0

				dec edi
			jnz .radmat
		add	edx,8                ; posun na dalsi prvek x
		add ecx,[ebp-4]          ; posun v matici pro jednotliva vlakna
		dec esi
	jnz .invec
        mov byte [eax + 21],1	 ; nastaveni semaforu na hotovo
		mov dword esp, ebp
       	pop dword ebp
ret 4

vxm_sse_ptrs_sp:
		push dword ebp
      	mov dword ebp,esp

      	sub esp,20					; rezerva pro 5 lokalnich promennych 5x 4B
 		mov eax,[ebp + 8]       	; ukazatel na PRTS
        mov esi,[eax + 12]			; delka vstupniho vektoru x
       	shr esi,2                   ; deleni 4 pro podmatici SP SSE 4x4
      	mov dword [ebp - 4],esi 	; delka vektoru x v poctu podvektoru

      	mov ecx,[eax + 20]        	; pocet vlaken
        push eax
	   	mov eax,[eax + 16]
	   	mov edi,eax             	; delka vystupniho vektoru y vzhledem k poctu vlaken
		mul ecx
        mov ebx,eax                 ; delka celeho vystuopnih vektoru y
        sub eax,edi             	; pocet vlaken x delka y vzhledem k poctu vlaken - delka y vzhledem k poctu vlaken
       	shr edi,2                   ; deleni 4 pro podmatici SP SSE 4x4
      	mov dword [ebp - 8],edi 	; delka vektoru y v poctu podvektoru
        shl eax,2               	; x4 pro jednoduchou presnost
        mov dword [ebp - 16],eax   	; posun v matici podle poctu vlaken

        mov dword [ebp - 12],3		; pocet radku podmatice -1
      	mov eax,16              	; max. delka podvektoru SSE v Bytech
       	shr ebx,2                   ; deleni 4 pro podmatici SP SSE 4x4
      	mul ebx			    		; pocet Byte pro celou delku vektoru y
        mov dword [ebp - 20],eax    ; posun na dalsi radek v submatici
      	mul dword [ebp - 12]
      	mov dword [ebp - 12],eax    ; posun na dalsi radek submatic
       	pop eax

     	mov ecx,[eax + 0]			;ukazatel na pole M
     	mov edx,[eax + 4]			;ukazatel na pole x
      	mov esi,[ebp - 4]   		;delka pole x v poctu podvektoru


	.invec:
        movups xmm0,[edx]
        mov ebx,[eax + 8]			;ukazatel na pole y
      	mov edi,[ebp - 8]  			;delka pole y v poctu podvektoru

			.radmat:
                movups xmm3,[ebx]

				movups xmm2,[ecx]
				add ecx,dword [ebp - 20]
				movups xmm1,xmm0
				shufps xmm1,xmm1,00000000b
				mulps xmm2,xmm1
				addps xmm3,xmm2

				movups xmm2,[ecx]
				add ecx,dword [ebp - 20]
				movups xmm1,xmm0
				shufps xmm1,xmm1,01010101b
				mulps xmm2,xmm1
				addps xmm3,xmm2

				movups xmm2,[ecx]
				add ecx,dword [ebp - 20]
				movups xmm1,xmm0
				shufps xmm1,xmm1,10101010b
				mulps xmm2,xmm1
				addps xmm3,xmm2

				movups xmm2,[ecx]
				movups xmm1,xmm0
				shufps xmm1,xmm1,11111111b
				mulps xmm2,xmm1
				addps xmm3,xmm2

				movups [ebx],xmm3

				add ebx,16
                sub ecx,dword [ebp - 12]
				add ecx,16

				dec edi
			jnz .radmat

      	add edx,16
      	add ecx,dword [ebp - 12]
      	add ecx,dword [ebp - 16]
      	dec esi
	jnz .invec
		mov byte [eax + 21],1	 ; nastaveni semaforu na hotovo
		mov dword esp,ebp
       	pop dword ebp
ret 4

vxm_sse_ptrs_dp:
		push dword ebp
      	mov dword ebp,esp

      	sub esp,20					; rezerva pro 5 lokalnich promennych 5x 4B
 		mov eax,[ebp + 8]       	; ukazatel na PRTS
        mov esi,[eax + 12]			; delka vstupniho vektoru x
       	shr esi,1                   ; deleni 2 pro podmatici DP SSE 2x2
      	mov dword [ebp - 4],esi 	; delka vektoru x v poctu podvektoru

      	mov ecx,[eax + 20]        	; pocet vlaken
        push eax
	   	mov eax,[eax + 16]
	   	mov edi,eax             	; delka vystupniho vektoru y vzhledem k poctu vlaken
		mul ecx
        mov ebx,eax                 ; delka celeho vystupniho vektoru y
        sub eax,edi             	; pocet vlaken x delka y vzhledem k poctu vlaken - delka y vzhledem k poctu vlaken
       	shr edi,1                   ; deleni 2 pro podmatici DP SSE 2x2
      	mov dword [ebp - 8],edi 	; delka vektoru y v poctu podvektoru
        shl eax,3               	; x8 pro dvojitou presnost
        mov dword [ebp - 16],eax   	; posun v matici podle poctu vlaken

        mov dword [ebp - 12],1		; pocet radku podmatice -1
      	mov eax,16              	; max. delka podvektoru SSE v Bytech
       	shr ebx,1                   ; deleni 2 pro podmatici DP SSE 2x2
      	mul ebx			    		; pocet Byte pro celou delku vektoru y
        mov dword [ebp - 20],eax    ; posun na dalsi radek v submatici
      	mul dword [ebp - 12]
      	mov dword [ebp - 12],eax    ; posun na dalsi radek submatic
       	pop eax

     	mov ecx,[eax + 0]			;ukazatel na pole M
     	mov edx,[eax + 4]			;ukazatel na pole x
      	mov esi,[ebp - 4]   		;delka pole x v poctu podvektoru


	.invec:
        movups xmm0,[edx]
        mov ebx,[eax + 8]			;ukazatel na pole y
      	mov edi,[ebp - 8]  			;delka pole y v poctu podvektoru

			.radmat:
                movupd xmm3,[ebx]

				movupd xmm2,[ecx]
				add ecx,dword [ebp - 20]
				movupd xmm1,xmm0
				shufpd xmm1,xmm1,00000000b
				mulpd xmm2,xmm1
				addpd xmm3,xmm2

				movupd xmm2,[ecx]
				movupd xmm1,xmm0
				shufpd xmm1,xmm1,11111111b
				mulpd xmm2,xmm1
				addpd xmm3,xmm2

				movupd [ebx],xmm3

				add ebx,16
                sub ecx,dword [ebp - 12]
				add ecx,16

				dec edi
			jnz .radmat

      	add edx,16
      	add ecx,dword [ebp - 12]
      	add ecx,dword [ebp - 16]
      	dec esi
	jnz .invec
		mov byte [eax + 21],1	 ; nastaveni semaforu na hotovo
		mov dword esp,ebp
       	pop dword ebp
ret 4

vxm_avx_ptrs_sp:
		push dword ebp
      	mov dword ebp,esp

      	sub esp,20					; rezerva pro 5 lokalnich promennych 5x 4B
 		mov eax,[ebp + 8]       	; ukazatel na PRTS
        mov esi,[eax + 12]			; delka vstupniho vektoru x
       	shr esi,3                   ; deleni 8 pro podmatici SP AVX 8x8
      	mov dword [ebp - 4],esi 	; delka vektoru x v poctu podvektoru

      	mov ecx,[eax + 20]        	; pocet vlaken
        push eax
	   	mov eax,[eax + 16]
	   	mov edi,eax             	; delka vystupniho vektoru y vzhledem k poctu vlaken
		mul ecx
        mov ebx,eax                 ; delka celeho vystupniho vektoru y
        sub eax,edi             	; pocet vlaken x delka y vzhledem k poctu vlaken - delka y vzhledem k poctu vlaken
       	shr edi,3                   ; deleni 8 pro podmatici SP AVX 8x8
      	mov dword [ebp - 8],edi 	; delka vektoru y v poctu podvektoru
        shl eax,2               	; x4 pro jednoduchou presnost
        mov dword [ebp - 16],eax   	; posun v matici podle poctu vlaken

        mov dword [ebp - 12],7		; pocet radku podmatice -1
      	mov eax,32              	; max. delka podvektoru AVX v Bytech
       	shr ebx,3                   ; deleni 8 pro podmatici SP AVX 8x8
      	mul ebx			    		; pocet Byte pro celou delku vektoru y
        mov dword [ebp - 20],eax    ; posun na dalsi radek v submatici
      	mul dword [ebp - 12]
      	mov dword [ebp - 12],eax    ; posun na dalsi radek submatic
       	pop eax

     	mov ecx,[eax + 0]			;ukazatel na pole M
     	mov edx,[eax + 4]			;ukazatel na pole x
      	mov esi,[ebp - 4]   		;delka pole x v poctu podvektoru

	.invec:
        mov ebx,[eax + 8]			;ukazatel na pole y
      	mov edi,[ebp - 8]  			;delka pole y v poctu podvektoru

			.radmat:
				vmovups ymm0,[ecx]
				add ecx,dword [ebp - 20]
				vbroadcastss ymm1,[edx]
				vmulps ymm2,ymm1,ymm0
				vaddps ymm3,ymm2,[ebx]
				vmovups ymm0,[ecx]
				add ecx,dword [ebp - 20]
				vbroadcastss ymm1,[edx+4]
				vmulps ymm2,ymm1,ymm0
				vaddps ymm3,ymm2,ymm3
				vmovups ymm0,[ecx]
				add ecx,dword [ebp - 20]
				vbroadcastss ymm1,[edx+8]
				vmulps ymm2,ymm1,ymm0
				vaddps ymm3,ymm2,ymm3
				vmovups ymm0,[ecx]
				add ecx,dword [ebp - 20]
				vbroadcastss ymm1,[edx+12]
				vmulps ymm2,ymm1,ymm0
				vaddps ymm3,ymm2,ymm3
				vmovups ymm0,[ecx]
				add ecx,dword [ebp - 20]
				vbroadcastss ymm1,[edx+16]
				vmulps ymm2,ymm1,ymm0
				vaddps ymm3,ymm2,ymm3
				vmovups ymm0,[ecx]
				add ecx,dword [ebp - 20]
				vbroadcastss ymm1,[edx+20]
				vmulps ymm2,ymm1,ymm0
				vaddps ymm3,ymm2,ymm3
				vmovups ymm0,[ecx]
				add ecx,dword [ebp - 20]
				vbroadcastss ymm1,[edx+24]
				vmulps ymm2,ymm1,ymm0
				vaddps ymm3,ymm2,ymm3
				vmovups ymm0,[ecx]
				vbroadcastss ymm1,[edx+28]
				vmulps ymm2,ymm1,ymm0
				vaddps ymm3,ymm2,ymm3
                vmovups [ebx],ymm3

				add ebx,32
                sub ecx,dword [ebp - 12]
				add ecx,32

				dec edi
			jnz .radmat

      	add edx,32
      	add ecx,dword [ebp - 12]
      	add ecx,dword [ebp - 16]
      	dec esi
	jnz .invec
		mov byte [eax + 21],1	 ; nastaveni semaforu na hotovo
		mov dword esp,ebp
       	pop dword ebp
ret 4

vxm_avx_ptrs_dp:
		push dword ebp
      	mov dword ebp,esp

      	sub esp,20					; rezerva pro 5 lokalnich promennych 5x 4B
 		mov eax,[ebp + 8]       	; ukazatel na PRTS
        mov esi,[eax + 12]			; delka vstupniho vektoru x
       	shr esi,2                   ; deleni 4 pro podmatici DP AVX 4x4
      	mov dword [ebp - 4],esi 	; delka vektoru x v poctu podvektoru

      	mov ecx,[eax + 20]        	; pocet vlaken
        push eax
	   	mov eax,[eax + 16]
	   	mov edi,eax             	; delka vystupniho vektoru y vzhledem k poctu vlaken
		mul ecx
        mov ebx,eax                 ; delka celeho vystupniho vektoru y
        sub eax,edi             	; pocet vlaken x delka y vzhledem k poctu vlaken - delka y vzhledem k poctu vlaken
       	shr edi,2                   ; deleni 4 pro podmatici DP AVX 4x4
      	mov dword [ebp - 8],edi 	; delka vektoru y v poctu podvektoru
        shl eax,3               	; x8 pro dvojitou presnost
        mov dword [ebp - 16],eax   	; posun v matici podle poctu vlaken

        mov dword [ebp - 12],3		; pocet radku podmatice -1
      	mov eax,32              	; max. delka podvektoru AVX v Bytech
       	shr ebx,2                   ; deleni 4 pro podmatici DP AVX 4x4
      	mul ebx			    		; pocet Byte pro celou delku vektoru y
        mov dword [ebp - 20],eax    ; posun na dalsi radek v submatici
      	mul dword [ebp - 12]
      	mov dword [ebp - 12],eax    ; posun na dalsi radek submatic
       	pop eax

     	mov ecx,[eax + 0]			;ukazatel na pole M
     	mov edx,[eax + 4]			;ukazatel na pole x
      	mov esi,[ebp - 4]   		;delka pole x v poctu podvektoru


	.invec:
        mov ebx,[eax + 8]			;ukazatel na pole y
      	mov edi,[ebp - 8]  			;delka pole y v poctu podvektoru

			.radmat:
				vmovupd ymm0,[ecx]
				add ecx,dword [ebp - 20]
				vbroadcastsd ymm1,[edx]
				vmulpd ymm2,ymm1,ymm0
				vaddpd ymm3,ymm2,[ebx]

				vmovupd ymm0,[ecx]
				add ecx,dword [ebp - 20]
				vbroadcastsd ymm1,[edx+8]
                vmulpd ymm2,ymm1,ymm0
				vaddpd ymm3,ymm2,ymm3

				vmovupd ymm0,[ecx]
				add ecx,dword [ebp - 20]
				vbroadcastsd ymm1,[edx+16]
                vmulpd ymm2,ymm1,ymm0
				vaddpd ymm3,ymm2,ymm3

				vmovupd ymm0,[ecx]
				vbroadcastsd ymm1,[edx+24]
                vmulpd ymm2,ymm1,ymm0
				vaddpd ymm3,ymm2,ymm3
				vmovupd [ebx],ymm3

				add ebx,32
                sub ecx,dword [ebp - 12]
				add ecx,32

				dec edi
			jnz .radmat

      	add edx,32
      	add ecx,dword [ebp - 12]
      	add ecx,dword [ebp - 16]
      	dec esi
	jnz .invec
		mov byte [eax + 21],1	 ; nastaveni semaforu na hotovo
		mov dword esp,ebp
       	pop dword ebp
ret 4