clear mex;clear all;close all;clc;
addpath(genpath(pwd));
load('plant_model');

uBound=[.5,.65,.65,.55];

%% SETUP
areaIndex=1;
Np=15;

model=model(areaIndex);

%% MPC
mpc.model=model;

mpc.cstr.u.min=-uBound(areaIndex);
mpc.cstr.u.max=+uBound(areaIndex);
mpc.cstr.c.min=-.1;
mpc.cstr.c.max=+.1;

mpc.param.Np=Np;
mpc.param.Wx=diag([1 2e-5 2e-5 2e-2]);
mpc.param.Wu=diag([2e-2]);
mpc.param.Wc=diag([1e6]);

mpc.param.uIndex=unique([1:mpc.param.Np]);
mpc.param.vIndex=unique([1:mpc.param.Np]);
mpc.param.cIndex=unique([1:mpc.param.Np]);

mpc=mpc_param(mpc);
mpc=mpc_pred(mpc);
mpc=mpc_obj(mpc);
mpc=mpc_cstr(mpc);

%% VALID
SystemData.x=zeros(mpc.model.nx,1);
SystemData.w=+.15;
AgentData.vpred_sequences(1:mpc.param.Np,1:mpc.model.nv)=0e-2*ones(mpc.param.Np,mpc.model.nv);
AgentData.vpred_sequences=AgentData.vpred_sequences(mpc.param.vIndex,:);
AgentData.yd=0;
AgentData=mpc_ctrl(mpc,SystemData,AgentData);

custom_plot(deparametrize(mpc,AgentData.ustar_sequences,'u'),'u',' ',...
    'lin',[-Inf Inf],[-Inf Inf],'Prediction horizon',' ',0,0,.001);
custom_plot(AgentData.xpred_sequences,'x',' ',...
    'lin',[-Inf Inf],[-Inf Inf],'Prediction horizon',' ',0,0,.001);
custom_plot(AgentData.ypred_sequences,'y',' ',...
    'lin',[-Inf Inf],[-Inf Inf],'Prediction horizon',' ',0,0,.001);
custom_plot(deparametrize(mpc,AgentData.zpred_sequences,'z'),'z',' ',...
    'lin',[-Inf Inf],[-Inf Inf],'Prediction horizon',' ',0,0,.001);

%% STORAGE
try load agent; end
SubsystemMPC(areaIndex)=mpc;
save agent SubsystemMPC;
