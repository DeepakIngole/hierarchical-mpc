function mpc=mpc_obj(mpc)

Np=mpc.param.Np;
A=mpc.model.A;B=mpc.model.B;F=mpc.model.F;M=mpc.model.M;
C=eye(mpc.model.nx);D=zeros(mpc.model.nx,mpc.model.nu);G=zeros(mpc.model.nx,mpc.model.nw);N=zeros(mpc.model.nx,mpc.model.nv);
nx=mpc.model.nx;nu=mpc.model.nu;nw=mpc.model.nw;nv=mpc.model.nv;
nc=mpc.model.nc;

np=numel(mpc.param.uIndex)*nu+nc;

Psi=zeros(nx*Np,nx);
Phi=zeros(nx*Np,nu*Np);
Theta=zeros(nx*Np,nw*Np);
Upsilon=zeros(nx*Np,nv*Np);
for i=1:Np
    try
        Psi((i-1)*nx+1:i*nx,:)=...
            Psi((i-2)*nx+1:(i-1)*nx,:)*A;
        Phi((i-1)*nx+1:i*nx,1:i*nu)=...
            [C*A^(i-2)*B Phi((i-2)*nx+1:(i-1)*nx,1:(i-1)*nu)];
        Theta((i-1)*nx+1:i*nx,1:i*nw)=...
            [C*A^(i-2)*F Theta((i-2)*nx+1:(i-1)*nx,1:(i-1)*nw)];
        Upsilon((i-1)*nx+1:i*nx,1:i*nv)=...
            [C*A^(i-2)*M Upsilon((i-2)*nx+1:(i-1)*nx,1:(i-1)*nv)];
    catch
        Psi((i-1)*nx+1:i*nx,:)=C;
        Phi((i-1)*nx+1:i*nx,1:i*nu)=D;
        Theta((i-1)*nx+1:i*nx,1:i*nw)=G;
        Upsilon((i-1)*nx+1:i*nx,1:i*nv)=N;
    end
end

Grand_Wx=kron(eye(Np),mpc.param.Wx);
Grand_Wu=kron(eye(Np),mpc.param.Wu);

H=mpc.param.uPi'*(Phi'*Grand_Wx*Phi+Grand_Wu)*mpc.param.uPi;
Fx=mpc.param.uPi'*Phi'*Grand_Wx*Psi;
Fw=mpc.param.uPi'*Phi'*Grand_Wx*Theta*mpc.param.wPi;
Fv=mpc.param.uPi'*Phi'*Grand_Wx*Upsilon*mpc.param.vPi;
Fxd=-mpc.param.uPi'*Phi'*Grand_Wx*mpc.param.xdPi;
Fud=-mpc.param.uPi'*Grand_Wu*mpc.param.udPi;

H=Psel(1:np-nc,np)'*H*Psel(1:np-nc,np)+...
    Psel(np-nc+1:np,np)'*mpc.param.Wc*Psel(np-nc+1:np,np);
Fx=Psel(1:np-nc,np)'*Fx;
Fw=Psel(1:np-nc,np)'*Fw;
Fv=Psel(1:np-nc,np)'*Fv;
Fxd=Psel(1:np-nc,np)'*Fxd;
Fud=Psel(1:np-nc,np)'*Fud;

mpc.qp=struct('np',np,...
              'H',.5*(H'+H),...
              'Fx',Fx,'Fw',Fw,'Fv',Fv,'Fxd',Fxd,'Fud',Fud);
mpc.qp.Wx=Grand_Wx;
mpc.qp.Wu=mpc.param.uPi'*Grand_Wu*mpc.param.uPi;

