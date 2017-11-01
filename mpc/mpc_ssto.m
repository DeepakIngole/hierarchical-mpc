function [xd,ud]=mpc_ssto(mpc,yd,w,vF)

A=mpc.model.A;B=mpc.model.B;M=mpc.model.M;
C=mpc.model.C;D=mpc.model.D;N=mpc.model.N;
nx=mpc.model.nx;nu=mpc.model.nu;

xd=[0;0;w;w];
ud=w;