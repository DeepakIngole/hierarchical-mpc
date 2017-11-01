function mpc=mpc_param(mpc)

% SET POINT
mpc.param.ydPi=...
    parametrize(mpc.model.ny,mpc.param.Np,deal(1));
mpc.param.udPi=...
    parametrize(mpc.model.nu,mpc.param.Np,deal(1));

% INPUT & OUTPUT
mpc.param.uPi=...
    parametrize(mpc.model.nu,mpc.param.Np,deal(mpc.param.uIndex)); 
mpc.param.cPi=...
    parametrize(mpc.model.nc,mpc.param.Np,deal(mpc.param.cIndex)); 

% INTERACTION
mpc.param.zIndex=mpc.param.vIndex;
mpc.param.vPi=...
    parametrize(mpc.model.nv,mpc.param.Np,deal(mpc.param.vIndex)); 
mpc.param.zPi=...
    parametrize(mpc.model.nz,mpc.param.Np,deal(mpc.param.zIndex));

% DISTURBANCE MODEL
mpc.param.wPi=parametrize(mpc.model.nw,mpc.param.Np,deal(1)); 

function [Pi_z, sel]=parametrize(n_d,N_p,id_i)

if iscell(id_i)
    assert(length(id_i)==n_d,'multi parametrized MPC : the number of control effort n_d must be equal to the number of array contained in the id cell');
    id = id_i;
else
    for k=1:n_d
        id{k} = id_i;
    end
end

n_z = 0;
id_full = [];
orig = [];
tempo = [];

for k=1:n_d
    n_z = n_z + length(id{k});
    id_full = [id_full id{k}];
    orig = [orig k*ones(1,length(id{k}))];
    tempo = [tempo 1:length(id{k})];
end

[~, b] = sort(id_full);
c = orig(b);
d = tempo(b);

S = 1:n_z;
for k=1:n_d
    n_id(k) = length(id{k});
    Pi_zk{k} = param_one(N_p,n_id(k),id{k});
    sel(k,:) = S(k==c);
end
Pi_z = zeros(N_p*n_d,n_z);
for i=1:n_z
    Pi_z(c(i):n_d:end,i) = Pi_zk{c(i)}(:,d(i));
end
    
function [ Pi_z ] = param_one( N_p, n_id, id )

Pi_z = zeros(N_p,n_id);

for i = 1:N_p
    for j = 1:n_id

        if id(j)==i
            Pi_z(i,j) = 1;
        end

        if j<length(id) && id(j+1)>i && id(j)<i
            Pi_z(i,j)  = 1*(id(j+1)  - i) / (id(j+1)-id(j)) ;
        end   

        if j>1 && id(j)>i && id(j-1)<i
            Pi_z(i,j)  = 1*(i-id(j-1)) / (id(j)-id(j-1)) ;
        end

        if j==n_id && i>id(end)
            Pi_z(i,j)  = 1;
        end

    end
end







