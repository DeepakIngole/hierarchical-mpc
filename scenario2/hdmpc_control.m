function out=hdmpc_control(HDMPC,SubsystemMPC,in)
   
% INPUT PARSING
inSel=cumsum([0 ... 
              SubsystemMPC(1).model.nx ...
              SubsystemMPC(2).model.nx ...
              SubsystemMPC(3).model.nx ...
              SubsystemMPC(4).model.nx ...
              SubsystemMPC(5).model.nx ...
              SubsystemMPC(1).model.nw ...
              SubsystemMPC(2).model.nw ...
              SubsystemMPC(3).model.nw ...
              SubsystemMPC(4).model.nw ...
              SubsystemMPC(5).model.nw]);   
SystemData(1).x=in(inSel(1)+1:inSel(2)); 
SystemData(2).x=in(inSel(2)+1:inSel(3)); 
SystemData(3).x=in(inSel(3)+1:inSel(4)); 
SystemData(4).x=in(inSel(4)+1:inSel(5)); 
SystemData(5).x=in(inSel(5)+1:inSel(6)); 
SystemData(1).w=in(inSel(6)+1:inSel(7)); 
SystemData(2).w=in(inSel(7)+1:inSel(8)); 
SystemData(3).w=in(inSel(8)+1:inSel(9)); 
SystemData(4).w=in(inSel(9)+1:inSel(10));
SystemData(5).w=in(inSel(10)+1:end);

% HDMPC
for i=1:HDMPC.Ns
    AgentData(i).vpred_sequences=...
        zeros(length(SubsystemMPC(i).param.vIndex),...
        SubsystemMPC(i).model.nv);
    AgentData(i).ustar_sequences=0;
    AgentData(i).xpred_sequences=0;
    AgentData(i).ypred_sequences=0;
    AgentData(i).zpred_sequences=0;
    AgentData(i).J=0;
    AgentData(i).yd=0;
end

N=2e1;
tStart=tic;
for k=1:N
    [~,~,nJ,AgentData]=master_optimize(HDMPC,SubsystemMPC,SystemData,AgentData);
end
tElapse=toc(tStart)/N/5;

% OUTPUT PARSING
out=[AgentData(1).ustar_sequences(1,:)';
     AgentData(2).ustar_sequences(1,:)';
     AgentData(3).ustar_sequences(1,:)';
     AgentData(4).ustar_sequences(1,:)';
     AgentData(5).ustar_sequences(1,:)';
     AgentData(1).yd;
     AgentData(2).yd;
     AgentData(3).yd;
     AgentData(4).yd;
     AgentData(5).yd;
     tElapse;
     nJ];

    
    
    
    