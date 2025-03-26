; ****************************************************************
; PROGRAM: Sériová komunikácia cez rozhranie RS232C
; AUTOR:   Martin Szuc
; DÁTUM:   2025
; 
; POPIS:
;   Tento program vytvára textové pouívate¾ské rozhranie (TUI) pre sériovú 
;   komunikáciu. Umoòuje posiela znaky napísané na lokálnom poèítaèi
;   na vzdialenı poèítaè a zobrazova znaky prijaté zo vzdialeného poèítaèa.
;

; ******************************** Makrá ***********************************
; Tieto makrá zjednodušujú bené operácie v programe:

; dosint - Volá slubu prerušenia DOS
; Parameter: Èíslo funkcie pre register AH
%macro dosint 1
            mov ah,%1         ; Naèítaj èíslo funkcie do AH
            int 21h           ; Volaj prerušenie DOS (21h)
%endmacro

; vidint - Volá slubu prerušenia Video BIOS
; Parameter: Èíslo funkcie pre register AH
%macro vidint 1
            mov ah,%1         ; Naèítaj èíslo funkcie do AH
            int 10h           ; Volaj prerušenie Video BIOS (10h)
%endmacro

; line - Zapisuje reazec na obrazovku s atribútmi
; Parametre: 
;   1 - BP: Adresa reazca na zobrazenie
;   2 - DH: Pozícia riadku (0-24)
;   3 - DL: Pozícia ståpca (0-79)
;   4 - CX: Dåka reazca
;   5 - BL: Atribút farby (popredie/pozadie)
%macro line 5
            mov bh,0          ; BH = Èíslo stránky (0)
            mov al,0          ; AL = Reim zápisu (0 = bez pohybu kurzora)
            mov bp,%1         ; BP = Adresa zdrojového reazca
            mov dh,%2         ; DH = Pozícia riadku
            mov dl,%3         ; DL = Pozícia ståpca
            mov cx,%4         ; CX = Dåka reazca
            mov bl,%5         ; BL = Atribút farby
            vidint 13h        ; Volaj INT 10h, Funkcia 13h (Zápis reazca)
%endmacro

; ******************************* Stack segment *****************************
; Definuje segment zásobníka s 64 bajtmi vyhradeného priestoru
segment stack stack
            resb 64          ; Rezervuj 64 bajtov pre zásobník
stacktop:                    ; Oznaèenie pre vrchol zásobníka

; ******************************* Data segment ******************************
; Obsahuje všetky dátové reazce a prvky UI pouívané v programe
segment data
; Hlavièka s názvom a informáciami o programe
h        db "Martin Szuc rozhrani"    
        times 10 db 32                 ; 10 spaces
        db "Serial Communication via RS232 Interface"
        times 1 db 32                 ; 1 space
        db "MNAV 2025"                

; Šablóna stredného riadku (pouíva sa pre prázdne riadky)
r0       db 186                            ; ¼avá zvislá èiara (¦)
        times 78 db 32                     ; 78 medzier
        db 186                             ; Pravá zvislá èiara (¦)

; Hornı okraj dátovej oblasti
r1       db 201                            ; ¼avı hornı roh (-)
        times 4 db 205                     ; 4 vodorovné èiary (=)
        db " Sent data string: "           ; Textovı popis
        times 55 db 205                    ; 55 vodorovnıch èiar
        db 187                             ; Pravı hornı roh (¬)

; Strednı odde¾ovaè dátovej oblasti
r2       db 204                            ; ¼avé T-spojenie (+)
        times 4 db 205                     ; 4 vodorovné èiary (=)
        db " Received data string: "       ; Textovı popis
        times 51 db 205                    ; 51 vodorovnıch èiar
        db 185                             ; Pravé T-spojenie (+)

; Spodnı okraj dátovej oblasti
r3       db 200                            ; ¼avı dolnı roh (L)
        times 78 db 205                    ; 78 vodorovnıch èiar (=)
        db 188                             ; Pravı dolnı roh (-)

; Päta s ovládacími prvkami a informáciami o pripojení
p        db " ESC-End "                    ; Inštrukcia na ukonèenie
        times 55 db 219                    ; 55 blokovıch znakov (-)
        db " COM1 1200bps "                ; Informácie o pripojení

; Potvrdzovacie dialógové okno
kon      db " Are you sure to end this program [y/n]? "
nkon     db "                                         "

; Pozície kurzora pre vysielacie a prijímacie okno
vydx     dw 0202h                          ; Vysielacie okno (riadok 2, ståpec 2)
prdx     dw 0d02h                          ; Prijímacie okno (riadok 13, ståpec 2)

; Premenné na sledovanie aktívneho okna a pozície kurzora
active_window db 0                         ; 0 = vysielacie okno, 1 = prijímacie okno
saved_cursor_pos dw 0                      ; Uloená pozícia kurzora

; ******************************* Code segment ******************************
; Obsahuje všetok spustite¾nı kód programu
segment code
..start:    
            ; Inicializácia registrov segmentov pre správne adresovanie pamäte
            mov ax,data       ; Získaj adresu dátového segmentu
            mov ds,ax         ; Nastav register dátového segmentu
            mov es,ax         ; Nastav register extra segmentu
            mov ax,stack      ; Získaj adresu segmentu zásobníka
            mov ss,ax         ; Nastav register segmentu zásobníka
            mov sp,stacktop   ; Inicializuj ukazovate¾ zásobníka
            
            ; Inicializácia sériového rozhrania a uívate¾ského rozhrania
            call port_init    ; Inicializuj sériové rozhranie
            call obrazovka    ; Vykresli uívate¾ské rozhranie
 
            ; Hlavná sluèka programu
main:       dosint 0bh        ; DOS Funkcia 0Bh: Skontroluj stav klávesnice
            cmp al,0          ; AL = 0 ak nebola stlaèená iadna klávesa
            je prijmi_data    ; Ak nebola stlaèená klávesa, skontroluj prijaté dáta
            
            ; Klávesa bola stlaèená, preèítaj znak
            dosint 8          ; DOS Funkcia 08h: Preèítaj znak (bez echa)
            
            ; Skontroluj, èi bola stlaèená klávesa ESC
            cmp al,1bh        ; Porovnaj s ASCII kódom pre ESC (27)
            jne mjmp1         ; Ak nie ESC, skontroluj ïalšie klávesy
            call dotaz        ; Ak ESC, zobraz potvrdzovacie okno
            jmp main          ; Vrá sa na zaèiatok hlavnej sluèky
            
mjmp1:      cmp al,8          ; Porovnaj s ASCII kódom pre Backspace (8)
            jne mjmp2         ; Ak nie Backspace, skontroluj ïalšie klávesy
            
            ; Skontroluj, v ktorom okne sa nachádza kurzor pred spracovaním Backspace
            call check_window ; Skontroluj a aktualizuj aktívne okno, ak je to potrebné
            call backspace    ; Ak Backspace, obslú mazanie znaku
            call odesli       ; Odošli znak Backspace cez sériové rozhranie
            jmp main          ; Vrá sa na zaèiatok hlavnej sluèky
            
mjmp2:      cmp al,0dh        ; Porovnaj s ASCII kódom pre Enter (13)
            jne mjmp3         ; Ak nie Enter, skontroluj ïalšie klávesy
            
            ; Skontroluj, v ktorom okne sa nachádza kurzor pred spracovaním Enter
            call check_window ; Skontroluj a aktualizuj aktívne okno, ak je to potrebné
            call ent          ; Ak Enter, obslú novı riadok
            call odesli       ; Odošli znak Enter cez sériové rozhranie
            jmp main          ; Vrá sa na zaèiatok hlavnej sluèky
            
mjmp3:      ; Skontroluj, v ktorom okne sa nachádza kurzor pred zapísaním znaku
            call check_window ; Skontroluj a aktualizuj aktívne okno, ak je to potrebné
            call wrchar       ; Zapíš znak na obrazovku
            call odesli       ; Odošli znak cez sériové rozhranie
            jmp main          ; Vrá sa na zaèiatok hlavnej sluèky

; Kontrola prijatıch dát            
prijmi_data:
            ; Skontroluj, èi boli prijaté dáta cez sériové rozhranie
            mov dx,3FDh       ; Adresa registra stavu linky
            in al,dx          ; Preèítaj stav linky do AL
            and al,1          ; Maskuj bit D0 (indikátor prijatıch dát)
            cmp al,0          ; Skontroluj, èi sú prijaté dáta
            je main           ; Ak nie sú prijaté dáta, vrá sa na zaèiatok
            
            ; Pred spracovaním prijatıch dát zabezpeè, e kurzor je v prijímacom okne
            call check_window_receive  ; Presmeruj kurzor do prijímacieho okna
            
            ; Ak sú prijaté dáta, preèítaj ich
            mov dx,3F8h       ; Adresa registra dát
            in al,dx          ; Preèítaj prijatı znak do AL
            
            ; Obslú prijaté dáta pod¾a ich hodnoty
            cmp al,8          ; Porovnaj s ASCII kódom pre Backspace (8)
            jne prijmi_mjmp1  ; Ak nie Backspace, skontroluj ïalšie znaky
            call backspacep   ; Ak Backspace, obslú mazanie znaku v prijímacom okne
            jmp main          ; Vrá sa na zaèiatok hlavnej sluèky
            
prijmi_mjmp1:
            cmp al,0dh        ; Porovnaj s ASCII kódom pre Enter (13)
            jne prijmi_mjmp2  ; Ak nie Enter, je to benı znak
            call entp         ; Ak Enter, obslú novı riadok v prijímacom okne
            jmp main          ; Vrá sa na zaèiatok hlavnej sluèky
            
prijmi_mjmp2:
            call wrcharp      ; Zapíš prijatı znak do prijímacieho okna
            jmp main          ; Vrá sa na zaèiatok hlavnej sluèky

; ********************************* Podprogramy *****************************

; check_window - Kontroluje a aktualizuje aktívne okno na základe pozície kurzora
; Presmeruje kurzor z prijímacieho okna do vysielacieho okna pre odosielanie
check_window:
            push ax           ; Ulo registre
            push bx
            push cx
            push dx
            
            ; Získaj aktuálnu pozíciu kurzora
            mov bh,0          ; Èíslo stránky
            vidint 3          ; Získaj pozíciu kurzora, vráti DH=riadok, DL=ståpec
            
            ; Skontroluj, èi je kurzor v prijímacom okne (riadky 13-23)
            cmp dh,12         ; Porovnaj s prvım riadkom oblasti prijímacieho okna
            jle check_win_end ; Ak riadok <= 12, u sme vo vysielacom okne, nie je potrebná zmena
            
            ; Sme v prijímacom okne, potrebujeme sa presunú do vysielacieho okna
            mov byte [active_window], 1  ; Oznaè prijímacie okno ako aktívne
            mov [saved_cursor_pos], dx   ; Ulo aktuálnu pozíciu kurzora
            
            ; Presuò kurzor do pozície vysielacieho okna
            mov dx,[vydx]     ; Naèítaj pozíciu kurzora pre vysielacie okno
            mov bh,0          ; Èíslo stránky
            vidint 2          ; Nastav pozíciu kurzora
            
            ; Aktualizuj príznak aktívneho okna
            mov byte [active_window], 0  ; Oznaè vysielacie okno ako aktívne
            
check_win_end:
            pop dx            ; Obnov registre
            pop cx
            pop bx
            pop ax
            ret               ; Návrat z podprogramu

; check_window_receive - Kontroluje a aktualizuje aktívne okno pre príjem dát
; Presmeruje kurzor z vysielacieho okna do prijímacieho okna pre zobrazenie prijatıch dát
check_window_receive:
            push ax           ; Ulo registre
            push bx
            push cx
            push dx
            
            ; Získaj aktuálnu pozíciu kurzora
            mov bh,0          ; Èíslo stránky
            vidint 3          ; Získaj pozíciu kurzora, vráti DH=riadok, DL=ståpec
            
            ; Skontroluj, èi je kurzor vo vysielacom okne (riadky 1-12)
            cmp dh,12         ; Porovnaj s prvım riadkom oblasti prijímacieho okna
            jg check_win_receive_end  ; Ak riadok > 12, u sme v prijímacom okne, nie je potrebná zmena
            
            ; Sme vo vysielacom okne, potrebujeme sa presunú do prijímacieho okna
            mov byte [active_window], 0  ; Oznaè vysielacie okno ako aktívne
            mov [saved_cursor_pos], dx   ; Ulo aktuálnu pozíciu kurzora (pre návrat naspä)
            mov [vydx], dx               ; Aktualizuj uloenú pozíciu vysielacieho kurzora
            
            ; Presuò kurzor do pozície prijímacieho okna
            mov dx,[prdx]     ; Naèítaj pozíciu kurzora pre prijímacie okno
            mov bh,0          ; Èíslo stránky
            vidint 2          ; Nastav pozíciu kurzora
            
            ; Aktualizuj príznak aktívneho okna
            mov byte [active_window], 1  ; Oznaè prijímacie okno ako aktívne
            
check_win_receive_end:
            pop dx            ; Obnov registre
            pop cx
            pop bx
            pop ax
            ret               ; Návrat z podprogramu

; wrchar - Zapíše znak do vysielacieho okna a posunie kurzor
wrchar:
            mov dx,[vydx]     ; Naèítaj aktuálnu pozíciu kurzora
            cmp dl,78         ; Skontroluj, èi sme na pravom okraji
            jl jm3            ; Ak nie sme na pravom okraji, skoè na jm3
            inc dh            ; Ak sme na pravom okraji, prejdi na novı riadok
            cmp dh,12         ; Skontroluj, èi sme dosiahli spodok okna
            jl jm4            ; Ak nie sme na spodku, skoè na jm4
            call scrol        ; Ak sme na spodku, skroluj okno
jm4:        mov dl,2          ; Nastav kurzor na ¾avı okraj
            vidint 2          ; Nastav pozíciu kurzora
jm3:        mov bh,0          ; Nastav èíslo stránky na 0
            mov cx,1          ; Nastav poèet znakov na 1
            mov bl,1eh        ; Nastav farbu (ltá na modrom pozadí)
            vidint 9          ; Zapíš znak s atribútom
            inc dl            ; Posuò kurzor doprava
            vidint 2          ; Nastav novú pozíciu kurzora
            mov [vydx],dx     ; Ulo novú pozíciu kurzora
            ret               ; Návrat z podprogramu

; wrcharp - Zapíše znak do prijímacieho okna a posunie kurzor
wrcharp:
            mov dx,[prdx]     ; Naèítaj aktuálnu pozíciu kurzora
            cmp dl,78         ; Skontroluj, èi sme na pravom okraji
            jl jm3p           ; Ak nie sme na pravom okraji, skoè na jm3p
            inc dh            ; Ak sme na pravom okraji, prejdi na novı riadok
            cmp dh,23         ; Skontroluj, èi sme dosiahli spodok okna
            jl jm4p           ; Ak nie sme na spodku, skoè na jm4p
            call scrolp       ; Ak sme na spodku, skroluj okno
jm4p:       mov dl,2          ; Nastav kurzor na ¾avı okraj
            vidint 2          ; Nastav pozíciu kurzora
jm3p:       mov bh,0          ; Nastav èíslo stránky na 0
            mov cx,1          ; Nastav poèet znakov na 1
            mov bl,1eh        ; Nastav farbu (ltá na modrom pozadí)
            vidint 9          ; Zapíš znak s atribútom
            inc dl            ; Posuò kurzor doprava
            vidint 2          ; Nastav novú pozíciu kurzora
            mov [prdx],dx     ; Ulo novú pozíciu kurzora
            ret               ; Návrat z podprogramu

; backspace - Vymae poslednı znak vo vysielacom okne
backspace:
            mov dx,[vydx]     ; Naèítaj aktuálnu pozíciu kurzora
            dec dl            ; Posuò kurzor do¾ava
            cmp dl,1          ; Skontroluj, èi sme na ¾avom okraji
            jg jm5            ; Ak nie sme na ¾avom okraji, skoè na jm5
            mov dl,78         ; Ak sme na ¾avom okraji, prejdi na koniec predchádzajúceho riadku
            dec dh            ; Posuò kurzor hore

; Nájdi poslednı neprázdny znak na predchádzajúcom riadku
l3:         dec dl            ; Posuò kurzor do¾ava
            cmp dl,1          ; Skontroluj, èi sme na ¾avom okraji
            je jm7            ; Ak sme na ¾avom okraji, skoè na jm7
            vidint 2          ; Nastav pozíciu kurzora
            mov bh,0          ; Nastav èíslo stránky na 0
            vidint 8          ; Preèítaj znak na aktuálnej pozícii
            cmp al,32         ; Porovnaj s medzerou
            je l3             ; Ak je to medzera, pokraèuj v h¾adaní
jm7:        inc dl            ; Posuò kurzor doprava po nájdení znaku

            cmp dh,1          ; Skontroluj, èi sme na hornom okraji
            jg jm5            ; Ak nie sme na hornom okraji, skoè na jm5
            mov dx,0202h      ; Ak sme na hornom okraji, nastav kurzor na zaèiatok
jm5:        mov bh,0          ; Nastav èíslo stránky na 0
            vidint 2          ; Nastav pozíciu kurzora
            mov al,32         ; Nastav znak na medzeru
            mov cx,1          ; Nastav poèet znakov na 1
            mov bl,1eh        ; Nastav farbu (ltá na modrom pozadí)
            vidint 9          ; Vyma znak (nahraï medzerou)
            mov al,8          ; Nastav znak Backspace pre odoslanie
            mov [vydx],dx     ; Ulo novú pozíciu kurzora
            ret               ; Návrat z podprogramu

; backspacep - Vymae poslednı znak v prijímacom okne
backspacep:
            mov dx,[prdx]     ; Naèítaj aktuálnu pozíciu kurzora
            dec dl            ; Posuò kurzor do¾ava
            cmp dl,1          ; Skontroluj, èi sme na ¾avom okraji
            jg jm5p           ; Ak nie sme na ¾avom okraji, skoè na jm5p
            mov dl,78         ; Ak sme na ¾avom okraji, prejdi na koniec predchádzajúceho riadku
            dec dh            ; Posuò kurzor hore

; Nájdi poslednı neprázdny znak na predchádzajúcom riadku
l3p:        dec dl            ; Posuò kurzor do¾ava
            cmp dl,1          ; Skontroluj, èi sme na ¾avom okraji
            je jm7p           ; Ak sme na ¾avom okraji, skoè na jm7p
            vidint 2          ; Nastav pozíciu kurzora
            mov bh,0          ; Nastav èíslo stránky na 0
            vidint 8          ; Preèítaj znak na aktuálnej pozícii
            cmp al,32         ; Porovnaj s medzerou
            je l3p            ; Ak je to medzera, pokraèuj v h¾adaní
jm7p:       inc dl            ; Posuò kurzor doprava po nájdení znaku

            cmp dh,12         ; Skontroluj, èi sme nad prijímacím oknom
            jg jm5p           ; Ak sme v prijímacom okne, skoè na jm5p
            mov dx,0d02h      ; Ak sme nad prijímacím oknom, nastav kurzor na zaèiatok okna
jm5p:       mov bh,0          ; Nastav èíslo stránky na 0
            vidint 2          ; Nastav pozíciu kurzora
            mov al,32         ; Nastav znak na medzeru
            mov cx,1          ; Nastav poèet znakov na 1
            mov bl,1eh        ; Nastav farbu (ltá na modrom pozadí)
            vidint 9          ; Vyma znak (nahraï medzerou)
            mov al,8          ; Nastav znak Backspace
            mov [prdx],dx     ; Ulo novú pozíciu kurzora
            ret               ; Návrat z podprogramu

; ent - Vytvorí novı riadok vo vysielacom okne
ent:
            mov dx,[vydx]     ; Naèítaj aktuálnu pozíciu kurzora
            inc dh            ; Posuò kurzor dole
            cmp dh,12         ; Skontroluj, èi sme dosiahli spodok okna
            jl jm6            ; Ak nie sme na spodku, skoè na jm6
            call scrol        ; Ak sme na spodku, skroluj okno
jm6:        mov dl,2          ; Nastav kurzor na ¾avı okraj
            mov bh,0          ; Nastav èíslo stránky na 0
            vidint 2          ; Nastav pozíciu kurzora
            mov [vydx],dx     ; Ulo novú pozíciu kurzora
            ret               ; Návrat z podprogramu

; entp - Vytvorí novı riadok v prijímacom okne
entp:
            mov dx,[prdx]     ; Naèítaj aktuálnu pozíciu kurzora
            inc dh            ; Posuò kurzor dole
            cmp dh,23         ; Skontroluj, èi sme dosiahli spodok okna
            jl jm6p           ; Ak nie sme na spodku, skoè na jm6p
            call scrolp       ; Ak sme na spodku, skroluj okno
jm6p:       mov dl,2          ; Nastav kurzor na ¾avı okraj
            mov bh,0          ; Nastav èíslo stránky na 0
            vidint 2          ; Nastav pozíciu kurzora
            mov [prdx],dx     ; Ulo novú pozíciu kurzora
            ret               ; Návrat z podprogramu

; scrol - Skroluje vysielacie okno o jeden riadok nahor
scrol:
            push ax           ; Ulo registre
            mov ch,2          ; Hornı riadok oblasti skrolovania
            mov cl,2          ; ¼avı ståpec
            mov dh,11         ; Spodnı riadok oblasti skrolovania
            mov dl,77         ; Pravı ståpec
            mov al,1          ; Poèet riadkov na skrolovanie
            mov bh,1fh        ; Atribút pre novı prázdny riadok (biela na modrom pozadí)
            vidint 6          ; Skroluj okno nahor
            pop ax            ; Obnov registre
            mov bh,0          ; Obnov èíslo stránky
            ret               ; Návrat z podprogramu

; scrolp - Skroluje prijímacie okno o jeden riadok nahor
scrolp:
            push ax           ; Ulo registre
            mov ch,13         ; Hornı riadok oblasti skrolovania
            mov cl,2          ; ¼avı ståpec
            mov dh,22         ; Spodnı riadok oblasti skrolovania
            mov dl,77         ; Pravı ståpec
            mov al,1          ; Poèet riadkov na skrolovanie
            mov bh,1fh        ; Atribút pre novı prázdny riadok (biela na modrom pozadí)
            vidint 6          ; Skroluj okno nahor
            pop ax            ; Obnov registre
            mov bh,0          ; Obnov èíslo stránky
            ret               ; Návrat z podprogramu

; obrazovka - Vytvorí uívate¾ské rozhranie aplikácie
obrazovka:
            mov al,2          ; Nastav video reim 2 (80x25 text s farbou)
            vidint 0          ; Video Funkcia 00h: Nastav video reim
            
            ; Inicializuj registre pre kreslenie opakovanej strednej èasti
            mov dh,2          ; DH = Zaèiatoènı riadok (2)
            mov bh,0          ; BH = Èíslo stránky (0)
            mov bp,r0         ; BP = Adresa šablóny riadku
            mov dl,0          ; DL = Zaèiatoènı ståpec (0)
            mov bl,1fh        ; BL = Atribút farby (biela na modrom pozadí)

; Sluèka na kreslenie prázdnych riadkov rozhrania
l1:         mov cx,80         ; CX = Dåka riadku (80 znakov)
            mov al,0          ; AL = Reim zápisu
            push dx           ; Ulo pozíciu riadku/ståpca
            vidint 13h        ; Video Funkcia 13h: Zapíš reazec
            pop dx            ; Obnov pozíciu riadku/ståpca
            inc dh            ; Prejdi na ïalší riadok
            cmp dh,23         ; Skontroluj, èi sme dosiahli riadok 23
            jl l1             ; Ak nie, pokraèuj v sluèke
            
            ; Nakresli špecifické èasti rozhrania pomocou makra line
            line h,0,0,80,0fh     ; Nakresli hlavièku (biela na èiernom pozadí)
            line r1,1,0,80,1fh    ; Nakresli hornı okraj (biela na modrom pozadí)
            line r2,12,0,80,1fh   ; Nakresli strednı odde¾ovaè (biela na modrom pozadí)
            line r3,23,0,80,1fh   ; Nakresli spodnı okraj (biela na modrom pozadí)
            line p,24,1,78,70h    ; Nakresli pätu (èierna na bielom pozadí)
            
            ; Nastav kurzor na zaèiatok vysielacieho okna
            mov dx,[vydx]     ; Naèítaj pozíciu kurzora pre vysielacie okno
            vidint 2          ; Nastav pozíciu kurzora
            ret               ; Návrat z podprogramu

; dotaz - Zobrazí potvrdzovacie okno pre ukonèenie programu
dotaz:
            line kon,24,17,41,70h  ; Zobraz potvrdzovacie okno (èierna na bielom pozadí)
l2:         dosint 8              ; Preèítaj odpoveï (bez echa)
            cmp al,79h            ; Je to malé 'y'?
            je jm1                ; Ak áno, skoè na jm1 (ukonèenie)
            cmp al,59h            ; Je to ve¾ké 'Y'?
            je jm1                ; Ak áno, skoè na jm1 (ukonèenie)
            cmp al,4eh            ; Je to malé 'n'?
            je jm2                ; Ak áno, skoè na jm2 (zrušenie)
            cmp al,6eh            ; Je to ve¾ké 'N'?
            jne l2                ; Ak nie, èakaj na platnú odpoveï
jm2:        line nkon,24,17,41,0fh ; Vyma dialógové okno
            ret                    ; Návrat z podprogramu (pokraèuj v programe)
jm1:        mov al,2               ; Vyèisti obrazovku (reim 2)
            vidint 0               ; Nastav video reim
            mov al,0               ; Návratovı kód 0
            dosint 4Ch             ; Ukonèi program

; port_init - Inicializuje sériové rozhranie
port_init:
            ; Nastavenie reimu nastavovania rıchlosti (DLAB = 1)
            mov al,80h             ; Bit 7 (DLAB) = 1
            mov dx,3FBh            ; Adresa registra riadenia linky
            out dx,al              ; Nastav DLAB na 1
            
            ; Nastavenie rıchlosti komunikácie (1200 bps, deliè = 96)
            mov al,96              ; Dolnı bajt delièa (96)
            mov dx,3F8h            ; Adresa registra vysielania/prijímania
            out dx,al              ; Nastav dolnı bajt delièa
            
            mov al,0               ; Hornı bajt delièa (0)
            mov dx,3F9h            ; Adresa registra povolenia prerušení
            out dx,al              ; Nastav hornı bajt delièa
            
            ; Nastavenie parametrov dátového rámca
            mov al,00000011b       ; 8 dátovıch bitov, 1 stop bit, iadna parita, DLAB = 0
            mov dx,3FBh            ; Adresa registra riadenia linky
            out dx,al              ; Nastav parametre a prepni do reimu komunikácie
            ret                    ; Návrat z podprogramu

; odesli - Odošle znak cez sériové rozhranie
odesli:
            mov dx,3F8h            ; Adresa registra vysielania
            out dx,al              ; Odošli znak
            
            ; Èakaj, kım nebude vysielací register prázdny
l4:         mov dx,3FDh            ; Adresa registra stavu linky
            in al,dx               ; Preèítaj stav linky
            and al,00100000b       ; Maskuj bit D5 (indikátor prázdneho vysielacieho registra)
            cmp al,0               ; Skontroluj, èi je vysielací register prázdny
            je l4                  ; Ak nie je prázdny, pokraèuj v èakaní
            ret                    ; Návrat z podprogramu
