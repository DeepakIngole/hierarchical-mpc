function mpc=mpc_cstr(mpc)

uIndex=mpc.param.uIndex;

nx=mpc.model.nx;nu=mpc.model.nu;nw=mpc.model.nw;nv=mpc.model.nv;
nc=mpc.model.nc;

np=mpc.qp.np;

% BOUND CSTR
u.min=[repmat(mpc.cstr.u.min,length(uIndex),1);-1e3*ones(nc,1)];
u.max=[repmat(mpc.cstr.u.max,length(uIndex),1);+1e3*ones(nc,1)];

% OUTPUT CSTR
c.A=[];c.b=[];c.bx=[];c.bw=[];c.bv=[];
for i=mpc.param.cIndex
    c.A=[c.A;
       -mpc.pred.z.Phi((i-1)*nc+1:i*nc,:) -eye(nc);
       +mpc.pred.z.Phi((i-1)*nc+1:i*nc,:) -eye(nc)];
    c.bx=[c.bx;
       +mpc.pred.z.Psi((i-1)*nc+1:i*nc,:);
       -mpc.pred.z.Psi((i-1)*nc+1:i*nc,:)];
    c.bw=[c.bw;
       +mpc.pred.z.Theta((i-1)*nc+1:i*nc,:);
       -mpc.pred.z.Theta((i-1)*nc+1:i*nc,:)];
    c.bv=[c.bv;
       +mpc.pred.z.Upsilon((i-1)*nc+1:i*nc,:);
       -mpc.pred.z.Upsilon((i-1)*nc+1:i*nc,:)];
    c.b=[c.b;-mpc.cstr.c.min;+mpc.cstr.c.max];
end
c.A=[c.A;-Psel(np-nc+1:np,np)];
c.bx=[c.bx;zeros(nc,nx)];
c.bw=[c.bw;zeros(nc,nw)];
c.bv=[c.bv;zeros(nc,nv*length(mpc.param.vIndex))];
c.b=[c.b;zeros(nc,1)];

% QP MATRICES
mpc.qp.lb=u.min;
mpc.qp.ub=u.max;
mpc.qp.A=c.A;
mpc.qp.b=c.b;
mpc.qp.bx=c.bx;
mpc.qp.bw=c.bw;
mpc.qp.bv=c.bv;
                          