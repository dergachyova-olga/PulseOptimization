% =========================================================================
% % name        : set_x0.m
% % type        : functions
% % purpose     : set initial solution for the optimizer
% %             : gs - global settings
% % output      : x0 - initial solution
% % author       : Olga Dergachyova
% % last update : 10/2020
% =========================================================================

function [x0] = set_x0(gs)

    % set the initial solution according to pulse train type
    switch gs.pulse.type
        
        % multi-shot 
        case 1
            x0 = [gs.pulse.init_pulse_seq.alpha, gs.pulse.init_pulse_seq.phi];

        % one-shot interval   
        case 2
            
            % multi-part (first part: angles - half max, phases - zero)
            if gs.pulse.mp.active == true
                x0_alpha = deg2rad(ones(1,gs.pulse.mp.nx_now)*gs.pulse.FA_max/2);
                x0_phi = zeros(1,gs.pulse.mp.nx_now);
                x0 = [x0_alpha, x0_phi];
            % single-part
            else
                x0 = set_interval_x0(gs.pulse);
            end
            
        % one-shot smooth (same as for intervals, but without multi-part option)
        case 3
            x0 = set_interval_x0(gs.pulse);
            

    end
    
end

% one-shot interval
function [x0] = set_interval_x0(pulse)

    % if number of optimization points is the same as number of pulses
    if pulse.nx == pulse.nt
        x0 = [pulse.init_pulse_seq.alpha, pulse.init_pulse_seq.phi];
    
    % if every optimization point corresponds to one interval
    else
        x0_alpha = get_intervals(pulse.init_pulse_seq.alpha, pulse.nx, pulse.nt);
        x0_phi = get_intervals(pulse.init_pulse_seq.phi, pulse.nx, pulse.nt);
        x0 = [x0_alpha, x0_phi];
    end
end

% compute intervals according to number of optimization points
function [x0] = get_intervals(data, nx, nt)

    % compute length of every x piece
    step = floor(nt/nx);

    % compute x0
    x0 = zeros(1, nx);
    for i=1:nx-1
        values = data(1,(i-1)*step+1 : (i-1)*step+step);
        x0(1,i) = get_value(values);
    end
    values = data(1,(nx-1)*step+1:end);
    x0(1,end) = get_value(values);
end

% get a value for interval
function [value] = get_value(values)
    
    % find local min and max values
    min_ = islocalmin(values);
    max_ = islocalmax(values);
    
    % compute value
    if any(min_) && any(max_)
        value = (max(values) - min(values))/2;
    elseif ~any(min_) && any(max_)
        value = max(values);
    elseif any(min_) && ~any(max_)
        value = min(values);
    elseif ~any(min_) && ~any(max_)
        value = mean([max(values),min(values)]);    
    end

end