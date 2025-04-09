function [methodinfo,structs,enuminfo,ThunkLibName]=operace_mx
%OPERACE_MX Create structures to define interfaces found in 'operace'.

%This function was generated by loadlibrary.m parser version 1.1.6.35 on Mon Mar 25 19:12:15 2019
%perl options:'operace.i -outfile=operace_mx.m'
ival={cell(1,0)}; % change 0 to the actual number of functions to preallocate the data.
structs=[];enuminfo=[];fcnNum=1;
fcns=struct('name',ival,'calltype',ival,'LHS',ival,'RHS',ival,'alias',ival);
ThunkLibName=[];
% int _stdcall soucet ( int x , int y , int z ); 
fcns.name{fcnNum}='soucet'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'int32', 'int32', 'int32'};fcnNum=fcnNum+1;
% float _stdcall fpu_op ( int x , float y ); 
fcns.name{fcnNum}='fpu_op'; fcns.calltype{fcnNum}='stdcall'; fcns.LHS{fcnNum}='single'; fcns.RHS{fcnNum}={'int32', 'single'};fcnNum=fcnNum+1;
methodinfo=fcns;