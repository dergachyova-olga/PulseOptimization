% =========================================================================
% % name        : pulse_intervals_multi_part.m
% % type        : function
% % purpose     : create multi-part one-shot interval pulse train from candidate solution
% % parameters  : x - candidate solution
% %             : nt - number of pulses
% %             : mp - multi-part settings
% % output      : pulse_seq_ - created pulse train
% %             : idx_after - starting index for next part
% % author       : Olga Dergachyova
% % last update : 10/2020
% =========================================================================

function [pulse_seq_, idx_after] = pulse_intervals_multi_part(x, nt, mp)
    
    % create empty sequence
    pulse_seq_ = struct;
    pulse_seq_.alpha = zeros(1,nt);
    pulse_seq_.phi = zeros(1,nt);
    
    % load 'before' part if available
    if ~isempty(mp.before_path)
        
        % load 
        load(mp.before_path, 'pulse_seq');
        nt_before = size(pulse_seq.alpha,2);
        pulse_seq_.alpha(1:nt_before) = pulse_seq.alpha;
        pulse_seq_.phi(1:nt_before) = pulse_seq.phi;
        
        % save 'now' start index
        idx_now = nt_before + 1;

    % save 1 as 'now' start index, if 'before' part isn't available    
    else
        idx_now = 1;        
    end

    % setup 'now' part
    pulse_seq_now_ = pulse_intervals(x,mp.nt_now);
    pulse_seq_.alpha(idx_now : idx_now - 1 + mp.nt_now) = pulse_seq_now_.alpha;
    pulse_seq_.phi(idx_now : idx_now - 1 + mp.nt_now) = pulse_seq_now_.phi;
    
    % save 'after' index
    idx_after = idx_now + mp.nt_now;
 
end