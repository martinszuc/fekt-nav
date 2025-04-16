clear all; close all; clc

% nacteni knihovny
hfile1 = 'detect.h';
[notfound,warnings]=loadlibrary('detect.dll', hfile1,'mfilename','detect_mx');

cputype=calllib('detect', 'CPUsign');
s='0000000000000000000000000000'; %28 bitu
ls=length(dec2bin(cputype));
s(29-ls:28)=dec2bin(cputype);
rs=fliplr(s);

EF=rs(28:-1:21);
EM=rs(20:-1:17);
T=rs(14:-1:13);
F=rs(12:-1:9);
M=rs(8:-1:5);
S=rs(4:-1:1);
disp(['Hexadecimální signatura procesoru: (',sprintf('%X',cputype),')'])
disp(['Binární 28b signatura procesoru:   ',s])

name=uint8(zeros(1,48));
pname = libpointer('uint8Ptr',name);
calllib('detect', 'CPUname',pname);
name=get(pname, 'Value');
fprintf('Detekované jméno procesoru: ')
for i=1:48 fprintf('%s',name(i)); end
fprintf('\n')

%Detekce pouze pro pracovni stanice (nejsou zde serverove a mobilni verze)
if F=='0110' & EM=='0001' & M=='1010' disp('Detekované kódové jméno procesoru: Nehalem (Bloomfield)'); end
if F=='0110' & EM=='0001' & M=='1110' disp('Detekované kódové jméno procesoru: Nehalem (Lynfield)'); end
if F=='0110' & EM=='0010' & M=='0101' disp('Detekované kódové jméno procesoru: Westmere (Clarkdale)'); end
if F=='0110' & EM=='0010' & M=='1100' disp('Detekované kódové jméno procesoru: Westmere (Gulftown)'); end
if F=='0110' & EM=='0010' & M=='1010' disp('Detekované kódové jméno procesoru: Sandy Bridge'); end
if F=='0110' & EM=='0011' & M=='1010' disp('Detekované kódové jméno procesoru: Ivy Bridge'); end
if F=='0110' & EM=='0011' & M=='1100' disp('Detekované kódové jméno procesoru: Haswell'); end
if F=='0110' & EM=='0011' & M=='1101' disp('Detekované kódové jméno procesoru: Broadwell'); end
if F=='0110' & EM=='0101' & M=='1110' disp('Detekované kódové jméno procesoru: Skylake'); end
if F=='0110' & EM=='1000' & M=='1110' disp('Detekované kódové jméno procesoru: Kaby Lake'); end
if F=='0110' & EM=='1001' & M=='1110' & S=='1001' disp('Detekované kódové jméno procesoru: Kaby Lake'); end
if F=='0110' & EM=='1001' & M=='1110' & S=='1010' | S=='1011' disp('Detekované kódové jméno procesoru: Coffee Lake'); end

fprintf('\nDetekované vlastnosti procesoru:\n')
disp(['Ext. Family [27:20]: ',EF,'(',sprintf('%X',bin2dec(EF)),')'])
disp(['Ext. Model  [19:16]: ',EM,'(',sprintf('%X',bin2dec(EM)),')'])
disp(['Type        [13:12]: ',T,'(',sprintf('%X',bin2dec(T)),')'])
disp(['Family       [11:8]: ',F,'(',sprintf('%X',bin2dec(F)),')'])
disp(['Model         [7:4]: ',M,'(',sprintf('%X',bin2dec(M)),')'])
disp(['Stepping      [3:0]: ',S,'(',sprintf('%X',bin2dec(S)),')'])

fprintf('\nPøepoètené vlastnosti procesoru:\n')
disp(['Calc. Ext. Family:   (',num2str(bin2dec(F)+bin2dec(EF)),')'])
disp(['Calc. Ext. Model:    (',num2str(bin2dec(EM)),sprintf('%X',bin2dec(M)),') {', num2str(16*bin2dec(EM)+bin2dec(M)),'}'])

fprintf('\nPodporovaná rozšíøení a instrukèní sady:\n')
if calllib('detect', 'EM64Tsupport')==1 fprintf('EM64T, '); end
if calllib('detect', 'MMXsupport')==1 fprintf('MMX, '); end
if calllib('detect', 'SSEsupport')==1 fprintf('SSE, '); end
if calllib('detect', 'SSE2support')==1 fprintf('SSE2, '); end
if calllib('detect', 'SSE3support')==1 fprintf('SSE3, '); end
if calllib('detect', 'SSSE3support')==1 fprintf('SSSE3, '); end
if calllib('detect', 'SSE41support')==1 fprintf('SSE4.1, '); end
if calllib('detect', 'SSE42support')==1 fprintf('SSE4.2, '); end
if calllib('detect', 'AVXsupport')==1 fprintf('AVX, '); end
if calllib('detect', 'AVX2support')==1 fprintf('AVX2, '); end
if calllib('detect', 'FMA3support')==1 fprintf('FMA3, '); end
if calllib('detect', 'AESsupport')==1 fprintf('AES, '); end
if calllib('detect', 'VAESsupport')==1 fprintf('VAES, '); end
if calllib('detect', 'CLMULsupport')==1 fprintf('CLMUL, '); end
if calllib('detect', 'VCLMULsupport')==1 fprintf('VCLMUL, '); end
if calllib('detect', 'SHAsupport')==1 fprintf('SHA, '); end


%nasledujici 3 radky pouzivaji detekci pro procesory Intel s mikroarchitekturou Core (eax=11)
fprintf ('\n\nMax. poèet vláken na jádro: %d\n',calllib('detect', 'cTpCintelnew'))
fprintf ('Celkový max. poèet vláken (poèet logických procesorù): %d\n',calllib('detect', 'cTintelnew'))
if calllib('detect', 'cTpCintelnew') fprintf ('Poèet fyzických procesorù (jader): %d\n',calllib('detect', 'cTintelnew')/calllib('detect', 'cTpCintelnew')); end
fprintf ('Èíslo aktuálního vlákna: %d\n',calllib('detect','THRnumber'))

unloadlibrary detect
