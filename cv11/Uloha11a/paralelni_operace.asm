; Autor: Miroslav Balík
; Source code: EXE(OBJ) 32bit Win32 API
; Directs for assembling and linking:
; nasm paralelni_operace.asm -fobj
; alink paralelni_operace.obj -oPE -subsys gui


%include 'WIN32N.inc'	;definice struktur a ruznych datovych typu

extern CreateThread
import CreateThread kernel32.dll
extern ExitProcess
import ExitProcess kernel32.dll

 	STRUC PTRS
 	 	
 		;viz cviceni 	

 	ENDSTRUC


[section .data class=DATA use32 align=16]

 ;vstupni vektor 1*4
 ;matice 4 * 4
y dd 0.0, 0.0, 0.0, 0.0
x dd 1.0, 2.0, 3.0, 4.0
M dd 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0


; vstupni vektor 1*4
; matice 4 * 6
;y1 dd 0.0, 0.0, 0.0, 0.0, 0.0,  0.0
;y2 dd 0.0, 0.0, 0.0, 0.0, 0.0,  0.0
;x dd 2.0, 2.0, 3.0, 5.0														
;M dd 8.0, 5.0, 1.0, 7.0, 2.2, 1.2, 8.0, 5.0, 1.0, 7.0, 3.3, 2.2, 1.0, 8.0, 7.0, 9.0, 2.4, 3.3, 1.0, 8.0, 7.0, 9.0, 9.9, 7.7		


; vstupni vektor 1*4
; matice 4 * 8
;y1 dd 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
;y2 dd 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
;x dd 2.0, 2.0, 3.0, 5.0														
;M dd 8.0, 5.0, 1.0, 7.0, 2.2, 1.2, 8.0, 5.0, 1.0, 7.0, 3.3, 2.2, 1.0, 8.0, 7.0, 9.0, 2.4, 3.3, 1.0, 8.0, 7.0, 9.0, 9.9, 7.7, 11.1, 15.8, 16.9, 18.4, 1.1, 8.0 ,9.8 ,10.1


; vstupni vektor 1*8
; matice 8 * 4
;y1 dd 0.0, 0.0, 0.0, 0.0
;y2 dd 0.0, 0.0, 0.0, 0.0
;x dd 2.0, 2.0, 3.0, 5.0, 3.3, 2.2, 5.5, 9.9														
;M dd  8.0, 5.0, 1.0, 7.0, 3.2, 5.0, 1.0, 2.0, 1.0, 8.0, 7.0, 9.0, 1.1, 8.8, 7.0, 4.0, 1.1, 2.8, 7.1, 88.0, 2.1, 5.8, 7.8, 45.0, 3.1, 6.8, 7.9, 44.0, 4.1, 8.8, 7.4, 11.0   	


; vstupni vektor 1*8
; matice 8 * 6
;y1 dd 0.0, 0.0, 0.0, 0.0, 0.0,  0.0
;y2 dd 0.0, 0.0, 0.0, 0.0, 0.0,  0.0
;x dd 2.0, 2.0, 3.0, 5.0, 3.3, 2.2, 5.5, 9.9   																																						
;M dd 8.0, 5.0, 1.0, 7.0, 5.4, 1.8, 3.2, 5.0, 1.0, 2.0, 5.0, 1.2, 1.0, 8.0, 7.0, 9.0, 1.1, 8.2, 1.1, 8.8, 7.0, 4.0, 2.2, 1.2, 1.1, 2.8, 7.1, 8.0, 8.8, 1.8, 2.1, 5.8, 7.8, 5.0, 11.99, 8.8, 3.1, 6.8, 7.9, 4.0, 9.1, 5.8, 4.1, 8.8, 7.4, 11.0, 9.9, 5.5

; vstupni vektor 1*8
; matice 8 * 8
;y1 dd 0.0, 0.0, 0.0, 0.0, 0.0,  0.0, 0.0,  0.0
;y2 dd 0.0, 0.0, 0.0, 0.0, 0.0,  0.0, 0.0,  0.0
;x dd 2.0, 2.0, 3.0, 5.0, 3.3, 2.2, 5.5, 9.9
;M dd 8.0, 5.0, 1.0, 7.0, 7.0, 4.0, 2.2, 1.2, 3.2, 5.0, 1.0, 2.0, 7.0, 4.0, 2.2, 1.2, 1.0, 8.0, 7.0, 9.0, 7.1, 8.0, 8.8, 1.8, 1.1, 8.8, 7.0, 4.0, 7.1, 8.0, 8.8, 1.8, 1.1, 2.8, 7.1, 88.0, 7.4, 11.0, 9.9, 5.5, 2.1, 5.8, 7.8, 45.0, 7.4, 11.0, 9.9, 5.5,3.1, 6.8, 7.9, 44.0, 1.0, 2.0, 5.0, 1.2, 4.1, 8.8, 7.4, 11.0, 1.0, 2.0, 5.0, 1.2


ptrs1:	resb 	PTRS_size
ptrs2:	resb 	PTRS_size


[section .code use32 class=CODE]

mat_x87_multi:
		
		;predchazejici priklad	

ret 24



mat_x87_ptrs:

		;viz cviceni

ret 4


..start:

		;viz cviceni

.end:
	push dword NULL
	call [ExitProcess]