function AgentData=mpc_ctrl(mpc,SystemData,AgentData)

nx=mpc.model.nx;nw=mpc.model.nw;nu=mpc.model.nu;nv=mpc.model.nv;

% PARSING INPUT
x=SystemData.x;
w=SystemData.w;
vpred_tilde=reshape(AgentData.vpred_sequences',[],1);
yd=AgentData.yd;

% STEADY-STATE TARGET OPTIMIZATION
ud=w;

% UPDATE & SOLVE QP
lb=mpc.qp.lb;ub=mpc.qp.ub;
H=mpc.qp.H;
f=[mpc.qp.Fx mpc.qp.Fw mpc.qp.Fv mpc.qp.Fyd mpc.qp.Fud]*...
  [x;w;vpred_tilde;yd;ud];
A=mpc.qp.A;
b=mpc.qp.b+...
  [mpc.qp.bx mpc.qp.bw mpc.qp.bv]*[x;w;vpred_tilde];
p_opt=cplexqp(H,f,A,b,[],[],lb,ub); 
                               
ustar_tilde=p_opt(1:mpc.qp.np-mpc.model.nc,1);
cstar_tilde=p_opt(mpc.qp.np-mpc.model.nc+1:end,1);

% PREDICTION
xpred_tilde=mpc.pred.x.Psi*x+...
            mpc.pred.x.Theta*w+...
            mpc.pred.x.Upsilon*vpred_tilde+...
            mpc.pred.x.Phi*ustar_tilde;
ypred_tilde=mpc.pred.y.Psi*x+...
            mpc.pred.y.Theta*w+...
            mpc.pred.y.Upsilon*vpred_tilde+...
            mpc.pred.y.Phi*ustar_tilde;
zpred_tilde=mpc.pred.z.Psi*x+...
            mpc.pred.z.Theta*w+...
            mpc.pred.z.Upsilon*vpred_tilde+...
            mpc.pred.z.Phi*ustar_tilde;
        
AgentData.ustar_sequences=reshape(ustar_tilde,mpc.model.nu,[])';
AgentData.xpred_sequences=reshape(xpred_tilde,mpc.model.nx,[])';
AgentData.ypred_sequences=reshape(ypred_tilde,mpc.model.ny,[])';
AgentData.zpred_sequences=reshape(zpred_tilde,mpc.model.nz,[])';

% COST
AgentData.J=ypred_tilde'*mpc.qp.Wy*ypred_tilde+...
            ustar_tilde'*mpc.qp.Wu*ustar_tilde+...
            cstar_tilde'*mpc.param.Wc*cstar_tilde;



