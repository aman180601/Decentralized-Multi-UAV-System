% Function to find the meeting points
function [meetingPointsMap] = findMeetingPoints(clientID, X, Y, Z, grid, mat, division, minHeight, coordinateMap)

    coordinateMap(clientID) = [X, Y, Z];
    n = length(coordinateMap);

    [firstCell] = getFirstCell(n, mat, division);
    [meetingPointsMap] = assignMeetingPoints(coordinateMap, firstCell(1), firstCell(2), minHeight, grid);
    [meetingPointsMap] = adjustHeights(meetingPointsMap);
    [time1, time2] = findTime(coordinateMap, meetingPointsMap);
    [meetingPointsMap] = mergeWithTime(meetingPointsMap, time1, time2);
end

% Local function to get first cell of meeting points
function [firstCell] = getFirstCell(n, mat, division)

    if division == 'h'  % Vertical division next
        totalHeight = mat(4) - mat(3) + 1;  % Total number of columns
        baseSize = floor(totalHeight / n);  % Base number of columns per subgrid
        extra = mod(totalHeight, n);  % Extra columns to distribute

        % Find last column of first subgrid
        lastColumn = mat(3) + baseSize - 1;
        if extra > 0
            lastColumn = lastColumn + 1;  % First subgrid gets an extra column if extra columns exist
        end
        firstCell = [mat(2), lastColumn];
        
    else    % Horizontal division next
        totalWidth = mat(2) - mat(1) + 1;  % Total number of rows
        baseSize = floor(totalWidth / n);  % Base number of rows per subgrid
        extra = mod(totalWidth, n);  % Extra rows to distribute

        % Find last row of first subgrid
        lastRow = mat(1) + baseSize - 1;
        if extra > 0
            lastRow = lastRow + 1;  % First subgrid gets an extra row if extra rows exist
        end
        firstCell = [lastRow, mat(4)];
    end
end

% Local function to assign meeting points to all clients
function [meetingPointsMap] = assignMeetingPoints(coordinateMap, x_start, y_start, minHeight, grid)
    
    ids = keys(coordinateMap);
    coords = values(coordinateMap);
    
    % Convert cell array to numeric array
    coords = cell2mat(coords');
    
    % Check alignment
    if all(coords(:,2) == coords(1,2))  % Vertically aligned (same column)
        % Sort by increasing x-values (ensuring increasing order)
        [~, sortedIdx] = sort(coords(:,1));
        
        % Assign them in a horizontal row (same x, increasing y)
        newX = x_start * ones(numel(ids), 1);
        newY = (y_start : y_start + numel(ids) - 1)';
        newZ = max(minHeight - 1, max(grid(x_start, :))) * ones(numel(ids), 1);
        
    elseif all(coords(:,1) == coords(1,1))  % Horizontally aligned (same row)
        % Sort by increasing y-values (ensuring increasing order)
        [~, sortedIdx] = sort(coords(:,2));
        
        % Assign them in a vertical column (same y, increasing x)
        newX = (x_start : x_start + numel(ids) - 1)';
        newY = y_start * ones(numel(ids), 1);
        newZ = max(minHeight - 1, max(grid(:, y_start))) * ones(numel(ids), 1);
    end

    % Preserve original ID mappings
    sortedIds = ids(sortedIdx);
    meetingPointsMap = containers.Map(sortedIds, num2cell([newX, newY, newZ], 2));
end

% Local function to adjust the meeting points' height
function [meetingPointsMap] = adjustHeights(meetingPointsMap)

    ids = keys(meetingPointsMap);

    for i = 1:numel(ids)
        temp = meetingPointsMap(ids{i});
        temp(3) = temp(3) + ids{i};
        meetingPointsMap(ids{i}) = temp;
    end
end

% Local function to find the maximum moving time
function [time1, time2] = findTime(coordinateMap, meetingPointsMap)

    time1 = 0;
    time2 = 0;
    ids = keys(meetingPointsMap);

    for i = 1:numel(ids)
        tupleS = coordinateMap(ids{i});
        tupleD = meetingPointsMap(ids{i});
        time1 = max(time1, abs(tupleS(2) - tupleD(2)) + abs(tupleS(1) - tupleD(1)));
        time2 = max(time2, tupleS(3) - tupleD(3));
    end
end

% Local function to merge the maximum moving time with meeting points map
function [meetingPointsMap] = mergeWithTime(meetingPointsMap, time1, time2)

    keysList = keys(meetingPointsMap);

    for i = 1:length(keysList)
        key = keysList{i};
        oldValue = meetingPointsMap(key);
        meetingPointsMap(key) = [oldValue, time1, time2];
    end
end