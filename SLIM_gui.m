
clear all; close all; 
addpath(fullfile(pwd,"src"))
%% global variables
global LOG_folder dataFolder;
global do_TDOA; do_TDOA = false;
global endLoop; endLoop = false;
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
p.XDataSource = "plotData.X";
p.YDataSource = "plotData.Y";
p.ZDataSource = "plotData.Z";
p.CDataSource = 'plotData.C';
p.SizeDataSource = 'plotData.S';
plotData = draw_circle(plotData, 250, 50); % draw circle diameter and points on plot
%%button handle
ButtonHandle = uicontrol(fig1,'Style', 'PushButton', ...
                              'String', 'SA',...
                              'Callback', @pushButton_handler);


% plot_tbr = true;
% while plot_tbr % wait untill all devices has transmitted gps location
%     pause(1)
%     data = readline(device);
%     strData = sprintf(data+"\n"); % display incoming data in command window
%     disp(strData);
%     
%     node = saveData(node, strData);
%     
%     if ~isempty(node.ID1.position) && ~isempty(node.ID2.position) && ~isempty(node.ID3.position)
%          p1 = node.ID1.position(1,1); p2 = node.ID2.position(1,1); p3 = node.ID3.position(1,1); % get gps positions
%         [plotData, s1, s2, s3] = get_sensors_pos(plotData, p1,p2,p3); % get cartesian coordinates from GPS 
%         [plotData, s1_rot, s2_rot, s3_rot] = rotate_sensor_coordinates(plotData, s1,s2,s3);
%         if abs(s2_rot(1)) > 1
%            disp("TBR 2 is not aligned with x-axis!")
%         else
%            refreshdata; drawnow
%            plot_tbr = false; 
%         end
%     end
% end



%% Run while loop 
while (~endLoop)
    pause(0.1)
    data = readline(device);
    strData = sprintf(data+"\n"); % display incoming data in command window
    disp(strData);
    node = saveData(node, strData); % save data to LOG file and node struct

%     if newTag_node1
%         disp("node1 new tag")
%     end
    if newTag_node3
        disp("why");
    end

    if newTag_node1 && newTag_node2 && newTag_node3
        newTag_node1 = false; newTag_node2 = false; newTag_node3 = false;
        [T21, T31, z, flag_doTDoA] = verify_lastTag(node);% todo needs testing
        if flag_doTDoA
            R21 = T21*c; R31 = T31*c;
            [x,y] =  TDoA(R21, R31, s1,s2,s3, z);
            plotData = plot_tag_pos(plotData, x,y,z);
            refreshdata
            drawnow
        else
            disp("TBR missed tag detection");
            
        end
    end


end
    



function pushButton_handler(src,~)
    global endLoop
    disp("Loop stopped by user");
    endLoop = true;
end






