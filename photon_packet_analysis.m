% Photon packet analysis.
%%%%%%%%%%%%%%%%%%%%%%%%%

% This code analyses the photon packet position history (imported as
% "positions" and determines if they intercept a target specified by the
% user. This target is parallel to the x, y or z plane (z is default), at a
% given distance.

% For packets that intercept this plane the code then determines the
% coordinates at which they intercept it, and the corresponding photon
% weight at this position. These results are saved as "coordinates" and
% "weights" in the workspace.

% 1) Setting up
%%%%%%%%%%%%%%%

prompt = {'Target plane (x,y or z):','Target distance (m):'};
dlgtitle = 'Specify target';
dims = [1 40];
definput = {'z','5'};
trgt_inputs = inputdlg(prompt,dlgtitle,dims,definput);

trgt_dist = str2num(trgt_inputs{2}); % Distance to target (m)

% Check in which plane the target lies
switch trgt_inputs{1}
    case 'x'
        trgt_plane = 1;
    case 'y'
        trgt_plane = 2;
    case 'z'
        trgt_plane = 3;
end

% 2) For a given pair of subsequent photon positions, "x" and "x+1", we
% check to see if the path intercepts the target plane. This is true if the
% value of the target coordinate in "x" is < the target distance, AND > the
% target distance for "x+1".

% We will copy pairs of positions into a Cell array "hits", to be analysed
% later
hits{1} = NaN(size(positions{1},1),4); % Positions before intercept
hits{2} = NaN(size(positions{1},1),4); % Positions after intercept
active_packets = true(size(positions{1},1),1);
hit_index = false(size(positions{1},1),1);

start = tic; % Start main timer
h1 = waitbar(0,'Step 1 of 2: Searching for packets that intercept the target plane...'); % Initialise progress bar   
h1_barlength = size(active_packets,1); % Max value for progress bar

for counter = 1:size(positions,2)-1
hit_index(active_packets) = ((positions{counter}(active_packets,trgt_plane)) < trgt_dist) & ((positions{counter+1}(active_packets,trgt_plane)) > trgt_dist);
hits{1}(hit_index,:) = positions{counter}(hit_index,:);
hits{2}(hit_index,:) = positions{counter+1}(hit_index,:);
active_packets(hit_index) = 0; % These packets have "hit" the target, so can be removed from further checking
hit_index(active_packets == 0) = 0;
waitbar(sum(active_packets == 0)/h1_barlength); % Update waitbar
end
close(h1) % Close waitbar

% Remove NaNs, i.e. lines corresponding to packets that never hit the
% target
idx = isnan(hits{1}(:,1));
hits{1}(idx,:) = [];
hits{2}(idx,:) = [];

% 3) Now we know which "pairs" of positions correspond to target
% intercepts, so we next work out the positions where these trajectories
% intercepted the target.

h2 = waitbar(0,'Step 2 of 2: Calculating coordinates of target intercepts...'); % Initialise progress bar
h2_barlength = size(hits{1},1); % Max value for progress bar

%%% Find the parametric line equations for these pairs of points:
syms t
line = hits{1}(:,1:3) +t*(hits{2}(:,1:3) - hits{1}(:,1:3)); % Line equations

coordinates = sym(zeros(size(line,1),3)); % Empty symbolic array for intercept coordinates
weights = NaN(size(line,1),1); % Empty (NaN) array for the corresponding hit weights
t_target = NaN(size(line,1),1); % Empty (NaN) array for values of parameter t

for counter = 1:size(t_target,1)
    t_target(counter,:) = solve(line(counter,3) == trgt_dist, t);
    coordinates(counter,:) = subs(line(counter,:),t,t_target(counter,:));
    weights(counter,:) = hits{1}(counter,4) * exp(-a*pdist([double(coordinates(counter,:));hits{1}(counter,1:3)]));
    waitbar(counter/h2_barlength); % Update waitbar
end
close(h2) % Close waitbar

% 4) Prepare outputs
%%%%%%%%%%%%%%%%%%%%
coordinates = double(coordinates); % Convert coordinates to double

% 5) Tidying up
%%%%%%%%%%%%%%%
total_time = toc(start); % Obtain total run time

TOT_HOUR = floor(total_time/60^2); % # of hours
TOT_MINS = floor(((total_time/60^2) - TOT_HOUR) * 60); % # of minutes
TOT_SEC = round(total_time - ((TOT_HOUR*60^2) + (TOT_MINS*60))); % # of secs

close_string = horzcat('Simulation complete. Total run time: ',num2str(TOT_HOUR),' h, ', num2str(TOT_MINS),' m, ', num2str(TOT_SEC),' s.');
f = msgbox(close_string); % Display run time