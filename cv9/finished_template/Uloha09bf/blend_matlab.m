% Autor: Miroslav Balík
% Source code: m-file Matlab

function  out=blend_matlab(a,b,fa)

out=(a.*fa + b.*(255-fa)) ./255;