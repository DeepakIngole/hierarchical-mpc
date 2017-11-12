clear all;close all;clc;
for i=1:10
    load(['aa_convergence_s2_beta' num2str(i*10)]);
    mean_iter(i)=mean(iter);
    beta(i)=i/10;
end
betanew=1e-1:1e-2:1;
iternew=interp1(beta,mean_iter,betanew,'spline');

plot(beta,mean_iter,'v');hold on;
plot(betanew,iternew,'-');

save aa_convergence_s2_beta beta mean_iter betanew iternew;