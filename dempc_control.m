function out=dempc_control(SubsystemMPC,in)
   
% INPUT PARSING
inSel=cumsum([0 ... 
              SubsystemMPC(1).model.nx ...
              SubsystemMPC(2).model.nx ...
              SubsystemMPC(3).model.nx ...
              SubsystemMPC(4).model.nx ...
              SubsystemMPC(1).model.nw ...
              SubsystemMPC(2).model.nw ...
              SubsystemMPC(3).model.nw ...
              SubsystemMPC(4).model.nw]);   
SystemData(1).x=in(inSel(1)+1:inSel(2)); 
SystemData(2).x=in(inSel(2)+1:inSel(3)); 
SystemData(3).x=in(inSel(3)+1:inSel(4)); 
SystemData(4).x=in(inSel(4)+1:inSel(5)); 
SystemData(1).w=in(inSel(5)+1:inSel(6)); 
SystemData(2).w=in(inSel(6)+1:inSel(7)); 
SystemData(3).w=in(inSel(7)+1:inSel(8)); 
SystemData(4).w=in(inSel(8)+1:end);

% HDMPC
for i=1:numel(SubsystemMPC)
    AgentData(i).vpred_sequences=...
        zeros(length(SubsystemMPC(i).param.vIndex),...
        SubsystemMPC(i).model.nv);
    AgentData(i).yd=0;
    AgentData(i).ustar_sequences=0;
    AgentData(i).xpred_sequences=0;
    AgentData(i).ypred_sequences=0;
    AgentData(i).zpred_sequences=0;
    AgentData(i).J=0;
    AgentData(i)=mpc_ctrl(SubsystemMPC(i),SystemData(i),AgentData(i));
end

% OUTPUT PARSING
out=[AgentData(1).ustar_sequences(1,:)';
     AgentData(2).ustar_sequences(1,:)';
     AgentData(3).ustar_sequences(1,:)';
     AgentData(4).ustar_sequences(1,:)';
     AgentData(1).yd;
     AgentData(2).yd;
     AgentData(3).yd;
     AgentData(4).yd;
     0;
     0];

    
    
    
    