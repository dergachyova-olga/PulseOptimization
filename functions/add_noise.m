% =========================================================================
% % name        : add_noise.m
% % type        : function
% % purpose     : adds noise to the signal
% % parameters  : sig - complex signal without noise
% %             : relative - indicates if signal-to-noise ratio to be computed retative to mean signal
% %             : SNR - signal-to-noise ratio after adding noise
% % output      : sig - complex signal with noise
% % author       : Olga Dergachyova
% % last update : 10/2020
% =========================================================================

% sig - complex signal
function [sig] = add_noise(sig, relative, SNR)
       
    % ----- NEW METHOD          
    if relative == true
        noise_std = mean(abs(sig))/SNR;
    else
        noise_std = 1/SNR;
    end

    N = noise_std * (randn(numel(sig),1) + 1i * randn(numel(sig),1));
    sig = sig + N;

end