
Nr = 8;
gps_path = "LOG/dive_" + string(Nr) + "/gps";
tag_path = "LOG/dive_" + string(Nr) + "/tag";

id1_tag = readlines(tag_path + "/ID1tag.txt");
id2_tag = readlines(tag_path + "/ID2tag.txt");
id3_tag = readlines(tag_path + "/ID3tag.txt");

gps1 = readlines(gps_path + "/ID1gps.txt");
gps2 = readlines(gps_path + "/ID2gps.txt");
gps3 = readlines(gps_path + "/ID3gps.txt");

ID.gps = strings(1,3);   % string from SLIM uppon GPS location
ID.tag = strings(1,10);  % string from SLIM uppon tag detection
ID.timestamp = [];       % timestamp in unix time and ms 
ID.tagData = [];         % tagData --> depth of tag
ID.position = [];        % longitude and latitude 
node.ID1 = ID;
node.ID2 = ID;
node.ID3 = ID;


node.ID1 = extractLog(node.ID1, id1_tag, gps1);
node.ID2 = extractLog(node.ID2, id2_tag, gps2);
node.ID3 = extractLog(node.ID3, id3_tag, gps3);


function ID =  extractLog(ID,id1_tag, gps1)
    for i=1:(length(id1_tag(:,1))-1)
        data = split(id1_tag(i,1),',')';
        ID.tag(i,:) = data;
        temp_t = split(data(1,4),':')';
        t = str2double(temp_t(1,2));
        temp_d = split(data(1,7),':')';
        d = str2double(temp_d(1,2));
        ID.tagData(i,1) = d;

        ID.timestamp(i,1) = t; % save timestamp to struct 
        ID.tagData(i,1) = d;
    end

    for i=1:(length(gps1(:,1))-1)
        data = split(gps1(i,1),',')';

        lat = split(data(2),':')';
        lon = split(data(3),':')';
        ID.position(i,1) = lat(1,2);
        ID.position(i,2) = lon(1,2);   
    end

end