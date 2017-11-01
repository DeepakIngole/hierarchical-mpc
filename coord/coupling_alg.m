function AgentData=coupling_alg(HDMPC,SubsystemMPC,SystemData,AgentData)

% PARAMETERS
m=HDMPC.aaParam.m;
smax=HDMPC.aaParam.smax;
atol=HDMPC.aaParam.atol;
rtol=HDMPC.aaParam.rtol;
droptol=HDMPC.aaParam.droptol;
beta=HDMPC.aaParam.beta;
AAstart=HDMPC.aaParam.AAstart;
verbose=HDMPC.aaParam.verbose;

% WARM START
for i=1:HDMPC.Ns
    x0(SubsystemMPC(i).model.nv*length(SubsystemMPC(i).param.vIndex)*(i-1)+1:...
       SubsystemMPC(i).model.nv*length(SubsystemMPC(i).param.vIndex)*i,1)=...
       reshape(AgentData(i).vpred_sequences,[],1);
end

% ANDERSON ACCELERATION
[x,~,err]=anderson_acceleration(...
    @(x) fp_fcn(HDMPC,SubsystemMPC,SystemData,AgentData,x),...
    x0,m,smax,atol,rtol,droptol,beta,AAstart);
for i=1:HDMPC.Ns
    AgentData(i).vpred_sequences=reshape(x...
        (SubsystemMPC(i).model.nv*length(SubsystemMPC(i).param.vIndex)*(i-1)+1:...
         SubsystemMPC(i).model.nv*length(SubsystemMPC(i).param.vIndex)*i),...
         [],SubsystemMPC(i).model.nv);
    AgentData(i)=mpc_ctrl(SubsystemMPC(i),SystemData(i),AgentData(i));
end

% DIAGNOSIS
if verbose
    custom_plot(err(:,2),'Residual versus Iteration','',...
        'log',[1 smax],[atol/10 Inf],'Iteration','Residual',0,1,.0001);
    for i=1:HDMPC.Ns
        custom_plot(deparametrize(SubsystemMPC(i),AgentData(i).ustar_sequences,'u'),...
            ['System control ' num2str(i)],'System control',...
            'lin',[-Inf Inf],[-Inf Inf],'Prediction horizon','System control',0,0,0.01);
        custom_plot(AgentData(i).ypred_sequences,...
            ['System output ' num2str(i)],'System output',...
            'lin',[-Inf Inf],[-Inf Inf],'Prediction horizon','System output',0,0,0.01);
%         custom_plot(deparametrize(SubsystemMPC(i),AgentData(i).vpred_sequences,'v'),...
%             ['System input coupling ' num2str(i)],'System input coupling',...
%             'lin',[-Inf Inf],[-Inf Inf],'Prediction horizon','System input coupling',0,0,0.01);
        custom_plot(deparametrize(SubsystemMPC(i),AgentData(i).zpred_sequences,'z'),...
            ['System output coupling ' num2str(i)],'System output coupling',...
            'lin',[-Inf Inf],[-Inf Inf],'Prediction horizon','System output coupling',0,0,0.01);
    end
end

function Gx=fp_fcn(HDMPC,SubsystemMPC,SystemData,AgentData,x)

for i=1:HDMPC.Ns
    AgentData(i).vpred_sequences=reshape(x...
        (SubsystemMPC(i).model.nv*length(SubsystemMPC(i).param.vIndex)*(i-1)+1:...
         SubsystemMPC(i).model.nv*length(SubsystemMPC(i).param.vIndex)*i),...
         [],SubsystemMPC(i).model.nv);
    AgentData(i)=mpc_ctrl(SubsystemMPC(i),SystemData(i),AgentData(i));
end

Gx=[];
for i=1:HDMPC.Ns
    for j=1:HDMPC.Ns
        if ~isempty(HDMPC.aaParam(i,j).topology)
            Gx=[Gx;
                AgentData(j).zpred_sequences(:,HDMPC.aaParam(i,j).topology)];
        end
    end
end

% for i=1:HDMPC.Ns
%     custom_plot(deparametrize(SubsystemMPC(i),AgentData(i).zpred_sequences,'z'),...
%         ['System output coupling ' num2str(i)],'System output coupling',...
%         'lin',[-Inf Inf],[-Inf Inf],'Prediction horizon','System output coupling',0,0,0.01);
% end
% 
% for i=1:HDMPC.Ns
% 	[~,z{i}]=fig2dat(['System output coupling ' num2str(i)]);
% end


