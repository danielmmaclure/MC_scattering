%%% New M.C. scripts, Apr 2018
%%% Kill out of bound packets
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%INPUTS:
% weights - current packet weights
% wmin - the minimum permitted packet weight (= the weight at PMAX)

%OUTPUT:
% active_index - the updated index of "active photons"

function [new_active_index] = path_length_kill(pos,pmax)
max_pos = max(pos,[],2); % Maximum x, y or z displacement of each photon
new_active_index = max_pos <= pmax;% Update list of active packets.
end