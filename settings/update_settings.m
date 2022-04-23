% =========================================================================
% % name        : pulse_intervals.m
% % type        : functions
% % purpose     : update settings for multi-shot pulse train if needed
% % parameters  : gs - global settings before update
% % output      : gs - global settings after update
% % author       : Olga Dergachyova
% % last update : 10/2020
% =========================================================================

function [gs] = update_settings(gs)

    % update parameters for multi-shot pulse train
    if gs.pulse.type == 1
        gs.pulse.init_pulse_seq.alpha = repmat(gs.pulse.init_pulse_seq.alpha, 1, gs.pulse.nshots);
        gs.pulse.init_pulse_seq.phi = repmat(gs.pulse.init_pulse_seq.phi, 1, gs.pulse.nshots);
        gs.pulse.TR = (gs.pulse.duration + gs.pulse.tau) *  gs.pulse.nt * gs.pulse.nshots;
        gs.pulse.nt = gs.pulse.nt * gs.pulse.nshots;
    end
    
end