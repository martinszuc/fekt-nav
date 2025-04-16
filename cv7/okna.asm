; Autor: Martin Szuc (ID: 231284) - vylepöen· verzia
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
extern SetTimer
import SetTimer user32.dll
extern KillTimer
import KillTimer user32.dll
extern GetClientRect
import GetClientRect user32.dll
extern SetWindowText
import SetWindowText user32.dll SetWindowTextA
extern GetWindowText
import GetWindowText user32.dll GetWindowTextA
extern CreateMenu
import CreateMenu user32.dll
extern CreatePopupMenu
import CreatePopupMenu user32.dll
extern AppendMenu
import AppendMenu user32.dll AppendMenuA
extern SetMenu
import SetMenu user32.dll
extern InvalidateRect
import InvalidateRect user32.dll
extern GetSysColor
import GetSysColor user32.dll

; DefinÌcie menu identifik·torov
%define IDM_ABOUT      101
%define IDM_EXIT       102
%define IDM_COLOR      103
%define IDM_HELP       104

; DefinÌcie ËasovaËa
%define TIMER_ID       1
%define TIMER_TIMEOUT  1000    ; 1 sekunda

; Datovy segment
; **************************************************************************
[section .data class=DATA use32 align=16]

; textove retazce
szWndClassName:       DB "WIN_CLASS32_ENHANCED",0
ClassNameStatButton:  DB "BUTTON",0
ClassNameEdit:        DB "EDIT",0
ClassNameStatic:      DB "STATIC",0
szCButn:              DB "Dialogove okno...",0
szClearBtn:           DB "Vymazaù",0
szCopyBtn:            DB "KopÌrovaù text",0
szLabel:              DB "Zadajte text:",0
cap_dialog:           DB "Nadpis dialogovÈ okno",0
mes_dialog:           DB "Text dialogovÈho okna.",0
szWndCaption:         DB "VylepöenÈ okno - CV7 Martin Szuc",0
szAboutTitle:         DB "O programe",0
szAboutMessage:       DB "Vylepöen· uk·ûka Win32 API v assembleri.",0
szHelpTitle:          DB "Pomoc",0
szHelpMessage:        DB "F1 - Pomoc, F2 - Zmena farby, ESC - Koniec",0
szDefaultEditText:    DB "Hello World!",0

; Status texty
szDialogShown:        DB "DialogovÈ okno bolo zobrazenÈ",0
szTextCopied:         DB "Text bol skopÌrovan˝",0
szTextCleared:        DB "Text bol vymazan˝",0
szColorChanged:       DB "Farba bola zmenen·",0
szCopiedTitle:        DB "SkopÌrovan˝ text",0

; menu poloûky
szFile:               DB "&S˙bor",0
szAbout:              DB "&O programe",0
szExit:               DB "&Koniec",0
szOptions:            DB "&Moûnosti",0
szColor:              DB "&Zmeniù farbu",0
szHelp:               DB "&Pomoc",0

; handly
hInstance             dd      0       ; instanc handle
hWnd                  dd      0       ; window handle
hButton               dd      0       ; button handle
hClearButton          dd      0       ; clear button handle
hCopyButton           dd      0       ; copy button handle
hEditBox              dd      0       ; edit box handle
hLabel                dd      0       ; label handle
hMenu                 dd      0       ; menu handle
hFileMenu             dd      0       ; file submenu handle
hOptionsMenu          dd      0       ; options submenu handle

; globalne premenne
Message:              resb    MSG_size    ; alokacia miesta v pamati pre spravu
BackgroundColor:      dd      COLOR_BACKGROUND ; aktu·lna farba pozadia
TextBuffer:           resb    256         ; buffer pre text

; Definicia struktury WndClass
WndClass:
    istruc WNDCLASSEX
        at WNDCLASSEX.cbSize, dd WNDCLASSEX_size
        at WNDCLASSEX.style, dd CS_VREDRAW + CS_HREDRAW + CS_GLOBALCLASS
        at WNDCLASSEX.lpfnWndProc, dd WndProc
        at WNDCLASSEX.cbClsExtra, dd 0
        at WNDCLASSEX.cbWndExtra, dd 0
        at WNDCLASSEX.hInstance, dd NULL
        at WNDCLASSEX.hIcon, dd NULL
        at WNDCLASSEX.hCursor, dd NULL
        at WNDCLASSEX.hbrBackground, dd COLOR_WINDOW
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
    
    ; Vytvorenie menu systÈmu
    call CreateAppMenu
    
    ; Vytvorenie hlavneho okna (teraz v‰Ëöie pre viac komponentov)
    push dword NULL
    push dword [hInstance]
    push dword NULL
    push dword NULL
    push dword 400             ; v˝öka
    push dword 500             ; öÌrka
    push dword 100             ; y pozÌcia
    push dword 100             ; x pozÌcia
    push dword WS_OVERLAPPEDWINDOW   ; öt˝l okna s plnou podporou pre vöetky funkcie
    push dword szWndCaption
    push dword szWndClassName
    push dword 0
    call [CreateWindowEx]
    test eax, eax
    jz near .Finish
    mov [hWnd], eax
    
    ; Priradenie menu k oknu
    push dword [hMenu]
    push dword [hWnd]
    call [SetMenu]
    
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
    test eax, eax  
    jz near .Finish
    cmp eax, -1 
    jz near .Finish

    push dword Message
    call [TranslateMessage] 
    push dword Message
    call [DispatchMessage]  
    jmp .MessageLoop
    
.Finish:
    push dword NULL
    call [ExitProcess]
    
; ---------------------- PROCEDURA PRE VYTVORENIE MENU -----------------
CreateAppMenu:
    ; Vytvorenie hlavnÈho menu
    call [CreateMenu]
    mov [hMenu], eax
    
    ; Vytvorenie submenu S˙bor
    call [CreatePopupMenu]
    mov [hFileMenu], eax
    
    ; Pridanie poloûiek do menu S˙bor
    push dword IDM_ABOUT
    push dword MF_STRING
    push dword szAbout
    push dword [hFileMenu]
    call [AppendMenu]
    
    push dword IDM_EXIT
    push dword MF_STRING
    push dword szExit
    push dword [hFileMenu]
    call [AppendMenu]
    
    ; Vytvorenie submenu Moûnosti
    call [CreatePopupMenu]
    mov [hOptionsMenu], eax
    
    ; Pridanie poloûiek do menu Moûnosti
    push dword IDM_COLOR
    push dword MF_STRING
    push dword szColor
    push dword [hOptionsMenu]
    call [AppendMenu]
    
    push dword IDM_HELP
    push dword MF_STRING
    push dword szHelp
    push dword [hOptionsMenu]
    call [AppendMenu]
    
    ; Pridanie submenu do hlavnÈho menu
    push dword [hFileMenu]
    push dword MF_POPUP
    push dword szFile
    push dword [hMenu]
    call [AppendMenu]
    
    push dword [hOptionsMenu]
    push dword MF_POPUP
    push dword szOptions
    push dword [hMenu]
    call [AppendMenu]
    
    ret
    
; ---------------------- PROCEDURA OKNA ---------------------------------
WndProc:
    WndProc_PARAMBYTES EQU 16
    enter 0, 0
    
    mov eax, dword [ebp+12]    ; zÌskanie typu spr·vy
    
    ; Spracovanie rÙznych typov spr·v
    cmp eax, WM_CREATE
        je near .Create
    cmp eax, WM_DESTROY
        je near .Destroy
    cmp eax, WM_CLOSE
        je near .Destroy
    cmp eax, WM_COMMAND        ; je v eax sprava WM_COMMAND?
        je near .Command
    cmp eax, WM_KEYDOWN
        je near .KeyDown
        
    ; Ak spr·va nie je zachyten·, pouûijeme default handler
    push dword [ebp+20]
    push dword [ebp+16]
    push dword [ebp+12]
    push dword [ebp+8]
    call [DefWindowProc]            
    jmp near .return

.Create:
    ; Vytvorenie komponenty Label (popis)
    push dword NULL
    push dword [hInstance]
    push dword NULL
    push dword [ebp+8]    ; hWnd
    push dword 20         ; v˝öka
    push dword 100        ; öÌrka
    push dword 20         ; y pozÌcia
    push dword 20         ; x pozÌcia
    push dword WS_CHILD | WS_VISIBLE | SS_LEFT
    push dword szLabel
    push dword ClassNameStatic
    push dword 0
    call [CreateWindowEx]
    mov [hLabel], eax
    
    ; Vytvorenie komponenty Edit box (textovÈ pole)
    push dword NULL
    push dword [hInstance]
    push dword NULL
    push dword [ebp+8]    ; hWnd
    push dword 25         ; v˝öka
    push dword 300        ; öÌrka
    push dword 50         ; y pozÌcia
    push dword 20         ; x pozÌcia
    push dword WS_CHILD | WS_VISIBLE | WS_BORDER | ES_AUTOHSCROLL
    push dword szDefaultEditText
    push dword ClassNameEdit
    push dword 0
    call [CreateWindowEx]
    mov [hEditBox], eax
    
    ; Vytvorenie tlaËidla "DialogovÈ okno"
    push dword NULL
    push dword [hInstance]
    push dword NULL
    push dword [ebp+8]    ; hWnd
    push dword 30         ; v˝öka
    push dword 150        ; öÌrka
    push dword 90         ; y pozÌcia
    push dword 20         ; x pozÌcia
    push dword WS_CHILD | BS_DEFPUSHBUTTON | WS_VISIBLE | WS_TABSTOP
    push dword szCButn
    push dword ClassNameStatButton
    push dword 0
    call [CreateWindowEx]
    mov [hButton], eax
    
    ; Vytvorenie tlaËidla "Vymazaù"
    push dword NULL
    push dword [hInstance]
    push dword NULL
    push dword [ebp+8]    ; hWnd
    push dword 30         ; v˝öka
    push dword 100        ; öÌrka
    push dword 90         ; y pozÌcia
    push dword 180        ; x pozÌcia
    push dword WS_CHILD | BS_PUSHBUTTON | WS_VISIBLE | WS_TABSTOP
    push dword szClearBtn
    push dword ClassNameStatButton
    push dword 0
    call [CreateWindowEx]
    mov [hClearButton], eax
    
    ; Vytvorenie tlaËidla "KopÌrovaù text"
    push dword NULL
    push dword [hInstance]
    push dword NULL
    push dword [ebp+8]    ; hWnd
    push dword 30         ; v˝öka
    push dword 150        ; öÌrka
    push dword 90         ; y pozÌcia
    push dword 290        ; x pozÌcia
    push dword WS_CHILD | BS_PUSHBUTTON | WS_VISIBLE | WS_TABSTOP
    push dword szCopyBtn
    push dword ClassNameStatButton
    push dword 0
    call [CreateWindowEx]
    mov [hCopyButton], eax
    
    jmp near .return

.Command:
    ; Zistenie, Ëo spÙsobilo WM_COMMAND (menu alebo kontroln˝ prvok)
    mov eax, [ebp+16]     ; wParam
    
    ; Kontrola ID menu poloûiek
    cmp ax, IDM_EXIT
    je near .Destroy
    
    cmp ax, IDM_ABOUT
    je near .ShowAbout
    
    cmp ax, IDM_COLOR
    je near .ChangeColor
    
    cmp ax, IDM_HELP
    je near .ShowHelp
    
    ; Kontrola, Ëi bolo kliknutÈ na niektorÈ tlaËidlo
    mov eax, [hButton]
    cmp [ebp+20], eax      ; lParam obsahuje handle kontrolnÈho prvku
    je near .CButton
    
    mov eax, [hClearButton]
    cmp [ebp+20], eax
    je near .ClearButton
    
    mov eax, [hCopyButton]
    cmp [ebp+20], eax
    je near .CopyButton
    
    jmp near .return
    
.CButton:
    ; Zobrazenie dialogovÈho okna po kliknutÌ na tlaËidlo
    push dword MB_OK | MB_ICONINFORMATION
    push dword cap_dialog
    push dword mes_dialog
    push dword [hWnd]     ; pouûÌvame hlavnÈ okno ako rodiËa
    call [MessageBox]
    
    jmp near .return

.ClearButton:
    ; Vymazanie textu v editovacom poli
    push dword 0          ; pr·zdny reùazec
    push dword [hEditBox]
    call [SetWindowText]
    
    jmp near .return

.CopyButton:
    ; ZÌskanie textu z editboxu a jeho kÛpia do bufferu
    push dword 255
    push dword TextBuffer
    push dword [hEditBox]
    call [GetWindowText]
    
    ; Zobrazenie dialogovÈho okna so skopÌrovan˝m textom
    push dword MB_OK | MB_ICONINFORMATION
    push dword szCopiedTitle
    push dword TextBuffer
    push dword [hWnd]
    call [MessageBox]
    
    jmp near .return

.ShowAbout:
    ; Zobrazenie dialogovÈho okna "O programe"
    push dword MB_OK | MB_ICONINFORMATION
    push dword szAboutTitle
    push dword szAboutMessage
    push dword [hWnd]
    call [MessageBox]
    
    jmp near .return

.ChangeColor:
    ; Zmena farby pozadia okna
    ; Jednoduch· implement·cia - prepÌnanie medzi pÙvodnou farbou a sivou
    mov eax, [WndClass + WNDCLASSEX.hbrBackground]
    
    cmp eax, COLOR_WINDOW
    je .SetGrayColor
    
    ; Inak nastavÌme sp‰ù na pÙvodn˙ farbu
    mov dword [WndClass + WNDCLASSEX.hbrBackground], COLOR_WINDOW
    jmp .RedrawWindow
    
.SetGrayColor:
    mov dword [WndClass + WNDCLASSEX.hbrBackground], COLOR_BTNFACE
    
.RedrawWindow:
    ; Vyn˙tenie prekresæovania okna
    push dword TRUE       ; Prekreslenie
    push dword NULL       ; CelÈ klientske okno
    push dword [hWnd]
    call [InvalidateRect]
    
    jmp near .return

.ShowHelp:
    ; Zobrazenie pomocnÈho dialogovÈho okna
    push dword MB_OK | MB_ICONINFORMATION
    push dword szHelpTitle
    push dword szHelpMessage
    push dword [hWnd]
    call [MessageBox]
    
    jmp near .return

.KeyDown:
    ; Obsluha kl·vesov˝ch skratiek
    mov eax, [ebp+16]     ; wParam obsahuje kÛd kl·vesy
    
    cmp eax, VK_ESCAPE    ; ESC = koniec
    je near .Destroy
    
    cmp eax, VK_F1        ; F1 = pomoc
    je near .ShowHelp
    
    cmp eax, VK_F2        ; F2 = zmena farby
    je near .ChangeColor
    
    jmp near .return

.Destroy:
    ; UkonËenie aplik·cie
    push dword 0
    call [PostQuitMessage]
    xor eax, eax
    jmp near .return
    
.return:
    leave
    ret WndProc_PARAMBYTES
; ---------------------- / PROCEDURA OKNA ---------------------------------
