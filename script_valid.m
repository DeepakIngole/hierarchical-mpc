clear mex;clear all;close all;clc;
addpath(genpath(pwd));
load agent;
load valid_scenario;

HDMPC.Ns=4;
HDMPC.aaParam=struct('topology',...
                     {[],[1],[],[];[1],[],[1],[];[],[1],[],[1];[],[],[1],[]},...
                     'm',5,'droptol',1e-1,'beta',1,'AAstart',0,...
                     'smax',1e2,'atol',1e-5,'rtol',1e-5,'verbose',0);
HDMPC.nlpParam=struct('algorithm',NLOPT_LN_BOBYQA,...
                     'pi',[1;1;1;1],'rmin',[-1;-1;-1;-1],'rmax',[+1;+1;+1;+1],...
                     'kmax',1e2,'axtol',1e-5*ones(4,1),'aftol',1e-5,...
                     'initstep',1*ones(4,1),'verbose',0);

%% EVALUATION
% SIMULATION
mode=1;
if mode<0
    set_param('hdmpc_pns/HDMPC','commented','on');
    set_param('hdmpc_pns/From Workspace2','commented','off');
else
    set_param('hdmpc_pns/HDMPC','commented','off');
    set_param('hdmpc_pns/From Workspace2','commented','on');
end
sim('hdmpc_pns');

t=x.time;
x=x.signals.values;
u=u.signals.values;
deltaPref=deltaPref.signals.values;
deltaFrequency=deltaFrequency.signals.values;
deltaPtie12=deltaPtie12.signals.values;
deltaPtie23=deltaPtie23.signals.values;
deltaPtie34=deltaPtie34.signals.values;

% ETA CRITERIA
etaCrit=eta_criterion(x',xO',u',uO',Q,R);

% STORAGE
if mode<0
    save pns_cmpc_valid t deltaPref deltaFrequency deltaPtie12 deltaPtie23 deltaPtie34;
else
    save pns_dmpc_valid t deltaPref deltaFrequency deltaPtie12 deltaPtie23 deltaPtie34;
end