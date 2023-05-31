function[node] = saveData(node,str)
    global newTag_node1 
    global newTag_node2 
    global newTag_node3
    
    if contains(str, "Not connected")
        return;
    end
    
    data = split(str,',')';
    if contains(str, "ID:1")
        % get data to struct 
        id = "1";
        [node.ID1, newTag_node1] = extractData(node.ID1,data, str, id);  
    
    elseif contains(str, "ID:2")
        % get data to struct 
        id = "2";
        [node.ID2, newTag_node2] = extractData(node.ID2,data, str, id);       
 
    elseif contains(str, "ID:3")
        % get data to struct
        id = "3";
        [node.ID3, newTag_node3] = extractData(node.ID2,data,str,id);
    end
end

function [ID, newTag] = extractData(ID,data, str, id)
    global LOG_folder
    disp(LOG_folder)
    newTag = false;
    if contains(data(2), "TBR") % new TBR data
        temp_t = split(data(1,4),':')';
        temp_t = str2double(temp_t(1,2));
        temp_tagData = split(data(1,7),':')';
        temp_tagData = temp_tagData(1,2);
        file = LOG_folder + "/tag/ID" + id + "tag.txt";
        
        if isempty(ID.timestamp)
            ID.tag(end+1,:) = data;
            ID.timestamp(end+1,1) = temp_t; % save timestamp to struct 
            ID.tagData(end+1,1) = temp_tagData;
            write_txt(file ,str)
            newTag = true;
        else
            if temp_t ~= ID.timestamp(end,1) % timespamp sometimes enters two times
                ID.tag(end+1,:) = data;
                ID.timestamp(end+1,1) = temp_t;     % save timestamp to struct
                ID.tagData(end+1,1) = temp_tagData;
                write_txt(file ,str)
                newTag = true;
            else 
                disp("timestamp already exist in struct!");
            end
        end
    elseif contains(data(1), "GPS") % new GPS data
        ID.gps(end+1,:) = data;
        file = LOG_folder + "/gps/ID" + id + "gps.txt";
        write_txt(file,str);
        
        lat = split(data(2),':')';
        lon = split(data(3),':')';
        ID.position(end+1,1) = lat(1,2);
        ID.position(end,2) = lon(1,2);
    else
        disp("nothing to extract, corrupted string");
    end
end

function write_txt(file, str)
    fid = fopen(file, 'a');
    fprintf(fid, str);
    fclose(fid);  
end