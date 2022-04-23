% =========================================================================
% % name        : gen_multi.m
% % type        : multi-objective function
% % purpose     : compute all objective scores for GM and WM signals
% % parameters  : x - candidate solution
% %             : gs - global settings
% %             : sim - simulation object
% % output      : of - vector with computed objective functions' scores
% % author       : Olga Dergachyova
% % last update : 10/2020
% =========================================================================

function [of] = gen_multi(x, gs, sim)

    % generate signal for multi-shot pulse train
    if gs.pulse.type == 1
        
        % create pulse sequence from x
        pulse_seq = get_pulse_seq(x, gs);
        pulse_seq_ = pulse_multi_shot(x, gs, true);
        
        % simulate magnetization for gray and white matter
        [mrf_GM, mrf_WM] = simulate(sim, pulse_seq_);
        
        % take only last shot's signal
        [mrf_GM, mrf_WM] = take_last_shot(mrf_GM, mrf_WM, gs.pulse.nshots, 0);
    
    % generate signal for one-shot pulse train    
    else 
        % create pulse sequence from x
        pulse_seq = get_pulse_seq(x, gs);

        % simulate magnetization for gray and white matter
        [mrf_GM, mrf_WM] = simulate(sim, pulse_seq);
    
    end

    % compute and combine objectives
    of = zeros(1,size(gs.optimizer.objectives,2));
    for i=1:size(of,2)
        
        % dot
        if strcmp(gs.optimizer.objectives(i), 'dot')
            of(i) = dot(mrf_GM.a, mrf_WM.a);
            
        % corr    
        elseif strcmp(gs.optimizer.objectives(i), 'corr')
            of(i) = abs(corr(mrf_GM.a', mrf_WM.a'));
            
        % cond
        elseif strcmp(gs.optimizer.objectives(i), 'cond')
            of(i) = cond(horzcat(mrf_GM.a, mrf_WM.a));
        end
    end
    
    % store iteration results
    store_progress(pulse_seq, x, mrf_GM.a, mrf_WM.a, gs.optimizer.objectives, num2cell(of));
    
end