function mpc=mpc_obj(mpc)

Np=mpc.param.Np;
A=mpc.model.A;B=mpc.model.B;F=mpc.model.F;M=mpc.model.M;
C=mpc.model.C;D=mpc.model.D;G=mpc.model.G;N=mpc.model.N;
nx=mpc.model.nx;nu=mpc.model.nu;nw=mpc.model.nw;nv=mpc.model.nv;
ny=mpc.model.ny;nc=mpc.model.nc;

np=numel(mpc.param.uIndex)*nu+nc;

Psi=zeros(ny*Np,nx);
Phi=zeros(ny*Np,nu*Np);
Theta=zeros(ny*Np,nw*Np);
Upsilon=zeros(ny*Np,nv*Np);
for i=1:Np
    try
        Psi((i-1)*ny+1:i*ny,:)=...
            Psi((i-2)*ny+1:(i-1)*ny,:)*A;
        Phi((i-1)*ny+1:i*ny,1:i*nu)=...
            [C*A^(i-2)*B Phi((i-2)*ny+1:(i-1)*ny,1:(i-1)*nu)];
        Theta((i-1)*ny+1:i*ny,1:i*nw)=...
            [C*A^(i-2)*F Theta((i-2)*ny+1:(i-1)*ny,1:(i-1)*nw)];
        Upsilon((i-1)*ny+1:i*ny,1:i*nv)=...
            [C*A^(i-2)*M Upsilon((i-2)*ny+1:(i-1)*ny,1:(i-1)*nv)];
    catch
        Psi((i-1)*ny+1:i*ny,:)=C;
        Phi((i-1)*ny+1:i*ny,1:i*nu)=D;
        Theta((i-1)*ny+1:i*ny,1:i*nw)=G;
        Upsilon((i-1)*ny+1:i*ny,1:i*nv)=N;
    end
end

Grand_Wy=kron(eye(Np),mpc.param.Wy);
Grand_Wu=kron(eye(Np),mpc.param.Wu);

H=mpc.param.uPi'*(Phi'*Grand_Wy*Phi+Grand_Wu)*mpc.param.uPi;
Fx=mpc.param.uPi'*Phi'*Grand_Wy*Psi;
Fw=mpc.param.uPi'*Phi'*Grand_Wy*Theta*mpc.param.wPi;
Fv=mpc.param.uPi'*Phi'*Grand_Wy*Upsilon*mpc.param.vPi;
Fyd=-mpc.param.uPi'*Phi'*Grand_Wy*mpc.param.ydPi;
Fud=-mpc.param.uPi'*Grand_Wu*mpc.param.udPi;

H=Psel(1:np-nc,np)'*H*Psel(1:np-nc,np)+...
    Psel(np-nc+1:np,np)'*mpc.param.Wc*Psel(np-nc+1:np,np);
Fx=Psel(1:np-nc,np)'*Fx;
Fw=Psel(1:np-nc,np)'*Fw;
Fv=Psel(1:np-nc,np)'*Fv;
Fyd=Psel(1:np-nc,np)'*Fyd;
Fud=Psel(1:np-nc,np)'*Fud;

mpc.qp=struct('np',np,...
              'H',.5*(H'+H),...
              'Fx',Fx,'Fw',Fw,'Fv',Fv,'Fyd',Fyd,'Fud',Fud);
mpc.qp.Wy=Grand_Wy;
mpc.qp.Wu=mpc.param.uPi'*Grand_Wu*mpc.param.uPi;

