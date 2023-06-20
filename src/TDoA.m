function [x,y] = TDoA(Rba, Rca, sensorA, sensorB, sensorC, z, x_act_sol, y_act_sol)
%TDOAV2 Summary of this function goes here
%   time difference of arrival based on paper from jo and co
%   Rba and Rca TDOA distance Rxx = TimeXX*C
% 
%function made with "hardkoded" algorithm
%  Main equations:
%  sqrt(x² + y² + z²) - sqrt((x-b)² + y² + z²) = V * T_ab = R_ab (1)
%  sqrt(x² + y² + z²) - sqrt((x-cx)² + (y-cy)² + z²) = V * T_ac = R_ac (2)
    format long 


    %tree sensors in position:
    % sensor A = (0,0,0)
    % sensor B = (bx,0,0)
    % sensor C = (cx, xy, 0)
    % sensor position:
    bx = sensorB(1);
    cx = sensorC(1);
    cy = sensorC(2);

    
    
    % coefficients:
%     h = cx^2 + cy^2 - Rca^2 + (((Rba*Rca* (1-(bx/Rba)^2)))/(2*cy));
%     g = (Rca*(bx/Rba) - cx)/cy;
%     d = -1*(1-(bx/Rba)^2 + g^2);
%     e = bx*(1-(bx/Rba)^2) - (2*g*h);
%     f = (Rba^2/4)* (1-(bx/Rba)^2)^2 - h^2;

c = sqrt(cx^2 + cy^2);
 if Rba ==0
       if Rca ==0
            x=(bx/2);
%             z=depth;
            y=(-((cx*bx)/(cy*2))+(c^2/(2*cy)));
            disp('Both Rba and Rca are zero');
            return 
       else
            x_temp(1,1)=bx/2;     %equal rooots
            x_temp(2,1)=bx/2;     %equal roots
%             z_m=depth;
            %solve for y
            term=(Rca^2-c^2+(cx*bx));
            %make quadratric equation
            a=(4*cy^2)-(4*Rca^2);                  %y^2
            b=(4*cy*term);                     %y
            c=(term^2)-(4*Rca^2*((bx/2)^2+z^2));  %const.
            p=[a b c];
            y_temp=roots(p);
            disp('Rba is zero');
%             x=x_temp(1,1);
%             z=depth*100;

            % verify solutions by inserting in "original" equation 
            R_ba_calc = sqrt(x_temp.^2 + y_temp.^2 + z^2) - sqrt((x_temp-bx).^2 + y_temp.^2 + z^2);
            R_ca_calc = sqrt(x_temp.^2 + y_temp.^2 + z^2) - sqrt((x_temp-cx).^2 + (y_temp-cy).^2 + z^2);

            [x,y] = verifySolution(Rba, Rca, R_ba_calc, R_ca_calc, x_temp, y_temp);
            
%             if  (isreal(y_temp(1,1))) && abs(y_temp(1,1)) < 800
%                 if abs(y_temp(1,1) - last_y) < abs(y_temp(2,1) - last_y)
%                     y = y_temp(1,1);
%                     last_y = y_temp(1,1);
%                 else
%                     y = y_temp(2,1);
%                     last_y = y_temp(2,1);
%                 end
%                 
% %                 y=y_temp(1,1);
% %             elseif (isreal(y_temp(2,1))) && y_temp(2,1)>-100
% %                 y=y_temp(2,1);
%             else
%                 x=0;y=0;
%             end
            return
       end
 else
        %caclutae g, h, d, e and f
        b_rba=bx/Rba;
        b_rba_1=1-b_rba^2;
        g=((Rca*b_rba)-cx)/cy;
        h=(c^2-Rca^2+(Rca*Rba*b_rba_1))/(2*cy);
        d=-1*(b_rba_1+g^2);
        e=(bx*b_rba_1)-(2*g*h);
        f=((Rba^2/4)*(b_rba_1^2))-h^2;
        %calculate x
        p=[d e (f-z^2)];
        x_temp=roots(p);
        %calculayte y
        y_temp=g*x_temp+h;
 end % end of xy calculation
    
    if ~isreal(x_temp(1)) && ~isreal(x_temp(2)) %abort if two complex solutions 
        x = NaN;
        y = NaN;
        return;
    end
    

    % verify solutions by inserting in "original" equation 
    R_ba_calc = sqrt(x_temp.^2 + y_temp.^2 + z^2) - sqrt((x_temp-bx).^2 + y_temp.^2 + z^2);
    R_ca_calc = sqrt(x_temp.^2 + y_temp.^2 + z^2) - sqrt((x_temp-cx).^2 + (y_temp-cy).^2 + z^2);
    
    [x,y] = verifySolution(Rba, Rca, R_ba_calc, R_ca_calc, x_temp, y_temp);
end


function [x,y] = verifySolution(Rba, Rca, R_ba_calc, R_ca_calc, x_temp, y_temp)

    % use last known position to chose nearest solution, if both solutions is valid 
    persistent last_x last_y;
    if isempty(last_x)
        last_x = 0;
    end
    if isempty(last_y)
        last_y = 0;
    end


    % if both solution is valid, choose the nearest from last known:
    if (abs(R_ba_calc(1)-Rba) < 2) && (abs(R_ca_calc(1) - Rca) < 2) && (abs(R_ba_calc(2)-Rba) < 2) && (abs(R_ca_calc(2) - Rca) < 2)
        deviation_x = abs(x_temp - last_x);
        deviation_y = abs(y_temp - last_y);
        [~,x_index] = min(deviation_x);
        [~,y_index] = min(deviation_y);
        x = x_temp(x_index);
        y = y_temp(y_index);
        if y_index ~= x_index
            disp("indexes of x and y does not match!");
        end
        last_y = y; last_x = x;

    elseif (abs(R_ba_calc(1)-Rba) < 2) && (abs(R_ca_calc(1) - Rca) < 2) % only first solution is valid
        x = x_temp(1);
        y = y_temp(1);
        last_y = y; last_x = x;

    elseif(abs(R_ba_calc(2)-Rba) < 2) && (abs(R_ca_calc(2) - Rca) < 2) % only second solution is valid
        x = x_temp(2);
        y = y_temp(2);
        last_y = y; last_x = x;    

    else % none of the solutions are valid
        disp("none valid solution for TDoA")
        x = NaN; y = NaN;
    end
    
end

