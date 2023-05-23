function [plotData] = draw_circle(plotData, radius, n_circle)
%DRAW_CIRCLE Summary of this function goes here
%   Detailed explanation goes here

radius = 250; %[m]
n_circle = 50; % dedicate 50 points for drawing circle
n_index = 7;
theta = linspace(0,2*pi,n_circle);
x_circle = radius*cos(theta) + radius;
y_circle = radius*sin(theta);% + radius*sin(pi/4);
plotData.X(n_index:((n_index-1)+n_circle)) = x_circle(:)';
plotData.Y(n_index:((n_index-1)+n_circle)) = y_circle(:)';
plotData.Z(n_index:((n_index-1)+n_circle)) = 0;
plotData.C(n_index:((n_index-1)+n_circle),1:3) = zeros(n_circle,3);
plotData.S(n_index:((n_index-1)+n_circle)) = 20;
end

