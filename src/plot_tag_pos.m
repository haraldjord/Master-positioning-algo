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
        collor = [0,0,0]; % black is default
    end

    plotData.X(1,end+1) = x;
    plotData.Y(1,end+1) = y;
    plotData.Z(1,end+1) = z;
    plotData.C(end+1,:) = collor;
    plotData.S(1,end+1) = 50;

end

