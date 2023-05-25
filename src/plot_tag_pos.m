function [plotData] = plot_tag_pos(plotData, x,y,z,collor)
%ADD_TAG_POS Summary of this function goes here
%   Detailed explanation goes here
    % plot tag position in figure 

    if nargin == 5
        if collor == 'r'
            collor = [1,0,0];
        elseif collor == 'g'
            collor = [0,1,0];
        elseif collor == 'b'
            collor  = [0,0,1];
        end
    else
        collor = [1,1,1]; % black is default
    end

    plotData.X(end+1) = x;
    plotData.Y(end+1) = y;
    plotData.Z(end+1) = z;
    plotData.C(end+1,:) = collor;
    plotData.S(end+1) = 50;

end

