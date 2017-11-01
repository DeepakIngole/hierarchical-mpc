clear all
close all
clc

str={'MPCfull','MPCdiag','MPCzero'};
for ii=1:3
  for jj=1:3
    [eta eta_g]=control_main(struct('scenario',num2str(ii),...
      'controlType',str{jj}));
    disp(['Scenario ' num2str(ii) ', control type '  str{jj}...
      '-> eta = ' num2str(eta) ', eta given = ' num2str(eta_g)]);
  end
end

