% =========================================================================
% % name        : pulse_smooth.m
% % type        : functions
% % purpose     : create one-shot smooth pulse train from candidate solution
% % parameters  : x - candidate solution
% %             : nt - number of pulses
% %             : FA_max - maximum allowed flip angle
% % output      : pulse_seq - created pulse train
% % author       : Olga Dergachyova
% % last update : 10/2020
% =========================================================================

function [pulse_seq] = pulse_smooth(x, nt, FA_max)

    % compute function parameters: number of control points (np) and 
    % number of pulses corresponding to each interval (step)
    np = size(x,2)/2;
    step = floor(nt/np);

    % create pulse train for alpha and phi separetely
    pulse_seq = struct;
    pulse_seq.alpha = get_smooth_sequence(x(1:np), nt, step, FA_max);
    pulse_seq.phi = get_smooth_sequence(x(np+1:end), nt, step, FA_max);
    
end

% create pulse train for one modality
function [seq] = get_smooth_sequence(x, nt, step, FA_max)

    % add zero intersection points at the beginning and end
    x = [0 x 0];
    
    % define extremum positions (with zero-intersections)
    x_ = floor(step/2) : step : nt-floor(step/2);
    x_ = [0 x_ nt];

    % create sequence
    xx_ = 1:1:nt;
    seq = spline(x_, x, xx_);
    
    % cut off negative values
    seq = max(seq,0);
    
    % normaize if exceeds maximum FA
    if any(seq > deg2rad(FA_max))
        seq = (seq/max(seq))*deg2rad(FA_max);
    end

end