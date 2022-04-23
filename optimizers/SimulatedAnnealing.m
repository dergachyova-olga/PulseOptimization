% =========================================================================
% % name        : SimulatedAnnealing.m
% % type        : optimizer
% % purpose     : run single-objective simulated annealing optimization
% % parameters  : gs - global settings
% %             : sim - simulation object
% % author       : Olga Dergachyova
% % last update : 10/2020
% =========================================================================

function [x,fval] = SimulatedAnnealing(gs, sim)

    % SA optimizer settings (for mor info see matlab doc)
    gs.optimizer.init_temp = 100; % initial tempeture
    gs.optimizer.temp_fun = 'temperatureexp'; % function defining tempreture progression; options: {'temperatureexp'} 'temperatureboltz', 'temperaturefast'
    gs.optimizer.anneal_fun = 'annealingfast'; % function defining progression of distance to possible solutions; options: 'annealingboltz', {'annealingfast'}
    gs.optimizer.reanneal_inter = 100; % number of iterations before re-annealing

    % update parameters
    options = optimoptions('simulannealbnd', 'Display', 'iter', 'PlotFcn', {@saplotbestx, @saplotbestf, @saplotx, @saplotf}, ...
                           'MaxIterations', gs.optimizer.niter, 'FunctionTolerance', gs.optimizer.eps, 'ObjectiveLimit', gs.optimizer.objlim, ...
                           'AnnealingFcn', gs.optimizer.anneal_fun, 'ReannealInterval', gs.optimizer.reanneal_inter, ...
                           'InitialTemperature', gs.optimizer.init_temp, 'TemperatureFcn', gs.optimizer.temp_fun);
                       
    % check if single-objective
    if size(gs.optimizer.objectives, 2) > 1
        error('Use a multi-objective method for multiple objectives');
    end
                       
    % set objective function
    if strcmp(gs.optimizer.objectives, 'dot')
        fun = @(x) gen_dot(x, gs, sim);
    elseif strcmp(gs.optimizer.objectives, 'corr')
        fun = @(x) gen_corr(x, gs, sim);
    elseif strcmp(gs.optimizer.objectives, 'cond')
        fun = @(x) gen_cond(x, gs, sim);
    end
    
    % optimize
    tic;
    [x,fval] = simulannealbnd(fun, gs.pulse.x0, gs.optimizer.const.lb, gs.optimizer.const.ub, options);
    toc;
end