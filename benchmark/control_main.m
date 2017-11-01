%% IMTL control for PNS
%
% This script create all the controls applicable to the Hycon2 beanchmark 1
% i.e. Power Network System and executes the simulation
% and evalution of performance.
%
% Implemented control:
%
% * decLMI (WIDE toolbox)
% * dlincon (WIDE toolbox)
% * HiMPC centralized (WIDE toolbox)
% * HiMPC decentralized (WIDE toolbox)
%
% Copyright Davide Barcelli (davide.barcelli@imtlucca.it) 2012
%

function [eta eta_g]=control_main(varargin)
  %% Function options
  defaults.scenario='2';
  defaults.discretization='Dss';
  defaults.controlType='MPCfull';
  defaults.runSimulation=1;
  defaults.runSimulink=0;
  defaults.X=0.1*ones(5*4,1);
  defaults.U=[.5;.65;.65;.65;.55;.5];
  defaults.close=1;
  if nargin<1
    options=defaults;
  else
    options=varargin{1};
  end
  if ~isstruct(options)
    options=defaults;
  else
    fns=fieldnames(defaults);
    for i=1:length(fns)
      if ~isfield(options,fns{i})
        options=setfield(options,fns{i},getfield(defaults,fns{i}));
      end
    end
  end
  
  if options.close==1
    close all;
  end
  
  eta=[];

  %% Load parameters
  evalin('base','parameters;');
  % browse the scenario folder
  cd(['scenario' num2str(options.scenario)]);
  % load scenario data
  cd([options.discretization '_' options.controlType]);
  evalin('base','load(''dataSim.mat'');');
  % restrict constrints to effective number
  Q=evalin('base','Q');
  R=evalin('base','R');
  options.X=options.X(1:size(Q,1));
  options.U=options.U(1:size(R,1));  
  cd ..
  
  xO=evalin('base','xO''');
  uO=evalin('base','uO''');
  
  %% Simulink Simulation
  if options.runSimulink==1
    name = ['simulatorPNS_AGC_' num2str(options.scenario) '.mdl'];
    open(name);
    sim(name);
%    close_system(name);
    cd ..

    x=x_sim.signals.values';
    u=u_sim.signals.values';

    eta=eta_criterion(x,xO,u,uO,Q,R);
    eta_g = evalin('base','eta;');
  else
    cd ..
  end

  if options.runSimulation==1
    %% run new simulation
    dPload = evalin('base','deltaPload.signals.values'';');
    dPref = evalin('base','deltaPref.signals.values'';');
    x0=evalin('base','zeros(size(A,1),1);');
    
    A=evalin('base','A;');
    B=evalin('base','B;');  
    L=evalin('base','L;');
    nl=size(L,2);    
    for i=1:size(R,1)
      dec(i).x=[[1+(i-1)*nl:i*nl]'; size(R,1)+i];
      dec(i).y=dec(i).x;
      dec(i).u=i;
      dec(i).applied=i;
    end
    AA=[A L;zeros(nl,size(A,2)) .99*eye(nl)];
    BB=[B;zeros(nl,size(B,2))];

    XX=[options.X;0.3*ones(nl,1)];
    QQ=blkdiag(Q,1e-2*eye(nl));
    Ctrl=createController(dec,AA,BB,QQ,R,XX,options.U,dPref);
    
    for i=1:length(Ctrl)
      [x u]=runSimulation(x0,dPload,Ctrl{i},uO,1);
      eta(i)=eta_criterion(x,xO,u,uO,Q,R);
      phi(i)=phi_criterion(x,options.scenario);
      disp(['Controller type: ' Ctrl{i}.type ...
        '   eta = ' num2str(eta(i)) '   phi = ' num2str(phi(i))]);
    end
  end
  
end

function [x u]=runSimulation(x0,deltaPload,Ctrl,uO,showPlot)
  Ac=evalin('base','Ac;');
  Bc=evalin('base','Bc;');
  Cc=evalin('base','Cc;');
  Dc=evalin('base','Dc;');
  Ts=evalin('base','Ts;');
  Lc=evalin('base','Lc;');
  xO=evalin('base','xO''');
  Tsim = evalin('base','Tsim;');

  nl=size(Lc,2);    

  nstep=Tsim/Ts;
  x=[x0 zeros(size(Ac,1),nstep-1)];
  u=zeros(size(Bc,2),nstep);
  xt=x0;
  tt=0;
  for k=1:nstep
    xx=x(:,k);
    dx=xx-Lc*deltaPload(:,k);
    if strcmp(Ctrl.type,'given')
      u(:,k)=Ctrl.u(:,k);
    elseif strcmp(Ctrl.type,'Kc')
      u(:,k)=Ctrl.K*dx+uO(:,k);
    elseif strcmp(Ctrl.type,'Kd')
      u(:,k)=Ctrl.K*dx+uO(:,k);
    elseif strcmp(Ctrl.type,'lincon')
      zz=zeros(nl,1);
      u(:,k) = Ctrl.L.Deval([xx;zz])+uO(:,k);
    elseif strcmp(Ctrl.type,'dlincon')
      zz=zeros(nl,1);
      u(:,k) = Ctrl.L.Deval([xx;zz])+uO(:,k);
    end
    uu=u(:,k);
    const=Lc*deltaPload(:,k);
    [t,yy]=ode45(@(t,x) Ac*x+Bc*uu+const,[0 Ts],xx);
    x(:,k+1) = yy(end,:)';
    xt=[xt yy'];
    tt=[tt;t+(k-1)*Ts];
  end
  
  if showPlot
%    figure;
%    plot(0:Ts:Tsim,x);
    figure
    plot(tt(2:end),xt(:,2:end));
  end
end

function Ctrl=createController(dec,A,B,Q,R,X,U,u)
  % net allows to determone the degree of decentralization
  [nx nu]=size(B);
  
  Ts=evalin('base','Ts;');
  
  clear Ctrl
  
  Ctrl{1}.type='given';
  Ctrl{1}.u=u;
  % Linear controller (WIDE decLMI)
  % Proportional controllers (WIDE decLMI)
  net=zeros(nu,nx);
  for i=1:numel(dec)
    net(dec(i).applied,dec(i).x)=1;
  end
  decLMIobj = decLMI(net,A,B,Q,R,[],X,U);
  tic
  decLMIobj = decLMIobj.solve_centralized_lmi();
  toc
  Ctrl{end+1}.type='Kc';
  Ctrl{end}.K=decLMIobj.K.ci(:,1:end-nu);
  tic
  decLMIobj = decLMIobj.solve_dec_ideal_lmi();
  toc
  Ctrl{end+1}.type='Kd';
  Ctrl{end}.K=decLMIobj.K.di(:,1:end-nu);
  
  % Linear MPC (WIDE dlincon)
  model=ss(A,B,eye(size(A)),[],Ts);
  clear cost interval limits
  cost.Q=Q;
  cost.R=R;
  interval.N=15;
  interval.Nu=15;
  limits=[];
  limits.ymax=X;
  limits.ymin=-X;  
  limits.umax=U;
  limits.umin=-U;    
  Ctrl{end+1}.L=dlincon(model,'reg',dec,cost,interval,limits);
  Ctrl{end}.type='lincon';
  
  Ctrl{end+1}.L=Ctrl{end}.L;
  Ctrl{end}.L=Ctrl{end}.L.setDefaultMode('Dglobal');
  Ctrl{end}.type='dlincon';
    
%   % Hierarchical MPC (WIDE HiMPC)
%   model=ss(A,B,eye(size(A)),[],Ts);  
%   Xcon.min=-X;
%   Xcon.max=X;
%   m=size(B,2);
%   DeltaK=[0.05*ones(2*size(A,1)-m,1);100*ones(m,1)];
%   obj=HiMPC(model,[],Xcon,DeltaK,[]);
%   obj.computeMOARS();
%   obj.computeDeltaR();
%   
  
  % Decentralized Hierarchical MPC (WIDE HiMPC)
end
