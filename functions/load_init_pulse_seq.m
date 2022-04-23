% =========================================================================
% % name        : load_init_pulse_seq.m
% % type        : function
% % purpose     : load initial pulse train from a *opt_pulse_seq.mat file
% % parameters  : gs - global settings
% % output      : init_pulse_seq - initial pulse train
% % author       : Olga Dergachyova
% % last update : 10/2020
% =========================================================================

function [init_pulse_seq] = load_init_pulse_seq(gs)
   
    % load if path provided
    if ~isempty(char(gs.pulse.init_path))
       
        load(gs.pulse.init_path);
        init_pulse_seq.alpha = pulse_seq.alpha(1:gs.pulse.nt);
        init_pulse_seq.phi = pulse_seq.phi(1:gs.pulse.nt);
    
    % if not, set all alpha to half of max flip angle, and all phi to zero
    else
        init_pulse_seq.alpha = deg2rad(ones(1,gs.pulse.nt)*gs.pulse.FA_max/2);
        init_pulse_seq.phi = zeros(1,gs.pulse.nt);
    end
    
end