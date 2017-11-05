% %% USER EVALUATION
% % SIMULATION
% open('pns_valid.mdl');
% mode=1;
% if mode<0
%     set_param('pns_valid/HDMPC','commented','on');
%     set_param('pns_valid/DEMPC','commented','off');
% else
%     set_param('pns_valid/HDMPC','commented','off');
%     set_param('pns_valid/DEMPC','commented','on');
% end
% sim('pns_valid');
% 
% t=x.time;
% x=x.signals.values;
% u=u.signals.values;
% deltaPref=deltaPref.signals.values;
% deltaFrequency=deltaFrequency.signals.values;
% deltaPtie12=deltaPtie12.signals.values;
% deltaPtie23=deltaPtie23.signals.values;
% deltaPtie34=deltaPtie34.signals.values;
% 
% r=r.signals.values;
% nJ=nJ.signals.values;
% tHDMPC=tHDMPC.signals.values;
% 
% % STORAGE
% if mode<0
%     save pns_dempc_valid t r u nJ tHDMPC deltaPref deltaFrequency deltaPtie12 deltaPtie23 deltaPtie34;
% else
%     save pns_dmpc_valid t r u nJ tHDMPC deltaPref deltaFrequency deltaPtie12 deltaPtie23 deltaPtie34;
% end