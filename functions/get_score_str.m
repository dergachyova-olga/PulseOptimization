% =========================================================================
% % name        : get_score_str.m
% % type        : function
% % purpose     : get string of scores for gray matter (GM) and white (WM) signals
% % parameters  : mrf_GM - GM fingerprint signal
% %             : mrf_WM - WM fingerprint signal
% % output      : str - string of scores
% % author       : Olga Dergachyova
% % last update : 10/2020
% =========================================================================

function [str] = get_score_str(mrf_GM, mrf_WM)

    % dot
    dot_ = dot(mrf_GM/norm(mrf_GM), mrf_WM/norm(mrf_WM));
    
    % corr
    corr_ = abs(corr(mrf_GM', mrf_WM'));
    
    % cond
    cond_ = cond(horzcat(mrf_GM, mrf_WM));
    
    % combine scores
    str = strcat("dot: ", num2str(dot_), " | corr: ", num2str(corr_), " | cond: ", num2str(cond_));
end