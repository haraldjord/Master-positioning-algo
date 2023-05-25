
function [T21, T31, bool] =  verify_lastTag(node)
    % get last tag detection
    elem1 = node.ID1.tagElement; elem2 = node.ID2.tagElement; elem3 = node.ID3.tagElement;
    t1 = node.ID1.timestamp(elem1); t2 = node.ID2.timestamp(elem2); t3 = node.ID3.timestamp(elem3);
    
    % Obseves that somethimes GPS misses by one second
    if (abs(t1 - t2) < 1) && (abs(t1-t2) < 1) 
        T21 = t1-t2;
        T31 = t1-t3;
        bool = true;
    
    elseif (abs(t1 - t2) < 2) && (abs(t1-t2) < 2) % fix one second error
        if abs(t1-t2)<2
            if t1>t2
                t1 = t1-1;
            else
                t2 = t2-1;
            end
        end
        if abs(t1-t3)>2
            if t3>t1
                t3 = t3-1;
            else
                t1 = t1-1;
            end
        end
        if(abs(t1 - t2) < 1) && (abs(t1-t2) < 1)
            T21 = t1-t2;
            T31 = t1-t3;
            bool = true;
        else
            bool = false;
        end
    else
        bool = false;
    end
end
