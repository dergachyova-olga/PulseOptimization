% =========================================================================
% % name        : pulse_intervals.m
% % type        : functions
% % purpose     : create one-shot interval pulse train from candidate solution
% % parameters  : x - candidate solution
% %             : nt - number of pulses
% % output      : pulse_seq - created pulse train
% % author       : Olga Dergachyova
% % last update : 10/2020
% =========================================================================

function [pulse_seq] = pulse_intervals(x, nt)

    % compute function parameters: number of intervals (np) and number of pulses in each interval (step)
    np = size(x,2)/2;
    step = floor(nt/np);

    % create pulse train for alpha and phi separetely
    pulse_seq = struct;
    pulse_seq.alpha = get_interval_sequence(x(1:np), np, nt, step);
    pulse_seq.phi = get_interval_sequence(x(np+1:end), np, nt, step);
    
end

% create pulse train for one modality
function [seq] = get_interval_sequence(x, np, nt, step)

    % create train from x
    seq = zeros(1, nt);
    for i=1:np-1
        seq(1,(i-1)*step+1 : (i-1)*step+step) = x(1,i);
    end
    seq(1,(np-1)*step+1:end) = x(1,end);

end