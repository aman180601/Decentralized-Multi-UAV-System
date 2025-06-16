% Function to move the client back to where it started from
function moveBackToStart(u, serverPort, ipAddress, X, Y, Z, Xs, Ys, Zs, maxHeight, speed, clientID)
    % Move up along Z
    while Z ~= maxHeight
        Z = Z + 1;
    
        % Send coordinates to server
        message = sprintf('%d,%.2f,%.2f', clientID, X - 0.5, Y - 0.5);
        write(u, uint8(message), ipAddress, serverPort);
        disp("Sent: " + message);
        pause(1 / speed);
    end

    stepX = sign(Xs - X);
    stepY = sign(Ys - Y);

    % Move along X
    for i = X:stepX:Xs

        % Send coordinates to server
        message = sprintf('%d,%.2f,%.2f', clientID, i - 0.5, Y - 0.5);
        write(u, uint8(message), ipAddress, serverPort);
        disp("Sent: " + message);
        pause(1 / speed);
    end

    % Move along Y
    for i = Y:stepY:Ys

        % Send coordinates to server
        message = sprintf('%d,%.2f,%.2f', clientID, Xs - 0.5, i - 0.5);
        write(u, uint8(message), ipAddress, serverPort);
        disp("Sent: " + message);
        pause(1 / speed);
    end

    % Move down along Z
    while Z ~= Zs
        Z = Z - 1;
    
        % Send coordinates to server
        message = sprintf('%d,%.2f,%.2f', clientID, Xs - 0.5, Ys - 0.5);
        write(u, uint8(message), ipAddress, serverPort);
        disp("Sent: " + message);
        pause(1 / speed);
    end

end