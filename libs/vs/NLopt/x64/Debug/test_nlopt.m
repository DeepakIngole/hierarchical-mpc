clear;clc;
opt.algorithm=NLOPT_LN_BOBYQA;
opt.stopval=1e-10;
opt.initial_step=[1e-2;1e-2];
opt.min_objective=@(x) x(1)^2+x(2)^2;
opt.lower_bounds=[-2;-2];
opt.upper_bounds=[+2;+2];
opt.verbose=1;
[xopt,fopt,retcode]=nlopt_optimize_mex(opt,[1;1])