; Autor: Miroslav Balik
; Source code: EXE(OBJ) 64bit Win64 API
; Directs for assembling and linking:
; nasm ao64.asm -fwin64
; golink ao64.obj kernel32.dll user32.dll

; sablonu je potreba prejmenovat na ao64.asm

extern ExitProcess
extern suma
extern suma_hp_lp_nr

section .data

par1 dq 1
par2 dq 2
par3 dq 3
par4 dq 4
par5 dq 5
par6 dq 6
par7 dq 7
par8 dq 8

par9 dd 5.0, 4.0, 3.0, 2.0


section .text
start:	

		sub rsp,28h                 ;zarovnani zasobniku - 1x8B a stinovani 4 primych 8B parametru, stinovany prostor je vlastnictvim volaneho!
		mov r9,[par4]              	;postupne prime predani 4 8B parametru skrze registry
		mov r8,[par3]
		mov rdx,[par2]
		mov rcx,[par1]
		call [suma]        			;volani funkce
        add rsp,28h

		movdqa xmm7,[par9]			;naplneni 4 registru pro testovani
		mov rbx,1
		mov rdi,2
		mov rsi,3

		;korektni optimalizovana verze volani ramcove funkce
		sub rsp,8                   ;zarovnani zasobniku - 1x8B
		push qword [par8]   		;do zasobniku paty parametr a dalsi parametry v opacnem poradi
		push qword [par7]
		push qword [par6]
		push qword [par5]
		sub rsp,20h					;stinovani 4 primych 8B parametru, stinovany prostor je vlastnictvim volaneho!
		mov r9,[par4]              	;postupne prime predani 4 8B parametru skrze registry
		mov r8,[par3]
		mov rdx,[par2]
		mov rcx,[par1]
		call [suma_hp_lp_nr]        ;volani funkce
		add rsp,48h     			;vycisteni stinovani zasobniku 4 prime + 4 pres zasobnik
									;+ 1x8B na zarovnani ( pripadne jine zarovnani dle nasledujicich instrukci)
                                    ;nasledovalo by zpracovani vystupniho celociselneho parametru predaneho skrze rax
		mov rcx,0
		call [ExitProcess]
	

	
	