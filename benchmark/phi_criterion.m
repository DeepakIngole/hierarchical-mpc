function r=phi_criterion(x,scenario)
Tsim=evalin('base','Tsim;');
Ts=evalin('base','Ts;');
r=0;
M=size(x,1)/4;
P=getP();
if scenario~=3
    P=P(:,1:M);
else
    P=P(:,[1 2 3 5]);
end
for k=1:Tsim
    for i=1:size(P,1)
      deltaTeta_i=x(1+(i-1)*4,k);
      [~,js]=find(P(i,:));
      for j=js
        deltaTeta_j=x(1+(j-1)*4,k);
        DeltaPtie=P(i,j)*(deltaTeta_i-deltaTeta_j);
        r = r + abs(DeltaPtie)*Ts;
      end
    end
end
r=r/Tsim;

function P=getP()
str=evalin('base','who(''deltaPtie*'')');
for i=1:length(str)
    if ~isempty(str2num(str{i}(10:end)))
      j=str2num(str{i}(10));
      k=str2num(str{i}(11));
      P(j,k)=evalin('base',str{i});
    end
end
