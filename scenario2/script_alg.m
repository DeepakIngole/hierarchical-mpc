clear mex;clear all;close all;clc;
addpath(genpath(pwd));
load agent;
HDMPC.Ns=5;

%% AA SPEED
HDMPC.aaParam=struct('topology',...
                     {[],[1],[],[],[];[1],[],[1],[],[1];[],[1],[],[1],[];[],[],[1],[],[1];[],[1],[],[1],[]},...
                     'm',5,'droptol',1e-1,'beta',1,'AAstart',0,...
                     'smax',2e2,'atol',1e-4,'rtol',1e-4,'verbose',1);
for k=1:100
    for i=1:HDMPC.Ns
        SystemData(i).x=-1e-1+2e-1*rand(SubsystemMPC(i).model.nx,1);
        SystemData(i).w=-1e-1+2e-1*rand(1);
        AgentData(i).vpred_sequences=...
            zeros(length(SubsystemMPC(i).param.vIndex),...
            SubsystemMPC(i).model.nv);
        AgentData(i).ustar_sequences=[];
        AgentData(i).xpred_sequences=[];
        AgentData(i).ypred_sequences=[];
        AgentData(i).zpred_sequences=[];
        AgentData(i).J=[];
        AgentData(i).yd=-1e-1+2e-1*rand(1);
    end
    AgentData=coupling_alg(HDMPC,SubsystemMPC,SystemData,AgentData);
end

[xData,yData]=fig2dat('Residual versus Iteration');
for i=1:100
    iter(i)=numel(xData{i});
end
err=yData;
save(['aa_convergence_s2_N' num2str(SubsystemMPC(1).param.Np)],'err','iter');

%% BOBYQA COMPLEXITY
HDMPC.aaParam=struct('topology',...
                     {[],[1],[],[];[1],[],[1],[];[],[1],[],[1];[],[],[1],[]},...
                     'm',5,'droptol',1e10,'beta',1,'AAstart',0,...
                     'smax',3e1,'atol',1e-5,'rtol',1e-5,'verbose',0);
HDMPC.nlpParam=struct('algorithm',NLOPT_LN_BOBYQA,...
                     'pi',[1;1;1;1],'rmin',-1e0*ones(4,1),'rmax',1e0*ones(4,1),...
                     'kmax',1e2,'axtol',1e-4*ones(4,1),'aftol',1e-4,...
                     'initstep',1e-2*ones(4,1),'verbose',0);
for k=1:100
    for i=1:HDMPC.Ns
        SystemData(i).x=-1e0+2e0*rand(SubsystemMPC(i).model.nx,1);
        SystemData(i).w=-5e-1+10e-1*rand(SubsystemMPC(i).model.nw,1);
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
    [ropt,Jopt,nJ(k),AgentData]=...
        master_optimize(HDMPC,SubsystemMPC,SystemData,AgentData);
    disp(num2str(nJ(k)));
end

save dfo_fcneval_s2 nJ;
