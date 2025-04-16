% Autor: Miroslav Balik
% Source code: m-file Matlab
% Volani funkci z knihovny tictoc.dll v Matlabu
% hlavickovy soubor je v tictoc.h


close all; clear all; clc

hfile = ['tictoc.h'];
[notfound,warnings]=loadlibrary('tictoc.dll', hfile,'mfilename','tictoc_mx');
v=[0 0]; pv = libpointer('int32Ptr', v);

disp('Vydrž!')
tic
calllib('tictoc', 'M_tic', pv);
I=0; MAX=2*2e4;
for i=0:MAX
        I=I+1;
    for j=0:MAX
    end
end
t=toc;
disp(['Doba výpoètu pomocí M_toc:   ',num2str(calllib('tictoc', 'M_toc', pv)/1000000,15),' s'])    %pocita v mikrosekundach
disp(['Doba výpoètu pomocí M_rtoc:  ',num2str(calllib('tictoc', 'M_rtoc', pv)/1000,15),' s'])      %pocita v milisekundach
disp(['Doba výpoètu pomocí Matlabu: ',num2str(t,15),' s'])                                         %pocita v sekundach


unloadlibrary tictoc