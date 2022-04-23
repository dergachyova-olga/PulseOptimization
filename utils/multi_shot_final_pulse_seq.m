% =========================================================================
% % name        : multi_shot_final_pulse_seq.m
% % type        : utility function for stand alone use
% % purpose     : makes and displays the results of multi-shot sequence
% % parameters  : path - path to *.mat file with pulse train 
% %             : shots - number of shots
% %             : min_ - low y-axis limit for signal plot
% %             : max_ - high y-axis limit for signal plot
% % comments    : need to set all parameters in ./settinbgs/global_settings.m
% % author       : Olga Dergachyova
% % last update : 10/2020
% =========================================================================

function multi_shot_final_pulse_seq(path, shots, min_, max_)

    close all;

    % add path to required functions
    addpath(genpath('functions'));
    addpath(genpath('settings'));
    addpath(genpath('simulator'));

    % load settings
    gs = global_settings();
    
    % load pulse train
    load(path, 'pulse_seq');
    init_pulse_seq = pulse_seq;
     
    % ----------- full multi-shot
    
    % make it multi-shot
    pulse_seq.alpha = repmat(pulse_seq.alpha, 1, shots);
    pulse_seq.phi = repmat(pulse_seq.phi, 1, shots);
    
    % save initial settings 
    gs.pulse.nx_ = size(init_pulse_seq.alpha,2);
    gs.pulse.nt_ = gs.pulse.nx_;
    gs.pulse.TR_ = gs.pulse.TR;
    
    % update settings 
    gs.pulse.nx = size(pulse_seq.alpha,2);
    gs.pulse.nt = gs.pulse.nx;
    gs.pulse.TR = (gs.pulse.duration + gs.pulse.tau) * gs.pulse.nx;  
    gs.pulse.init_pulse_seq = pulse_seq; 

    % prepare simulation
    sim = prepare_simulation(gs);
    
    % generate magnetization
    [mrf_GM, mrf_WM, mrf_GM_, mrf_WM_, sim] = simulate_final(sim, pulse_seq);
        
    % get alphas for display
    alpha = max(pulse_seq.alpha) * sim.seq.w1 / max(sim.seq.w1);
    alpha = rad2deg(alpha);

    % interpolate for max display
    steps = round((gs.pulse.duration+gs.pulse.tau)*1000/gs.sim.dt);
    tmp = zeros(2,(gs.pulse.nt-1)*steps); % 1st - GM, 2nd - WM
    for j=1:gs.pulse.nt-1
        tmp(1,(j-1)*steps+1:(j-1)*steps+steps) = linspace(mrf_GM_(1,j),mrf_GM_(1,j+1),steps);
        tmp(2,(j-1)*steps+1:(j-1)*steps+steps) = linspace(mrf_WM_(1,j),mrf_WM_(1,j+1),steps);
    end
    pre = zeros(1,gs.pulse.duration*1000/gs.sim.dt);
    post = zeros(1,round(gs.pulse.TR*1000/gs.sim.dt) - size(pre,2) - size(tmp,2));
    mrf_GM_disp = horzcat(pre, tmp(1,:), post);
    mrf_WM_disp = horzcat(pre, tmp(2,:), post);

    % display
    fig = figure('name','Final results: stacked');
    subplot(4,1,1); hold on;
        plot(1000*sim.seq.t,alpha, 'k');
        hold off; box on; title('Flip angle','fontweight','bold'); 
        xlabel('time [ms]'); ylabel('[degrees]'); xlim([0 gs.pulse.TR]); ylim([0 gs.pulse.FA_max*1.05]);
    subplot(4,1,2); hold on;
        plot(1000*sim.seq.t,rad2deg(mod(sim.seq.phi,2*pi)), 'k');
        hold off; box on; title('Phase','fontweight','bold'); 
        xlabel('time [ms]'); ylabel('[degrees]'); xlim([0 gs.pulse.TR]); ylim([0 gs.pulse.phi_max*1.05]);
    subplot(4,1,3); hold on; 
        scores = get_score_str(mrf_GM, mrf_WM);
        xaxis = linspace(1,gs.pulse.TR,size(mrf_GM,2));
        plot(xaxis, mrf_GM); plot(xaxis, mrf_WM); 
        hold off; box on; title(strcat("Full magnetization (", scores, ")"),'fontweight','bold'); legend('GM', 'WM');
        xlabel('time [ms]'); xlim([1 gs.pulse.TR]); ylim([0 1]);
    subplot(4,1,4); hold on; 
        scores = get_score_str(mrf_GM_, mrf_WM_);
        xaxis = linspace(1,gs.pulse.TR,size(mrf_GM_disp,2));
        plot(xaxis,mrf_GM_disp); plot(xaxis,mrf_WM_disp); 
        hold off; box on; title(strcat("Max magnetization (", scores, ")"),'fontweight','bold'); legend('GM', 'WM');
        xlabel('time [ms]'); xlim([1 gs.pulse.TR]); 
        
        if min_ == -1 && max_ == -1
            ylim([min(min(mrf_GM_(:)), min(mrf_WM_(:))), max(max(mrf_GM_(:)), max(mrf_WM_(:)))]);
        else
            ylim([min_, max_]);
        end
          
    saveas(fig, fullfile(gs.save.path, strcat(gs.save.name, '.multi-shot.full.png')));  
    
    % ----------- last shot only
    % update setting again
    gs.pulse.nx = gs.pulse.nx_;
    gs.pulse.nt = gs.pulse.nt_;
    gs.pulse.TR = gs.pulse.TR_;
    
    % extract last shot signal
    mrf_GM = mrf_GM_(end-gs.pulse.nx+1:end);
    mrf_WM = mrf_WM_(end-gs.pulse.nx+1:end);
    
    % create timeline for display
    timeline = linspace(0, gs.pulse.TR, gs.display.margin + gs.pulse.TR*1000/gs.sim.dt);

    % align pulse train to display timeline
    alpha = align_pulses_to_timeline(gs, pulse_seq.alpha);
    phi = align_pulses_to_timeline(gs, pulse_seq.phi);

    % interpolate and align simulated signal to display timeline
    mrf_GM_ = align_signal_to_timeline(gs, mrf_GM);
    mrf_WM_ = align_signal_to_timeline(gs, mrf_WM);

    % display
    fig = figure('name','Final results: stacked');
    subplot(3,1,1); 
        plot(timeline, rad2deg(alpha), 'k');
        box on; xlabel('time [ms]'); ylabel('[degrees]'); title('Flip angle','fontweight','bold'); 
        xlim([0 gs.pulse.TR]); ylim([0 gs.pulse.FA_max*1.05]);
    subplot(3,1,2); 
        plot(timeline,rad2deg(phi), 'k');
        box on; xlabel('time [ms]'); ylabel('[degrees]'); title('Phase','fontweight','bold'); 
        xlim([0 gs.pulse.TR]); ylim([0 gs.pulse.phi_max*1.05]);
    subplot(3,1,3); 
        hold on; plot(timeline,mrf_GM_); plot(timeline,mrf_WM_); hold off; 
        box on; xlabel('time [ms]'); xlim([1 gs.pulse.TR]); legend('GM', 'WM');
        title(strcat("Max magnetization (", get_score_str(mrf_GM, mrf_WM), ")"),'fontweight','bold');
        if min_ == -1 && max_ == -1
            ylim([min(min(mrf_GM(:)), min(mrf_WM(:))), max(max(mrf_GM(:)), max(mrf_WM(:)))]);
        else
            ylim([min_, max_]);
        end  
          
    saveas(fig, fullfile(gs.save.path, strcat(gs.save.name, '.multi-shot.last.png')));
end