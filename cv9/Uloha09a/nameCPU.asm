; Autor: Miroslav Balik
; Source code: EXE(OBJ) 32bit Win32 API
; Directs for assembling and linking:
; nasm nameCPU.asm -fobj
; alink nameCPU.obj -oPE -subsys gui

extern ExitProcess
import ExitProcess kernel32.dll
extern CPUname
import CPUname detect.dll

%include 'WIN32N.inc'	;definice struktur a ruznych datovych typu

[section .data class=DATA use32 align=16]

nc	 db " "

[section .code use32 class=CODE]

..start:	push nc
			call [CPUname]
			
			push dword NULL
			call [ExitProcess]
	