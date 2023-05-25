clear all; close all;
%mock gps piont
addpath(fullfile(pwd), 'src')
% p1 = [63.446010508267236, 10.372019653070462]; %use p1 as origin
% p2 = [63.44600091580862, 10.37736261294867];
% p3 = [63.44739178875956, 10.374616031163889];
% p1 = [63.43849029968278, 10.369756205147839]; %use p1 as origin
% p2 = [63.43849029968278, 10.377233872175594];
% p3 = [63.44028246744449, 10.373764234694644];
p1 = [63.43853131694196, 10.364339890621668]; %use p1 as origin
p2 = [63.43861156554258, 10.366672922720927];
p3 = [63.439133175966454, 10.365356853331601];


%% make scatter plot
%plotData.X = NaN(10000,1); plotData.Y =NaN(10000,1); plotData.Z = NaN(10000,1); %Points coordinates 
plotData.X = []; plotData.Y =[]; plotData.Z = []; %Points coordinates 

% marker size and collor are udated for every new position, to separete
% between tag and recievers.
% plotData.S = NaN(10000,1); plotData.S(1:3) = 100; % marker size
% plotData.C = NaN(10000,3); plotData.C(1:3,:) = [0,1,0;0,1,0;0,1,0]; % collor 
plotData.S = []; % marker size
plotData.C = []; % collor 

[plotData, s1, s2, s3] = get_sensors_pos(plotData, p1,p2,p3); % get cartesian coordinates from GPS 
[plotData, s1, s2, s3] = rotate_sensor_coordinates(plotData, s1,s2,s3);


% make scatter figure
fig1 = figure(1)
p = scatter3(plotData.X, plotData.Y ,plotData.Z, plotData.S, plotData.C)
% xlim([0,600]);
% ylim([-200,600])
xlabel("X-direction [m] (East)")
ylabel("Y-direction [m] (North)");
p.XDataSource = "plotData.X";
p.YDataSource = "plotData.Y";
p.ZDataSource = "plotData.Z";
p.CDataSource = 'plotData.C';
p.SizeDataSource = 'plotData.S';

%draw circle:
plotData = draw_circle(plotData, 70, 50);

%mock data TDOF
% simulated trajectory
tx = [linspace(50,180,10), linspace(180,400,10)];%, linspace(6,5,10)];
ty = [linspace(20,-50,10), linspace(-50,-150,10)];%, linspace(6,4,10)];
tz = [linspace(-10,-10,5), linspace(-10,-10,15)];
mockpos = [tx;ty;tz];
traj = NaN(3,20);
roots = NaN(3,20);

% mock data of time difference 
mockd21 = sqrt((tx - s1(1)).^2 + (ty - s1(2)).^2 + (tz - s1(3)).^2) - sqrt((tx - s2(1)).^2 + (ty - s2(2)).^2 + (tz - s3(3)).^2);
mockd31 = sqrt((tx - s1(1)).^2 + (ty - s1(2)).^2 + (tz - s1(3)).^2) - sqrt((tx - s3(1)).^2 + (ty - s3(2)).^2 + (tz - s3(3)).^2);  %vec source - vec sensor = distance*1m/s


for i=1:20 %% update plot inside this loop.
    d21 = mockd21(i);
    d31 = mockd31(i);
    %v1    
%     pos = TDOA(s1,s2,s3,d21,d31,c);
%     traj(:,i) = [pos(1); pos(2); tz(i)];
%     plot3(pos(1), pos(2), tz(i), '*');
    %v2:
    [x,y] =  TDoA(d21, d31, s1,s2,s3, tz(i), tx(i), ty(i));
    plotData = plot_tag_pos(plotData, x,y,tz(i),'r');           % plot TDoA pos in red 
    plotData = plot_tag_pos(plotData, tx(i), ty(i), tz(i),'b'); % plot real value in blue
    
    refreshdata
    drawnow
    pause(0.5)
end

% p.Marker = '.';

