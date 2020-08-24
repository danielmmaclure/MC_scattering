%%% New M.C. scripts, Apr 2018
%%% Create new photons, Lambertian source
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [init_packet_weight,pos,dir] = create_photons(packets,squares,fitfunc)

t1 = rand(packets,1); % Dice roll for Azimuth (theta) angles
t2 = rand(packets,1); % Dice roll for Elevation (psi) angles
theta = 2*pi*(t1); % Randomised initial Azimuth (Theta) angles (0 to 2pi)
psi = fitfunc(t2); % Initialise psi angles using previously defined fit function
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

pos(:,1) = tx+squares(tsquare,1); % Initial x coordinates 
pos(:,2) = ty+squares(tsquare,2); % Initial y coordinates 
pos(:,3) = zeros(packets,1); % Initial z coordinates (all = 0)

end