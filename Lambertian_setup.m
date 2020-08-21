% Define Lambertian order based on semiangle of emission %
% See Khalighi et al. IEEE Photonics Journal 2017        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [source_qfit] = Lambertian_setup(semiangle_degrees)
semiangle = deg2rad(semiangle_degrees); % Semiangle of LED emission (converted to Radians)
m = (-log(2)) / log(cos(semiangle)); % Lambertian order of emission

theta = (0:0.01:pi/2);
fun = @(x)(((m+1)/(2*pi))*cos(x).^m).*sin(x); % Define Lambertian model...
% sin(x) required because we are calculating the probability of a photon 
% being emitted into any element of solid angle, not the probability of it
% being emitted at a particular angle.

index = 1;
while index < length(theta)+1
    q(:,index) = 2*pi*integral(fun,0,theta(index)); % Integrate to find relationship between q and emission angle, theta
    index = index + 1;
end

source_qfit = fit(transpose(q),transpose(theta),'linearinterp'); % Fit to pass to the rest of the script
