% Target analysis
%%%%%%%%%%%%%%%%%

% This code analyses the coordinates of photons that have intercepted at
% target plane (outputs from fast_plane_analysis.m) and:

% a) Calculates the sum of packet weights that "hit" a square detector with
% a user-specified area, that is parallel to the target plane.

% b) Calculates the distribution of packet weights across a user-specified 
% area within the target plane.

% Info from:
% https://tinyurl.com/ycte3xbr

% 1) Setting up
%%%%%%%%%%%%%%%
function [Rx_received_total,xGrid,yGrid,weightMatrix] = target_plane_analysis(coordinates,hitweights,centre,max_deviation,grid_width,grid_num,Rx_previous,weightMatrix_previous,savetype,save_yn,outputfilename)
x_min = centre(:,1) - max_deviation/2;
x_max = centre(:,1) + max_deviation/2;
y_min = centre(:,2) - max_deviation/2;
y_max = centre(:,2) + max_deviation/2;

% 2) Find all packets within target area and sum their packet weights
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
target_hits = find(coordinates(:,1) >= x_min & coordinates(:,1) <= x_max...
    & coordinates(:,2) >= y_min & coordinates(:,2) <= y_max);
Rx_received_total = sum(hitweights(target_hits)); % This is the total sum of packets hitting the receiver
Rx_received_total = Rx_received_total + Rx_previous; % Add the previous total to the new total

% 3) Calculated distribution of packets within the specified 'grid'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Define target area
targetLoc = [-0.5*grid_width, -0.5*grid_width, grid_width, grid_width];
%[x (lower left corner), y (lower left corner), width, height], (m)

% Create target grid
xGrid = linspace(targetLoc(1),targetLoc(1)+targetLoc(3),grid_num+1);
yGrid = linspace(targetLoc(2),targetLoc(1)+targetLoc(4),grid_num+1);

% Find packets within grid boundaries
grid_hits = find(abs(coordinates(:,1)) <= 0.5*grid_width & ... 
    abs(coordinates(:,2)) <= 0.5*grid_width); 

% Compute number of photon "hits" within each grid box
[nHits,~,~,binX,binY] = histcounts2(coordinates(grid_hits,1), coordinates(grid_hits,2), xGrid, yGrid); 

% Check if there are previous results to add
if isempty(weightMatrix_previous) == 1
    weightMatrix_previous = zeros(length(xGrid)-1,length(yGrid)-1); % If so, set all values to 0
end

% Sum weights within each bin
[~, hitGroups, hitGroupID] = unique([binX,binY],'rows','stable');
totWeights = splitapply(@sum,hitweights(grid_hits),hitGroupID); 
ind = sub2ind(size(nHits),binX(hitGroups), binY(hitGroups));
weightMatrix = nHits; 
weightMatrix(ind) = totWeights;
weightMatrix = weightMatrix + weightMatrix_previous; % Add results from this loop to the previous loop

% Save results (if this is the final loop to analyse)
if save_yn == "yes"
    if savetype == "Results only"
    save(outputfilename,'xGrid','yGrid', ...
    'Rx_received_total','weightMatrix'); % Save output
    elseif savetype == "All"
    save(outputfilename,'coordinates','hitweights','xGrid','yGrid', ...
    'Rx_received_total','weightMatrix'); % Save output
    end
end
