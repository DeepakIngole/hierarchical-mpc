clear all
close all
clc
for i=1:3
  disp(sprintf('Scenario %d',i));
  control_main(struct('scenario',num2str(i)));
  %pause
  disp(sprintf('\n\n'));
end