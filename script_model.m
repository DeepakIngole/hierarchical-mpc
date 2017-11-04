clear mex;clear all;close all;clc;
addpath(genpath(pwd));
load('PNS_SS_matrices');

for i=1:4
    sys{i}=c2d(ss(A{i},B{i},C{i},D{i}),1);
end

interIndex{1}=3;
interIndex{2}=[3 4];
interIndex{3}=[3 4];
interIndex{4}=3;

for i=1:4
    
    model(i).nx=4;
    model(i).nu=1;
    model(i).nw=1;
    model(i).nv=numel(interIndex{i});
    model(i).ny=1;
    model(i).nc=1;
    model(i).nz=1;

    model(i).Ts=1;

    model(i).A=sys{i}.A;
    model(i).B=sys{i}.B(:,1);
    model(i).F=sys{i}.B(:,2);
    model(i).M=sys{i}.B(:,interIndex{i});

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
