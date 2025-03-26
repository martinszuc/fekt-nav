; ****************************************************************
; PROGRAM: S�riov� komunik�cia cez rozhranie RS232C
; AUTOR:   Martin Szuc
; D�TUM:   2025
; 
; POPIS:
;   Tento program vytv�ra textov� pou��vate�sk� rozhranie (TUI) pre s�riov� 
;   komunik�ciu. Umo��uje posiela� znaky nap�san� na lok�lnom po��ta�i
;   na vzdialen� po��ta� a zobrazova� znaky prijat� zo vzdialen�ho po��ta�a.
;

; ******************************** Makr� ***********************************
; Tieto makr� zjednodu�uj� be�n� oper�cie v programe:

; dosint - Vol� slu�bu preru�enia DOS
; Parameter: ��slo funkcie pre register AH
%macro dosint 1
            mov ah,%1         ; Na��taj ��slo funkcie do AH
            int 21h           ; Volaj preru�enie DOS (21h)
%endmacro

; vidint - Vol� slu�bu preru�enia Video BIOS
; Parameter: ��slo funkcie pre register AH
%macro vidint 1
            mov ah,%1         ; Na��taj ��slo funkcie do AH
            int 10h           ; Volaj preru�enie Video BIOS (10h)
%endmacro

; line - Zapisuje re�azec na obrazovku s atrib�tmi
; Parametre: 
;   1 - BP: Adresa re�azca na zobrazenie
;   2 - DH: Poz�cia riadku (0-24)
;   3 - DL: Poz�cia st�pca (0-79)
;   4 - CX: D�ka re�azca
;   5 - BL: Atrib�t farby (popredie/pozadie)
%macro line 5
            mov bh,0          ; BH = ��slo str�nky (0)
            mov al,0          ; AL = Re�im z�pisu (0 = bez pohybu kurzora)
            mov bp,%1         ; BP = Adresa zdrojov�ho re�azca
            mov dh,%2         ; DH = Poz�cia riadku
            mov dl,%3         ; DL = Poz�cia st�pca
            mov cx,%4         ; CX = D�ka re�azca
            mov bl,%5         ; BL = Atrib�t farby
            vidint 13h        ; Volaj INT 10h, Funkcia 13h (Z�pis re�azca)
%endmacro

; ******************************* Stack segment *****************************
; Definuje segment z�sobn�ka s 64 bajtmi vyhraden�ho priestoru
segment stack stack
            resb 64          ; Rezervuj 64 bajtov pre z�sobn�k
stacktop:                    ; Ozna�enie pre vrchol z�sobn�ka

; ******************************* Data segment ******************************
; Obsahuje v�etky d�tov� re�azce a prvky UI pou��van� v programe
segment data
; Hlavi�ka s n�zvom a inform�ciami o programe
h        db "Martin Szuc rozhrani"    
        times 10 db 32                 ; 10 spaces
        db "Serial Communication via RS232 Interface"
        times 1 db 32                 ; 1 space
        db "MNAV 2025"                

; �abl�na stredn�ho riadku (pou��va sa pre pr�zdne riadky)
r0       db 186                            ; �av� zvisl� �iara (�)
        times 78 db 32                     ; 78 medzier
        db 186                             ; Prav� zvisl� �iara (�)

; Horn� okraj d�tovej oblasti
r1       db 201                            ; �av� horn� roh (-)
        times 4 db 205                     ; 4 vodorovn� �iary (=)
        db " Sent data string: "           ; Textov� popis
        times 55 db 205                    ; 55 vodorovn�ch �iar
        db 187                             ; Prav� horn� roh (�)

; Stredn� odde�ova� d�tovej oblasti
r2       db 204                            ; �av� T-spojenie (+)
        times 4 db 205                     ; 4 vodorovn� �iary (=)
        db " Received data string: "       ; Textov� popis
        times 51 db 205                    ; 51 vodorovn�ch �iar
        db 185                             ; Prav� T-spojenie (+)

; Spodn� okraj d�tovej oblasti
r3       db 200                            ; �av� doln� roh (L)
        times 78 db 205                    ; 78 vodorovn�ch �iar (=)
        db 188                             ; Prav� doln� roh (-)

; P�ta s ovl�dac�mi prvkami a inform�ciami o pripojen�
p        db " ESC-End "                    ; In�trukcia na ukon�enie
        times 55 db 219                    ; 55 blokov�ch znakov (-)
        db " COM1 1200bps "                ; Inform�cie o pripojen�

; Potvrdzovacie dial�gov� okno
kon      db " Are you sure to end this program [y/n]? "
nkon     db "                                         "

; Poz�cie kurzora pre vysielacie a prij�macie okno
vydx     dw 0202h                          ; Vysielacie okno (riadok 2, st�pec 2)
prdx     dw 0d02h                          ; Prij�macie okno (riadok 13, st�pec 2)

; Premenn� na sledovanie akt�vneho okna a poz�cie kurzora
active_window db 0                         ; 0 = vysielacie okno, 1 = prij�macie okno
saved_cursor_pos dw 0                      ; Ulo�en� poz�cia kurzora

; ******************************* Code segment ******************************
; Obsahuje v�etok spustite�n� k�d programu
segment code
..start:    
            ; Inicializ�cia registrov segmentov pre spr�vne adresovanie pam�te
            mov ax,data       ; Z�skaj adresu d�tov�ho segmentu
            mov ds,ax         ; Nastav register d�tov�ho segmentu
            mov es,ax         ; Nastav register extra segmentu
            mov ax,stack      ; Z�skaj adresu segmentu z�sobn�ka
            mov ss,ax         ; Nastav register segmentu z�sobn�ka
            mov sp,stacktop   ; Inicializuj ukazovate� z�sobn�ka
            
            ; Inicializ�cia s�riov�ho rozhrania a u��vate�sk�ho rozhrania
            call port_init    ; Inicializuj s�riov� rozhranie
            call obrazovka    ; Vykresli u��vate�sk� rozhranie
 
            ; Hlavn� slu�ka programu
main:       dosint 0bh        ; DOS Funkcia 0Bh: Skontroluj stav kl�vesnice
            cmp al,0          ; AL = 0 ak nebola stla�en� �iadna kl�vesa
            je prijmi_data    ; Ak nebola stla�en� kl�vesa, skontroluj prijat� d�ta
            
            ; Kl�vesa bola stla�en�, pre��taj znak
            dosint 8          ; DOS Funkcia 08h: Pre��taj znak (bez echa)
            
            ; Skontroluj, �i bola stla�en� kl�vesa ESC
            cmp al,1bh        ; Porovnaj s ASCII k�dom pre ESC (27)
            jne mjmp1         ; Ak nie ESC, skontroluj �al�ie kl�vesy
            call dotaz        ; Ak ESC, zobraz potvrdzovacie okno
            jmp main          ; Vr� sa na za�iatok hlavnej slu�ky
            
mjmp1:      cmp al,8          ; Porovnaj s ASCII k�dom pre Backspace (8)
            jne mjmp2         ; Ak nie Backspace, skontroluj �al�ie kl�vesy
            
            ; Skontroluj, v ktorom okne sa nach�dza kurzor pred spracovan�m Backspace
            call check_window ; Skontroluj a aktualizuj akt�vne okno, ak je to potrebn�
            call backspace    ; Ak Backspace, obsl�� mazanie znaku
            call odesli       ; Odo�li znak Backspace cez s�riov� rozhranie
            jmp main          ; Vr� sa na za�iatok hlavnej slu�ky
            
mjmp2:      cmp al,0dh        ; Porovnaj s ASCII k�dom pre Enter (13)
            jne mjmp3         ; Ak nie Enter, skontroluj �al�ie kl�vesy
            
            ; Skontroluj, v ktorom okne sa nach�dza kurzor pred spracovan�m Enter
            call check_window ; Skontroluj a aktualizuj akt�vne okno, ak je to potrebn�
            call ent          ; Ak Enter, obsl�� nov� riadok
            call odesli       ; Odo�li znak Enter cez s�riov� rozhranie
            jmp main          ; Vr� sa na za�iatok hlavnej slu�ky
            
mjmp3:      ; Skontroluj, v ktorom okne sa nach�dza kurzor pred zap�san�m znaku
            call check_window ; Skontroluj a aktualizuj akt�vne okno, ak je to potrebn�
            call wrchar       ; Zap� znak na obrazovku
            call odesli       ; Odo�li znak cez s�riov� rozhranie
            jmp main          ; Vr� sa na za�iatok hlavnej slu�ky

; Kontrola prijat�ch d�t            
prijmi_data:
            ; Skontroluj, �i boli prijat� d�ta cez s�riov� rozhranie
            mov dx,3FDh       ; Adresa registra stavu linky
            in al,dx          ; Pre��taj stav linky do AL
            and al,1          ; Maskuj bit D0 (indik�tor prijat�ch d�t)
            cmp al,0          ; Skontroluj, �i s� prijat� d�ta
            je main           ; Ak nie s� prijat� d�ta, vr� sa na za�iatok
            
            ; Pred spracovan�m prijat�ch d�t zabezpe�, �e kurzor je v prij�macom okne
            call check_window_receive  ; Presmeruj kurzor do prij�macieho okna
            
            ; Ak s� prijat� d�ta, pre��taj ich
            mov dx,3F8h       ; Adresa registra d�t
            in al,dx          ; Pre��taj prijat� znak do AL
            
            ; Obsl�� prijat� d�ta pod�a ich hodnoty
            cmp al,8          ; Porovnaj s ASCII k�dom pre Backspace (8)
            jne prijmi_mjmp1  ; Ak nie Backspace, skontroluj �al�ie znaky
            call backspacep   ; Ak Backspace, obsl�� mazanie znaku v prij�macom okne
            jmp main          ; Vr� sa na za�iatok hlavnej slu�ky
            
prijmi_mjmp1:
            cmp al,0dh        ; Porovnaj s ASCII k�dom pre Enter (13)
            jne prijmi_mjmp2  ; Ak nie Enter, je to be�n� znak
            call entp         ; Ak Enter, obsl�� nov� riadok v prij�macom okne
            jmp main          ; Vr� sa na za�iatok hlavnej slu�ky
            
prijmi_mjmp2:
            call wrcharp      ; Zap� prijat� znak do prij�macieho okna
            jmp main          ; Vr� sa na za�iatok hlavnej slu�ky

; ********************************* Podprogramy *****************************

; check_window - Kontroluje a aktualizuje akt�vne okno na z�klade poz�cie kurzora
; Presmeruje kurzor z prij�macieho okna do vysielacieho okna pre odosielanie
check_window:
            push ax           ; Ulo� registre
            push bx
            push cx
            push dx
            
            ; Z�skaj aktu�lnu poz�ciu kurzora
            mov bh,0          ; ��slo str�nky
            vidint 3          ; Z�skaj poz�ciu kurzora, vr�ti DH=riadok, DL=st�pec
            
            ; Skontroluj, �i je kurzor v prij�macom okne (riadky 13-23)
            cmp dh,12         ; Porovnaj s prv�m riadkom oblasti prij�macieho okna
            jle check_win_end ; Ak riadok <= 12, u� sme vo vysielacom okne, nie je potrebn� zmena
            
            ; Sme v prij�macom okne, potrebujeme sa presun�� do vysielacieho okna
            mov byte [active_window], 1  ; Ozna� prij�macie okno ako akt�vne
            mov [saved_cursor_pos], dx   ; Ulo� aktu�lnu poz�ciu kurzora
            
            ; Presu� kurzor do poz�cie vysielacieho okna
            mov dx,[vydx]     ; Na��taj poz�ciu kurzora pre vysielacie okno
            mov bh,0          ; ��slo str�nky
            vidint 2          ; Nastav poz�ciu kurzora
            
            ; Aktualizuj pr�znak akt�vneho okna
            mov byte [active_window], 0  ; Ozna� vysielacie okno ako akt�vne
            
check_win_end:
            pop dx            ; Obnov registre
            pop cx
            pop bx
            pop ax
            ret               ; N�vrat z podprogramu

; check_window_receive - Kontroluje a aktualizuje akt�vne okno pre pr�jem d�t
; Presmeruje kurzor z vysielacieho okna do prij�macieho okna pre zobrazenie prijat�ch d�t
check_window_receive:
            push ax           ; Ulo� registre
            push bx
            push cx
            push dx
            
            ; Z�skaj aktu�lnu poz�ciu kurzora
            mov bh,0          ; ��slo str�nky
            vidint 3          ; Z�skaj poz�ciu kurzora, vr�ti DH=riadok, DL=st�pec
            
            ; Skontroluj, �i je kurzor vo vysielacom okne (riadky 1-12)
            cmp dh,12         ; Porovnaj s prv�m riadkom oblasti prij�macieho okna
            jg check_win_receive_end  ; Ak riadok > 12, u� sme v prij�macom okne, nie je potrebn� zmena
            
            ; Sme vo vysielacom okne, potrebujeme sa presun�� do prij�macieho okna
            mov byte [active_window], 0  ; Ozna� vysielacie okno ako akt�vne
            mov [saved_cursor_pos], dx   ; Ulo� aktu�lnu poz�ciu kurzora (pre n�vrat nasp�)
            mov [vydx], dx               ; Aktualizuj ulo�en� poz�ciu vysielacieho kurzora
            
            ; Presu� kurzor do poz�cie prij�macieho okna
            mov dx,[prdx]     ; Na��taj poz�ciu kurzora pre prij�macie okno
            mov bh,0          ; ��slo str�nky
            vidint 2          ; Nastav poz�ciu kurzora
            
            ; Aktualizuj pr�znak akt�vneho okna
            mov byte [active_window], 1  ; Ozna� prij�macie okno ako akt�vne
            
check_win_receive_end:
            pop dx            ; Obnov registre
            pop cx
            pop bx
            pop ax
            ret               ; N�vrat z podprogramu

; wrchar - Zap�e znak do vysielacieho okna a posunie kurzor
wrchar:
            mov dx,[vydx]     ; Na��taj aktu�lnu poz�ciu kurzora
            cmp dl,78         ; Skontroluj, �i sme na pravom okraji
            jl jm3            ; Ak nie sme na pravom okraji, sko� na jm3
            inc dh            ; Ak sme na pravom okraji, prejdi na nov� riadok
            cmp dh,12         ; Skontroluj, �i sme dosiahli spodok okna
            jl jm4            ; Ak nie sme na spodku, sko� na jm4
            call scrol        ; Ak sme na spodku, skroluj okno
jm4:        mov dl,2          ; Nastav kurzor na �av� okraj
            vidint 2          ; Nastav poz�ciu kurzora
jm3:        mov bh,0          ; Nastav ��slo str�nky na 0
            mov cx,1          ; Nastav po�et znakov na 1
            mov bl,1eh        ; Nastav farbu (�lt� na modrom pozad�)
            vidint 9          ; Zap� znak s atrib�tom
            inc dl            ; Posu� kurzor doprava
            vidint 2          ; Nastav nov� poz�ciu kurzora
            mov [vydx],dx     ; Ulo� nov� poz�ciu kurzora
            ret               ; N�vrat z podprogramu

; wrcharp - Zap�e znak do prij�macieho okna a posunie kurzor
wrcharp:
            mov dx,[prdx]     ; Na��taj aktu�lnu poz�ciu kurzora
            cmp dl,78         ; Skontroluj, �i sme na pravom okraji
            jl jm3p           ; Ak nie sme na pravom okraji, sko� na jm3p
            inc dh            ; Ak sme na pravom okraji, prejdi na nov� riadok
            cmp dh,23         ; Skontroluj, �i sme dosiahli spodok okna
            jl jm4p           ; Ak nie sme na spodku, sko� na jm4p
            call scrolp       ; Ak sme na spodku, skroluj okno
jm4p:       mov dl,2          ; Nastav kurzor na �av� okraj
            vidint 2          ; Nastav poz�ciu kurzora
jm3p:       mov bh,0          ; Nastav ��slo str�nky na 0
            mov cx,1          ; Nastav po�et znakov na 1
            mov bl,1eh        ; Nastav farbu (�lt� na modrom pozad�)
            vidint 9          ; Zap� znak s atrib�tom
            inc dl            ; Posu� kurzor doprava
            vidint 2          ; Nastav nov� poz�ciu kurzora
            mov [prdx],dx     ; Ulo� nov� poz�ciu kurzora
            ret               ; N�vrat z podprogramu

; backspace - Vyma�e posledn� znak vo vysielacom okne
backspace:
            mov dx,[vydx]     ; Na��taj aktu�lnu poz�ciu kurzora
            dec dl            ; Posu� kurzor do�ava
            cmp dl,1          ; Skontroluj, �i sme na �avom okraji
            jg jm5            ; Ak nie sme na �avom okraji, sko� na jm5
            mov dl,78         ; Ak sme na �avom okraji, prejdi na koniec predch�dzaj�ceho riadku
            dec dh            ; Posu� kurzor hore

; N�jdi posledn� nepr�zdny znak na predch�dzaj�com riadku
l3:         dec dl            ; Posu� kurzor do�ava
            cmp dl,1          ; Skontroluj, �i sme na �avom okraji
            je jm7            ; Ak sme na �avom okraji, sko� na jm7
            vidint 2          ; Nastav poz�ciu kurzora
            mov bh,0          ; Nastav ��slo str�nky na 0
            vidint 8          ; Pre��taj znak na aktu�lnej poz�cii
            cmp al,32         ; Porovnaj s medzerou
            je l3             ; Ak je to medzera, pokra�uj v h�adan�
jm7:        inc dl            ; Posu� kurzor doprava po n�jden� znaku

            cmp dh,1          ; Skontroluj, �i sme na hornom okraji
            jg jm5            ; Ak nie sme na hornom okraji, sko� na jm5
            mov dx,0202h      ; Ak sme na hornom okraji, nastav kurzor na za�iatok
jm5:        mov bh,0          ; Nastav ��slo str�nky na 0
            vidint 2          ; Nastav poz�ciu kurzora
            mov al,32         ; Nastav znak na medzeru
            mov cx,1          ; Nastav po�et znakov na 1
            mov bl,1eh        ; Nastav farbu (�lt� na modrom pozad�)
            vidint 9          ; Vyma� znak (nahra� medzerou)
            mov al,8          ; Nastav znak Backspace pre odoslanie
            mov [vydx],dx     ; Ulo� nov� poz�ciu kurzora
            ret               ; N�vrat z podprogramu

; backspacep - Vyma�e posledn� znak v prij�macom okne
backspacep:
            mov dx,[prdx]     ; Na��taj aktu�lnu poz�ciu kurzora
            dec dl            ; Posu� kurzor do�ava
            cmp dl,1          ; Skontroluj, �i sme na �avom okraji
            jg jm5p           ; Ak nie sme na �avom okraji, sko� na jm5p
            mov dl,78         ; Ak sme na �avom okraji, prejdi na koniec predch�dzaj�ceho riadku
            dec dh            ; Posu� kurzor hore

; N�jdi posledn� nepr�zdny znak na predch�dzaj�com riadku
l3p:        dec dl            ; Posu� kurzor do�ava
            cmp dl,1          ; Skontroluj, �i sme na �avom okraji
            je jm7p           ; Ak sme na �avom okraji, sko� na jm7p
            vidint 2          ; Nastav poz�ciu kurzora
            mov bh,0          ; Nastav ��slo str�nky na 0
            vidint 8          ; Pre��taj znak na aktu�lnej poz�cii
            cmp al,32         ; Porovnaj s medzerou
            je l3p            ; Ak je to medzera, pokra�uj v h�adan�
jm7p:       inc dl            ; Posu� kurzor doprava po n�jden� znaku

            cmp dh,12         ; Skontroluj, �i sme nad prij�mac�m oknom
            jg jm5p           ; Ak sme v prij�macom okne, sko� na jm5p
            mov dx,0d02h      ; Ak sme nad prij�mac�m oknom, nastav kurzor na za�iatok okna
jm5p:       mov bh,0          ; Nastav ��slo str�nky na 0
            vidint 2          ; Nastav poz�ciu kurzora
            mov al,32         ; Nastav znak na medzeru
            mov cx,1          ; Nastav po�et znakov na 1
            mov bl,1eh        ; Nastav farbu (�lt� na modrom pozad�)
            vidint 9          ; Vyma� znak (nahra� medzerou)
            mov al,8          ; Nastav znak Backspace
            mov [prdx],dx     ; Ulo� nov� poz�ciu kurzora
            ret               ; N�vrat z podprogramu

; ent - Vytvor� nov� riadok vo vysielacom okne
ent:
            mov dx,[vydx]     ; Na��taj aktu�lnu poz�ciu kurzora
            inc dh            ; Posu� kurzor dole
            cmp dh,12         ; Skontroluj, �i sme dosiahli spodok okna
            jl jm6            ; Ak nie sme na spodku, sko� na jm6
            call scrol        ; Ak sme na spodku, skroluj okno
jm6:        mov dl,2          ; Nastav kurzor na �av� okraj
            mov bh,0          ; Nastav ��slo str�nky na 0
            vidint 2          ; Nastav poz�ciu kurzora
            mov [vydx],dx     ; Ulo� nov� poz�ciu kurzora
            ret               ; N�vrat z podprogramu

; entp - Vytvor� nov� riadok v prij�macom okne
entp:
            mov dx,[prdx]     ; Na��taj aktu�lnu poz�ciu kurzora
            inc dh            ; Posu� kurzor dole
            cmp dh,23         ; Skontroluj, �i sme dosiahli spodok okna
            jl jm6p           ; Ak nie sme na spodku, sko� na jm6p
            call scrolp       ; Ak sme na spodku, skroluj okno
jm6p:       mov dl,2          ; Nastav kurzor na �av� okraj
            mov bh,0          ; Nastav ��slo str�nky na 0
            vidint 2          ; Nastav poz�ciu kurzora
            mov [prdx],dx     ; Ulo� nov� poz�ciu kurzora
            ret               ; N�vrat z podprogramu

; scrol - Skroluje vysielacie okno o jeden riadok nahor
scrol:
            push ax           ; Ulo� registre
            mov ch,2          ; Horn� riadok oblasti skrolovania
            mov cl,2          ; �av� st�pec
            mov dh,11         ; Spodn� riadok oblasti skrolovania
            mov dl,77         ; Prav� st�pec
            mov al,1          ; Po�et riadkov na skrolovanie
            mov bh,1fh        ; Atrib�t pre nov� pr�zdny riadok (biela na modrom pozad�)
            vidint 6          ; Skroluj okno nahor
            pop ax            ; Obnov registre
            mov bh,0          ; Obnov ��slo str�nky
            ret               ; N�vrat z podprogramu

; scrolp - Skroluje prij�macie okno o jeden riadok nahor
scrolp:
            push ax           ; Ulo� registre
            mov ch,13         ; Horn� riadok oblasti skrolovania
            mov cl,2          ; �av� st�pec
            mov dh,22         ; Spodn� riadok oblasti skrolovania
            mov dl,77         ; Prav� st�pec
            mov al,1          ; Po�et riadkov na skrolovanie
            mov bh,1fh        ; Atrib�t pre nov� pr�zdny riadok (biela na modrom pozad�)
            vidint 6          ; Skroluj okno nahor
            pop ax            ; Obnov registre
            mov bh,0          ; Obnov ��slo str�nky
            ret               ; N�vrat z podprogramu

; obrazovka - Vytvor� u��vate�sk� rozhranie aplik�cie
obrazovka:
            mov al,2          ; Nastav video re�im 2 (80x25 text s farbou)
            vidint 0          ; Video Funkcia 00h: Nastav video re�im
            
            ; Inicializuj registre pre kreslenie opakovanej strednej �asti
            mov dh,2          ; DH = Za�iato�n� riadok (2)
            mov bh,0          ; BH = ��slo str�nky (0)
            mov bp,r0         ; BP = Adresa �abl�ny riadku
            mov dl,0          ; DL = Za�iato�n� st�pec (0)
            mov bl,1fh        ; BL = Atrib�t farby (biela na modrom pozad�)

; Slu�ka na kreslenie pr�zdnych riadkov rozhrania
l1:         mov cx,80         ; CX = D�ka riadku (80 znakov)
            mov al,0          ; AL = Re�im z�pisu
            push dx           ; Ulo� poz�ciu riadku/st�pca
            vidint 13h        ; Video Funkcia 13h: Zap� re�azec
            pop dx            ; Obnov poz�ciu riadku/st�pca
            inc dh            ; Prejdi na �al�� riadok
            cmp dh,23         ; Skontroluj, �i sme dosiahli riadok 23
            jl l1             ; Ak nie, pokra�uj v slu�ke
            
            ; Nakresli �pecifick� �asti rozhrania pomocou makra line
            line h,0,0,80,0fh     ; Nakresli hlavi�ku (biela na �iernom pozad�)
            line r1,1,0,80,1fh    ; Nakresli horn� okraj (biela na modrom pozad�)
            line r2,12,0,80,1fh   ; Nakresli stredn� odde�ova� (biela na modrom pozad�)
            line r3,23,0,80,1fh   ; Nakresli spodn� okraj (biela na modrom pozad�)
            line p,24,1,78,70h    ; Nakresli p�tu (�ierna na bielom pozad�)
            
            ; Nastav kurzor na za�iatok vysielacieho okna
            mov dx,[vydx]     ; Na��taj poz�ciu kurzora pre vysielacie okno
            vidint 2          ; Nastav poz�ciu kurzora
            ret               ; N�vrat z podprogramu

; dotaz - Zobraz� potvrdzovacie okno pre ukon�enie programu
dotaz:
            line kon,24,17,41,70h  ; Zobraz potvrdzovacie okno (�ierna na bielom pozad�)
l2:         dosint 8              ; Pre��taj odpove� (bez echa)
            cmp al,79h            ; Je to mal� 'y'?
            je jm1                ; Ak �no, sko� na jm1 (ukon�enie)
            cmp al,59h            ; Je to ve�k� 'Y'?
            je jm1                ; Ak �no, sko� na jm1 (ukon�enie)
            cmp al,4eh            ; Je to mal� 'n'?
            je jm2                ; Ak �no, sko� na jm2 (zru�enie)
            cmp al,6eh            ; Je to ve�k� 'N'?
            jne l2                ; Ak nie, �akaj na platn� odpove�
jm2:        line nkon,24,17,41,0fh ; Vyma� dial�gov� okno
            ret                    ; N�vrat z podprogramu (pokra�uj v programe)
jm1:        mov al,2               ; Vy�isti obrazovku (re�im 2)
            vidint 0               ; Nastav video re�im
            mov al,0               ; N�vratov� k�d 0
            dosint 4Ch             ; Ukon�i program

; port_init - Inicializuje s�riov� rozhranie
port_init:
            ; Nastavenie re�imu nastavovania r�chlosti (DLAB = 1)
            mov al,80h             ; Bit 7 (DLAB) = 1
            mov dx,3FBh            ; Adresa registra riadenia linky
            out dx,al              ; Nastav DLAB na 1
            
            ; Nastavenie r�chlosti komunik�cie (1200 bps, deli� = 96)
            mov al,96              ; Doln� bajt deli�a (96)
            mov dx,3F8h            ; Adresa registra vysielania/prij�mania
            out dx,al              ; Nastav doln� bajt deli�a
            
            mov al,0               ; Horn� bajt deli�a (0)
            mov dx,3F9h            ; Adresa registra povolenia preru�en�
            out dx,al              ; Nastav horn� bajt deli�a
            
            ; Nastavenie parametrov d�tov�ho r�mca
            mov al,00000011b       ; 8 d�tov�ch bitov, 1 stop bit, �iadna parita, DLAB = 0
            mov dx,3FBh            ; Adresa registra riadenia linky
            out dx,al              ; Nastav parametre a prepni do re�imu komunik�cie
            ret                    ; N�vrat z podprogramu

; odesli - Odo�le znak cez s�riov� rozhranie
odesli:
            mov dx,3F8h            ; Adresa registra vysielania
            out dx,al              ; Odo�li znak
            
            ; �akaj, k�m nebude vysielac� register pr�zdny
l4:         mov dx,3FDh            ; Adresa registra stavu linky
            in al,dx               ; Pre��taj stav linky
            and al,00100000b       ; Maskuj bit D5 (indik�tor pr�zdneho vysielacieho registra)
            cmp al,0               ; Skontroluj, �i je vysielac� register pr�zdny
            je l4                  ; Ak nie je pr�zdny, pokra�uj v �akan�
            ret                    ; N�vrat z podprogramu
