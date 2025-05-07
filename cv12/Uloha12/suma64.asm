; Autor: Miroslav Balik
; Source code: DLL(OBJ) 64bit Win64 API
; Directs for assembling and linking:
; nasm suma64.asm -fwin64
; golink suma64.obj /dll /ni

; sablonu je potreba prejmenovat na suma64.asm

global suma          ;globalní funkce
export suma          ;externí funkce
global suma_hp_lp_nr
export suma_hp_lp_nr

; datový segment 
section .data

; kódový segment 
section .text

start:

DllMain:           					; povinny vstup do knihovny pro 64b dll
		mov rax,1
		ret
        

suma:
	push rbp
	mov rbp,rsp

	add rcx,rdx
	add rcx,r8
	add rcx,r9
	mov rax,rcx
	; vystupni parametr jako cele cislo musi byt v rax a v hodnote 0Ah nebo 10d

    mov rsp,rbp
	pop rbp
ret


suma_hp_lp_nr:    ;hot-patch, lokalni promenne, nevolatilni registry
	;prolog
	db	48h							;vyhrazeni mista REX prefixu pro hot-patching
	push rbp
	sub rsp,50h                     ;rezervace v zasobniku na pocet mist odpovidajici souctu
									;lokalnich promenych a zalohovanych nevolatilnich registru
									;zde 4x8B lok. prom. a 2x8B+8B+8B+8B nev. reg.
									;musi byt zarovnano, tedy nutne misto o 9 posunout o 10 (48h -> 50h)
	lea rbp,[rsp+20h]               ;nahrani rsp s posunem do rbp (ramcovy ukazatel)
									;posun rovny 4 lok. promenym, opet jen vzdy zarovnane
	movdqa [rbp],xmm7               ;obsazeni 2x8B polozek zasobniku
	mov qword [rbp+10h],rbx				;obsazeni dalsi 8B polozky zasobniku
	mov qword [rbp+18h],rsi				;obsazeni dalsi 8B polozky zasobniku
	mov qword [rbp+20h],rdi				;obsazeni dalsi 8B polozky zasobniku
		
	;algoritmus funkce vyuzivajici lokalni promenne, tady 4 lok. prom. [rbp-8h] az [rbp-20h]
	mov qword [rbp-8h],10h
	mov qword [rbp-10h],11h
	mov qword [rbp-18h],12h
	mov qword [rbp-20h],13h
	;pokud se zde vola funkce, je vzdy nutne volat zarovnane
	
	;souèet osmi èísel
	add rcx,rdx
	add rcx,r8
	add rcx,r9
	add qword rcx, [rbp + 60h]       ; par5 brany ze zasobniku jako 5. 64b polozka
	add qword rcx, [rbp + 68h]       ; par6 brany ze zasobniku jako 6. 64b polozka
	add qword rcx, [rbp + 70h]       ; par7 brany ze zasobniku jako 7. 64b polozka
	add qword rcx, [rbp + 78h]       ; par8 brany ze zasobniku jako 8. 64b polozka
	mov rax,rcx
	; vystupni parametr jako cele cislo musi byt v rax a v hodnote 24h nebo 36d

	;epilog
	movdqa xmm7,[rbp]				;obnoveni nevolatilnich registru
	mov rbx,[rbp+10h]
	mov rsi,[rbp+18h]
	mov rdi,[rbp+20h]
	lea rsp,[rbp-20h]               ;nastaveni rsp na puvodni celkovou rezervaci
	add rsp,50h                     ;plne obnoveni puvodniho rsp - odstraneni rezervace
	pop rbp                         ;obnoveni puvodniho rbp
	ret
							