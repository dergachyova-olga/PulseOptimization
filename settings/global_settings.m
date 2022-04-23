% =========================================================================
% % name        : global_settings.m
% % type        : settings function
% % purpose     : loads parameters defining simulated object, pulse train,
% %               and optimization
% % author       : Olga Dergachyova
% % last update : 10/2020
% =========================================================================

function [gs] = global_settings()

    % ---- prepare structure for settings
    gs = struct;
    
    % ---- simulated object
    gs.obj.n = 2; % number of simulated tissues (e.g., GM & WM = 2)
    
    gs.obj.GM.T1short   = 30.22 * 1e-3; % [s] gray matter T1 short
    gs.obj.GM.T1long    = 30.22 * 1e-3; % [s] gray matter T1 long
    gs.obj.GM.T2short   = 4  * 1e-3; % [s] gray matter T2 short
    gs.obj.GM.T2long    = 26.4 * 1e-3; % [s] gray matter T2 long

    gs.obj.WM.T1short   = 29.24 * 1e-3; % [s] white matter T1 short
    gs.obj.WM.T1long    = 29.24 * 1e-3; % [s] white matter T1 long
    gs.obj.WM.T2short   = 3.9  * 1e-3; % [s] white matter T2 short
    gs.obj.WM.T2long    = 22.1 * 1e-3; % [s] white matter T2 long

    % ---- pulse
    gs.pulse.TR = 85; % [ms] time for the entire sequence including final delay (applies for one-shot sequences only)
    gs.pulse.TE = 0.4; % [ms] echo time
    gs.pulse.tau = 7.5; % [ms] delay between pulses
    gs.pulse.TI = 2 * gs.pulse.tau; % [ms] inversion time
    gs.pulse.duration = 1; % [ms] pulse duration
    gs.pulse.FA_max = 150; % [degrees] maximum possible flip angle
    gs.pulse.phi_max = 180; % [degrees] maximum possible phase
    gs.pulse.nt = 10; % number of pulses
    gs.pulse.nx = 10; % number of points to optimize 
    gs.pulse.choice = 'np'; % options: 'np' (n-pulses), 'ir' (inversion recovery + np)
    gs.pulse.type = 2; % options: 1 - multi-shot train, 2 - one-shot train with intervals, 3 - one-shot smooth train
    gs.pulse.nshots = 1; % number of shots (activates only for gs.pulse.type = 1)
    gs.pulse.init_path = ''; % path to initial pulse train, should have '*.opt_pulse_seq.mat' extension
    
    % ---- simulation
    gs.sim.dt = 250; % [us] dwell time
    gs.sim.adc = 10; % [ms] readout time

    % ---- multi-part pulse train (warning: legacy code/parameters - not tested here)
    gs.pulse.mp.active = false; % defines if pulse train should be simulated and optimized in several parts
    gs.pulse.mp.nt_now = 3; % number of pulses in current part
    gs.pulse.mp.nx_now = gs.pulse.mp.nt_now; % number of points to optimize for current part
    gs.pulse.mp.before_path = ''; % path to previous part; if empty, current part will be first

    % ---- noise (warning: legacy code/parameters - not tested here)
    gs.noise.apply = false; % defines if noise is simulated
    gs.noise.SNR = 20; % signal-to-noise ration
    gs.noise.relative = false; % defines if SNR to be computed retative to mean signal

    % ---- optimizer
    gs.optimizer.type = 'GA'; % optimization algorithm; options: 'SA' (simulated annealing), 'GA' (genetic algorithm), 'GAm' (multi-objective GA), 'PSm' (multi-objective Pareto front)
    gs.optimizer.objectives = {'corr'}; % objective functions to minimize during optimization; options: 'dot' (dot product), 'corr' (Pearson correlation), 'cond' (condition number); can be combined, for ex. {'corr', 'dot'}. 
    gs.optimizer.ndim = gs.pulse.nx*2; % total number of dimensions for optimization = optimization points x modalities (i.e. angle and phase)
    gs.optimizer.niter = 100; % number of iterations (generations in case of GA)
    gs.optimizer.objlim = -Inf; % optimization stops if this limit attained 
    gs.optimizer.eps = 1e-6; % optimization stops if difference between subsequent iterations is smaller than epsilon

    % ---- optimization penalties (warning: legacy code/parameters - not tested here)
    gs.optimizer.penalty.apply = false; % defines if optimization function should be penalized (increased) if optimization points violate constraints
    gs.optimizer.penalty.targets = {'fa'}; % optimization constraints; options: 'sar' (specific absorption rate), 'fa' (flip angle), 'gradient'; see ./functions/penalize.m
    gs.optimizer.penalty.function = 'linear_20-90'; % penalty function name (for fa only, see ./functions/penalize.m and ./penalties)
    gs.optimizer.penalty.lim = {gs.pulse.nt*(60.^2)}; % penalty limit that restricts flip angle amplitudes (for sar only), ex: nt*(FA.^2)
    gs.optimizer.penalty.coef = {0.1}; % penalty coefficient that defines the intensity of penalty 

    % ---- optimization constraints
    gs.optimizer.const.A = deg2rad([]); % inequality optimization constraints (see matlab doc)
    gs.optimizer.const.b = deg2rad([]); % inequality optimization constraints (see matlab doc)
    gs.optimizer.const.Aeq = deg2rad([]); % equality optimization constraints (see matlab doc)
    gs.optimizer.const.beq = deg2rad([]); % equality optimization constraints (see matlab doc)
    gs.optimizer.const.lb = deg2rad(zeros(1,gs.pulse.nx*2)); % lower bound contraint (see matlab doc)
    gs.optimizer.const.ub = deg2rad([gs.pulse.FA_max * ones(1,gs.pulse.nx), gs.pulse.phi_max * ones(1,gs.pulse.nx)]); % upper bound contraint (see matlab doc)

    % ---- display
    gs.display.margin = 3; % display margin for pulse train and signal
    gs.display.video_step = 1; % step between iterations for video showing optimization progress
    gs.display.frame_rate = 0.5; % [fps] framerate for video showing optimization progress
    
    % ---- saving
    gs.save.path = './results/'; % folder to save results
    gs.save.name = 'sample'; % name of the experiment used to save the results
            
end
