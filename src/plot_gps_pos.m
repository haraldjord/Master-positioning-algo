function [plotData, pos_known] = plot_gps_pos(plotData, p1, p_known, z_known)
%GET_GPS_POS Summary of this function goes here
%   Transform latitude, longitude GPS position into xy plane and plot the
%   position.
%   Detailed explanation goes here
%   

%create a world geodetic system of 1984 reference ellipsoid with length
%unit of meters
wgs84 = wgs84Ellipsoid("m");


% Calculate the geodetic distance and azimuth between the two points
[dist1_known, az1_known] = distance(p1, p_known, wgs84);


% Convert distance and azimuth to x and y distances
x1_known = dist1_known * sind(az1_known);
y1_known = dist1_known * cosd(az1_known);

pos_known = [x1_known, y1_known, z_known];

plotData.X(end+1) = x1_known;
plotData.Y(end+1) = y1_known;
plotData.Z(end+1) = z_known;
plotData.S(end+1) = 100; % marker size
plotData.C(end+1,:) = [1,0,0]; % collor 

% (1:3,1:3) = [0,1,0;0,1,0;0,1,0]; % collor 

end

