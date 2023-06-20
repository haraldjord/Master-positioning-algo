
clear all; close all; 
addpath(fullfile(pwd,"src"))

%% set flags 
useGPS_pos = true; %true: use gps position from slim, false: manualy insert gps position of nodes
%% end flag
%% manual GPS position of nodes
% brattørkaia:
% node1_pos = [63.439240354412384, 10.400165974247875]; %use p1 as origin
% node2_pos = [63.439399789602994, 10.400935997117775];
% node3_pos = [63.43967455880626, 10.400344255404944];
%Børsa:
% node1_pos = []; %use p1 as origin
% node2_pos = [];
% node3_pos = [];


%% global variables
global LOG_folder dataFolder;
global do_TDOA; do_TDOA = false;
global endLoop; endLoop = false;
global getGPS; getGPS = false;
global getUNIX; getUNIX = false;
global newTag_node1 newTag_node2 newTag_node3;
newTag_node1 = false; newTag_node2 = false; newTag_node3 = false;
c = 1500;% [m/s] signal speed
%% Make new LOG and data folder
[LOG_folder, dataFolder] = make_new_log();
%% Setup serial port
device = serialport("COM3", 9600);
%% initiate node struct
ID.gps = strings(1,3);   % string from SLIM uppon GPS location
ID.tag = strings(1,10);  % string from SLIM uppon tag detection
ID.timestamp = [];       % timestamp in unix time and ms 
ID.tagData = [];         % tagData --> depth of tag
ID.position = [];        % longitude and latitude 
node.ID1 = ID;
node.ID2 = ID;
node.ID3 = ID;
%% Initiate figure
plotData.X = []; plotData.Y =[]; plotData.Z = []; %Points coordinates 
plotData.S = []; % marker size
plotData.C = []; % collor 
fig1 = figure(1);
p = scatter3(plotData.X, plotData.Y ,plotData.Z, plotData.S, plotData.C);

xlabel("x-direction (East) [m]")
ylabel("y-direction (North) [m]");

set(gca,'ZDir','Reverse');

xlim([-100 100]);
ylim([-100 100])

set(gca, 'xtick', -100:5:100)
set(gca, 'ytick', -100:5:100)

axis square % make square axis, to more easely interperate position.

% set(gca,'units','centimeters');
%axpos = get(gca,'position');
%set(gca,'position',[axpos(1:2) abs(diff(xlim)) abs(diff(ylim))]);

p.XDataSource = "plotData.X";
p.YDataSource = "plotData.Y";
p.ZDataSource = "plotData.Z";
p.CDataSource = 'plotData.C';
p.SizeDataSource = 'plotData.S';
%plotData = draw_circle(plotData, 250, 50); % draw circle diameter and points on plot
%%button handle
ButtonHandle = uicontrol(fig1,'Style', 'PushButton', ...
                              'String', 'Stop Loop',...
                              'Callback', @pushButton_handler);
                          
getGPS_Button = uicontrol(fig1, 'Style', 'pushButton', ...
                            'string', 'Get GPS Pos', ...
                            'Position', [20,60,70,30], ...
                            'Callback', @getGPS_handler);

getUNIX_Button = uicontrol(fig1, 'Style', 'pushButton', ...
                            'string', 'Get UNIX time', ...
                            'Position', [20,100,70,30], ...
                            'Callback', @getUNIX_handler);

                        
                        
                        
                        
if useGPS_pos                          
    plot_tbr = true;
    while plot_tbr % wait untill all devices has transmitted gps location
        pause(0.1)
        if getGPS == true
            getGPS = false;
            writeline(device, "#get_GPS_Pos");
        end
    if getUNIX == true
        writeline(device, "#get_UNIX_tim");
        getUNIX = false;
    end
    strData = readline(device);
        %strData = sprintf(data+"\n"); % display incoming data in command window
        disp(strData);
        
        %node = saveData(node, strData);
    if ~isempty(strData)
        node = saveData(node, strData); % save data to LOG file and node struct
    end
        if ~isempty(node.ID1.position) && ~isempty(node.ID2.position) && ~isempty(node.ID3.position)
             p1 = [node.ID1.position(1,1)/1e7, node.ID1.position(1,2)/1e7, ]; 
             p2 = [node.ID2.position(1,1)/1e7, node.ID2.position(1,2)/1e7]; 
             p3 = [node.ID3.position(1,1)/1e7, node.ID3.position(1,2)/1e7]; % get gps positions
            [plotData, s1, s2, s3] = get_sensors_pos(plotData, p1,p2,p3); % get cartesian coordinates from GPS 
            [plotData, s1_rot, s2_rot, s3_rot, rot_theta] = rotate_sensor_coordinates(plotData, s1,s2,s3);
            if abs(s2_rot(1,2)) > 1
               disp("TBR 2 is not aligned with x-axis!")
            else
               refreshdata; drawnow
               plot_tbr = false; 
            end
        end
    end
else
    % plot manual entered gps pos of nodes
    [plotData, s1, s2, s3] = get_sensors_pos(plotData, node1_pos,node2_pos,node3_pos); % get cartesian coordinates from GPS 
    [plotData, s1_rot, s2_rot, s3_rot, rot_theta] = rotate_sensor_coordinates(plotData, s1,s2,s3);
    refreshdata; drawnow;

    plot_tbr = false;
end


%% Run while loop 
while (~endLoop)
    pause(0.1)
    strData = readline(device);
%     strData = sprintf(data+"\n"); % display incoming data in command window
    disp(strData);
    if ~isempty(strData)
        node = saveData(node, strData); % save data to LOG file and node struct
    end

    if getGPS == true
        writeline(device, "#get_GPS_Pos");
        getGPS = false;
    end
    if getUNIX == true
        writeline(device, "#get_UNIX_time");
        getUNIX = false;
    end
    if newTag_node1 && newTag_node2 && newTag_node3
        %newTag_node1 = false; newTag_node2 = false; newTag_node3 = false;
        [T21, T31, z, flag_doTDoA] = verify_lastTag(node);% todo needs testing
        if flag_doTDoA
            newTag_node1 = false; newTag_node2 = false; newTag_node3 = false;
            
            R21 = T21*c; R31 = T31*c;
            [x,y] =  TDoA(R21, R31, s1_rot,s2_rot,s3_rot, z);
            [x,y] = rotate_position(x,y,rot_theta)
%             [x,y] = pos_algo(node, s1, s2, s3) 
            plotData = plot_tag_pos(plotData, x,y,z);
            refreshdata; drawnow;
        else
%             disp("TBR missed tag detection");
        end
    end


end
    
% save node data as .mat file
nodeFile = dataFolder + '/nodes.mat';
save(nodeFile, 'node');


%% End of scrip 
function pushButton_handler(src,~)
    global endLoop
    disp("Loop stopped by user");
    endLoop = true;
end

function getGPS_handler(src, ~)
    disp("Get GPS command is sendt to SLIM!");
    global getGPS;
    getGPS = true; 
end

function getUNIX_handler(src, ~)
    disp("Get UNIX time command is sendt to SLIM!");
    global getUNIX;
    getUNIX = true; 
end


function [x_rot,y_rot] = rotate_position(x,y,rot_theta)

    % rotate in "positive" direction
    rot_theta = 2*pi - rot_theta;
    
    % make rotation matrix
    R = [cos(rot_theta), -sin(rot_theta);
    sin(rot_theta), cos(rot_theta)];

    %rotate position 
    pos_rot = R*[x; y];
    
    x_rot = pos_rot(1,1);
    y_rot = pos_rot(2,1);
end





