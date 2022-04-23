% =========================================================================
% % name        : make_final_video.m
% % type        : utility function for stand alone use
% % purpose     : make video of optimization progress
% % parameters  : path - path to *.mat file with optimization progress data 
% %             : min_ - low y-axis limit for signal plot
% %             : max_ - high y-axis limit for signal plot
% % comments    : need to set all parameters in ./settinbgs/global_settings.m
% %             : this script can only be used for GA and corr pair
% % author       : Olga Dergachyova
% % last update : 10/2020
% =========================================================================

function make_final_video(path, min_, max_)

    close all;

    % ----------- load and configure 
    
    % load settings
    addpath(genpath('functions'));
    addpath(genpath('settings'));
    gs = global_settings();

    % load progress data
    load(path, 'progress_alpha', 'progress_phi', 'progress_mrf', 'progress_objectives');
    corr = cell2mat(progress_target.corr);
    
    % get number of iterations and population size
    ngen = gs.optimizer.niter + 1;
    pop = size(corr,1) / ngen;
    
    % find individuals in each generation with min correlation values 
    [~, argmax] = min(reshape(corr, [pop, ngen]), [], 1);
    
    % get indices of these individuals
    idx = reshape(1:size(corr,1), [pop, ngen]);
    max_idx = zeros(ngen, 1);
    for i=1:ngen
        max_idx(i,1) = idx(argmax(1,i),i);
    end
    
    % remove first generation cause it's random
    max_idx = max_idx(2:end,1);
    ngen = ngen - 1;
    
    % ----------- make video
    
    % create and open video writer
    v = VideoWriter(fullfile(gs.save.path, strcat(gs.save.name,'.avi')));
    v.FrameRate = gs.display.frame_rate;
    open(v);

    % make frames
    for i=1:gs.display.video_step:ngen

        % extract data for current generation
        pulse_seq.alpha = squeeze(progress_alpha(max_idx(i,1),:));
        pulse_seq.phi =  squeeze(progress_phi(max_idx(i,1),:));
        
        mrf_GM =  squeeze(progress_mrf(max_idx(i,1),1,:))';
        mrf_WM =  squeeze(progress_mrf(max_idx(i,1),2,:))';
        
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

       % put title with current generation number      
       annotation(fig,'textbox',[0.44 0.95 0.15 0.045],'string',{strcat("Generation: ", num2str(i))},'horizontalalignment','center',...
            'fontweight','bold','fontsize',12,'fitboxtotext','on','linestyle','none','color',[0.45 0.45 0.45]);
        
        % write frame
        frame = getframe(gcf);
        writeVideo(v,frame);
        pause(0.5);
    end
    
    close(v);
    close all;
end