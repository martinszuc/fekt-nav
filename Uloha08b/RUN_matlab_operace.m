% Autor: Miroslav Balik
% Source code: m-file Matlab
% Volani funkce soucet a fpu_op (z knihovny operace.dll) v Matlabu
% hlavickovy soubor je v operace.h

close all; clear all; clc

hfile = ['operace.h'];
[notfound,warnings]=loadlibrary('operace.dll', hfile,'mfilename','operace_mx');

a=11;
b=-5;
c=3;

vys1=calllib('operace', 'soucet', a,b,c);

if (vys1==(a+b+c))
   disp('Sou�et sed� ...')
   vys1
else
   disp('V�sledek je �patn� ...')    
end

10/pi
vys2=calllib('operace', 'fpu_op', 10,pi)

unloadlibrary operace