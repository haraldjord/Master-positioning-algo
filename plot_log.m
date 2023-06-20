%%plot raw mission log

clc; clear all; close all;
addpath(fullfile(pwd,"src"));
%% load dive data.
Nr = '6';
file = "missionData/dive_" + Nr + "/nodes.mat";
% file = "Borsa_demonstration/full_LOG/nodes.mat"
load(file);



%% make tag struct, with tag related data
tagData.x = [];
tagData.y = [];
tagData.z = [];
tagData.t = [];


%% analyse results with known position.
known_pos = false;


c = 1500; %[m/s] speed of signal
%% Get position of nodes
node1_pos = [mean(node.ID1.position(:,1)/1e7), mean(node.ID1.position(:,2))/1e7]; %use p1 as origin
node2_pos = [mean(node.ID2.position(:,1)/1e7), mean(node.ID2.position(:,2))/1e7];
node3_pos = [mean(node.ID3.position(:,1)/1e7), mean(node.ID3.position(:,2))/1e7];
% Børsa
% node3_pos = [63.330856428678494, 10.072498692879375]; %use p1 as origin
% node2_pos = [63.33158356108008, 10.073045863469309];
% node1_pos = [63.33139335272297, 10.073898805859505];

%% Initiate figure
plotData.X = []; plotData.Y =[]; plotData.Z = []; %Points coordinates 
plotData.S = []; % marker size
plotData.C = []; % collor 
fig1 = figure(1);
p = scatter3(plotData.X, plotData.Y ,plotData.Z, plotData.S, plotData.C);
xlabel("x-direction (East) [m]")
ylabel("y-direction (North) [m]");
set(gca,'ZDir','Reverse');
xwindow = [-80, 50]; 
ywindow = [-10, 120];
xlim(xwindow);
ylim(ywindow)
set(gca, 'xtick', xwindow(1,1):10:xwindow(1,2));
set(gca, 'ytick', ywindow(1,1):10:ywindow(1,2));
axis square % make square axis.

p.XDataSource = "plotData.X";
p.YDataSource = "plotData.Y";
p.ZDataSource = "plotData.Z";
p.CDataSource = 'plotData.C';
p.SizeDataSource = 'plotData.S';

%% plot position
[plotData, s1, s2, s3] = get_sensors_pos(plotData, node1_pos,node2_pos,node3_pos); % get cartesian coordinates from GPS 
[plotData, s1_rot, s2_rot, s3_rot, rot_theta] = rotate_sensor_coordinates(plotData, s1,s2,s3);
text(s1(1,1),s1(1,2),'1');
text(s2(1,1),s2(1,2),'2');
text(s3(1,1),s3(1,2),'3')
refreshdata; drawnow;




%% remove tag detection that where not detected by all three nodes.

t_start = 1;
t_end = 0;

t1 = node.ID1.timestamp(t_start:end-t_end);
t2 = node.ID2.timestamp(t_start:end-t_end);
t3 = node.ID3.timestamp(t_start:end-t_end);
[t1, t2, t3] = remove_erroneous_timestamps(t1, t2, t3, 1);




T21 = max(abs(t1-t2))
T31 = max(abs(t1-t3))



for i=1:(length(t1)-2)
    %pause(0.2);      
    z = 0.5;
    
    T21 = t1(i) - t2(i);
    T31 = t1(i) - t3(i);
    
    R21 = T21*c; R31 = T31*c;
    [x,y] =  TDoA(R21, R31, s1_rot,s2_rot,s3_rot, z);
    [x,y] = rotate_position(x,y,rot_theta)
    %             [x,y] = pos_algo(node, s1, s2, s3) 
    plotData = plot_tag_pos(plotData, x,y,z);
    refreshdata; drawnow;
    % add pos to tag data struct
    time = mean([t1(i), t2(i), t3(i)]);
    tagData = add_tag_pos(tagData, x, y, z, time);
 
end

% remove nan values from list

%% plot position of known tag location
if known_pos
    p_known = [63.43952926388662, 10.40065079561492]; 
    z_known = 0.5;
    [plotData, pos_known] = plot_gps_pos(plotData, node1_pos, p_known, z_known);
    refreshdata; drawnow;

    % get average and max error from known position 
    e = get_distance(tagData, pos_known);
end



%% functions
function data = remove_duplicates(timestamps, numbers)
    % Find all unique numbers
    unique_numbers = unique(numbers);

    for i = 1:length(unique_numbers)
        % Find all occurrences of the current number
        num = unique_numbers(i);
        indices = find(numbers == num);

        if length(indices) >= 2
            % Group these occurrences by the second in which they occurred
            [~, ~, groups] = unique(floor(timestamps(indices)));

            % Find groups with 2 or more occurrences
            counts = accumarray(groups, 1);
            duplicate_groups = find(counts >= 2);

            if ~isempty(duplicate_groups)
                % If there are any such groups, remove all occurrences of the current number
                numbers(numbers == num) = [];
                timestamps(numbers == num) = [];
            end
        end
    end

    % Combine the timestamps and numbers into a two-column matrix
    data = [timestamps, numbers];
end



function [list1, list2, list3] = remove_erroneous_timestamps(list1, list2, list3, error_threshold)
    % Create copies of the lists
    list1_copy = list1;
    list2_copy = list2;
    list3_copy = list3;

    % Remove elements from list1
    for i = 1:length(list1)
        [min_diff_2, ~] = min(abs(list1(i) - list2_copy));
        [min_diff_3, ~] = min(abs(list1(i) - list3_copy));
        if min_diff_2 > error_threshold || min_diff_3 > error_threshold
            list1(i) = NaN;
        end
    end

    % Remove elements from list2
    for i = 1:length(list2)
        [min_diff_1, ~] = min(abs(list2(i) - list1_copy));
        [min_diff_3, ~] = min(abs(list2(i) - list3_copy));
        if min_diff_1 > error_threshold || min_diff_3 > error_threshold
            list2(i) = NaN;
        end
    end

    % Remove elements from list3
    for i = 1:length(list3)
        [min_diff_1, ~] = min(abs(list3(i) - list1_copy));
        [min_diff_2, ~] = min(abs(list3(i) - list2_copy));
        if min_diff_1 > error_threshold || min_diff_2 > error_threshold
            list3(i) = NaN;
        end
    end

    % Remove the NaN values
    list1(isnan(list1)) = [];
    list2(isnan(list2)) = [];
    list3(isnan(list3)) = [];
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

function tagData = add_tag_pos(tagData, x, y, z, time)
    % time is the average timestamp, a more advanced determination of time
    % can be determined by solving the main equations in TDoA:
    %  sqrt(x² + y² + z²) - sqrt((x-b)² + y² + z²) = V * T_ab = R_ab (1)
    %  sqrt(x² + y² + z²) - sqrt((x-cx)² + (y-cy)² + z²) = V * T_ac = R_ac (2)

    if (size(tagData.x) == 0) % first element
        tagData.x(1,1) = x;
        tagData.y(1,1) = y;
        tagData.z(1,1) = z;
        tagData.t(1,1) = time;
    else
        tagData.x(end+1,1) = x;
        tagData.y(end+1,1) = y;
        tagData.z(end+1,1) = z;
        tagData.t(end+1,1) = time;
    end
end

function e = get_distance(tagData, pos_known)

    x_known = pos_known(1,1);
    y_known = pos_known(1,2);
    z_known = pos_known(1,3);
    
    e = NaN(length(tagData.x(:,1)),1);
    for i = 1:length(tagData.x(:,1))
        x = tagData.x(i,1);
        y = tagData.y(i,1);
        z = tagData.z(i,1);
        
        e(i,1) = sqrt((x-x_known)^2 + (y-y_known)^2 + (z-z_known)^2);
    end
    % remove nan values from list
    e(isnan(e)) = [];


end
