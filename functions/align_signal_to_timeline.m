% =========================================================================
% % name        : align_signal_to_timeline.m
% % type        : function
% % purpose     : align given signal (GM or WM) to the timeline
% % parameters  : gs - global settings
% %             : input_signal - GM or WM fingerprint signal
% % output      : output_signal - aligned signal
% % author       : Olga Dergachyova
% % last update : 10/2020
% =========================================================================

function [output_signal] = align_signal_to_timeline(gs, input_signal)

        % compute number of steps between pulses
        steps = round((gs.pulse.duration+gs.pulse.tau)*1000/gs.sim.dt);
        
        % create empty container
        output_signal = zeros(1,(gs.pulse.nt-1)*steps);

        % interpolate between neighboring signals 
        for j=1:gs.pulse.nt-1
            output_signal(1,(j-1)*steps+1:(j-1)*steps+steps) = linspace(input_signal(1,j),input_signal(1,j+1),steps);
        end
        
        % compute delays before (pre) and after alignment (post)
        pre = zeros(1,gs.pulse.duration*1000/gs.sim.dt);
        post = zeros(1,gs.pulse.TR*1000/gs.sim.dt - size(pre,2) - size(output_signal,2));
        
        % put together aligned signal and delays
        output_signal = horzcat(zeros(1,gs.display.margin), pre, output_signal, post);

end