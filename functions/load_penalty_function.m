% =========================================================================
% % name        : load_penalty_function.m
% % type        : function
% % purpose     : load one of the penalty functions from ./penalties folder
% % parameters  : gs - global settings
% % output      : pf - penalty function
% % author       : Olga Dergachyova
% % last update : 10/2020
% =========================================================================

function [pf] = load_penalty_function(gs)

    % load optimization penalty function if required
    if gs.optimizer.penalty.apply == true
        load(fullfile('./penalties', gs.optimizer.penalty.function), 'pf');
    else
        pf = false;
    end
    
end