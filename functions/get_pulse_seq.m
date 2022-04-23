% =========================================================================
% % name        : get_pulse_seq.m
% % type        : function
% % purpose     : trasnform candidate solution x to pulse train
% % parameters  : x - candidate solution
% %             : gs - global settings
% % output      : pulse_seq - pulse train
% % author       : Olga Dergachyova
% % last update : 10/2020
% =========================================================================

function [pulse_seq] = get_pulse_seq(x, gs)

    % create pulse train from candidate solution
    switch gs.pulse.type
        
        % multi-shot  
        case 1
            pulse_seq = pulse_multi_shot(x, gs, false);
        
        % one-shot interval     
        case 2
            if gs.pulse.mp.active == true
                [pulse_seq, ~] = pulse_intervals_multi_part(x, gs.pulse.nt, gs.pulse.mp);
            else
                pulse_seq = pulse_intervals(x,gs.pulse.nt);
            end
            
        % one-shot smooth      
        case 3
            pulse_seq = pulse_smooth(x,gs.pulse.nt, gs.pulse.FA_max);
    end
       
end