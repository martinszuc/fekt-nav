; Autor: Martin Szuc (ID: 231284)
; Source code: EXE(OBJ) 32bit Win32 API
; Directs for assembling and linking:
; nasm okna.asm -fobj
; alink okna.obj -oPE -subsys gui

%include 'win32n.inc'	; definicie struktur a roznych datovych typov


; importovanie externych funkcii
extern ExitProcess
import ExitProcess kernel32.dll
extern GetModuleHandle
import GetModuleHandle kernel32.dll GetModuleHandleA
extern RegisterClassEx
import RegisterClassEx user32.dll RegisterClassExA
extern CreateWindowEx
import CreateWindowEx user32.dll CreateWindowExA
extern PostQuitMessage
import PostQuitMessage user32.dll
extern DefWindowProc
import DefWindowProc user32.dll DefWindowProcA
extern PostQuitMessage
import PostQuitMessage user32.dll
extern GetMessage
import GetMessage user32.dll GetMessageA
extern TranslateMessage
import TranslateMessage user32.dll
extern DispatchMessage
import DispatchMessage user32.dll DispatchMessageA
extern ShowWindow
import ShowWindow user32.dll
extern LoadIcon
import LoadIcon user32.dll LoadIconA
extern LoadCursor
import LoadCursor user32.dll LoadCursorA
extern PostMessage
import PostMessage user32.dll PostMessageA
extern MessageBox
import MessageBox user32.dll MessageBoxA



; Datovy segment
; **************************************************************************
[section .data class=DATA use32 align=16]

; textove retazce
szWndClassName: DB "WIN CLASS32",0
ClassNameStatButton: DB "BUTTON",0
szCButn: DB "Dialogove okno...",0
cap_dialog: DB "Nadpis dialogove okno.",0
mes_dialog: DB "Text dialogoveho okna.",0
szWndCaption: DB "Okno - CV7 Martin Szuc",0

; handly
hInstance       dd      0       ; instanc handle
hWnd            dd      0       ; window handle
hButton         dd      0       ; button handle

; globalne premenne
Message:        resb    MSG_size    ; alokacia miesta v pamati pre spravu

; Definicia struktury WndClass
WndClass:
    istruc WNDCLASSEX
        at WNDCLASSEX.cbSize, dd WNDCLASSEX_size
        at WNDCLASSEX.style, dd CS_VREDRAW+ CS_HREDRAW + CS_GLOBALCLASS
        at WNDCLASSEX.lpfnWndProc, dd WndProc
        at WNDCLASSEX.cbClsExtra, dd 0
        at WNDCLASSEX.cbWndExtra, dd 0
        at WNDCLASSEX.hInstance, dd NULL
        at WNDCLASSEX.hIcon, dd NULL
        at WNDCLASSEX.hCursor, dd NULL
        at WNDCLASSEX.hbrBackground, dd COLOR_BACKGROUND
        at WNDCLASSEX.lpszMenuName, dd NULL
        at WNDCLASSEX.lpszClassName, dd szWndClassName
        at WNDCLASSEX.hIconSm, dd NULL
    iend

; Kodovy segment
; ***************************************************************************
[section .code use32 class=CODE]

..start:
    ; Ziskanie handle instancie
    push dword NULL
    call [GetModuleHandle]
    mov [hInstance], eax
    
    ; Nastavenie ikon a kurzorov
    push dword IDI_APPLICATION
    push dword NULL
    call [LoadIcon]
    mov [WndClass + WNDCLASSEX.hIcon], eax
    mov [WndClass + WNDCLASSEX.hIconSm], eax
    
    push dword IDC_ARROW
    push dword NULL
    call [LoadCursor]
    mov [WndClass + WNDCLASSEX.hCursor], eax
    
    ; Nastavenie handlu instancie
    mov eax, [hInstance]
    mov [WndClass + WNDCLASSEX.hInstance], eax
    
    ; Registracia triedy okna
    push dword WndClass
    call [RegisterClassEx]
    test eax, eax
    jz near .Finish
    
    ; Vytvorenie hlavneho okna
    push dword NULL
    push dword [hInstance]
    push dword NULL
    push dword NULL
    push dword 275
    push dword 300
    push dword 100
    push dword 100
    push dword WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_MINIMIZEBOX
    push dword szWndCaption
    push dword szWndClassName
    push dword 0
    call [CreateWindowEx]
    test eax, eax
    jz near .Finish
    mov [hWnd], eax
    
    ; Zobrazenie okna
    push dword SW_SHOWNORMAL
    push dword [hWnd]
    call [ShowWindow]


; ------------------------- SLUCKA SPRAV ---------------------------------
.MessageLoop:
    push dword 0
    push dword 0
    push dword NULL
    push dword Message
    call [GetMessage]
    test eax,eax  
    jz near .Finish
    cmp eax,-1 
    jz near .Finish

    push dword Message
    call [TranslateMessage] 
    push dword Message
    call [DispatchMessage]  
    jmp .MessageLoop
    

.Finish:
    push dword NULL
    call [ExitProcess]
    
; ---------------------- PROCEDURA OKNA ---------------------------------
    WndProc:
        WndProc_PARAMBYTES EQU 16
        enter 0,0
        
        mov eax,dword [ebp+12]
        cmp eax,WM_CREATE
            je near .Create
        cmp eax,WM_DESTROY
            je near .Destroy
        cmp eax,WM_CLOSE
            je near .Destroy
        cmp eax,WM_COMMAND ; je v eax sprava WM_COMMAND?
            je near .Command

            push dword [ebp+20]
            push dword [ebp+16]
            push dword [ebp+12]
            push dword [ebp+8]
            call [DefWindowProc]            
            jmp near .return

    
    .Create:
        ; Vytvorenie tlacidla
        push dword NULL
        push dword [hInstance]
        push dword NULL
        push dword [ebp+8]
        push dword 30
        push dword 140
        push dword 210
        push dword 80
        push dword WS_CHILD | BS_DEFPUSHBUTTON | WS_VISIBLE | WS_TABSTOP
        push dword szCButn
        push dword ClassNameStatButton
        push dword 0
        call [CreateWindowEx]
        mov [hButton], eax
        jmp near .return

    .Command:
        ; Kontrola, ci bolo kliknute na tlacidlo
        mov eax, [hButton]
        cmp [ebp+20], eax
        je near .CButton
        jmp near .return
        
    .CButton:
        ; Zobrazenie dialogoveho okna po kliknuti na tlacidlo
        push dword MB_OK | MB_ICONINFORMATION
        push dword cap_dialog
        push dword mes_dialog
        push dword NULL
        call [MessageBox]
        jmp near .return

    .Destroy:
        push dword 0
        call [PostQuitMessage]
        xor eax, eax
        jmp near .return
        
    .return:
        leave
        ret WndProc_PARAMBYTES
; ---------------------- / PROCEDURA OKNA ---------------------------------
