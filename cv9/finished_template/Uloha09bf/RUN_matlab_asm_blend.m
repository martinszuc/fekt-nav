% Autor: Miroslav Balík
% Source code: m-file Matlab
% Volani funkci z knihovny blend.dll v Matlabu
% hlavickovy soubor je v blend.h

% Uzavreni vsech grafu a smazani vsech promennych
close all; clear all; clc;

% fa je velikost prolinani mezi obrazky
fa=100; % rozsah je [0-255]

% nacteni knihovny
hfile1 = 'blend.h';
[notfound,warnings]=loadlibrary('blend.dll', hfile1,'mfilename','blend_mx');

if calllib('blend', 'MMXsupport');disp ('MMX je podporováno!'); end

hfile1 = 'tictoc.h';
[notfound,warnings]=loadlibrary('tictoc.dll', hfile1,'mfilename','tictoc_mx');
v=[0 0]; pv = libpointer('int32Ptr', v);

% import obrazku, prvni je png obrazek a druhy bmp
kostka=importdata('kostkyVELKE.png');
pozadi=importdata('pozadi.bmp');


% "rozklad" 3D pole do 2D pole. Konverze datovych typu, byte (8bit) na unsigned int
% (32bit). 
a=uint32(kostka.cdata);
A=(a(:,:,1)+  a(:,:,2)*256+  a(:,:,3)*(256^2)+  uint32(kostka.alpha)  *(256^3));

pozadi.alpha=255*uint8(ones(600,800));
b=uint32(pozadi.cdata);
B=(b(:,:,1)+  b(:,:,2)*256+  b(:,:,3)*(256^2)+  uint32(pozadi.alpha)  *(256^3));

%zobrazeni obou obrazku
figure; h=imshow(kostka.cdata);
set(h, 'AlphaData', kostka.alpha);
figure; h=imshow(pozadi.cdata);
set(h, 'AlphaData', pozadi.alpha);


% ziskani ukazatelu na A,B,fa.
pA = libpointer('uint32Ptr', A);
pB = libpointer('uint32Ptr', B);
faALL=(fa  +  fa*256^1  +  fa*256^2  +  fa*256^3);
pfa = libpointer('uint32Ptr', faALL);



%--------------------------------- ASM --------------------------------- 
%-----------------------------------
% Volani funkce blend z blend.dll
%-----------------------------------
calllib('tictoc', 'M_tic', pv);
calllib('blend','blend',pA,pB,pfa);
cas1=calllib('tictoc', 'M_toc', pv);
%-----------------------------------

% nove ukazate pA,pB ukazuji na vystupni obrazky. Z techto ukazatelu jsou
B2=double(get(pB,'Value'));

% Zpetny "rozklad" z 1D pole do 3D pole. Vystupni matice jsou v a2,b2.
% Alfa kanal je a2alpha a b2alpha.
b2alpha=uint8(fix(B2/(256^3)));
pom=B2-double(b2alpha)*(256^3);
b2(:,:,3)=uint8(fix(pom/(256^2)));
pom=pom-double(b2(:,:,3))*(256^2);
b2(:,:,2)=uint8(fix(pom/(256)));
pom=pom-double(b2(:,:,2))*(256);
b2(:,:,1)=uint8(fix(pom));

% Zobrazeni vystupnich obrazku.
figure; h=imshow(b2);
set(h, 'AlphaData', b2alpha);



%--------------------------------MATLAB-------------------------------- 
B2old=B2;

a=kostka.cdata; a(:,:,4)=kostka.alpha;
b=pozadi.cdata; b(:,:,4)=pozadi.alpha;
a=double(a); b=double(b); 
%-----------------------------------
% Volani funkce blend z matlabu
%-----------------------------------
calllib('tictoc', 'M_tic', pv);
a_out=blend_matlab(a,b,fa);
cas2=calllib('tictoc', 'M_toc', pv);
%-----------------------------------

% Zobrazeni vystupnich obrazku.
a_out=uint8(a_out);
figure; h=imshow(a_out(:,:,1:3));
set(h, 'AlphaData', a_out(:,:,4));

% smazani knihoven z matlabu
unloadlibrary blend
unloadlibrary tictoc

disp(['Doba trvaní funkce prolínání (ASM-MMX):  ',num2str(cas1),' us'])
disp(['Doba trvaní funkce prolínání (Matlab):   ',num2str(cas2),' us'])
