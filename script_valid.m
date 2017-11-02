clear mex;clear all;close all;clc;
addpath(genpath(pwd));
load agent;

HDMPC.Ns=4;
HDMPC.aaParam=struct('topology',...
                     {[],[1],[],[];[1],[],[1],[];[],[1],[],[1];[],[],[1],[]},...
                     'm',5,'droptol',1e-1,'beta',1,'AAstart',0,...
                     'smax',3e1,'atol',1e-4,'rtol',1e-4,'verbose',1);
HDMPC.nlpParam=struct('algorithm',NLOPT_LN_BOBYQA,...
                     'pi',[1;1;1;1],'rmin',[-1;-1;-1;-1],'rmax',[+1;+1;+1;+1],...
                     'kmax',1e2,'axtol',1e-4*ones(4,1),'aftol',1e-4,...
                     'initstep',1*ones(4,1),'verbose',0);

for i=1:HDMPC.Ns
    SystemData(i).x=-1e-1+2e-1*rand(SubsystemMPC(i).model.nx,1);
    SystemData(i).w=zeros(SubsystemMPC(i).model.nw,1);
    AgentData(i).vpred_sequences=...
        zeros(length(SubsystemMPC(i).param.vIndex),...
        SubsystemMPC(i).model.nv);
    AgentData(i).ustar_sequences=[];
    AgentData(i).xpred_sequences=[];
    AgentData(i).ypred_sequences=[];
    AgentData(i).zpred_sequences=[];
    AgentData(i).J=[];
    AgentData(i).yd=0;
end
[ropt,Jopt,nJ,AgentData]=master_optimize(HDMPC,SubsystemMPC,SystemData,AgentData);
