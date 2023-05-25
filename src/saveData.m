function[node] = saveData(node,str)
    global newTag_node1 
    global newTag_node2 
    global newTag_node3
    
    if contains(str, "Not connected")
        return;
    end
    
    data = split(str,',')';
    if contains(str, "ID:1")
        % save raw log
        fid = fopen("LOG/ID1_log.txt", 'a');
        fprintf(fid, str);
        fclose(fid);        
        % get data to struct 
        [node.ID1, newTag_node1] = extractData(node.ID1,data);  
    
    elseif contains(str, "ID:2")
        %prepare data and save rag log file
        fid = fopen("LOG/ID2_log.txt", 'a');
        fprintf(fid, str);
        fclose(fid);
        % get data to struct 
        [node.ID2, newTag_node2] = extractData(node.ID2,data);       
 
    elseif contains(str, "ID:3")
        % save raw log
        fid = fopen("LOG/ID3_log.txt", 'a');
        fprintf(fid, str);
        fclose(fid);        
        % get data to struct 
        [node.ID3, newTag_node3] = extractData(node.ID2,data);
    end
end