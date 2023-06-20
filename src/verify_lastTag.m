
function [T21, T31, depth, bool] =  verify_lastTag(node)
%         global newTag_node1 
%          global newTag_node2
%          global newTag_node3

    % get last tag detection
    t1 = node.ID1.timestamp(end); t2 = node.ID2.timestamp(end); t3 = node.ID3.timestamp(end);
    
    % get depth
    depth = (node.ID1.tagData(end)-4) * 0.3922; % 4 if offset in sensor 
%     depth = 0.5;
    
   
    % observes that tbr return two decimals instead of three, in case abort TDoA calculation.
%     digits_t1 = count_digits(t1);
%     digits_t2 = count_digits(t2);
%     digits_t3 = count_digits(t3);
    
    % Obseves that sometimes GPS misses by one second
    if (abs(t1 - t2) < 1) && (abs(t1-t3) < 1) 
        T21 = t1-t2;
        T31 = t1-t3;
%         if digits_t1 == 3 && digits_t2 == 3 && digits_t3 == 3
            bool = true;
%             newTag_node1 = false; newTag_node2 = false; newTag_node3 = false;

%         else
%             bool = false;
%         end
    
%     elseif (abs(t1 - t2) < 2) && (abs(t1-t2) < 2) % fix one second error
%         if abs(t1-t2)<2
%             if t1>t2
%                 t1 = t1-1;
%             else
%                 t2 = t2-1;
%             end
%         end
%         if abs(t1-t3)>2
%             if t3>t1
%                 t3 = t3-1;
%             else
%                 t1 = t1-1;
%             end
%         end
%         if(abs(t1 - t2) < 1) && (abs(t1-t2) < 1)
%             T21 = t1-t2;
%             T31 = t1-t3;
%             bool = true;
%         else
%             bool = false;
%         end
    else
        bool = false;
        T21 = 0; T31 = 0; depth = 0;
    end
end

function num_digits = count_digits(number)
    % Convert the number to a string
    str = num2str(number);
    
    % Remove the decimal point if it exists
    str(str == '.') = [];
    
    % Count the number of characters in the string
    num_digits = length(str);
end
