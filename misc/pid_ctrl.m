function AgentData=pid_ctrl(mpc,SystemData,AgentData)

% PARSING INPUT
x=SystemData.x;
w=SystemData.w;
vpred_sequences=AgentData.vpred_sequences;
yd=AgentData.yd;

% PI CONTROL SIMULATION
Kp=10;Ki=0;

xpred_sequences(1,:)=x';
ypred_sequences(1,:)=xpred_sequences(1,2);
zpred_sequences(1,:)=xpred_sequences(1,1);
err=yd'-ypred_sequences(1,:)';
integral=err;
ustar_sequences(1,:)=(Kp*err+Ki*integral)'+w;
    
for k=2:mpc.param.Np
    xpred_sequences(k,:)=(mpc.model.A*xpred_sequences(k-1,:)'+...
                          mpc.model.B*ustar_sequences(k-1,:)'+...
                          mpc.model.F*w+...
                          mpc.model.M*vpred_sequences(k-1,:)')';
    ypred_sequences(k,:)=xpred_sequences(k,2);  
    zpred_sequences(k,:)=xpred_sequences(k,1);  
    err=yd'-ypred_sequences(k,:)';
    integral=integral+err;
    ustar_sequences(k,:)=(Kp*err+Ki*integral)'+w;
end

AgentData.xpred_sequences=xpred_sequences;
AgentData.ypred_sequences=ypred_sequences;
AgentData.zpred_sequences=zpred_sequences;
AgentData.ustar_sequences=ustar_sequences;

% COST
xpred_tilde=reshape(AgentData.xpred_sequences',[],1);
ustar_tilde=reshape(AgentData.ustar_sequences',[],1);
AgentData.J=(xpred_tilde-repmat([0;0;w;w],mpc.param.Np,1))'*mpc.qp.Wx*(xpred_tilde-repmat([0;0;w;w],mpc.param.Np,1))+...
            (ustar_tilde-repmat(w,mpc.param.Np,1))'*mpc.qp.Wu*(ustar_tilde-repmat(w,mpc.param.Np,1)); 
