function [plotData, s1_rot,s2_rot,s3_rot, rot_theta] = rotate_sensor_coordinates(plotData, s1,s2,s3)
%UNTITLED Summary of this function goes here
%   Rotate sensorcoordinates such that s2 is aligned with x axis
%   Detailed explanation goes here


    s1_rot = [0,0,0]; % still in origin

    % sensor location from gps in cartesian coordinates
    x2 = s2(1); y2 = s2(2);
    x3 = s3(1); y3 = s3(2);
    
    
    % Angle to rotate
    rot_theta = -atan(y2/x2);  %2*pi - atan(y2/x2);
    %theta = pi/2;
    
    %construct rotation matrix
    R = [cos(rot_theta), -sin(rot_theta);
        sin(rot_theta), cos(rot_theta)];

    s2_rot = R*[x2; y2];
    s3_rot = R*[x3; y3];

    %add z- coordinate
    s2_rot = [s2_rot', 0];
    s3_rot = [s3_rot', 0];

    % Plot rotated position of sensor 2 and 3
%     plotData.X(4:6) = [s1_rot(1), s2_rot(1), s3_rot(1)];
%     plotData.Y(4:6) = [s1_rot(2), s2_rot(2), s3_rot(2)];
%     plotData.Z(4:6) = [0,0,0];
%     plotData.S(4:6) = 100; % marker size
%     plotData.C(4:6,1:3) = [255,255,0;255,255,0;255,255,0]; % collor 
end

