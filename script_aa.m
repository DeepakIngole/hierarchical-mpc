clear mex;clear all;close all;clc;
addpath(genpath(pwd));
load agent;

HDMPC.Ns=4;

%% CONVERGENCE
HDMPC.aaParam=struct('topology',...
                     {[],[1],[],[];[1],[],[1],[];[],[1],[],[1];[],[],[1],[]},...
                     'm',5,'droptol',1e-1,'beta',1,'AAstart',0,...
                     'smax',3e1,'atol',1e-4,'rtol',1e-4,'verbose',1);

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

for i=1:HDMPC.Ns
    [~,u{i}]=fig2dat(['System control ' num2str(i)]);
    [~,y{i}]=fig2dat(['System output ' num2str(i)]);
    [~,z{i}]=fig2dat(['System output coupling ' num2str(i)]);
end

save aa_profiles u y z SystemData AgentData;

[ropt,Jopt,nJ,AgentData]=master_optimize(HDMPC,SubsystemMPC,SystemData,AgentData);

for i=1:HDMPC.Ns
    [~,u{i}]=fig2dat(['System control ' num2str(i)]);
    [~,y{i}]=fig2dat(['System output ' num2str(i)]);
    [~,z{i}]=fig2dat(['System output coupling ' num2str(i)]);
end

save aa_profiles_opt u y z SystemData AgentData;

%% CONVERGENCE SPEED
HDMPC.aaParam=struct('topology',...
                     {[],[1],[],[];[1],[],[1],[];[],[1],[],[1];[],[],[1],[]},...
                     'm',5,'droptol',1e-1,'beta',1,'AAstart',0,...
                     'smax',5e1,'atol',1e-4,'rtol',1e-4,'verbose',1);
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
save aa_convergence err iter;

%% INITIALIZATION
HDMPC.aaParam=struct('topology',...
                     {[],[1],[],[];[1],[],[1],[];[],[1],[],[1];[],[],[1],[]},...
                     'm',5,'droptol',1e-1,'beta',1,'AAstart',0,...
                     'smax',3e1,'atol',1e-4,'rtol',1e-4,'verbose',1);
for k=1:100
    for i=1:HDMPC.Ns
        SystemData(i).x=-1e-1+2e-1*rand(SubsystemMPC(i).model.nx,1);
        SystemData(i).w=-1e-1+2e-1*rand(1);
        AgentData(i).vpred_sequences=...
            -1e-1+2e-1*rand(length(SubsystemMPC(i).param.vIndex),...
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
save aa_init1 err iter;

%% MEMORY
for i=1:HDMPC.Ns
    SystemData(i).x=-1e-1+2e-1*rand(SubsystemMPC(i).model.nx,1);
    SystemData(i).w=-1e-1+2e-1*rand(1);
    AgentData(i).yd=-1e-1+2e-1*rand(1);
end

HDMPC.aaParam=struct('topology',...
                     {[],[1],[],[];[1],[],[1],[];[],[1],[],[1];[],[],[1],[]},...
                     'm',1,'droptol',1e-1,'beta',1,'AAstart',0,...
                     'smax',3e1,'atol',1e-8,'rtol',1e-8,'verbose',1);
for i=1:HDMPC.Ns
    AgentData(i).vpred_sequences=...
        zeros(length(SubsystemMPC(i).param.vIndex),...
        SubsystemMPC(i).model.nv);
    AgentData(i).ustar_sequences=[];
    AgentData(i).xpred_sequences=[];
    AgentData(i).ypred_sequences=[];
    AgentData(i).zpred_sequences=[];
    AgentData(i).J=[];
end
AgentData=coupling_alg(HDMPC,SubsystemMPC,SystemData,AgentData);

HDMPC.aaParam=struct('topology',...
                     {[],[1],[],[];[1],[],[1],[];[],[1],[],[1];[],[],[1],[]},...
                     'm',3,'droptol',1e-1,'beta',1,'AAstart',0,...
                     'smax',3e1,'atol',1e-8,'rtol',1e-8,'verbose',1);
for i=1:HDMPC.Ns
    AgentData(i).vpred_sequences=...
        zeros(length(SubsystemMPC(i).param.vIndex),...
        SubsystemMPC(i).model.nv);
    AgentData(i).ustar_sequences=[];
    AgentData(i).xpred_sequences=[];
    AgentData(i).ypred_sequences=[];
    AgentData(i).zpred_sequences=[];
    AgentData(i).J=[];
end
AgentData=coupling_alg(HDMPC,SubsystemMPC,SystemData,AgentData);

HDMPC.aaParam=struct('topology',...
                     {[],[1],[],[];[1],[],[1],[];[],[1],[],[1];[],[],[1],[]},...
                     'm',5,'droptol',1e-1,'beta',1,'AAstart',0,...
                     'smax',3e1,'atol',1e-8,'rtol',1e-8,'verbose',1);
for i=1:HDMPC.Ns
    AgentData(i).vpred_sequences=...
        zeros(length(SubsystemMPC(i).param.vIndex),...
        SubsystemMPC(i).model.nv);
    AgentData(i).ustar_sequences=[];
    AgentData(i).xpred_sequences=[];
    AgentData(i).ypred_sequences=[];
    AgentData(i).zpred_sequences=[];
    AgentData(i).J=[];
end
AgentData=coupling_alg(HDMPC,SubsystemMPC,SystemData,AgentData);

HDMPC.aaParam=struct('topology',...
                     {[],[1],[],[];[1],[],[1],[];[],[1],[],[1];[],[],[1],[]},...
                     'm',10,'droptol',1e-1,'beta',1,'AAstart',0,...
                     'smax',3e1,'atol',1e-8,'rtol',1e-8,'verbose',1);
for i=1:HDMPC.Ns
    AgentData(i).vpred_sequences=...
        zeros(length(SubsystemMPC(i).param.vIndex),...
        SubsystemMPC(i).model.nv);
    AgentData(i).ustar_sequences=[];
    AgentData(i).xpred_sequences=[];
    AgentData(i).ypred_sequences=[];
    AgentData(i).zpred_sequences=[];
    AgentData(i).J=[];
end
AgentData=coupling_alg(HDMPC,SubsystemMPC,SystemData,AgentData);

%% ITERATION VISUALIZATION
HDMPC.aaParam=struct('topology',...
                     {[],[1],[],[];[1],[],[1],[];[],[1],[],[1];[],[],[1],[]},...
                     'm',5,'droptol',1e-1,'beta',1,'AAstart',0,...
                     'smax',3e1,'atol',1e-4,'rtol',1e-4,'verbose',0);

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
