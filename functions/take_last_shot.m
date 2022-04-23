% =========================================================================
% % name        : take_last_shot.m
% % type        : functions
% % purpose     : exctract signals from last shot only
% % parameters  : mrf_GM - GM fingerprint signal for all shots
% %             : mrf_WM - WM fingerprint signal for all shots
% %             : nshots - number of shots
% %             : final - indicates if done at the end of optimization
% % outputs     : mrf_GM - GM fingerprint signal for last shot
% %             : mrf_WM - WM fingerprint signal for last shot
% % author       : Olga Dergachyova
% % last update : 10/2020
% =========================================================================

function [mrf_GM, mrf_WM] = take_last_shot(mrf_GM, mrf_WM, nshots, final)

    % just take last shot's signal without re-nornalization
    if final == true
        s = size(mrf_GM,2) / nshots;
        mrf_GM = mrf_GM(end-s+1:end);
        mrf_WM = mrf_WM(end-s+1:end);
        
    % take last shot's signal and re-normalize    
    else
        mrf_GM = take_last(mrf_GM, nshots);
        mrf_WM = take_last(mrf_WM, nshots);
    end
    
end

% take last shot's signal with re-normalization
function [mrf] = take_last(mrf, nshots)

    % reverse normalization
    mrf.c = mrf.c * mrf.n;
    
    % take last shot
    s = size(mrf.c,2) / nshots;
    mrf.c = mrf.c(end-s+1:end);
    
    % renormalize
    mrf.n = norm(mrf.c);
    mrf.c = mrf.c/mrf.n;
    
    % take absolute
    mrf.a = abs(mrf.c);
 
end
