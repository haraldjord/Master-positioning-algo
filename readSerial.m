clear all; close all;
addpath(fullfile(pwd,"src"))
%% global variables
global do_TDOA; do_TDOA = false;
global newTag_node1 newTag_node2 newTag_node3;
newTag_node1 = false; newTag_node2 = false; newTag_node3 = false;

%% Setup serial port
device = serialport("COM3", 9600);
%% initiate node struct
ID.gps = (strings(2000,3)); % consider not initiating NaN, but add element after last for every iteration..
ID.tag = (strings(2000,10));
ID.timestamp = (NaN(2000,1));
ID.position = NaN(2000,2);
ID.tagElement = 1;
ID.gpsElement = 1;
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

plot_tbr = true;
while plot_tbr % wait untill all devices has transmitted gps location
    pause(1)
    data = readline(device);
    strData = sprintf(data+"\n"); % display incoming data in command window
    disp(strData);
    
    node = saveData(node, strData);
    p1 = node.ID1.position(1,1); p2 = node.ID2.position(1,1); p3 = node.ID3.position(1,1); % get gps positions 
    if ~isempty(p1) && ~isempty(p2) && ~isempty(p3)
        [plotData, s1, s2, s3] = get_sensors_pos(plotData, p1,p2,p3); % get cartesian coordinates from GPS 
        [plotData, s1_rot, s2_rot, s3_rot] = rotate_sensor_coordinates(plotData, s1,s2,s3);
        if abs(s2_rot(1)) > 1
           disp("TBR 2 is not aligned with x-axis!")
        else
           refreshdata; drawnow
           plot_tbr = false;
        end
    end
end



%% Run while loop abort with ctrl + c
while (true)
    pause(0.1)
    data = readline(device);
    strData = sprintf(data+"\n"); % display incoming data in command window
    disp(strData);
    node = saveData(node, strData); % save data to LOG file and node struct

 
    if newTag_node1 && newTag_node2 && newTag_node3
        newTag_node1 = false; newTag_node2 = false; newTag_node3 = false;
        [R21, R31, bool] = verify_lastTag(node); % todo make this function
        if bool
            [x,y] =  TDoA(d21, d31, s1,s2,s3, tz(i));
            plotData = add_tag_pos(plotData, x,y,tz(i));
            refreshdata
            drawnow
        end
    end
    
end


function[node] = saveData(node,str)
    global newTag_node1 
    global newTag_node2 
    global newTag_node3
    
    if contains(str, "ID:1")
        % save raw log
        fid = fopen("LOG/ID1_log.txt", 'a');
        fprintf(fid, str);
        fclose(fid);
        
        % get data to struct 
        data = split(str,',')';
        if contains(data(2), "TBR") % new TBR data
            elem = node.ID1.tagElement;
            node.ID1.tag(elem,:) = data; % save string to struct
            
            tempTimestamp = split(node.ID1.tag(elem,4),':')';
            node.ID1.timestamp(elem) = tempTimestamp(1,2); % save timestamp to struct
            node.ID1.tagElement = elem + 1;
            newTag_node1 = true;
        elseif contains(data(1), "GPS") % new GPS data
            elem = node.ID1.gpsElement;
            node.ID1.gps(elem,:) = data;
            
            lat = split(data(2),':')';
            lon = split(data(3),':')';
            node.ID1.position(elem,1) = lat(1,2);
            node.ID1.position(elem,2) = lon(1,2);
            node.ID1.gpsElement = elem + 1;
        end
    end     
        
        
        
        
    
    if contains(str, "ID:2")
        %prepare data and save rag log file
        fid = fopen("LOG/ID1_log.txt", 'a');
        fprintf(fid, str);
        fclose(fid);
        
        % get data to struct 
        data = split(str,',')';
        if contains(data(2), "TBR") % new TBR data
            elem = node.ID2.tagElement;
            node.ID2.tag(elem,:) = data; % save string to struct
            
            tempTimestamp = split(node.ID2.tag(elem,4),':')';
            node.ID2.timestamp(elem) = tempTimestamp(1,2); % save timestamp to struct
            node.ID2.tagElement = elem + 1;
            newTag_node1 = true;
        elseif contains(data(1), "GPS") % new GPS data
            elem = node.ID1.gpsElement;
            node.ID1.gps(elem,:) = data;
            
            lat = split(data(2),':')';
            lon = split(data(3),':')';
            node.ID1.position(elem,1) = lat(1,2);
            node.ID1.position(elem,2) = lon(1,2);
            node.ID1.gpsElement = elem + 1;
        end
        newTag_node2 = true;
    end
    
    
    if contains(str, "ID:3")
        % prepare data
        % save raw log
        fid = fopen("LOG/ID3_log.txt", 'a');
        fprintf(fid, str);
        fclose(fid);
        
        % get data to struct 
        data = split(str,',')';
        if contains(data(2), "TBR") % new TBR data
            elem = node.ID2.tagElement;
            node.ID2.tag(elem,:) = data; % save string to struct
            
            tempTimestamp = split(node.ID2.tag(elem,4),':')';
            node.ID2.timestamp(elem) = tempTimestamp(1,2); % save timestamp to struct
            node.ID2.tagElement = elem + 1;
        elseif contains(data(1), "GPS") % new GPS data
            elem = node.ID1.gpsElement;
            node.ID2.gps(elem,:) = data;
            
            lat = split(data(2),':')';
            lon = split(data(3),':')';
            node.ID2.position(elem,1) = lat(1,2);
            node.ID2.position(elem,2) = lon(1,2);
            node.ID2.gpsElement = elem + 1;
            newTag_node3 = true;
        end
    end
end




function [R21, R31, bool] =  verify_lastTag(node)
    % get last tag detection
    tbr1_tag = node.ID1.timestamp(end); tbr2_tag = node.ID2.timestamp(end); tbr3_tag = node.ID3.timestamp(end) 
    

end

