%%% New M.C. scripts, Apr 2018
%%% Create new photons, Lambertian source
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [init_packet_weight,pos,dir] = create_photons_ideal(packets,squares)

t1 = rand(packets,1); % Dice roll for Azimuth (Theta) angles

theta = 2*pi*(t1); % Randomised initial Azimuth (Theta) angles (0 to 2pi)
psi = zeros(packets,1); % Initial psi angles (all zero)
init_packet_weight = ones(packets,1); % Initial packet weights (all 1)

% Calculate direction cosines (see Leathers, Section 3.2 and 4.2)
dir(:,1) = sin(psi).*cos(theta);
dir(:,2) = sin(psi).*sin(theta);
dir(:,3) = cos(psi);

% Initialise photon positions (all start a z = 0);
n = size(squares,1); % Number of squares
tsquare = randi(n,packets,1); % Randomly allocate packets to each square
tx = rand(packets,1); % Randomise the x position within that square
ty = rand(packets,1); % Randomise the x position within that square

pos(:,1) = squares(tsquare,1) + (tx.*squares(tsquare,3)); % Initial x coordinates (bottom left corner + random width)
pos(:,2) = squares(tsquare,2) + (ty.*squares(tsquare,4)); % Initial y coordinates (bottom left corner + random height)
pos(:,3) = zeros(packets,1); % Initial z coordinates (all = 0)

end