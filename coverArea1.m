% Function to cover the left area by a single UAV (single UAV left case)
function coverArea1(grid, u, serverPort, ipAddress, X, Y, Z, Xs, Ys, Zs, maxHeight, division, speed, clientID, uncoveredArea)
    maxZ = Z;
    [rows, ] = size(uncoveredArea);
    for i = 1:rows
        mx = max(max(grid(uncoveredArea(i,1):uncoveredArea(i,2), uncoveredArea(i,3):uncoveredArea(i,4)))) + 1;
        maxZ = max(maxZ, mx);
    end

    % Move along Z
    while Z ~= maxZ
        Z = Z + 1;
    
        % Send coordinates to server
        message = sprintf('%d,%.2f,%.2f', clientID, X - 0.5, Y - 0.5);
        write(u, uint8(message), ipAddress, serverPort);
        disp("Sent: " + message);
        pause(1 / speed);
    end

    % Cover uncovered area one by one
    for i = 1:rows
        x1 = uncoveredArea(i,1);
        x2 = uncoveredArea(i,2);
        y1 = uncoveredArea(i,3);
        y2 = uncoveredArea(i,4);
        [x, y] = findSubgridFirstPoint(X, Y, division, x1, x2, y1, y2);
        moveBetweenStartingAndMeetingPoint(u, serverPort, ipAddress, X, Y, x, y, speed, division, clientID);
        X = x;
        Y = y;
        traverseArea(u, serverPort, ipAddress, X, Y, Z, x, y, Z, Z, x1, x2, y1, y2, speed, clientID);
    end

    moveBackToStart(u, serverPort, ipAddress, X, Y, Z, Xs, Ys, Zs, maxHeight, speed, clientID);
end

% Local function to move to starting point of subgrid
function [x, y] = findSubgridFirstPoint(X, Y, division, x1, x2, y1, y2)
    if division == 'v'
        y = Y;
        d1 = abs(X - x1);
        d2 = abs(X - x2);

        if d1 <= d2
            x = x1;
        else
            x = x2;
        end

    else
        x = X;
        d1 = abs(Y - y1);
        d2 = abs(Y - y2);

        if d1 <= d2
            y = y1;
        else
            y = y2;
        end
    end
end