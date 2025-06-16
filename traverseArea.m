% Function to traverse the assigned area
function traverseArea(u, port, ip, X, Y, Z, x, y, z, Zm, x1, x2, y1, y2, speed, clientID)
    travelAlongZ(u, port, ip, X, Y, Z, z, speed, clientID);
    travelMatrix(u, port, ip, X, Y, x, y, x1, x2, y1, y2, speed, clientID);
    travelAlongZ(u, port, ip, X, Y, z, Zm, speed, clientID);
end

% Local function to move in z-direction
function travelAlongZ(u, port, ip, X, Y, Z, z, speed, clientID)
    stepZ = sign(z - Z);
    for i = Z:stepZ:z

        % Send coordinates to server
        message = sprintf('%d,%.2f,%.2f', clientID, X - 0.5, Y - 0.5);
        write(u, uint8(message), ip, port);
        disp("Sent: " + message);
        pause(1 / speed);
    end
end

% Local function to travel the matrix
function travelMatrix(u, port, ip, X, Y, x, y, x1, x2, y1, y2, speed, clientID)
    rows = abs(x2 - x1) + 1;
    cols = abs(y2 - y1) + 1;

    % Decide traversal preference
    if mod(rows,2) == 0 && mod(cols,2) == 0
        rowPreferred = rows <= cols;
    elseif mod(rows,2) == 0
        rowPreferred = true;
    elseif mod(cols,2) == 0
        rowPreferred = false;
    else
        rowPreferred = false;
    end

    % Determine step directions from current corner
    rowStep = sign(x2 - x1);
    colStep = sign(y2 - y1);

    if X == x2
        rowStep = -rowStep;
    end
    if Y == y2
        colStep = -colStep;
    end

    % Build proper ranges
    if rowStep == 1
        mainRowRange = x1:x2;
    else
        mainRowRange = x2:-1:x1;
    end

    if colStep == 1
        mainColRange = y1:y2;
    else
        mainColRange = y2:-1:y1;
    end

    % Traverse
    if rowPreferred
        % Row-wise zigzag
        for i = mainRowRange
            if mod(find(mainRowRange == i, 1) - 1, 2) == 0
                colRange = mainColRange;
            else
                colRange = fliplr(mainColRange);
            end
            for j = colRange

                % Send coordinates to server
                message = sprintf('%d,%.2f,%.2f', clientID, i - 0.5, j - 0.5);
                write(u, uint8(message), ip, port);
                disp("Sent: " + message);
                pause(1 / speed);

                lastX = i;
                lastY = j;
            end
        end

    else
        % Column-wise zigzag
        for j = mainColRange
            if mod(find(mainColRange == j, 1) - 1, 2) == 0
                rowRange = mainRowRange;
            else
                rowRange = fliplr(mainRowRange);
            end
            for i = rowRange

                % Send coordinates to server
                message = sprintf('%d,%.2f,%.2f', clientID, i - 0.5, j - 0.5);
                write(u, uint8(message), ip, port);
                disp("Sent: " + message);
                pause(1 / speed);

                lastX = i;
                lastY = j;
            end
        end
    end

    returnBackToStart(u, port, ip, lastX, lastY, x, y, speed, clientID);
end

% Local function to return back to starting point
function returnBackToStart(u, port, ip, X, Y, x, y, speed, clientID)
    stepX = sign(x - X);
    stepY = sign(y - Y);
    
    % Move horizontally first
    for i = Y:stepY:y

        % Send coordinates to server
        message = sprintf('%d,%.2f,%.2f', clientID, X - 0.5, i - 0.5);
        write(u, uint8(message), ip, port);
        disp("Sent: " + message);
        pause(1 / speed);
    end

    % Now move vertically
    for i = X:stepX:x

        % Send coordinates to server
        message = sprintf('%d,%.2f,%.2f', clientID, i - 0.5, Y - 0.5);
        write(u, uint8(message), ip, port);
        disp("Sent: " + message);
        pause(1 / speed);
    end
end
