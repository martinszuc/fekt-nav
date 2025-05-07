; Autor: Miroslav Balik
; Source code: EXE(OBJ) 64bit Win64 API
; Directs for assembling and linking:
; nasm pozdrav64.asm -fwin64
; golink pozdrav64.obj kernel32.dll user32.dll

; sablonu je potreba prejmenovat na pozdrav64.asm


%include 'WIN32N.inc'	;definice struktur a ruznych datovych typu

extern MessageBoxA
extern ExitProcess

section .data
titulek		db "Pozdrav",0
muj_text	db "Ahoj, jak se máš?",0

section .code
start:
    sub rsp,28h      	; rezervace zasobniku, zarovnani zasobniku

	mov r9,MB_OK | MB_ICONINFORMATION
	mov r8,titulek
	mov rdx,muj_text 	
	mov rcx,0
	call [MessageBoxA]

    add rsp,28h      	; smazani rezervace zasobniku, zasobnik do puvodniho stavu

  	mov rcx,0
	call [ExitProcess]