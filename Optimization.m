% =========================================================================
% % name        : Optimization.m
% % type        : main script
% % purpose     : optimize pulse train for fingerprinting to provide a good
% %               signal separation between targeted tissues 
% % parameters  : change parameters in 'settings/GlobalSettings.m'
% % author       : Olga Dergachyova
% % last update : 10/2020
% =========================================================================

%% -------------------------- Prepare workspace ------------------------ %%

% clean
clear; close all; clc; rng(0);

% add path to all required functions
addpath(genpath('settings'));
addpath(genpath('functions'));
addpath(genpath('penalties'));
addpath(genpath('optimizers'));
addpath(genpath('pulses'));
addpath(genpath('objectives'));
addpath(genpath('simulator'));

%% ----------------------------- Setup --------------------------------- %% 

% load settings
disp('Load settings...');
gs = global_settings();

% initialize global variables to track results at every iteration
if gs.optimizer.niter == Inf, n = 1; else, n = gs.optimizer.niter; end
global progress_x; progress_x = zeros(n,gs.optimizer.ndim);
global progress_alpha; progress_alpha = zeros(n,gs.pulse.nt);
global progress_phi; progress_phi = zeros(n,gs.pulse.nt);
global progress_mrf; progress_mrf = zeros(n,gs.obj.n,gs.pulse.nt);
global progress_objectives; progress_objectives = struct;
global opt_params; opt_params = struct;
global ncalls; ncalls = 0;

% load initial pulse sequence and set initial state (x0) for optimization
disp('Load initial sequence...');
gs.pulse.init_pulse_seq = load_init_pulse_seq(gs);
gs.pulse.x0 = set_x0(gs);

% update some parameters
gs = update_settings(gs);

% load optimization penalty function
gs.optimizer.penalty.function = load_penalty_function(gs);

% prepare simulation 
disp('Prepare simulation...');
sim = prepare_simulation(gs);


%% ------------------------------ Optimize ----------------------------- %% 
disp('Optimize...');

% chose optimization algorithm and run optimization
if strcmp(gs.optimizer.type, 'SA')
    [x,fval] = SimulatedAnnealing(gs, sim);
elseif strcmp(gs.optimizer.type, 'GA')
    [x,fval] = GeneticAlgorithm(gs, sim);
elseif strcmp(gs.optimizer.type, 'GAm')
    [x,fval] = GeneticAlgorithm_multi(gs, sim);
elseif strcmp(gs.optimizer.type, 'PSm')
    [x,fval] = ParetoSearch_multi(gs, sim);
end


%% ------------------------- Save results ------------------------------ %%
disp('Save...');

% history
save_progress(gs.save.path, gs.save.name);

% final results
save_final(x, fval, gs);

% optimization progress
saveas(gcf, fullfile(gs.save.path, strcat(gs.save.name,'.progress.png')));

% optimal sequence
save_opt_pulse_seq(x, gs);


%% ------------------------- Display results --------------------------- %% 
% final figure with pulse train and generated signal
display_final_results(x, gs, sim);
