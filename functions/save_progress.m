% =========================================================================
% % name        : save_progress.m
% % type        : function
% % purpose     : save progress of the optimization (each iteration's solution)
% % parameters  : path - path to save
% %             : name - name (without extension) to save
% % author       : Olga Dergachyova
% % last update : 10/2020
% =========================================================================

function save_progress(path, name)

    % get global variables
    global progress_x;
    global progress_alpha;
    global progress_phi;
    global progress_mrf;
    global progress_objectives;
    global ncalls;
    
    % save
    save(fullfile(path, strcat(name,'.progress.mat')), 'progress_x', 'progress_alpha', 'progress_phi', 'progress_mrf', 'progress_objectives', 'ncalls');
    
end