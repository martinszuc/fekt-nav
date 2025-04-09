; Autor: Miroslav Balik
; Source code: DLL(OBJ) 32bit Win32 API
; Directs for assembling and linking:
; nasm tictoc.asm –fobj 
; alink tictoc.obj -oPE -dll -o tictoc.dll

%include 'WIN32N.inc'	;definice struktur a ruznych datovych typu

extern QueryPerformanceFrequency
import QueryPerformanceFrequency kernel32.dll


global M_toc          ;globalní funkce 
export M_toc          ;externí funkce 
global M_rtoc         ;globalní funkce
export M_rtoc         ;externí funkce
global M_tic          ;globalní funkce 
export M_tic          ;externí funkce 


; datový segment 
[section .data class=DATA use32 align=16]


; kódový segment 
[section .code use32 class=CODE] 

..start:             

DllMain:
		mov eax,1
ret 12

M_toc:                 
	push dword ebp  
	mov dword ebp, esp
	sub esp, 8

	lea ebx, [EBP - 8]
	push ebx
	call [QueryPerformanceFrequency]

	rdtsc		; v eax:edx je hodnota 2. citace

	mov ecx, edx  ; v eax:ecx je hodnota 2. citace
	mov ebx, [EBP + 8]
	sub eax, [EBX]
	sbb ecx, [EBX + 4]	;vysledek bude v ecx:eax

	mov ebx, 1000		
	mul ebx			; vynasobi eax hodnotou 1000, aby byl cas v ms
	push eax
	push edx

	mov eax, ecx		
	mul ebx			; jeste vynasobi ecx hodntou 1000
	pop ecx
	add ecx, eax

	pop eax			;rozdil v cyklech mezi 1.a 2. citacem je ted v ecx:eax

	mov edx,ecx
	mov ecx, [EBP - 8]	; v ecx je ted delitel, tj. hodnota frekvence CPU
	
	div ecx			; tj. eax = edx:eax (rozdil v taktech) / ecx (CPU frekv.)

	;mov dword [EBP + 12], eax
	mov dword esp, ebp 
	pop dword ebp
ret 4


M_rtoc:                 
	push dword ebp  
	mov dword ebp, esp
	sub esp, 8

	finit
	mov eax, [EBP + 8]
	fild qword [eax]


	rdtsc
	mov [EBP - 4], edx
	mov [EBP - 8], eax
	fild qword [EBP - 8]
	fsub st1

	lea eax, [EBP - 8]
	push eax
	call [QueryPerformanceFrequency]
	fild qword [EBP - 8]
	fdivr st1

	mov dword esp, ebp 
	pop dword ebp
ret 4


M_tic:
	push dword ebp  
	mov dword ebp, esp

	rdtsc
	mov ebx, [ebp+8]
	mov [ebx], eax
	mov [ebx+4], edx

	mov dword esp, ebp 
	pop dword ebp
ret 4

 