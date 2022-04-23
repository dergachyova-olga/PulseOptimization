% =========================================================================
% % name        : GeneticAlgorithm_multi.m
% % type        : optimizer
% % purpose     : run multi-objective genetic algorithm optimization
% % parameters  : gs - global settings
% %             : sim - simulation object
% % author       : Olga Dergachyova
% % last update : 10/2020
% =========================================================================

function [x,fval] = GeneticAlgorithm_multi(gs, sim)

    % GA optimizer settings (for mor info see matlab doc)
    gs.optimizer.pop = 50; % population size; advised 50 if ndim <5, 200 otherwise
    gs.optimizer.pareto_frac = 0.35; % fraction of candidates selected for Pareto front
    gs.optimizer.distance = 'phenotype'; % distance type between candidates; options: {'phenotype'}, 'genotype'

    % update parameters
    options = optimoptions('gamultiobj', 'Display', 'iter', 'PlotFcn', {@gaplotrankhist, @gaplotpareto, @gaplotparetodistance, @gaplotspread}, ...
                           'PopulationSize', gs.optimizer.pop, 'MaxGenerations', gs.optimizer.niter, 'FunctionTolerance', gs.optimizer.eps, ...
                           'ParetoFraction', gs.optimizer.pareto_frac, 'DistanceMeasureFcn', {@distancecrowding, gs.optimizer.distance});
   
    % check if multi-objective
    if size(gs.optimizer.objectives, 2) == 1
        error('Use single-objective GA for single objective');
    end
    
    % optimize
    tic;
    [x,fval] = gamultiobj({@gen_multi, gs, sim}, gs.optimizer.ndim, ...
                          gs.optimizer.const.A, gs.optimizer.const.b, gs.optimizer.const.Aeq, gs.optimizer.const.beq, ...
                          gs.optimizer.const.lb, gs.optimizer.const.ub, [], options);
    toc;
end