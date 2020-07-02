% This function finds low weight packets (that haven't been terminated
% previously) and boosts them 10x, with a 10% probability, as per Stujenske
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [weights] = boost(weights,active_index)
low_weight_index = find ((weights(active_index)) < 1e-6); % Find the indexs of low-weight active packets
dr1 = rand(length(low_weight_index),1); % Dice roll to select the 10% to be boosted

search_boost = low_weight_index(find (dr1 <= 0.1)); % Find which packets to boost
to_boost = active_index(search_boost);

%to_boost = find (dr1 <= 0.1); % Find which packets to boost
weights(to_boost) = 10.* weights(to_boost); % Boost those selected packets

end