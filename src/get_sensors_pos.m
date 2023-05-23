function [plotData, s1, s2 ,s3] = get_sensors_pos(plotData, p1, p2, p3)
%GET_SENSORS_POS Summary of this function goes here
%   Detailed explanation goes here


%create a world geodetic system of 1984 reference ellipsoid with length
%unit of meters
wgs84 = wgs84Ellipsoid("m");

% Calculate the geodetic distance and azimuth between the two points
[dist1_2, az1_2] = distance(p1, p2, wgs84);
[dist1_3, az1_3] = distance(p1, p3, wgs84);


% Convert distance and azimuth to x and y distances
x1_2 = dist1_2 * sind(az1_2);
y1_2 = dist1_2 * cosd(az1_2);

x1_3 = dist1_3 * sind(az1_3);
y1_3 = dist1_3 * cosd(az1_3);

s1 = [0,0,0];
s2 = [x1_2, y1_2,0];
s3 = [x1_3, y1_3,0];


plotData.X(1:3) = [s1(1), s2(1), s3(1)];
plotData.Y(1:3) = [s1(2), s2(2), s3(2)];
plotData.Z(1:3) = [0,0,0];
plotData.S(1:3) = 100; % marker size
plotData.C(1:3,1:3) = [0,1,0;0,1,0;0,1,0]; % collor 

end

