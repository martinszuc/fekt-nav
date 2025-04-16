; Autor: Miroslav Balík
; Source code: EXE(OBJ) 32bit Win32 API
; Directs for assembling and linking:
; nasm mmxpodpora.asm -fobj
; alink mmxpodpora.obj -oPE -subsys gui


%include 'WIN32N.inc'	;definice struktur a ruznych datovych typu

extern MessageBox
import MessageBox user32.dll MessageBoxA
extern ExitProcess
import ExitProcess kernel32.dll

[section .data class=DATA use32 align=16]

headline: DB "Test MMX podpory",0
txtpodporujemmx: DB "MMX je podporováno.",0
txtnepodporujemmx: DB "MMX není podporováno.",0

[section .code use32 class=CODE]
..start:

	mov eax, 1
   	cpuid
    mov eax, edx
    shr eax, 23
    and eax, 1

	cmp    eax, 0
   	je .nepodporuje

  	push dword MB_OK
	push dword headline
	push dword txtpodporujemmx
	push dword NULL
	call [MessageBox]
	jmp .end

.nepodporuje:
	push dword MB_OK
	push dword headline
	push dword txtnepodporujemmx
	push dword NULL
	call [MessageBox]

.end:
	push dword NULL
	call [ExitProcess]