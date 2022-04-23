% =========================================================================
% % name        : GeneticAlgorithm.m
% % type        : optimizer
% % purpose     : run single-objective genetic algorithm optimization
% % parameters  : gs - global settings
% %             : sim - simulation object
% % author       : Olga Dergachyova
% % last update : 10/2020
% =========================================================================

function [x,fval] = GeneticAlgorithm(gs, sim)

    % GA optimizer settings (for mor info see matlab doc)
    gs.optimizer.pop = 50; % population size; advised 50 if ndim <5, 200 otherwise
    gs.optimizer.selection_fun = 'selectionstochunif'; % function for selecting candidates for next generation; options: {'selectionstochunif'}, 'selectionremainder', 'selectionuniform', 'selectionroulette'
    gs.optimizer.crossover_fun = 'crossoverscattered'; % function for crossover of candidates; options: {'crossoverscattered'}, 'crossoverheuristic', 'crossoversinglepoint', 'crossovertwopoint', 'crossoverarithmetic'
    gs.optimizer.mutation_fun = 'mutationadaptfeasible'; % function for mutation of individual candidates; options: {'mutationgaussian'}, 'mutationuniform', 'mutationadaptfeasible'
    gs.optimizer.fitness_scale_fun = 'fitscalingrank'; % function for ranking candidates; options: {'fitscalingrank'}, 'fitscalingshiftlinear', 'fitscalingprop', 'fitscalingtop'
    gs.optimizer.crossover_frac = 0.8; % portion of candidates that get crossovered
    gs.optimizer.elite_count = ceil(0.05*gs.optimizer.pop); % number of candidates that automatically selected for next generation

    % update parameters
    options = optimoptions('ga', 'Display', 'iter', 'PlotFcn', @gaplotbestf, ...
                           'PopulationSize', gs.optimizer.pop, 'MaxGenerations', gs.optimizer.niter, ...
                           'FunctionTolerance', gs.optimizer.eps, 'FitnessLimit', gs.optimizer.objlim, ...
                           'SelectionFcn', gs.optimizer.selection_fun, 'FitnessScalingFcn', gs.optimizer.fitness_scale_fun, ...
                           'CrossoverFcn', gs.optimizer.crossover_fun, 'MutationFcn', gs.optimizer.mutation_fun, ...
                           'CrossoverFraction', gs.optimizer.crossover_frac, 'EliteCount', gs.optimizer.elite_count);

    % check if single-objective
    if size(gs.optimizer.objectives, 2) > 1
        error('Use multi-objective GA for multiple objectives');
    end
    
    % set objective function
    if strcmp(gs.optimizer.objectives, 'dot')
        fun = @gen_dot;
    elseif strcmp(gs.optimizer.objectives, 'corr')
        fun = @gen_corr;
    elseif strcmp(gs.optimizer.objectives, 'cond')
        fun = @gen_cond;
    end
    
    % optimize
    tic;
    [x,fval] = ga({fun, gs, sim}, gs.optimizer.ndim, ...
                  gs.optimizer.const.A, gs.optimizer.const.b, gs.optimizer.const.Aeq, gs.optimizer.const.beq, ...
                  gs.optimizer.const.lb, gs.optimizer.const.ub, [], options);
    toc;
end