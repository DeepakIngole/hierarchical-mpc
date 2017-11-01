function [ropt,Jopt,nJ,AgentData]=...
    master_optimize(HDMPC,SubsystemMPC,SystemData,AgentData)

% SETUP
opt.algorithm=HDMPC.nlpParam.algorithm;
opt.xtol_abs=HDMPC.nlpParam.axtol;
opt.ftol_abs=HDMPC.nlpParam.aftol;
opt.maxeval=HDMPC.nlpParam.kmax;
opt.min_objective=...
    @(r) master_cost_approx(HDMPC,SubsystemMPC,SystemData,AgentData,r);
opt.lower_bounds=[HDMPC.nlpParam.rmin];
opt.upper_bounds=[HDMPC.nlpParam.rmax];
opt.verbose=HDMPC.nlpParam.verbose;
r0=0*(opt.lower_bounds+opt.upper_bounds);
opt.initial_step=HDMPC.nlpParam.initstep;

% SOLVE NLP
[ropt,Jopt,nJ]=nlopt_optimize_mex(opt,r0);
for i=1:HDMPC.Ns
    AgentData(i).yd=ropt(i);
end
AgentData=coupling_alg(HDMPC,SubsystemMPC,SystemData,AgentData);

% DIAGNOSIS
if HDMPC.nlpParam.verbose
    for i=1:HDMPC.Ns
        custom_plot(deparametrize(SubsystemMPC(i),AgentData(i).ustar_sequences,'u'),...
            ['System control ' num2str(i)],'System control',...
            'lin',[-Inf Inf],[-Inf Inf],'Prediction horizon','System control',0,0,0.01);
        custom_plot(AgentData(i).ypred_sequences,...
            ['System output ' num2str(i)],'System output',...
            'lin',[-Inf Inf],[-Inf Inf],'Prediction horizon','System output',0,0,0.01);
        custom_plot(deparametrize(SubsystemMPC(i),AgentData(i).zpred_sequences,'z'),...
            ['System output coupling ' num2str(i)],'System output coupling',...
            'lin',[-Inf Inf],[-Inf Inf],'Prediction horizon','System output coupling',0,0,0.01);
    end
end

function Jr=master_cost_approx(HDMPC,SubsystemMPC,SystemData,AgentData,r)

% REFERENCE
for i=1:HDMPC.Ns
    AgentData(i).yd=r(i);
end

% MASTER COST
AgentData=coupling_alg(HDMPC,SubsystemMPC,SystemData,AgentData);
for i=1:length(SubsystemMPC)
    Jr(i,1)=AgentData(i).J;
end
Jr=HDMPC.nlpParam.pi'*Jr;



















