% Autor: Miroslav Bal�k
% Source code: m-file Matlab
% Volani funkci z knihovny mthrX32.dll v Matlabu
% hlavickovy soubor je v mthrX32.h

% Uzavreni vsech grafu a smazani vsech promennych
clear all; close all; clc

f1=1000;
f2=1100;
fs=8000;

Np=20;
N=8*1024;       %d�liteln� 8
disp(['Rozm�r matice DCT IV:                     ',num2str(N),' x ',num2str(N)])
disp(['Po�et opakov�n� v�po�tu DCT IV:           ',num2str(Np)])
n=0:N-1;
k=0:N-1;

%definice signalu
x=0.7*cos(2*pi*f1/fs*(0:N-1))+0.3*cos(2*pi*f2/fs*(0:N-1));

Lx=length(x);
%v�po�et DCT verze IV
M=cos(pi/N*(n'+1/2)*(k+1/2));
clear n k
% nacteni knihovny
hfile1 = 'mthrX32.h';
[notfound,warnings]=loadlibrary('mthrX32.dll', hfile1,'mfilename','mthrX32_mx');
fprintf ('Po�et fyzick�ch procesor� (jader):        %d\n',calllib('mthrX32', 'cCintelnew'))
fprintf ('Po�et logick�ch procesor�:                %d\n',calllib('mthrX32', 'cTintelnew'))


fprintf('V�po�et vxM v Matlabu DP 32b:                    ')
td=0;
for  i=1:Np
tic;
y=x*M;
td=td+toc/Np;
end
disp([num2str(td,6),' s'])
Ly=length(y);
plot(y* sqrt(2/N)), clear y
hold on
grid on

% volani jednoducha presnost
px = libpointer('singlePtr', x);pM = libpointer('singlePtr', M);
fprintf('V�po�et vxM v ASM pomoc� FPU SP 32b 1 vl�kno:    ')
td=0;
for  i=1:Np
y0=zeros(1,N); y0=single(y0); py0 = libpointer('singlePtr', y0);
tic;
calllib('mthrX32', 'vxm_x1_x87_sp', pM, px, py0, Lx, Ly);
td=td+toc/Np;
end
disp([num2str(td,6),' s'])
y_1_x87_sp=get(py0, 'Value');
plot(y_1_x87_sp* sqrt(2/N),'r'); clear y_1_x87_sp

fprintf('V�po�et vxM v ASM pomoc� FPU SP 32b 2 vl�kna:    ')
td=0;
for  i=1:Np
y0=zeros(1,N); y0=single(y0); py0 = libpointer('singlePtr', y0);
tic;
calllib('mthrX32', 'vxm_x2_x87_sp', pM, px, py0, Lx, Ly);
td=td+toc/Np;
end
disp([num2str(td,6),' s'])
y_2_x87_sp=get(py0, 'Value');
plot(y_2_x87_sp* sqrt(2/N),'g'); clear y_2_x87_sp

fprintf('V�po�et vxM v ASM pomoc� FPU SP 32b 4 vl�kna:    ')
td=0;
for  i=1:Np
y0=zeros(1,N); y0=single(y0); py0 = libpointer('singlePtr', y0);
tic;
calllib('mthrX32', 'vxm_x4_x87_sp', pM, px, py0, Lx, Ly);
td=td+toc/Np;
end
disp([num2str(td,6),' s'])
y_4_x87_sp=get(py0, 'Value');
plot(y_4_x87_sp* sqrt(2/N),'m'); clear y_4_x87_sp

fprintf('V�po�et vxM v ASM pomoc� FPU SP 32b 8 vl�ken:    ')
td=0;
for  i=1:Np
y0=zeros(1,N); y0=single(y0); py0 = libpointer('singlePtr', y0);
tic;
calllib('mthrX32', 'vxm_x8_x87_sp', pM, px, py0, Lx, Ly);
td=td+toc/Np;
end
disp([num2str(td,6),' s'])
y_8_x87_sp=get(py0, 'Value');
plot(y_8_x87_sp* sqrt(2/N),'k'); clear y_8_x87_sp


%volani dvojita presnost
px = libpointer('doublePtr', x);pM = libpointer('doublePtr', M);
fprintf('V�po�et vxM v ASM pomoc� FPU DP 32b 1 vl�kno:    ')
td=0;
for  i=1:Np
y0=zeros(1,N); y0=double(y0); py0 = libpointer('doublePtr', y0);
tic;
calllib('mthrX32', 'vxm_x1_x87_dp', pM, px, py0, Lx, Ly);
td=td+toc/Np;
end
disp([num2str(td,6),' s'])
y_1_x87_dp=get(py0, 'Value');
plot(y_1_x87_dp* sqrt(2/N),'r'); clear y_1_x87_dp

fprintf('V�po�et vxM v ASM pomoc� FPU DP 32b 2 vl�kna:    ')
td=0;
for  i=1:Np
y0=zeros(1,N); y0=double(y0); py0 = libpointer('doublePtr', y0);
tic;
calllib('mthrX32', 'vxm_x2_x87_dp', pM, px, py0, Lx, Ly);
td=td+toc/Np;
end
disp([num2str(td,6),' s'])
y_2_x87_dp=get(py0, 'Value');
plot(y_2_x87_dp* sqrt(2/N),'g'); clear y_2_x87_dp

fprintf('V�po�et vxM v ASM pomoc� FPU DP 32b 4 vl�kna:    ')
td=0;
for  i=1:Np
y0=zeros(1,N); y0=double(y0); py0 = libpointer('doublePtr', y0);
tic;
calllib('mthrX32', 'vxm_x4_x87_dp', pM, px, py0, Lx, Ly);
td=td+toc/Np;
end
disp([num2str(td,6),' s'])
y_4_x87_dp=get(py0, 'Value');
plot(y_4_x87_dp* sqrt(2/N),'m'); clear y_4_x87_dp

fprintf('V�po�et vxM v ASM pomoc� FPU DP 32b 8 vl�ken:    ')
td=0;
for  i=1:Np
y0=zeros(1,N); y0=double(y0); py0 = libpointer('doublePtr', y0);
tic;
calllib('mthrX32', 'vxm_x8_x87_dp', pM, px, py0, Lx, Ly);
td=td+toc/Np;
end
disp([num2str(td,6),' s'])
y_8_x87_dp=get(py0, 'Value');
plot(y_8_x87_dp* sqrt(2/N),'k'); clear y_8_x87_dp

legend('DCT IV vxM v Matlabu',...
    'DCT IV vxM x1 FPU SP',...
    'DCT IV vxM x2 FPU SP',...
    'DCT IV vxM x4 FPU SP',...
    'DCT IV vxM x8 FPU SP',...
    'DCT IV vxM x1 FPU DP',...
    'DCT IV vxM x2 FPU DP',...
    'DCT IV vxM x4 FPU DP',...
    'DCT IV vxM x8 FPU DP')

clear M

N=round(N/6)*6;       %d�liteln� 6
fprintf('\n')
disp(['Rozm�r matice DCT IV:                     ',num2str(N),' x ',num2str(N)])
disp(['Po�et opakov�n� v�po�tu DCT IV:           ',num2str(Np)])
n=0:N-1;
k=0:N-1;


%definice signalu
x=0.7*cos(2*pi*f1/fs*(0:N-1))+0.3*cos(2*pi*f2/fs*(0:N-1));

Lx=length(x);
%v�po�et DCT verze IV
M=cos(pi/N*(n'+1/2)*(k+1/2));
clear n k
figure
fprintf('V�po�et vxM v Matlabu DP 32b:                    ')
td=0;
for  i=1:Np
tic;
y=x*M;
td=td+toc/Np;
end
disp([num2str(td,6),' s'])
Ly=length(y);
plot(y* sqrt(2/N)); clear y
hold on
grid on


% volani 6 vlaken
fprintf('V�po�et vxM v ASM pomoc� FPU SP 32b 6 vl�ken:    ')
px = libpointer('singlePtr', x);pM = libpointer('singlePtr', M);
td=0;
for  i=1:Np
y0=zeros(1,N); y0=single(y0); py0 = libpointer('singlePtr', y0);
tic;
calllib('mthrX32', 'vxm_x6_x87_sp', pM, px, py0, Lx, Ly);
td=td+toc/Np;
end
disp([num2str(td,6),' s'])
y_6_x87_sp=get(py0, 'Value');
plot(y_6_x87_sp* sqrt(2/N),'r'); clear y_6_x87_sp


fprintf('V�po�et vxM v ASM pomoc� FPU DP 32b 6 vl�ken:    ')
px = libpointer('doublePtr', x);pM = libpointer('doublePtr', M);
td=0;
for  i=1:Np
y0=zeros(1,N); y0=double(y0); py0 = libpointer('doublePtr', y0);
tic;
calllib('mthrX32', 'vxm_x6_x87_dp', pM, px, py0, Lx, Ly);
td=td+toc/Np;
end
disp([num2str(td,6),' s'])
y_6_x87_dp=get(py0, 'Value');
plot(y_6_x87_dp* sqrt(2/N),'k'); clear y_6_x87_dp


legend('DCT IV vxM v Matlabu',...
    'DCT IV vxM x6 FPU SP',...
    'DCT IV vxM x6 FPU DP')

clear all
unloadlibrary mthrX32
