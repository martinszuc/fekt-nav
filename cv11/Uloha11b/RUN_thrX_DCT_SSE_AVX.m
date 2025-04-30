% Autor: Miroslav Balík
% Source code: m-file Matlab
% Volani funkci z knihovny mthrX32.dll v Matlabu
% hlavickovy soubor je v mthrX32.h

% Uzavreni vsech grafu a smazani vsech promennych
clear all; close all; clc

f1=1000;
f2=1100;
fs=8000;

Np=20;
N=8*1024;       %dìlitelné 8
disp(['Rozmìr matice DCT IV:                     ',num2str(N),' x ',num2str(N)])
disp(['Poèet opakování výpoètu DCT IV:           ',num2str(Np)])
n=0:N-1;
k=0:N-1;

%definice signalu
x=0.7*cos(2*pi*f1/fs*(0:N-1))+0.3*cos(2*pi*f2/fs*(0:N-1));
Lx=length(x);

%výpoèet DCT verze IV
M=cos(pi/N*(n'+1/2)*(k+1/2));
clear n k

% nacteni knihovny
hfile1 = 'mthrX32.h';
[notfound,warnings]=loadlibrary('mthrX32.dll', hfile1,'mfilename','mthrX32_mx');
fprintf ('Poèet fyzických procesorù (jader):        %d\n',calllib('mthrX32', 'cCintelnew'))
fprintf ('Poèet logických procesorù:                %d\n',calllib('mthrX32', 'cTintelnew'))


fprintf('Výpoèet vxM v Matlabu DP 32b:                    ')
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

% volani jednoducha presnost
px = libpointer('singlePtr', x);pM = libpointer('singlePtr', M);

fprintf('Výpoèet vxM v ASM pomocí SSE SP 32b 1 vlákno:    ')
td=0;
for  i=1:Np
y0=zeros(1,N); y0=single(y0); py0 = libpointer('singlePtr', y0);
tic;
calllib('mthrX32', 'vxm_x1_sse_sp', pM, px, py0, Lx, Ly);
td=td+toc/Np;
end
disp([num2str(td,6),' s'])
y_1_sse_sp=get(py0, 'Value');
plot(y_1_sse_sp* sqrt(2/N),'r'), clear y_1_sse_sp

fprintf('Výpoèet vxM v ASM pomocí AVX SP 32b 1 vlákno:    ')
td=0;
for  i=1:Np
y0=zeros(1,N); y0=single(y0); py0 = libpointer('singlePtr', y0);
tic;
calllib('mthrX32', 'vxm_x1_avx_sp', pM, px, py0, Lx, Ly);
td=td+toc/Np;
end
disp([num2str(td,6),' s'])
y_1_avx_sp=get(py0, 'Value');
plot(y_1_avx_sp* sqrt(2/N),'r'), clear y_1_avx_sp

fprintf('Výpoèet vxM v ASM pomocí SSE SP 32b 2 vlákna:    ')
td=0;
for  i=1:Np
y0=zeros(1,N); y0=single(y0); py0 = libpointer('singlePtr', y0);
tic;
calllib('mthrX32', 'vxm_x2_sse_sp', pM, px, py0, Lx, Ly);
td=td+toc/Np;
end
disp([num2str(td,6),' s'])
y_2_sse_sp=get(py0, 'Value');
plot(y_2_sse_sp* sqrt(2/N),'g'); clear y_2_sse_sp

fprintf('Výpoèet vxM v ASM pomocí AVX SP 32b 2 vlákna:    ')
td=0;
for  i=1:Np
y0=zeros(1,N); y0=single(y0); py0 = libpointer('singlePtr', y0);
tic;
calllib('mthrX32', 'vxm_x2_avx_sp', pM, px, py0, Lx, Ly);
td=td+toc/Np;
end
disp([num2str(td,6),' s'])
y_2_avx_sp=get(py0, 'Value');
plot(y_2_avx_sp* sqrt(2/N),'g'); clear y_2_avx_sp

fprintf('Výpoèet vxM v ASM pomocí SSE SP 32b 4 vlákna:    ')
td=0;
for  i=1:Np
y0=zeros(1,N); y0=single(y0); py0 = libpointer('singlePtr', y0);
tic;
calllib('mthrX32', 'vxm_x4_sse_sp', pM, px, py0, Lx, Ly);
td=td+toc/Np;
end
disp([num2str(td,6),' s'])
y_4_sse_sp=get(py0, 'Value');
plot(y_4_sse_sp* sqrt(2/N),'m'); clear y_4_sse_sp

fprintf('Výpoèet vxM v ASM pomocí AVX SP 32b 4 vlákna:    ')
td=0;
for  i=1:Np
y0=zeros(1,N); y0=single(y0); py0 = libpointer('singlePtr', y0);
tic;
calllib('mthrX32', 'vxm_x4_avx_sp', pM, px, py0, Lx, Ly);
td=td+toc/Np;
end
disp([num2str(td,6),' s'])
y_4_avx_sp=get(py0, 'Value');
plot(y_4_avx_sp* sqrt(2/N),'m'); clear y_4_avx_sp

fprintf('Výpoèet vxM v ASM pomocí SSE SP 32b 8 vláken:    ')
td=0;
for  i=1:Np
y0=zeros(1,N); y0=single(y0); py0 = libpointer('singlePtr', y0);
tic;
calllib('mthrX32', 'vxm_x8_sse_sp', pM, px, py0, Lx, Ly);
td=td+toc/Np;
end
disp([num2str(td,6),' s'])
y_8_sse_sp=get(py0, 'Value');
plot(y_8_sse_sp* sqrt(2/N),'k'); clear y_8_sse_sp



%volani dvojita presnost
px = libpointer('doublePtr', x);pM = libpointer('doublePtr', M);
fprintf('Výpoèet vxM v ASM pomocí SSE DP 32b 1 vlákno:    ')
td=0;
for  i=1:Np
y0=zeros(1,N); y0=double(y0); py0 = libpointer('doublePtr', y0);
tic;
calllib('mthrX32', 'vxm_x1_sse_dp', pM, px, py0, Lx, Ly);
td=td+toc/Np;
end
disp([num2str(td,6),' s'])
y_1_sse_dp=get(py0, 'Value');
plot(y_1_sse_dp* sqrt(2/N),'r'); clear y_1_sse_dp

fprintf('Výpoèet vxM v ASM pomocí AVX DP 32b 1 vlákno:    ')
td=0;
for  i=1:Np
y0=zeros(1,N); y0=double(y0); py0 = libpointer('doublePtr', y0);
tic;
calllib('mthrX32', 'vxm_x1_avx_dp', pM, px, py0, Lx, Ly);
td=td+toc/Np;
end
disp([num2str(td,6),' s'])
y_1_avx_dp=get(py0, 'Value');
plot(y_1_avx_dp* sqrt(2/N),'r'); clear y_1_avx_dp

fprintf('Výpoèet vxM v ASM pomocí SSE DP 32b 2 vlákna:    ')
td=0;
for  i=1:Np
y0=zeros(1,N); y0=double(y0); py0 = libpointer('doublePtr', y0);
tic;
calllib('mthrX32', 'vxm_x2_sse_dp', pM, px, py0, Lx, Ly);
td=td+toc/Np;
end
disp([num2str(td,6),' s'])
y_2_sse_dp=get(py0, 'Value');
plot(y_2_sse_dp* sqrt(2/N),'g'); clear y_2_sse_dp

fprintf('Výpoèet vxM v ASM pomocí AVX DP 32b 2 vlákna:    ')
td=0;
for  i=1:Np
y0=zeros(1,N); y0=double(y0); py0 = libpointer('doublePtr', y0);
tic;
calllib('mthrX32', 'vxm_x2_avx_dp', pM, px, py0, Lx, Ly);
td=td+toc/Np;
end
disp([num2str(td,6),' s'])
y_2_avx_dp=get(py0, 'Value');
plot(y_2_avx_dp* sqrt(2/N),'g'); clear y_2_avx_dp

fprintf('Výpoèet vxM v ASM pomocí SSE DP 32b 4 vlákna:    ')
td=0;
for  i=1:Np
y0=zeros(1,N); y0=double(y0); py0 = libpointer('doublePtr', y0);
tic;
calllib('mthrX32', 'vxm_x4_sse_dp', pM, px, py0, Lx, Ly);
td=td+toc/Np;
end
disp([num2str(td,6),' s'])
y_4_sse_dp=get(py0, 'Value');
plot(y_4_sse_dp* sqrt(2/N),'m'); clear y_4_sse_dp

fprintf('Výpoèet vxM v ASM pomocí AVX DP 32b 4 vlákna:    ')
td=0;
for  i=1:Np
y0=zeros(1,N); y0=double(y0); py0 = libpointer('doublePtr', y0);
tic;
calllib('mthrX32', 'vxm_x4_avx_dp', pM, px, py0, Lx, Ly);
td=td+toc/Np;
end
disp([num2str(td,6),' s'])
y_4_avx_dp=get(py0, 'Value');
plot(y_4_avx_dp* sqrt(2/N),'m'); clear y_4_avx_dp

fprintf('Výpoèet vxM v ASM pomocí SSE DP 32b 8 vláken:    ')
td=0;
for  i=1:Np
y0=zeros(1,N); y0=double(y0); py0 = libpointer('doublePtr', y0);
tic;
calllib('mthrX32', 'vxm_x8_sse_dp', pM, px, py0, Lx, Ly);
td=td+toc/Np;
end
disp([num2str(td,6),' s'])
y_8_sse_dp=get(py0, 'Value');
plot(y_8_sse_dp* sqrt(2/N),'k'); clear y_8_sse_dp


legend('DCT IV vxM v Matlabu',...
    'DCT IV vxM x1 SSE SP',...
    'DCT IV vxM x1 AVX SP',...
    'DCT IV vxM x2 SSE SP',...
    'DCT IV vxM x2 AVX SP',...
    'DCT IV vxM x4 SSE SP',...
    'DCT IV vxM x4 AVX SP',...
    'DCT IV vxM x8 SSE SP',...
    'DCT IV vxM x1 SSE DP',...
    'DCT IV vxM x1 AVX DP',...
    'DCT IV vxM x2 SSE DP',...
    'DCT IV vxM x2 AVX DP',...
    'DCT IV vxM x4 SSE DP',...
    'DCT IV vxM x4 AVX DP',...
    'DCT IV vxM x8 SSE DP')

clear M

N=round(N/48)*48;       %dìlitelné 6*8
fprintf('\n')
disp(['Rozmìr matice DCT IV:                     ',num2str(N),' x ',num2str(N)])
disp(['Poèet opakování výpoètu DCT IV:           ',num2str(Np)])
n=0:N-1;
k=0:N-1;

%definice signalu
x=0.7*cos(2*pi*f1/fs*(0:N-1))+0.3*cos(2*pi*f2/fs*(0:N-1));
Lx=length(x);

%výpoèet DCT verze IV
M=cos(pi/N*(n'+1/2)*(k+1/2));
clear n k

figure
fprintf('Výpoèet vxM v Matlabu DP 32b:                    ')
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


% volani jednoducha presnost
px = libpointer('singlePtr', x);pM = libpointer('singlePtr', M);

fprintf('Výpoèet vxM v ASM pomocí SSE SP 32b 3 vlákna:    ')
td=0;
for  i=1:Np
y0=zeros(1,N); y0=single(y0); py0 = libpointer('singlePtr', y0);
tic;
calllib('mthrX32', 'vxm_x3_sse_sp', pM, px, py0, Lx, Ly);
td=td+toc/Np;
end
disp([num2str(td,6),' s'])
y_3_sse_sp=get(py0, 'Value');
plot(y_3_sse_sp* sqrt(2/N),'r'); clear y_3_sse_sp


fprintf('Výpoèet vxM v ASM pomocí SSE SP 32b 6 vláken:    ')
td=0;
for  i=1:Np
y0=zeros(1,N); y0=single(y0); py0 = libpointer('singlePtr', y0);
tic;
calllib('mthrX32', 'vxm_x6_sse_sp', pM, px, py0, Lx, Ly);
td=td+toc/Np;
end
disp([num2str(td,6),' s'])
y_6_sse_sp=get(py0, 'Value');
plot(y_6_sse_sp* sqrt(2/N),'g'); clear y_6_sse_sp

fprintf('Výpoèet vxM v ASM pomocí AVX SP 32b 3 vlákna:    ')
td=0;
for  i=1:Np
y0=zeros(1,N); y0=single(y0); py0 = libpointer('singlePtr', y0);
tic;
calllib('mthrX32', 'vxm_x3_avx_sp', pM, px, py0, Lx, Ly);
td=td+toc/Np;
end
disp([num2str(td,6),' s'])
y_3_avx_sp=get(py0, 'Value');
plot(y_3_avx_sp* sqrt(2/N),'m'); clear y_3_avx_sp

fprintf('Výpoèet vxM v ASM pomocí AVX SP 32b 6 vláken:    ')
td=0;
for  i=1:Np
y0=zeros(1,N); y0=single(y0); py0 = libpointer('singlePtr', y0);
tic;
calllib('mthrX32', 'vxm_x6_avx_sp', pM, px, py0, Lx, Ly);
td=td+toc/Np;
end
disp([num2str(td,6),' s'])
y_6_avx_sp=get(py0, 'Value');
plot(y_6_avx_sp* sqrt(2/N),'y'); clear y_6_avx_sp

% volani dvojita presnost
px = libpointer('doublePtr', x);pM = libpointer('doublePtr', M);
fprintf('Výpoèet vxM v ASM pomocí SSE DP 32b 3 vlákna:    ')
td=0;
for  i=1:Np
y0=zeros(1,N); y0=double(y0); py0 = libpointer('doublePtr', y0);
tic;
calllib('mthrX32', 'vxm_x3_sse_dp', pM, px, py0, Lx, Ly);
td=td+toc/Np;
end
disp([num2str(td,6),' s'])
y_3_sse_dp=get(py0, 'Value');
plot(y_3_sse_dp* sqrt(2/N),'r'); clear y_3_sse_dp

fprintf('Výpoèet vxM v ASM pomocí SSE DP 32b 6 vláken:    ')
td=0;
for  i=1:Np
y0=zeros(1,N); y0=double(y0); py0 = libpointer('doublePtr', y0);
tic;
calllib('mthrX32', 'vxm_x6_sse_dp', pM, px, py0, Lx, Ly);
td=td+toc/Np;
end
disp([num2str(td,6),' s'])
y_6_sse_dp=get(py0, 'Value');
plot(y_6_sse_dp* sqrt(2/N),'g'); clear y_6_sse_dp

fprintf('Výpoèet vxM v ASM pomocí AVX DP 32b 3 vlákna:    ')
td=0;
for  i=1:Np
y0=zeros(1,N); y0=double(y0); py0 = libpointer('doublePtr', y0);
tic;
calllib('mthrX32', 'vxm_x3_avx_dp', pM, px, py0, Lx, Ly);
td=td+toc/Np;
end
disp([num2str(td,6),' s'])
y_3_avx_dp=get(py0, 'Value');
plot(y_3_avx_dp* sqrt(2/N),'m'); clear y_3_avx_dp


fprintf('Výpoèet vxM v ASM pomocí AVX DP 32b 6 vláken:    ')
td=0;
for  i=1:Np
y0=zeros(1,N); y0=double(y0); py0 = libpointer('doublePtr', y0);
tic;
calllib('mthrX32', 'vxm_x6_avx_dp', pM, px, py0, Lx, Ly);
td=td+toc/Np;
end
disp([num2str(td,6),' s'])
y_6_avx_dp=get(py0, 'Value');
plot(y_6_avx_dp* sqrt(2/N),'k'); clear y_6_avx_dp


legend('DCT IV vxM v Matlabu',...
        'DCT IV vxM x3 SSE SP',...
    'DCT IV vxM x6 SSE SP',...
        'DCT IV vxM x3 AVX SP',...
    'DCT IV vxM x6 AVX SP',...
        'DCT IV vxM x3 SSE DP',...
    'DCT IV vxM x6 SSE DP',...
        'DCT IV vxM x3 AVX DP',...
    'DCT IV vxM x6 AVX DP')



clear all
unloadlibrary mthrX32
