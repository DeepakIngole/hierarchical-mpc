function mpc=mpc_pred(mpc)

mpc=mpc_predictor_gen(mpc,'x');
mpc=mpc_predictor_gen(mpc,'y');
mpc=mpc_predictor_gen(mpc,'z');
    
function mpc=mpc_predictor_gen(mpc,varName)

A=mpc.model.A;B=mpc.model.B;F=mpc.model.F;M=mpc.model.M;
nx=mpc.model.nx;nu=mpc.model.nu;nw=mpc.model.nw;nv=mpc.model.nv;
Np=mpc.param.Np;

switch varName
    case 'x'
        C=eye(mpc.model.nx);
        D=zeros(mpc.model.nx,mpc.model.nu);
        G=zeros(mpc.model.nx,mpc.model.nw);
        N=zeros(mpc.model.nx,mpc.model.nv);
        nvar=mpc.model.nx;
        Index=1:mpc.param.Np;
    case 'y'
        C=mpc.model.C;
        D=mpc.model.D;
        G=mpc.model.G;
        N=mpc.model.N;
        nvar=mpc.model.ny;
        Index=1:mpc.param.Np;
    case 'z'
        C=mpc.model.Cz;
        D=mpc.model.Dz;
        G=mpc.model.Gz;
        N=mpc.model.Nz;
        nvar=mpc.model.nz;
        Index=mpc.param.zIndex;
end

Psi=zeros(nvar*Np,nx);
Phi=zeros(nvar*Np,nu*Np);
Theta=zeros(nvar*Np,nw*Np);
Upsilon=zeros(nvar*Np,nv*Np);
for i=1:Np
    try
        Psi((i-1)*nvar+1:i*nvar,:)=...
            Psi((i-2)*nvar+1:(i-1)*nvar,:)*A;
        Phi((i-1)*nvar+1:i*nvar,1:i*nu)=...
            [C*A^(i-2)*B Phi((i-2)*nvar+1:(i-1)*nvar,1:(i-1)*nu)];
        Theta((i-1)*nvar+1:i*nvar,1:i*nw)=...
            [C*A^(i-2)*F Theta((i-2)*nvar+1:(i-1)*nvar,1:(i-1)*nw)];
        Upsilon((i-1)*nvar+1:i*nvar,1:i*nv)=...
            [C*A^(i-2)*M Upsilon((i-2)*nvar+1:(i-1)*nvar,1:(i-1)*nv)];
    catch
        Psi((i-1)*nvar+1:i*nvar,:)=C*A^(i-1);
        Phi((i-1)*nvar+1:i*nvar,1:i*nu)=D;
        Theta((i-1)*nvar+1:i*nvar,1:i*nw)=G;
        Upsilon((i-1)*nvar+1:i*nvar,1:i*nv)=N;
    end
end
Phi=Phi*mpc.param.uPi;
Theta=Theta*mpc.param.wPi;
Upsilon=Upsilon*mpc.param.vPi;

Nvar=numel(Index);
varIndex=zeros(nvar*Nvar,1);
for i=1:Nvar
    varIndex((i-1)*nvar+1:i*nvar)=[(Index(i)-1)*nvar+1:Index(i)*nvar]';
end
Psi=Psi(varIndex,:);
Phi=Phi(varIndex,:);
Theta=Theta(varIndex,:);
Upsilon=Upsilon(varIndex,:);

switch varName
    case 'x'
        mpc.pred.x=struct('Psi',Psi,'Theta',Theta,'Phi',Phi,'Upsilon',Upsilon);
    case 'y'
        mpc.pred.y=struct('Psi',Psi,'Theta',Theta,'Phi',Phi,'Upsilon',Upsilon);
    case 'z'
        mpc.pred.z=struct('Psi',Psi,'Theta',Theta,'Phi',Phi,'Upsilon',Upsilon);
end

