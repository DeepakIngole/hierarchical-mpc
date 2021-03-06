clear mex;clear all;close all;clc;
addpath(genpath(pwd));
load agent;
load dataValid;

HDMPC.Ns=5;
HDMPC.aaParam=struct('topology',...
                     {[],[1],[],[],[];[1],[],[1],[],[1];[],[1],[],[1],[];[],[],[1],[],[1];[],[1],[],[1],[]},...
                     'm',5,'droptol',1e-1,'beta',1,'AAstart',0,...
                     'smax',1e2,'atol',1e-5,'rtol',1e-5,'verbose',0);
HDMPC.nlpParam=struct('algorithm',NLOPT_LN_BOBYQA,...
                     'pi',[1;1;1;1;1],'rmin',-1e-1*ones(5,1),'rmax',1e-1*ones(5,1),...
                     'kmax',1e4,'axtol',1e-4*ones(5,1),'aftol',1e-4,...
                     'initstep',1e-2*ones(5,1),'verbose',0);

%% SCENARIO EVALUATION
% SIMULATION
Ts=1e-3;
open('hdmpc_pns.mdl');
mode=1;
if mode<0
    set_param('hdmpc_pns/HDMPC','commented','on');
    set_param('hdmpc_pns/From Workspace2','commented','off');
else
    set_param('hdmpc_pns/HDMPC','commented','off');
    set_param('hdmpc_pns/From Workspace2','commented','on');
end
sim('hdmpc_pns.mdl');

t=x.time;
x=x.signals.values;
u=u.signals.values;
deltaPref=deltaPref.signals.values;
deltaFrequency=deltaFrequency.signals.values;
deltaPtie12=deltaPtie12.signals.values;
deltaPtie23=deltaPtie23.signals.values;
deltaPtie34=deltaPtie34.signals.values;
deltaPtie25=deltaPtie25.signals.values;
deltaPtie45=deltaPtie45.signals.values;

try
    r=r.signals.values;
    nJ=nJ.signals.values;
    tHDMPC=tHDMPC.signals.values;
end

% STORAGE
if mode<0
    save cmpc_valid_s2 t u deltaPref deltaFrequency deltaPtie12 deltaPtie23 deltaPtie34;
else
    save dempc_valid_s2 t r u nJ tHDMPC deltaPref deltaFrequency deltaPtie12 deltaPtie23 deltaPtie34;
end

%% EVALUATION
P12=4;P23=2;P34=2;P25=3;P45=3;
Ts=1;
open('hdmpc_pns.mdl');
mode=1;
if mode<0
    set_param('hdmpc_pns/HDMPC','commented','on');
    set_param('hdmpc_pns/From Workspace2','commented','off');
else
    set_param('hdmpc_pns/HDMPC','commented','off');
    set_param('hdmpc_pns/From Workspace2','commented','on');
end
sim('hdmpc_pns.mdl');

x=x.signals.values(2:end,:);
u=u.signals.values(2:end,:);

Eta=eta_criterion(x',xO',u',uO',Q,R)
Phi=phi_criterion(x')
