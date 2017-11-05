clear mex;clear all;close all;clc;
addpath(genpath(pwd));
load agent;
load valid_scenario;

HDMPC.Ns=4;
HDMPC.aaParam=struct('topology',...
                     {[],[1],[],[];[1],[],[1],[];[],[1],[],[1];[],[],[1],[]},...
                     'm',3,'droptol',1e-1,'beta',1,'AAstart',0,...
                     'smax',1e2,'atol',1e-6,'rtol',1e-6,'verbose',0);
HDMPC.nlpParam=struct('algorithm',NLOPT_LN_BOBYQA,...
                     'pi',[1e6;1;1;1],'rmin',-1e-1*ones(4,1),'rmax',1e-1*ones(4,1),...
                     'kmax',1e4,'axtol',1e-3*ones(4,1),'aftol',1e-4,...
                     'initstep',1e-2*ones(4,1),'verbose',0);

%% SCENARIO EVALUATION
% SIMULATION
open('pns_priority.mdl');
sim('pns_priority.mdl');

t=x.time;
x=x.signals.values;
u=u.signals.values;
deltaPref=deltaPref.signals.values;
deltaFrequency=deltaFrequency.signals.values;
deltaPtie12=deltaPtie12.signals.values;
deltaPtie23=deltaPtie23.signals.values;
deltaPtie34=deltaPtie34.signals.values;
r=r.signals.values;
nJ=nJ.signals.values;
tHDMPC=tHDMPC.signals.values;

% STORAGE
save pns_dmpc_priority t r u nJ tHDMPC deltaPref deltaFrequency deltaPtie12 deltaPtie23 deltaPtie34;



