%%% Move photons & reduce their weight
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [new_pos,weights] = move_packets(weights,pos,dir,a,b,active_packets)
packets = size(active_packets,1);
S = -log(rand(packets,1)) / b; % Move each active packet a random distance. This is related to the mean free path for scattering 
S(active_packets==0) = NaN; % Inactive packets are returned as "NaN"
weights= weights.* exp(-a * S); % Adjust new weight of each active packet to account for absorption and their respective path lengths.

% Update positions by summing previous x,y,z position, direction cosines
% and path lengths (See Leathers section 3.2)
new_pos(:,1) = pos(:,1) + (dir(:,1).*S); % New x coordinate
new_pos(:,2) = pos(:,2) + (dir(:,2).*S); % New y coordinate
new_pos(:,3) = pos(:,3) + (dir(:,3).*S); % New y coordinate
new_pos(:,4) = weights.* exp(-a * S); % Adjust new weight of each active packet to account for absorption and their respective path lengths.
end
