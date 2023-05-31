% script for comparing timestamp expected to arrive at same time
Nr = 1;
data = load("missionData/dive_" + string(Nr) + "/nodes.mat");

node1_t = data.node.ID1.timestamp;
node2_t = data.node.ID2.timestamp;

diff = node1_t - node2_t;

disp(max(diff));
disp(min(diff));


for i = min(diff):0.001:max(diff)
    n = 0;
%     disp(round(i,3))
    for j =1:length(diff)
        if round(diff(j),3) == round(i,3)
            n = n+1;
        end
    end
    txt = sprintf("%d detections missed by %.4f seconds", n, i);
    disp(txt);
end
