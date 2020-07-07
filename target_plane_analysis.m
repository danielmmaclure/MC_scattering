% Target analysis
%%%%%%%%%%%%%%%%%

% This code analyses the coordinates of photons that have intercepted at
% target plane (outputs from fast_plane_analysis.m) and:

% a) Calculates the sum of packet weights that "hit" a square detector with
% a user-specified area, that is parallel to the target plane.

% b) Calculates the distribution of packet weights across a user-specified 
% area within the target plane.

% 1) Setting up
%%%%%%%%%%%%%%%

prompt = {'Target centre coordinates:','Target width (m):','Grid width (m):','Grid step size (m):'};
dlgtitle = 'Inputs required';
dims = [1 40];
definput = {'[0,0]','1e-3','1','0.05'};
trgt_plane_inputs = inputdlg(prompt,dlgtitle,dims,definput);

centre = str2num(trgt_plane_inputs{1}); % Target centre coordinates
max_deviation = 0.5 * str2num(trgt_plane_inputs{2}); % Maximum x/y deviation from the centre

x_min = centre(:,1) - max_deviation;
x_max = centre(:,1) + max_deviation;
y_min = centre(:,2) - max_deviation;
y_max = centre(:,2) + max_deviation;

% 2) Find all packets within target area and sum their packet weights
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
target_hits = find(coordinates(:,1) >= x_min & coordinates(:,1) <= x_max...
    & coordinates(:,2) >= y_min & coordinates(:,2) <= y_max);
Rx_received_total = sum(weights(target_hits)); % This is the total sum of packets hitting the receiver.

% 3) Calculated distribution of packets within the specified 'grid'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
grid_width = str2double(trgt_plane_inputs{3}); % Width of grid (m)
grid_step = str2double(trgt_plane_inputs{4}); % Grid step size (m)

grid_hits = find(abs(coordinates(:,1)) <= 0.5*grid_width & ... 
    abs(coordinates(:,2)) <= 0.5*grid_width); % Find packets within grid boundaries

[xq,yq] = meshgrid(-grid_width/2:grid_step:grid_width/2,...
    -grid_width/2:grid_step:grid_width/2); % Target mesh grid
% 
% vq = griddata(coordinates(:,1),coordinates(:,2),weights,xq,yq);
% % Interpolate the 3D scattered data (2D coordinate and weight)
% 
% % Plot received intensity profile at the target plane.
% contourf(xq,yq,vq);
% xlabel('X (m)'); ylabel('Y (m)');
% set(gca, 'FontSize', 20);
% title('Interpolated received intensity at target');
