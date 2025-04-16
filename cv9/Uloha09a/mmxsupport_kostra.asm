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

	;
	; volani instrukce pro zjisteni podpory MMX
	;

	;
	; smycka if, pokud neni zjistena podpora tak se proveden skok na navesti .nepodporuje
	;


	;
	; Zobrazi dialogove okno s hlasenim, ze je zjistena podpora MMX
	;

	;	
	; provede skok na navesti .end
	;
   		
.nepodporuje:  
 	
	;
	; Zobrazi dialogove okno s hlasenim, ze neni zjistena podpora MMX
	;

.end:
	push dword NULL
	call [ExitProcess]