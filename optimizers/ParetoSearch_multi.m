% =========================================================================
% % name        : ParetoSearch_multi.m
% % type        : optimizer
% % purpose     : run multi-objective genetic algorithm optimization
% % parameters  : gs - global settings
% %             : sim - simulation object
% % author       : Olga Dergachyova
% % last update : 10/2020
% =========================================================================

function [x,fval] = ParetoSearch_multi(gs, sim)

    % Pareto search optimizer settings (for mor info see matlab doc)
    gs.optimizer.size = 60; % size of the Pareto front

    % update parameters
    options = optimoptions('paretosearch', 'Display', 'iter', 'PlotFcn', 'psplotparetof', ... 
                           'ParetoSetSize', gs.optimizer.size, 'ParetoSetChangeTolerance', gs.optimizer.eps, ...
                           'MaxIterations', gs.optimizer.niter*(gs.pulse.nx+size(gs.optimizer.objectives,2)));
   
    % check if multi-objective
    if size(gs.optimizer.objectives, 2) == 1
        error('Use a single-objective method for single objective');
    end
    
    % set objective functions
    fun = @(x) gen_multi(x, gs, sim);
    
    % optimize
    tic;
    [x,fval] = paretosearch(fun, gs.optimizer.ndim, ...
                            gs.optimizer.const.A, gs.optimizer.const.b, gs.optimizer.const.Aeq, gs.optimizer.const.beq, ...
                            gs.optimizer.const.lb, gs.optimizer.const.ub, [], options);
    toc;
end