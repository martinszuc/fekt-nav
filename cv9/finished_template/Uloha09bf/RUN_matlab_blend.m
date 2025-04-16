% Autor: Miroslav Balík
% Source code: m-file Matlab
% Volani funkce blend v Matlabu


% Uzavreni vsech grafu a smazani vsech promennych
close all; clear all; clc;

% fa je velikost prolinani mezi obrazky
fa=100; % rozsah je [0-255]

% nacteni knihovny
hfile1 = 'tictoc.h';
[notfound,warnings]=loadlibrary('tictoc.dll', hfile1,'mfilename','tictoc_mx');
v=[0 0]; pv = libpointer('int32Ptr', v);

% import obrazku, prvni je png obrazek a druhy bmp
kostka=importdata('kostkyVELKE.png');
pozadi=importdata('pozadi.bmp');
pozadi.alpha=255*uint8(ones(600,800));

%zobrazeni obou obrazku
figure; h=imshow(kostka.cdata);
set(h, 'AlphaData', kostka.alpha);
figure; h=imshow(pozadi.cdata);
set(h, 'AlphaData', pozadi.alpha);



%--------------------------------MATLAB-------------------------------- 
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
unloadlibrary tictoc

disp(['Doba trvaní funkce prolínání (Matlab):   ',num2str(cas2),' us'])
