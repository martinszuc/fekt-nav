; Autor: Miroslav Balík
; Source code: EXE(OBJ) 32bit Win32 API
; Directs for assembling and linking:
; nasm mmxoperace.asm -fobj
; alink mmxoperace.obj -oPE -subsys gui


%include 'WIN32N.inc'	;definice struktur a ruznych datovych typu


extern ExitProcess
import ExitProcess kernel32.dll




[section .data class=DATA use32 align=16]

a: db 100,110,120,130
b: db 200,200,200,200
;f: db 127,127,127,127
f: db 128,128,128,128
y: db 0,0,0,0




[section .code use32 class=CODE]
..start:
		mov  esi,a
		mov  edi,b
		mov  eax,f
		mov  ebx,y

		; ---------- MMX ------------
	  	; ulozeni hodnot do mm1, mm2, mm3. Vynuluje se mm5
		movd        mm1,[esi]		; mm1 = 0 0 0 0 aA aR aG aB
		movd        mm2,[edi]		; mm2 = 0 0 0 0 bA bR bG bB
		pxor        mm5,mm5			; mm5 = 0 0 0 0 0 0 0 0
		punpcklbw   mm1,mm5			; mm1 = 0 aA 0 aR 0 aG 0 aB
		punpcklbw   mm2,mm5			; mm2 = 0 bA 0 bR 0 bG 0 bB
		movd        mm3,[eax]			; mm3 = 0 0 0 0 faA faR faG faB

		; fa ze zde rozsiri na rozsah [0-256]
		; logika je takova, ze pokud je puvodni fa vetsi nez 127 tak se mu pricte 1
		punpcklbw   mm3,mm5			; mm3 = 0 faA 0 faR 0 faG 0 faB
		movq        mm6,mm3			; mm6 = faA faR faG faB [0 - 255]
		psrlw       mm6,7			; mm6 = faA faR faG faB [0 - 1]
		paddw       mm3,mm6			; mm3 = faA faR faG faB [0 - 256]
		; fb = 256 - fa, fb bude v mm4
		pcmpeqw     mm4,mm4			; mm4 = 0xFFFF 0xFFFF 0xFFFF 0xFFFF
		psrlw       mm4,15			; mm4 =   1   1   1   1
		psllw       mm4,8			; mm4 = 256 256 256 256
		psubw       mm4,mm3			; mm4 = fbA fbR fbG fbB
		; res = (a*fa + b*fb)/256
		pmullw      mm1,mm3			; mm1 = aA aR aG aB
		pmullw      mm2,mm4			; mm2 = bA bR bG bB
		paddw       mm1,mm2			; mm1 = rA rR rG rB
		psrlw       mm1,8			; mm1 = 0 rA 0 rR 0 rG 0 rB
		; pack into output registr
		packuswb    mm1,mm1			; mm1 = 0 0 0 0 rA rR rG rB
		movd       	[ebx],mm1		; ebx = rA rR rG rB
									; v knihovne je nutne pouzit vystup do edi
		emms
		; ---------- /MMX ------------
.end:
	push dword NULL
	call [ExitProcess]
	
	