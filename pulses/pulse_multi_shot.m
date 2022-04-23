% =========================================================================
% % name        : pulse_multi_shot.m
% % type        : functions
% % purpose     : create multi-shot pulse train from candidate solution
% % parameters  : x - candidate solution
% %             : gs - global settings
% %             : multi - indicates if x should be transformed to one(last)-shot or sequence of repeated shots
% % output      : pulse_seq - created pulse train
% % author       : Olga Dergachyova
% % last update : 10/2020
% =========================================================================
function [pulse_seq] = pulse_multi_shot(x, gs, multi)

    % create a pulse train which is a sequence of repeated shots
    if multi == true
        pulse_seq.alpha = repmat(x(1,1:end/2), 1, gs.pulse.nshots);
        pulse_seq.phi = repmat(x(1,end/2+1:end), 1, gs.pulse.nshots);
        
    % create a pulse train which is a sequence of one shot only
    else
        pulse_seq.alpha = x(1,1:end/2);
        pulse_seq.phi = x(1,end/2+1:end);
    end
    
end