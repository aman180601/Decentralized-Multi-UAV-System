% Function to move between meeting point and starting point
function moveBetweenStartingAndMeetingPoint(u, port, ip, X, Y, x, y, speed, division, clientID)

    stepX = sign(x - X);
    stepY = sign(y - Y);
    
    if division == 'v'
        % Move vertically
        for i = X:stepX:x

            % Send coordinates to server
            message = sprintf('%d,%.2f,%.2f', clientID, i - 0.5, Y - 0.5);
            write(u, uint8(message), ip, port);
            disp("Sent: " + message);
            pause(1 / speed);
        end
        
    else
        % Move horizontally
        for i = Y:stepY:y

            % Send coordinates to server
            message = sprintf('%d,%.2f,%.2f', clientID, X - 0.5, i - 0.5);
            write(u, uint8(message), ip, port);
            disp("Sent: " + message);
            pause(1 / speed);
        end
    end
end