clear mex;clear all;close all;clc;
load('dataSim');

sys{1}.A=A(1:4,1:4);
sys{1}.B=B(1:4,1);
sys{1}.F=L(1:4,1);
sys{1}.M=A(1:4,5);

sys{2}.A=A(5:8,5:8);
sys{2}.B=B(5:8,2);
sys{2}.F=L(5:8,2);
sys{2}.M=A(1:4,[1 9 17]);

sys{3}.A=A(9:12,9:12);
sys{3}.B=B(9:12,3);
sys{3}.F=L(9:12,3);
sys{3}.M=A(9:12,[5 13]);

sys{4}.A=A(13:16,13:16);
sys{4}.B=B(13:16,4);
sys{4}.F=L(13:16,4);
sys{4}.M=A(13:16,[9 17]);

sys{5}.A=A(17:20,17:20);
sys{5}.B=B(17:20,5);
sys{5}.F=L(17:20,5);
sys{5}.M=A(17:20,[5 13]);

for i=1:5
    
    model(i).nx=4;
    model(i).nu=1;
    model(i).nw=1;
    model(i).nv=size(sys{i}.M,2);
    model(i).ny=1;
    model(i).nc=1;
    model(i).nz=1;

    model(i).Ts=1;

    model(i).A=sys{i}.A;
    model(i).B=sys{i}.B;
    model(i).F=sys{i}.F;
    model(i).M=sys{i}.M;

    model(i).C=[0 1 0 0];
    model(i).D=zeros(1,1);
    model(i).G=zeros(1,1);
    model(i).N=zeros(1,model(i).nv);

    model(i).Cc=[1 0 0 0];
    model(i).Dc=zeros(1,1);
    model(i).Gc=zeros(1,1);
    model(i).Nc=zeros(1,model(i).nv);

    model(i).Cz=[1 0 0 0];
    model(i).Dz=zeros(1,1);
    model(i).Gz=zeros(1,1);
    model(i).Nz=zeros(1,model(i).nv);
    
end

save plant_model model;
