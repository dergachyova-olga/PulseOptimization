% =========================================================================
% % name        : align_pulses_to_timeline.m
% % type        : function
% % purpose     : align given modality (flip angle alpha or phase phi) to the timeline
% % parameters  : gs - global settings
% %             : input_modality - data (flip angle alpha or phase phi)
% % output      : output_modality - aligned data
% % author       : Olga Dergachyova
% % last update : 10/2020
% =========================================================================

function [output_modality] = align_pulses_to_timeline(gs, input_modality)

        % create empty container
        output_modality = zeros(1, gs.pulse.TR*1000/gs.sim.dt);      
        
        % compute number of steps for one pulse and between pulses
        pulse_steps = round(gs.pulse.duration*1000/gs.sim.dt);
        steps = round((gs.pulse.duration+gs.pulse.tau)*1000/gs.sim.dt);
        
        % align every pulse
        for j=1:gs.pulse.nt
            output_modality(1,(j-1)*steps+1:(j-1)*steps+pulse_steps) = ones(1,pulse_steps) * input_modality(1,j);
        end
        
        % add margin for display
        output_modality = [zeros(1,gs.display.margin), output_modality];
    
end