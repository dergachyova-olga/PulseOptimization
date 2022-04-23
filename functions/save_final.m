% =========================================================================
% % name        : save_final.m
% % type        : function
% % purpose     : save final optimal solution
% % parameters  : x - final optimal solution
% %             : fval - its objective function's score
% %             : gs - global settings
% % author       : Olga Dergachyova
% % last update : 10/2020
% =========================================================================

function save_final(x, fval, gs)

    % save final results
    save(fullfile(gs.save.path, strcat(gs.save.name,'.final.mat')), 'x', 'fval');
    
    % save before sequence if multi-part pulse train
    if gs.pulse.mp.active == true
        
        % get 'before' part
        [pulse_seq, idx_after] = pulse_intervals_multi_part(x, gs.pulse.nt, gs.pulse.mp);
        pulse_seq.alpha = pulse_seq.alpha(1:idx_after-1);
        pulse_seq.phi = pulse_seq.phi(1:idx_after-1);
        
        % save 'before' part
        save(fullfile(gs.save.path, strcat(gs.save.name,'.before.final.mat')), 'pulse_seq');
    end

end