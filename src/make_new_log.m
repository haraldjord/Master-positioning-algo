function [LOG_folder,data_folder] = make_new_log()
%MAKE_NEW_LOG Summary of this function goes here
%   Get last dive Nr, and create new log folder for gps and tag detection
%   Detailed explanation goes here

    folder = dir("LOG");
    n = size(folder);
    n = n(1,1); % two unknown folders named "." and ".." are included
    
    if n == 2 % dive_1 folder does not exist...
        mkdir("missionData/dive_1");
        mkdir("LOG/dive_1");
        LOG_folder = "LOG/dive_1";
        data_folder = "missionData/dive_1";
        tagFolder = LOG_folder + "/tag";
        gpsFolder = LOG_folder + "/gps";    
        mkdir(tagFolder);
        mkdir(gpsFolder);
        make_txt_files(tagFolder, gpsFolder);    
    else
        % last file
        file = dir("LOG/" + folder(n).name + "/tag/");
        if file(3).bytes == 0
            LOG_folder = "LOG/dive_" + string(n-2);
            data_folder = "missionData/dive_" + string(n-2);
        else
            LOG_folder = "LOG/dive_" + string(n-1); 
            data_folder = "missionData/dive_" + string(n-1);
        end

        tagFolder = LOG_folder + "/tag";
        gpsFolder = LOG_folder + "/gps";    

        %make new folder for mission data one higher than last 
        mkdir(data_folder);
        % make new folder with name one higher than last
        mkdir(LOG_folder);
        mkdir(tagFolder);
        mkdir(gpsFolder);

         make_txt_files(tagFolder, gpsFolder);
    end

end

function make_txt_files(tagFolder, gpsFolder)

    %make new node 1,2,3 tag log file 
    fid = fopen(tagFolder + "/ID1tag.txt", 'w'); fclose(fid);
    fid = fopen(tagFolder + "/ID2tag.txt", 'w'); fclose(fid);
    fid = fopen(tagFolder + "/ID3tag.txt", 'w'); fclose(fid);
    
    %make new node 1,2,3 gps log file 
    fid = fopen(gpsFolder + "/ID1gps.txt", 'w'); fclose(fid);
    fid = fopen(gpsFolder + "/ID2gps.txt", 'w'); fclose(fid);
    fid = fopen(gpsFolder + "/ID3gps.txt", 'w'); fclose(fid);
    

end

