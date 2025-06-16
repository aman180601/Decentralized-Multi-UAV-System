% Function to move the meeting point first time
function moveToMeetingPoint(u, port, ip, X, Y, Xm, Ym, speed, division, clientID)

    stepX = sign(Xm - X);
    stepY = sign(Ym - Y);
    
    if division == 'v'
        % Move horizontally first
        for i = Y:stepY:Ym

            % Send coordinates to server
            message = sprintf('%d,%.2f,%.2f', clientID, X - 0.5, i - 0.5);
            write(u, uint8(message), ip, port);
            disp("Sent: " + message);
            pause(1 / speed);
        end
        
        % Move vertically
        for i = X:stepX:Xm

            % Send coordinates to server
            message = sprintf('%d,%.2f,%.2f', clientID, i - 0.5, Ym - 0.5);
            write(u, uint8(message), ip, port);
            disp("Sent: " + message);
            pause(1 / speed);
        end
        
    else
        % Move vertically first
        for i = X:stepX:Xm

            % Send coordinates to server
            message = sprintf('%d,%.2f,%.2f', clientID, i - 0.5, Y - 0.5);
            write(u, uint8(message), ip, port);
            disp("Sent: " + message);
            pause(1 / speed);
        end
        
        % Move horizontally
        for i = Y:stepY:Ym

            % Send coordinates to server
            message = sprintf('%d,%.2f,%.2f', clientID, Xm - 0.5, i - 0.5);
            write(u, uint8(message), ip, port);
            disp("Sent: " + message);
            pause(1 / speed);
        end
    end
end