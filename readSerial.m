clear all; close all;
addpath(fullfile(pwd,"src"))
%% global variables
global do_TDOA; do_TDOA = false;
global newTag_node1 newTag_node2 newTag_node3;
newTag_node1 = false; newTag_node2 = false; newTag_node3 = false;
c = 1500;% [m/s] signal speed
%% Setup serial port
device = serialport("COM3", 9600);
%% initiate node struct
% consider not initiating NaN, but add element after last for every iteration..
ID.gps = (strings(2000,3));     % string from SLIM uppon GPS location
ID.tag = (strings(2000,10));    % string from SLIM uppon tag detection
ID.timestamp = (NaN(2000,1));   % timestamp in unix time and ms 
ID.position = NaN(2000,2);      % longitude and latitude 
ID.tagElement = 1;              % keep track of number of elements 
ID.gpsElement = 1;              % keep track of number of elements
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
% while plot_tbr % wait untill all devices has transmitted gps location
%     pause(1)
%     data = readline(device);
%     strData = sprintf(data+"\n"); % display incoming data in command window
%     disp(strData);
%     
%     node = saveData(node, strData);
%     p1 = node.ID1.position(1,1); p2 = node.ID2.position(1,1); p3 = node.ID3.position(1,1); % get gps positions 
%     if ~isempty(p1) && ~isempty(p2) && ~isempty(p3)
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



%% Run while loop abort with ctrl + c
while (true)
    pause(0.1)
    data = readline(device);
    strData = sprintf(data+"\n"); % display incoming data in command window
    disp(strData);
    node = saveData(node, strData); % save data to LOG file and node struct

 
    if newTag_node1 && newTag_node2 && newTag_node3
        newTag_node1 = false; newTag_node2 = false; newTag_node3 = false;
        [T21, T31, z, bool] = verify_lastTag(node);% todo needs testing
        if bool
            R21 = T21*c; R31 = T31*c;
            [x,y] =  TDoA(R21, R31, s1,s2,s3, z);
            plotData = plot_tag_pos(plotData, x,y,z);
            refreshdata
            drawnow
        else
            disp("TBR missed tag detection")
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
            newTag_node2 = true;
        elseif contains(data(1), "GPS") % new GPS data todo add comma in SLIM after ID and change to index 2
            elem = node.ID1.gpsElement;
            node.ID1.gps(elem,:) = data;
            
            lat = split(data(2),':')';
            lon = split(data(3),':')';
            node.ID1.position(elem,1) = lat(1,2);
            node.ID1.position(elem,2) = lon(1,2);
            node.ID1.gpsElement = elem + 1;
        end
       
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
            newTag_node3 = true;
        elseif contains(data(1), "GPS") % new GPS data
            elem = node.ID1.gpsElement;
            node.ID2.gps(elem,:) = data;
            
            lat = split(data(2),':')';
            lon = split(data(3),':')';
            node.ID2.position(elem,1) = lat(1,2);
            node.ID2.position(elem,2) = lon(1,2);
            node.ID2.gpsElement = elem + 1;
            
        end
    end
end




function [T21, T31, bool] =  verify_lastTag(node)
    % get last tag detection
    elem1 = node.ID1.tagElement; elem2 = node.ID2.tagElement; elem3 = node.ID3.tagElement;
    t1 = node.ID1.timestamp(elem1); t2 = node.ID2.timestamp(elem2); t3 = node.ID3.timestamp(elem3);
    
    % Obseves that somethimes GPS misses by one second
    if (abs(t1 - t2) < 1) && (abs(t1-t2) < 1) 
        T21 = t1-t2;
        T31 = t1-t3;
        bool = true;
    
    elseif (abs(t1 - t2) < 2) && (abs(t1-t2) < 2) % fix one second error
        if abs(t1-t2)<2
            if t1>t2
                t1 = t1-1;
            else
                t2 = t2-1;
            end
        end
        if abs(t1-t3)>2
            if t3>t1
                t3 = t3-1;
            else
                t1 = t1-1;
            end
        end
        if(abs(t1 - t2) < 1) && (abs(t1-t2) < 1)
            T21 = t1-t2;
            T31 = t1-t3;
            bool = true;
        else
            bool = false;
        end
    else
        bool = false;
    end
end

