% 1) Setup
%%%%%%%%%%
%clear all
close all

%%% INPUTS %%%

% 1) Define input properties
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The following code prompts the user for some inputs
prompt = {'Absorption coefficient, a (m^{-1})','Scattering coefficient, b (m^-1)','Packets launched per loop','Number of loops','Path length max. (m)','Maximum number of scattering events'};
def = {'0.00922','0.179','100e4','5','50','10'};
options.Resize='on';
options.WindowStyle='normal';
inputs = inputdlg(prompt,'Inputs',1,def,options);
inputs = str2double(inputs);

a = inputs(1,1); % absorption coefficient m^ -1
b = inputs(2,1); % scattering coefficient m^-1

packets = inputs(3,1); % # of packets launched per loop
total_loops = inputs(4,1); % # Total number of loops
pmax = inputs(5,1); % Maximum path length (m)
max_scatter = inputs(6,1); % Maximum number of scattering events

% 2) Begin simulation
%%%%%%%%%%%%%%%%%%%%%
start = tic; % Start main timer
h = waitbar(0,'Simulation progress...'); % Initialise progress bar   
progress = 0; % Initialise progress
num_loops = 0;

while num_loops < total_loops

% a) Create packets
active_packets = true(packets,1); % Index of "Active photons"
weights = ones(packets,1); % Initial photon weights

[weights,start_pos,dir] = create_photons(packets); % Initialises photon packet angles, weights, positions and direction vectors
positions = cell(1,max_scatter); % Empty cell array to be populated with packet position history as they are moved during simulation
positions{1} = horzcat(single(start_pos),single(weights)); % First position saved is the start position, 4th column are the packet weights at these positions
scatter_cntr = 1;

waitbar(num_loops/total_loops,h);

% Internal MC loop - Move, adjust weights, kill, scatter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic;
while 1

% b) Move active packets, adjust weights and update position history
scatter_cntr = scatter_cntr + 1; % Increment scattering event counter
[positions{scatter_cntr},weights] = move_packets(weights,positions{scatter_cntr-1},dir,a,b,active_packets); % Moves all active packets and adjusts weights accordingly.

% c) Kill packets that have exceeded the maximum permitted path length
[active_packets] = path_length_kill(positions{scatter_cntr}(:,1:3),pmax);

% d) Terminate low-weight packets
[active_packets] = abs_kill(weights,active_packets);

% e) Test if the loop has completed (no more active packets, or max number
% of scattering events has been reached).
     if isempty(active_packets) == 1 || scatter_cntr == max_scatter       
         num_loops = num_loops + 1;
         break
     end     

% f) Boost low-weight packets
[weights] = boost(weights,active_packets);

% g) Scatter active packets
[dir] = scatter_packets(dir,active_packets); % Scatter active packets

end
% h) Save position and weights history
savename = horzcat('Loop',num2str(num_loops),'.mat');
save(savename,'positions','a','inputs');
end

% Simulation complete. Tidying up:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close(h); % Close progress bar
total_time = toc(start); % Obtain total run time

TOT_HOUR = floor(total_time/60^2); % # of hours
TOT_MINS = floor(((total_time/60^2) - TOT_HOUR) * 60); % # of minutes
TOT_SEC = round(total_time - ((TOT_HOUR*60^2) + (TOT_MINS*60))); % # of secs

close_string = horzcat('Simulation complete. Total run time: ',num2str(TOT_HOUR),' h, ', num2str(TOT_MINS),' m, ', num2str(TOT_SEC),' s.');
f = msgbox(close_string); % Display run time