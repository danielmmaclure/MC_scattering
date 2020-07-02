%%% This script terminates active packets that have a low weight (<1 e-4)
%%% They are terminated with 90% probability.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [active_index] = abs_kill(weights,active_index)

low_weight_index = find ((weights(active_index)) < 1e-6); % Find the indexs of low-weight active packets

dr1 = rand(length(low_weight_index),1); % Dice roll to select the 90% to be terminated

to_terminate = low_weight_index(find (dr1 <= 0.9)); % Find which packets to terminate

active_index(to_terminate,:) = 0; % Terminated packets set to "NaN".

end

