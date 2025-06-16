% Function to cover the left area by two UAVs (two UAVs left/fail case)
function coverArea2(grid, threshold, minHeight, totalClients, buffer, speed, serverIP, serverPort, clientID, portNo, ipAddress, clientsMap, division, X, Y, Z, maxHeight, Xm, Ym, Zm, u, Xs, Ys, Zs, uncoveredArea)

    % Ensure there are two area divisions left
    if size(uncoveredArea, 1) ~= 2
        [uncoveredArea] = divideAreaIntoTwoParts(uncoveredArea(1,:), division);
    end
    
    % 1st Communication
    timeout = 15 + buffer;
    tStart = tic;
    [message] = encodeR(X, Y, Z, clientID);
    clientKeys = keys(clientsMap);
    for i = 1:length(clientKeys)
        pair = clientsMap(clientKeys{i});
        write(u, uint8(char(message)), pair{2}, pair{1});
        disp("Sent: " + message);
    end

    while  toc(tStart) < timeout
            pause(0.1);
    end

    timeout = 5 + buffer;
    tStart = tic;
    [receivedData] = getReceivedMessages(portNo);
    clearReceivedMessages(portNo);
    [coordinateMap] = decodeR(receivedData);
    
    % Check if the client has the highest priority
    [isPrior] = checkPriority(clientID, coordinateMap);
    
    while  toc(tStart) < timeout
            pause(0.1);
    end

    % Wait or find area division, starting points and traversal time
    timeout = 15 + buffer;
    tStart = tic;
    if isPrior
        [uavNewMap] = findAreaStartingPointandTime2(clientID, X, Y, Z, grid, coordinateMap, division, uncoveredArea);
        for i = 1:length(clientKeys)
            pair = clientsMap(clientKeys{i});
            if isKey(uavNewMap, clientKeys{i})
                data = uavNewMap(clientKeys{i});
                [message] = encodeT(data.rowStart, data.rowEnd, data.colStart, data.colEnd, data.x, data.y, data.z, data.time1, data.time2);
                write(u, uint8(char(message)), pair{2}, pair{1});
                disp("Sent: " + message);
            end
        end
        data = uavNewMap(clientID);
        [message] = encodeT(data.rowStart, data.rowEnd, data.colStart, data.colEnd, data.x, data.y, data.z, data.time1, data.time2);
        write(u, uint8(char(message)), ipAddress, portNo);
        disp("Sent: " + message);
    end
        
    % Wait and then process the receieved messages
    while  toc(tStart) < timeout
            pause(0.1);
    end

    timeout = 5 + buffer;
    tStart = tic;
    [receivedData] = getReceivedMessages(portNo);
    clearReceivedMessages(portNo);
    [x1, x2, y1, y2, x, y, z, t1, t2] = decodeT(receivedData);

    % Wait and then move to the starting point
    while  toc(tStart) < timeout
            pause(0.1);
    end

    timeout = (t1 / speed) + buffer;
    tStart = tic;
    moveBetweenStartingAndMeetingPoint(u, serverPort, serverIP, X, Y, x, y, speed, division, clientID);
    X = x;
    Y = y;
    
    % Wait and then traverse the assigned area division
    while  toc(tStart) < timeout
            pause(0.1);
    end

    timeout = (t2 / speed) + buffer;
    tStart = tic;
    traverseArea(u, serverPort, serverIP, X, Y, Z, x, y, z, Zm, x1, x2, y1, y2, speed, clientID);

    % Wait and then move back to the meeting point
    while  toc(tStart) < timeout
            pause(0.1);
    end

    timeout = (t1 / speed) + buffer;
    tStart = tic;
    moveBetweenStartingAndMeetingPoint(u, serverPort, serverIP, X, Y, Xm, Ym, speed, division, clientID);
    X = Xm;
    Y = Ym;

    while  toc(tStart) < timeout
            pause(0.1);
    end

    % 2nd communication
    timeout = 15 + buffer;
    tStart = tic;
    [message] = encodeD(x1, x2, y1, y2, clientID);
    clientKeys = keys(clientsMap);
    for i = 1:length(clientKeys)
        pair = clientsMap(clientKeys{i});
        write(u, uint8(char(message)), pair{2}, pair{1});
        disp("Sent: " + message);
    end

    while  toc(tStart) < timeout
            pause(0.1);
    end

    timeout = 5 + buffer;
    tStart = tic;
    [receivedData] = getReceivedMessages(portNo);
    clearReceivedMessages(portNo);
    [coveredAreaMap] = decodeD(receivedData);
    coveredAreaMap(clientID) = [x1, x2, y1, y2];
    
    while  toc(tStart) < timeout
            pause(0.1);
    end

    % Find uncovered area
    timeout = 5 + buffer;
    tStart = tic;
    [newUncoveredArea] = findUncoveredArea2(uncoveredArea, coveredAreaMap);
    uncoveredArea = newUncoveredArea;

    while  toc(tStart) < timeout
            pause(0.1);
    end

    % Update data based on number of clients left
    if coveredAreaMap.Count == totalClients
        moveBackToStart(u, serverPort, serverIP, X, Y, Z, Xs, Ys, Zs, maxHeight, speed, clientID);

    elseif coveredAreaMap.Count == 1
        coverArea1(grid, u, serverPort, serverIP, X, Y, Z, Xs, Ys, Zs, maxHeight, division, speed, clientID, uncoveredArea);
    end
end

% Local function to divide area into two divisions
function [uncoveredArea] = divideAreaIntoTwoParts(mat, div)

    numUAVs = 2;
    numRows = mat(2) - mat(1) + 1;
    numCols = mat(4) - mat(3) + 1;

    if div == 'v'   % Horizontal division next
        total = numRows;

    else    % Vertical division next
        total = numCols;
    end

    % Compute base division sizes
    baseSize = floor(total / numUAVs);
    remainder = mod(total, numUAVs);

    startIdx = 1;
    uncoveredArea = [];

    for i = 1:numUAVs
        extra = i <= remainder;
        chunkSize = baseSize + extra;
        endIdx = startIdx + chunkSize - 1;

        if div == 'v'   % Horizontal division next
            x1 = mat(1) + startIdx - 1;
            x2 = mat(1) + endIdx - 1;
            y1 = mat(3);
            y2 = mat(4);

        else    % Vertical division next
            x1 = mat(1);
            x2 = mat(2);
            y1 = mat(3) + startIdx - 1;
            y2 = mat(3) + endIdx - 1;
        end

        uncoveredArea = [uncoveredArea; x1, x2, y1, y2];
        startIdx = endIdx + 1;
    end
end