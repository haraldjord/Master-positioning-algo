%% read data ectracted from comport wizard
% load node with known gps pos
node_t = load ("../../missionData/dive_12/nodes.mat");


node.ID1.timestamp = [0];
node.ID2.timestamp = [0];
node.ID3.timestamp = [0];

node.ID3.tagData = [0];
node.ID2.tagData = [0];
node.ID1.tagData = [0];


f = ("LOG_all.csv");
T = readtable(f, 'ReadVariableNames', false);
hz = table2array(T(:,5));
time = table2array(T(:,2));
tagData = table2array(T(:,4));
tbr = table2array(T(:,7));

g = 0;
for i=1:length(time)
    if contains(string(hz(i)),'69')
        if tbr(i) == 22 %ID3
            node.ID3.timestamp(end+1) = time(i);
            node.ID3.tagData(end+1) = tagData(i);
        elseif tbr(i) == 47 % ID1
            node.ID1.timestamp(end+1) = time(i);
            node.ID1.tagData(end+1) = tagData(i);
        elseif tbr(i) == 632 % ID2
            node.ID2.timestamp(end+1) = time(i);
            node.ID2.tagData(end+1) = tagData(i);
        end
    else    
        g = g +1;
    end
end
% 
% node.ID1.timestamp = flip(node.ID1.timestamp(2:120)');
% node.ID2.timestamp = flip(node.ID2.timestamp(2:120)');
% node.ID3.timestamp = flip(node.ID3.timestamp(2:120)');


node.ID1.position = node_t.node.ID1.position;
node.ID2.position = node_t.node.ID2.position;
node.ID3.position = node_t.node.ID3.position;

