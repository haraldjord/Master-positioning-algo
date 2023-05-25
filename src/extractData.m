function [ID, newTag] = extractData(ID,data)
    newTag = false;
    if contains(data(2), "TBR") % new TBR data
        ID.tag(end+1,:) = data; % save string to struct

        temp_t = split(ID.tag(end,4),':')';
        ID.timestamp(end+1,1) = temp_t(1,2); % save timestamp to struct
        newTag = true;
    elseif contains(data(1), "GPS") % new GPS data
        ID.gps(end+1,:) = data;

        lat = split(data(2),':')';
        lon = split(data(3),':')';
        ID.position(end+1,1) = lat(1,2);
        ID.position(end,2) = lon(1,2);
    end
end