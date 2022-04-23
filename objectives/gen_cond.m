% =========================================================================
% % name        : gen_cond.m
% % type        : objective function
% % purpose     : compute condition number between GM and WM signals
% % parameters  : x - candidate solution
% %             : gs - global settings
% %             : sim - simulation object
% % output      : cond_ - computed condition number
% % author       : Olga Dergachyova
% % last update : 10/2020
% =========================================================================

function [cond_] = gen_cond(x, gs, sim)

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
       
    % compute correlation coefficient
    cond_ = cond(horzcat(mrf_GM.a, mrf_WM.a));
    
    % store iteration results
    store_progress(pulse_seq, x, mrf_GM.a, mrf_WM.a, {'cond'}, {cond_});
    
end