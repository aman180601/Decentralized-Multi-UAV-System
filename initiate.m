% Function to initiate the given client
function initiate(grid, threshold, minHeight, totalClients, buffer, speed, serverIP, serverPort, clientID, portNo, ipAddress, clientsMap, division, mat, X, Y, Z, maxHeight, Xm, Ym, Zm, u, Xs, Ys, Zs)
    
    % First communication
    timeout = 15 + buffer;
    tStart = tic;
    [message] = encodeW(X, Y, Z, clientID);
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
    [coordinateMap] = decodeW(receivedData);
    
    % Check if the client has the highest priority
    [isPrior] = checkPriority(clientID, coordinateMap);
    
    while  toc(tStart) < timeout
            pause(0.1);
    end
    
    % Wait or find meeting points
    timeout = 15 + buffer;
    tStart = tic;
    if isPrior
        [meetingPointsMap] = findMeetingPoints(clientID, X, Y, Z, grid, mat, division, minHeight, coordinateMap);
        for i = 1:length(clientKeys)
            pair = clientsMap(clientKeys{i});
            if isKey(meetingPointsMap, clientKeys{i})
                multiple = meetingPointsMap(clientKeys{i});
                [message] = encodeG(multiple(1), multiple(2), multiple(3), multiple(4), multiple(5));
                write(u, uint8(char(message)), pair{2}, pair{1});
                disp("Sent: " + message);
            end
        end
        multiple = meetingPointsMap(clientID);
        [message] = encodeG(multiple(1), multiple(2), multiple(3), multiple(4), multiple(5));
        write(u, uint8(char(message)), ipAddress, portNo);
        disp("Sent: " + message);
    end
        
    % Wait and then process the receieved meeting point
    while  toc(tStart) < timeout
            pause(0.1);
    end
    
    timeout = 5 + buffer;
    tStart = tic;
    [receivedData] = getReceivedMessages(portNo);
    clearReceivedMessages(portNo);
    [x, y, z, t1, t2] = decodeG(receivedData);
    Xm = x;
    Ym = y;
    Zm = z;
    
    % Wait and then move to the meeting point
    while  toc(tStart) < timeout
            pause(0.1);
    end
    
    timeout = (t1 / speed) + buffer;
    tStart = tic;
    moveToMeetingPoint(u, serverPort, serverIP, X, Y, Xm, Ym, speed, division, clientID);
    X = Xm;
    Y = Ym;
    
    while  toc(tStart) < timeout
            pause(0.1);
    end
    
    timeout = (t2 / speed) + buffer;
    tStart = tic;
    while Z ~= Zm
        Z = Z - 1;
    
        % Send coordinates to server
        message = sprintf('%d,%.2f,%.2f', clientID, X - 0.5, Y - 0.5);
        write(u, uint8(message), serverIP, serverPort);
        disp("Sent: " + message);
        pause(1 / speed);
    end
    
    while  toc(tStart) < timeout
            pause(0.1);
    end
    

    % 2nd communication
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
        [uavNewMap] = findAreaStartingPointandTime(clientID, X, Y, Z, grid, coordinateMap, division, mat);
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


    % 3rd communication
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

    % Check if the client has the highest priority
    [isPrior] = checkPriority(clientID, coveredAreaMap);
    
    while  toc(tStart) < timeout
            pause(0.1);
    end

    % Find uncovered area
    timeout = 5 + buffer;
    tStart = tic;
    [uncoveredArea] = findUncoveredArea(mat, coveredAreaMap, division);

    while  toc(tStart) < timeout
            pause(0.1);
    end

    % Update data based on number of clients left
    if coveredAreaMap.Count == totalClients
        moveBackToStart(u, serverPort, serverIP, X, Y, Z, Xs, Ys, Zs, maxHeight, speed, clientID);

    elseif coveredAreaMap.Count == 1
        coverArea1(grid, u, serverPort, serverIP, X, Y, Z, Xs, Ys, Zs, maxHeight, division, speed, clientID, uncoveredArea);

    elseif coveredAreaMap.Count == 3
        timeout = 5 + buffer;
        tStart = tic;
        if isPrior
            moveBackToStart(u, serverPort, serverIP, X, Y, Z, Xs, Ys, Zs, maxHeight, speed, clientID);

        else
            [newDivision, newClientsMap] = updateUAV3(clientID, division, clientsMap, coveredAreaMap);
            mat = uncoveredArea(1,:);
            division = newDivision;
            clientsMap = newClientsMap;
            while  toc(tStart) < timeout
                pause(0.1);
            end
            totalClients = 2;
            initiate(grid, threshold, minHeight, totalClients, buffer, speed, serverIP, serverPort, clientID, portNo, ipAddress, clientsMap, division, mat, X, Y, Z, maxHeight, Xm, Ym, Zm, u, Xs, Ys, Zs);
        end

    elseif coveredAreaMap.Count == 2
        timeout = 5 + buffer;
        tStart = tic;
        [newClientsMap] = updateUAV2(clientsMap, coveredAreaMap);
        totalClients = 2;
        clientsMap = newClientsMap;
        while  toc(tStart) < timeout
            pause(0.1);
        end

        coverArea2(grid, threshold, minHeight, totalClients, buffer, speed, serverIP, serverPort, clientID, portNo, ipAddress, clientsMap, division, X, Y, Z, maxHeight, Xm, Ym, Zm, u, Xs, Ys, Zs, uncoveredArea);
    end

    % Cleanup
    clear u;

end