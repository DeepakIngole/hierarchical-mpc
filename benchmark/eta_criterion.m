function r = eta_criterion(x,xO,u,uO,Q,R)
  Tsim=evalin('base','Tsim;');
  % number of states of subsystems
  r=0;
  for k=1:Tsim
    dx = x(:,k) - xO(:,k);
    du = u(:,k) - uO(:,k);
    r = r + mnorm(dx,Q) + mnorm(du,R);
  end
  r=r/Tsim;

end
function r=mnorm(x,A)
  r=x'*A*x;
end