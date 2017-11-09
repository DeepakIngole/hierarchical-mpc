function r=phi_criterion(x)
  Tsim=evalin('base','Tsim;');
  Ts=evalin('base','Ts;');
  % number of states of subsystems
  r=0;
  M=size(x,1)/4; %4 states for each subsystem
  P=getP();
  P=P(:,1:M);
  for k=1:Tsim
    for i=1:size(P,1)
      deltaTeta_i=x(1+(i-1)*4,k);
      [tmp js]=find(P(i,:));
      for j=js
        deltaTeta_j=x(1+(j-1)*4,k);
        DeltaPtie=P(i,j)*(deltaTeta_i-deltaTeta_j);
        r = r + abs(DeltaPtie)*Ts;
      end
    end
  end
  r=r/Tsim;
end

function P=getP()
  str=evalin('base','who(''P*'')');
  for i=1:length(str)
    if ~isempty(str2num(str{i}(2:end)))
      j=str2num(str{i}(2));
      k=str2num(str{i}(3));
      P(j,k)=evalin('base',str{i});
    end
  end
end