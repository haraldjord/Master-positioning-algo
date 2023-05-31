% function [ID, newTag] = extractData(ID,data, str)
%     newTag = false;
%     if contains(data(2), "TBR") % new TBR data
%         ID.tag(end+1,:) = data; % save string to struct
%         temp_t = split(ID.tag(end,4),':')';
%         temp_t = str2double(temp_t(1,2));
%         
%         if isempty(ID.timestamp)
%             ID.timestamp(end+1,1) = temp_t; % save timestamp to struct
%             newTag = true;
%         else
%             if temp_t(1,2) ~= ID.timestamp(end,1) % timespamp sometimes enters two times
%                 ID.timestamp(end+1,1) = temp_t; % save timestamp to struct
%                 newTag = true;
%             end
%         end
%     elseif contains(data(1), "GPS") % new GPS data
%         ID.gps(end+1,:) = data;
% 
%         lat = split(data(2),':')';
%         lon = split(data(3),':')';
%         ID.position(end+1,1) = lat(1,2);
%         ID.position(end,2) = lon(1,2);
%     else
%         disp("nothing to extract, corrupted string");
%     end
% end
% 
% function write_txt(file, str)
%     fid = fopen("file", 'a');
%     fprintf(fid, str);
%     fclose(fid);  
% end