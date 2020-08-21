% Define function for initial photon packet setup,based on an imported 
% custom intensity profile.
% See Khalighi et al. IEEE Photonics Journal 2017        

% Imported data should be formated as .csv, column 1 = angle (degress),
% column 2 = relative intensity (0 to 1).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [source_qfit] = Custom_setup(theta_degrees,profile)
theta = deg2rad(theta_degrees);
intensity = (profile.*sin(theta))/pi;
int_fit = fit(theta,intensity,'linearinterp');

index = 1;
while index < length(theta)+1
    q(:,index) = 2*pi*integrate(int_fit,theta(index),0); % Integrate to find relationship between q and emission angle, theta
    index = index + 1;
end

source_qfit = fit(transpose(q),theta,'linearinterp'); % Fit to pass to the rest of the script