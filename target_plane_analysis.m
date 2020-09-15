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
function [Rx_received_total,xGrid,yGrid,weightMatrix] = target_plane_analysis(coordinates,hitweights,centre,max_deviation,grid_width,gridSize,outputfilename,savetype)
x_min = centre(:,1) - max_deviation/2;
x_max = centre(:,1) + max_deviation/2;
y_min = centre(:,2) - max_deviation/2;
y_max = centre(:,2) + max_deviation/2;

% 2) Find all packets within target area and sum their packet weights
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
target_hits = find(coordinates(:,1) >= x_min & coordinates(:,1) <= x_max...
    & coordinates(:,2) >= y_min & coordinates(:,2) <= y_max);
Rx_received_total = sum(hitweights(target_hits)); % This is the total sum of packets hitting the receiver.

% 3) Calculated distribution of packets within the specified 'grid'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Define target area
targetLoc = [-0.5*grid_width, -0.5*grid_width, grid_width, grid_width];
%[x (lower left corner), y (lower left corner), width, height], (m)

% Create target grid
xGrid = targetLoc(1) + gridSize*(0:floor(targetLoc(3)/gridSize));
yGrid = targetLoc(2) + gridSize*(0:floor(targetLoc(4)/gridSize));

% Find packets within grid boundaries
grid_hits = find(abs(coordinates(:,1)) <= 0.5*grid_width & ... 
    abs(coordinates(:,2)) <= 0.5*grid_width); 

% Compute number of photon "hits" within each grid box
[nHits,~,~,binX,binY] = histcounts2(coordinates(grid_hits,1), coordinates(grid_hits,2), xGrid, yGrid); 

% Sum weights within each bin
[~, hitGroups, hitGroupID] = unique([binX,binY],'rows','stable');
totWeights = splitapply(@sum,hitweights(grid_hits),hitGroupID); 
ind = sub2ind(size(nHits),binX(hitGroups), binY(hitGroups));
weightMatrix = nHits; 
weightMatrix(ind) = totWeights;

if savetype == "Results only"
    save(outputfilename,'xGrid','yGrid', ...
    'Rx_received_total','weightMatrix'); % Save output
elseif savetype == "All"
    save(outputfilename,'coordinates','hitweights','xGrid','yGrid', ...
    'Rx_received_total','weightMatrix'); % Save output
end

% Add weighted hit plot
% ax2 = subplot(1,1,1); 
% I = imagesc(ax2,xGrid(1:end-1)+gridSize/2, yGrid(1:end-1)+gridSize/2,weightMatrix');
% ax2.YDir = 'normal';
% linkprop([ax,ax2],{'xlim','ylim','xtick','ytick','XTickLabel','YTickLabel'})
% grid(ax2,'on')
% axis(ax2,'equal')
% axis(ax2,'tight')
% cb2 = colorbar(ax2);
% ax2.CLim = [0,max(totWeights)]; 
% ax2.Colormap(1,:) = [1,1,1]; % This sets 0-values to white
% ylabel(cb2,'Weight sum')
% title(ax2,'Weighted hits')
% text(ax2, xGridMat(hitIdx)+gridSize/2, yGridMat(hitIdx)+gridSize/2, compose('%.2f',weightMatrix(hitIdx)), ...
%     'HorizontalAlignment', 'Center', 'VerticalAlignment', 'middle','Fontsize', 10, 'Color', 'r')
% text(ax2, min(xlim(ax2)), min(ylim(ax2)), 'Numbers show sum of weights', 'VerticalAlignment', 'bottom')
