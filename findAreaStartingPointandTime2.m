% Function to find area, starting point and time (2 UAVs left/fail case)
function [uavNewMap] = findAreaStartingPointandTime2(clientID, X, Y, Z, grid, uavPosMap, div, uncoveredArea)
    
    uavPosMap(clientID) = [X, Y, Z];

    [uavDivisions] = divideGrid(uncoveredArea, uavPosMap, div);
    [uavNewMap] = assignAreaStartingPointandTime(grid, uavPosMap, div, uavDivisions);
end

% Local function to assign area division
function [uavDivisions] = divideGrid(uncoveredArea, uavPosMap, div)

    uavIDs = keys(uavPosMap);
    pos1 = uavPosMap(uavIDs{1});
    pos2 = uavPosMap(uavIDs{2});

    distances = zeros(2, 2);  % [UAVs, Areas]
    for areaIdx = 1:2
        x1 = uncoveredArea(areaIdx, 1);
        x2 = uncoveredArea(areaIdx, 2);
        y1 = uncoveredArea(areaIdx, 3);
        y2 = uncoveredArea(areaIdx, 4);
        corners = [x1 y1; x1 y2; x2 y1; x2 y2];

        % Manhattan distances
        d1 = abs(corners(:,1) - pos1(1)) + abs(corners(:,2) - pos1(2));
        d2 = abs(corners(:,1) - pos2(1)) + abs(corners(:,2) - pos2(2));
        distances(1, areaIdx) = min(d1);
        distances(2, areaIdx) = min(d2);
    end

    % Decide assignment
    assign1 = distances(1,1) + distances(2,2);
    assign2 = distances(1,2) + distances(2,1);

    uavDivisions = containers.Map('KeyType', 'int32', 'ValueType', 'any');
    if assign1 <= assign2
        uavDivisions(uavIDs{1}) = uncoveredArea(1, :);
        uavDivisions(uavIDs{2}) = uncoveredArea(2, :);
    else
        uavDivisions(uavIDs{1}) = uncoveredArea(2, :);
        uavDivisions(uavIDs{2}) = uncoveredArea(1, :);
    end
end

% Local function to assign area, starting point and time
function [uavNewMap] = assignAreaStartingPointandTime(grid, uavPosMap, div, uavDivisions)
    uavNewMap = containers.Map('KeyType', 'int32', 'ValueType', 'any');
    stepsToStart = 0;
    stepsToCoverReturn = 0;

    uavIDs = keys(uavPosMap);
    numUAVs = length(uavIDs);

    for i = 1:numUAVs
        uavID = uavIDs{i};
        currentPos = uavPosMap(uavID);
        area = uavDivisions(uavID);

        rowStart = area(1);
        rowEnd = area(2);
        colStart = area(3);
        colEnd = area(4);

        if div == 'v'   % Horizontal division next
            target1 = [rowStart, colEnd];
            target2 = [rowEnd, colEnd];

        else    % Vertical division next
            target1 = [rowEnd, colStart];
            target2 = [rowEnd, colEnd];
        end

        maxZ = max(max(grid(rowStart:rowEnd, colStart:colEnd))) + 1;

        subRows = rowEnd - rowStart + 1;
        subCols = colEnd - colStart + 1;

        % Calculate shortest move to reach target (either corner)
        dist1 = abs(currentPos(1) - target1(1)) + abs(currentPos(2) - target1(2));
        dist2 = abs(currentPos(1) - target2(1)) + abs(currentPos(2) - target2(2));

        if dist1 <= dist2
            target = target1;
            flatDist = dist1;
        else
            target = target2;
            flatDist = dist2;
        end

        zStep = max(0, maxZ - currentPos(3));  % climbing cost only
        stepsToStart = max(stepsToStart, flatDist);

        stepsToCoverReturn = max(stepsToCoverReturn, minStepsToCoverAndReturn(subRows, subCols) + zStep);

        % Build result struct
        result = struct( ...
            'x', target(1), ...
            'y', target(2), ...
            'z', max(maxZ, currentPos(3)) ...
        );

        % Add area bounds to struct
        result.rowStart = rowStart;
        result.rowEnd = rowEnd;
        result.colStart = colStart;
        result.colEnd = colEnd;

        % Store in output map
        uavNewMap(uavID) = result;
    end

    % Find the maximum moving time
    for i = 1:numUAVs
        uavID = uavIDs{i};
        result = uavNewMap(uavID);
        result.time1 = stepsToStart;
        result.time2 = stepsToCoverReturn;
        uavNewMap(uavID) = result;
    end
end

% Local function to calculate time for area coverage with zero displacement
function steps = minStepsToCoverAndReturn(rows, cols)
    % Step 1: Visit all cells
    visitSteps = rows * cols - 1;

    % Step 2: Compute return path based on parity
    if mod(rows,2) == 0 && mod(cols,2) == 0
        % Both even: move depending on which is minimum
        returnSteps = min(rows, cols) - 1;

    elseif mod(rows,2) == 0
        % Even rows: move left/right first
        returnSteps = rows - 1;

    elseif mod(cols,2) == 0
        % Even cols: move up/down first
        returnSteps = cols - 1;

    else
        % Both odd: move either way first
        returnSteps = (rows - 1) + (cols - 1);
    end

    steps = visitSteps + returnSteps;
end