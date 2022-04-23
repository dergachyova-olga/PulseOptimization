% =========================================================================
% % name        : penalize.m
% % type        : functions
% % purpose     : penalize objective function's score with given constraint
% % parameters  : score - objective function's score before penalty applied
% %             : gs - global settings
% %             : pulse_seq - pulse train
% %             : x - candidate solution
% % output      : score - objective function's score after penalty applied
% % author       : Olga Dergachyova
% % last update : 10/2020
% =========================================================================

function [score] = penalize(score, gs, pulse_seq, x)
    
    % SAR penalty if activated
    if any(strcmp(gs.optimizer.penalty.targets,'sar'))
        score = sar_penalty(score, gs.optimizer.penalty, pulse_seq);
    end
    
    % flip angle penalty if activated
    if any(strcmp(gs.optimizer.penalty.targets,'fa'))
        score = fa_penalty(score, gs.optimizer.penalty, x);
    end
    
    % gradient angle penalty if activated
    if any(strcmp(gs.optimizer.penalty.targets,'gradient'))
        score = gradient_penalty(score, gs.optimizer.penalty, x);
    end    
end

% SAR penalty
function [score] = sar_penalty(score, penalty, pulse_seq)

    % fetch limit and coeficient
    lim = cell2mat(penalty.lim(strcmp(penalty.targets, 'sar')));
    coef = cell2mat(penalty.coef(strcmp(penalty.targets, 'sar')));

    % compute penalty
    sar_ = sum((rad2deg(pulse_seq)).^2);
    
    % apply penalty
    if sar_ > lim
       score = score * coef;
    end
    
end

% flip angle penalty
function [score] = fa_penalty(score, penalty, x)

    % fetch coeficient
    coef = cell2mat(penalty.coef(strcmp(penalty.targets, 'fa')));

    % convert radiants to degrees
    x_ = round(rad2deg(x));
    
    % to avoid calling 0 index
    x_(x_ == 0) = 1;

    % compute penalty
    p = coef * mean(penalty.function(x_));
    
    % apply penalty
    score = score + p;
    
end

% gradient penalty
function [score] = gradient_penalty(score, penalty, x)

    % fetch coeficient
    coef = cell2mat(penalty.coef(strcmp(penalty.targets, 'gradient')));

    % compute penalty
    p = coef * sum(abs(gradient(x)));
    
    % apply penalty
    score = score + p;
    
end