% =========================================================================
% % name        : save_final.m
% % type        : function
% % purpose     : save final optimal pulse train
% % parameters  : x - final optimal solution
% %             : gs - global settings
% % author       : Olga Dergachyova
% % last update : 10/2020
% =========================================================================

function save_opt_pulse_seq(x, gs)

    % create pulse train from solution x
    pulse_seq = get_pulse_seq(x, gs);
    
    % save
    save(fullfile(gs.save.path, strcat(gs.save.name,'.opt_pulse_seq.mat')), 'pulse_seq');

end