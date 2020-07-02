
%%% Code for analysing saved photon packet position and weight histories
%%% to determine the distribution of received photons at some
%%% user-defined receiver plane.

%%% Methodology and code based on reading from:
%%% http://www2.math.umd.edu/~jmr/241/lines_planes.html
%%% https://www.youtube.com/watch?v=_W3aVWsMp14
%%% https://tinyurl.com/y8ze6vtn
%%% and https://tinyurl.com/ycgydekk
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 1) Setting up
%%%%%%%%%%%%%%%

% First we need to ask the user to define the position of the receiver
% plane by providing the coordinates of three points that lie on the plane.
prompt = {'Point 1:','Point 2:','Point 3:'};
dlgtitle = 'Enter Rx coordinates (m)';
dims = [1 40];
definput = {'[1,1,1]','[-1,1,1]','[1,-1,1]'};
rx_points = inputdlg(prompt,dlgtitle,dims,definput);

p1 = str2num(rx_points{1});
p2 = str2num(rx_points{2});
p3 = str2num(rx_points{3});

active_packets = 1:1:size(positions{1},1); % Initial index of 'active' packets

% 2) Derive the plane equation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% a) Find the cross-product of two vectors that are parallel to this plane
normal = cross(p1-p2,p1-p3);

%%% Next, we declare x, y, and z to be symbolic variables, create a vector
%%% whose components represent the vector from P1 to a typical point on the
%%% plane, and compute the dot product of this vector with our normal.

syms x y z
P = [x,y,z];
planefunction = dot(normal, P-p1); % This is the plane equation

%%% Analysis loop %%%
for loop_cntr = 1:size(positions,2)
disp(horzcat("Loop number",num2str(loop_cntr)));
% 3) Derive the line equations between the recorded points of photon travel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
point1 = positions{loop_cntr}; % Previous positions (cols 1-3) & weights (col 4)
point2 = positions{loop_cntr+1}; % Most recent position & weights

%%% We parametrize the lines:
syms t
line = point1(active_packets,1:3) + t*(point2(active_packets,1:3)-point1(active_packets,1:3));

% 4) Substitute the parametric line equations into the plane equation and
% solve to find the value of the parameter "t" where they would intersect
% the receiver plane (t0). This is then substituted into the line equation
% to find the points of intersection. The photon packet weights at these
% positions are then calculated.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
newfunction = sym(zeros(size(line,1),1));
t0 = zeros(size(line,1),1);
hit_points = zeros(size(line,1),3);
hit_weights = zeros(size(line,1),1);

for counter = 1:size(line,1);
newfunction(counter,:) = subs(planefunction, P, line(counter,:));
t0(counter,:) = double(solve(newfunction(counter)));
hit_points(counter,:) = double(subs(line(counter,:), t, t0(counter,:)));
hit_weights(counter,1) = exp(-a*pdist([hit_points(counter,:);point1(counter,1:3)]));
end

%%% Note at this point the maths assumes that the photon line of travel is
%%% infinitely long, and the point of intersection (if it exists) is found
%%% on that basis.

%%% We need to check if the actual path, having finite length, actually
%%% contiues far enough to reach the receiver plane. This is valid if t0 is
%%% less than or equal to 1. Only "hit" packets are recorded to the output.

hit = t0 <= 1; % Check which packets hit in the last loop
output{loop_cntr} = num2cell(horzcat(hit_points(hit == 1,:),hit_weights(hit == 1,:))); % Save hit points and weights

% Packets that have "hit" the receiver can be removed from further
% analysis. In the next iteration we only count the remaining "active"
% packets.
active_packets = find(hit == 0);

if isempty(active_packets) == 1 % If there are no more active packets, terminate the loop
    break
end

end

%%% Finally concatenate the outputs and convert to a double array %%%
output = cell2mat(cat(1,output{:}));