function var_sequences=deparametrize(mpc,varparam_sequences,varname)

switch varname
    case 'u'
        varPi=mpc.param.uPi;
        nvar=mpc.model.nu;
    case 'v'
        varPi=mpc.param.vPi;
        nvar=mpc.model.nv;
    case 'z'
        varPi=mpc.param.zPi;
        nvar=mpc.model.nz;
end
        
var_sequences=reshape(varPi*reshape(varparam_sequences',[],1),nvar,[])';