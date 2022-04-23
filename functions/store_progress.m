% =========================================================================
% % name        : store_progress.m
% % type        : function
% % purpose     : save progress of the optimization at every iteration
% % parameters  : pulse_seq - pulse train
% %             : x - candidate solution
% %             : mrf_GM - gray matter signal
% %             : mrf_WM - white matter signal  
% %             : targets - names of objective functions to minimize
% %             : target_values - scores of objective functions
% % author       : Olga Dergachyova
% % last update : 10/2020
% =========================================================================

function store_progress(pulse_seq, x, mrf_GM, mrf_WM, objectives, objectives_values)

    % declare global variables
    global progress_x; 
    global progress_alpha;
    global progress_phi;
    global progress_mrf;
    global progress_objectives;
    global ncalls;

    % save iteration results
    ncalls = ncalls + 1;
    progress_x(ncalls,:) = x;
    progress_alpha(ncalls,:) = pulse_seq.alpha;
    progress_phi(ncalls,:) = pulse_seq.phi;
    progress_mrf(ncalls,1,:) = mrf_GM;
    progress_mrf(ncalls,2,:) = mrf_WM;
    
    % save objective function's values
    for i=1:size(objectives,2)
        if strcmp(objectives(i), 'dot')
            progress_objectives.dot(ncalls,1) = objectives_values(i);
        elseif strcmp(objectives(i), 'crlb')
            progress_objectives.crlb(ncalls,1) = objectives_values(i);
        elseif strcmp(objectives(i), 'corr')
            progress_objectives.corr(ncalls,1) = objectives_values(i);
        elseif strcmp(objectives(i), 'cond')
            progress_objectives.cond(ncalls,1) = objectives_values(i);
        end
    end
    
end