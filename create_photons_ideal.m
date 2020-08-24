%%% New M.C. scripts, Apr 2018
%%% Create new photons, Lambertian source
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [init_packet_weight,pos,dir] = create_photons_ideal(packets)

t1 = rand(packets,1); % Dice roll for Azimuth (Theta) angles

theta = 2*pi*(t1); % Randomised initial Azimuth (Theta) angles (0 to 2pi)
psi = zeros(packets,1); % Initial psi angles (all zero)
init_packet_weight = ones(packets,1); % Initial packet weights (all 1)

% Calculate direction cosines (see Leathers, Section 3.2 and 4.2)
dir(:,1) = sin(psi).*cos(theta);
dir(:,2) = sin(psi).*sin(theta);
dir(:,3) = cos(psi);

% Initialise photon positions (x,y,z) = (0,0,0)
pos(:,1) = zeros(packets,1); % Initial x,y,z coordinates (all photons start at 0,0,0) - x
pos(:,2) = zeros(packets,1); % y
pos(:,3) = zeros(packets,1); % z

end