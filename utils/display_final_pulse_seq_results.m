% =========================================================================
% % name        : display_final_pulse_seq_results.m
% % type        : utility function for stand alone use
% % purpose     : display results of the optimization (optimal pulse train and generated signal)
% % parameters  : path - path to *.mat file with final optimimal pulse train 
% %             : min_ - low y-axis limit for signal plot
% %             : max_ - high y-axis limit for signal plot
% % comments    : need to set all parameters in ./settinbgs/global_settings.m
% % author       : Olga Dergachyova
% % last update : 10/2020
% =========================================================================

function display_final_pulse_seq_results(path, min_, max_)

    % add path to required functions
    addpath(genpath('functions'));
    addpath(genpath('settings'));
    addpath(genpath('simulator'));

    % load settings
    gs = global_settings();
    
    % load initial pulse train
    gs.pulse.init_pulse_seq = load_init_pulse_seq(gs);
    gs.pulse.x0 = set_x0(gs);

    % update some parameters
    gs = update_settings(gs);

    % prepare simulation
    sim = prepare_simulation(gs);

    % load optimal pulse train
    load(path, 'pulse_seq');
    
    % generate signal for multi-shot pulse train
    if gs.pulse.type == 1

        % repeat loaded optimal pulse train for required number of shots
        pulse_seq_.alpha = repmat(pulse_seq.alpha, 1, gs.pulse.nshots);
        pulse_seq_.phi = repmat(pulse_seq.phi, 1, gs.pulse.nshots);

        % simulate magnetization for gray and white matter
        [~,~,mrf_GM, mrf_WM,~] = simulate_final(sim, pulse_seq_);

        % take only last shot's signal
        [mrf_GM, mrf_WM] = take_last_shot(mrf_GM, mrf_WM, gs.pulse.nshots, 1);

        % update pulse params for display only last shot
        gs.pulse.TR = gs.pulse.TR / gs.pulse.nshots;
        gs.pulse.nt = gs.pulse.nt / gs.pulse.nshots;

    % generate signal for one-shot pulse train  
    else 

        % simulate magnetization for gray and white matter
        [~,~,mrf_GM, mrf_WM,~] = simulate_final(sim, pulse_seq);

    end
    
    % create timeline for display
    timeline = linspace(0, gs.pulse.TR, gs.display.margin + gs.pulse.TR*1000/gs.sim.dt);

    % align pulse train to display timeline
    alpha = align_pulses_to_timeline(gs, pulse_seq.alpha);
    phi = align_pulses_to_timeline(gs, pulse_seq.phi);

    % interpolate and align simulated signal to display timeline
    mrf_GM_ = align_signal_to_timeline(gs, mrf_GM);
    mrf_WM_ = align_signal_to_timeline(gs, mrf_WM);

    % ------- display image
    fig = figure('units','normalized','outerposition', [0 0 0.8 0.85], 'name','Final results');

    % display flip angle alpha
    subplot(3,1,1); 
        plot(timeline, rad2deg(alpha), 'k');
        box on; xlabel('time [ms]'); ylabel('[degrees]'); title('Flip angle','fontweight','bold'); 
        xlim([0 gs.pulse.TR]); ylim([0 gs.pulse.FA_max*1.05]);

    % display phase phi
    subplot(3,1,2); 
        plot(timeline,rad2deg(phi), 'k');
        box on; xlabel('time [ms]'); ylabel('[degrees]'); title('Phase','fontweight','bold'); 
        xlim([0 gs.pulse.TR]); ylim([0 gs.pulse.phi_max*1.05]);

    % display simulated signals    
    subplot(3,1,3); 
        hold on; plot(timeline,mrf_GM_); plot(timeline,mrf_WM_); hold off; 
        box on; xlabel('time [ms]'); xlim([1 gs.pulse.TR]); legend('GM', 'WM');
        title(strcat("Max magnetization (", get_score_str(mrf_GM, mrf_WM), ")"),'fontweight','bold');
        if min_ == -1 && max_ == -1
            ylim([min(min(mrf_GM(:)), min(mrf_WM(:))), max(max(mrf_GM(:)), max(mrf_WM(:)))]);
        else
            ylim([min_, max_]);
        end
         
    saveas(fig, fullfile(gs.save.path, strcat(gs.save.name, '.final.png')));   
end