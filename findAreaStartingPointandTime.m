% Function to find area, starting point and time
function [uavNewMap] = findAreaStartingPointandTime(clientID, X, Y, Z, grid, uavPosMap, div, mat)

    uavPosMap(clientID) = [X, Y, Z];

    % Get grid section and divide
    gridSection = grid(mat(1):mat(2), mat(3):mat(4));
    [numRows, numCols] = size(gridSection);

    [uavDivisions] = divideGrid(numRows, numCols, uavPosMap, div);
    [uavNewMap] = assignAreaStartingPointandTime(grid, uavPosMap, div, mat, uavDivisions);
end

% Local function to find area divisions
function [uavDivisions] = divideGrid(gridRows, gridCols, uavPosMap, div)

    uavIDs = keys(uavPosMap);
    numUAVs = length(uavIDs);
    positions = zeros(numUAVs, 2); % Store [row, col] per UAV

    % Extract positions
    for i = 1:numUAVs
        pos = uavPosMap(uavIDs{i});
        positions(i, :) = [pos(1), pos(2)];
    end

    % Sort UAVs based on div type
    if div == 'v'   % Horizontal division next
        [~, sortedIdx] = sort(positions(:,1)); % sort by row
        total = gridRows;

    else    % Vertical division next
        [~, sortedIdx] = sort(positions(:,2)); % sort by col
        total = gridCols;
    end

    % Compute base division sizes
    baseSize = floor(total / numUAVs);
    remainder = mod(total, numUAVs);

    % Assign areas based on sorted order
    uavDivisions = containers.Map('KeyType', 'int32', 'ValueType', 'any');
    startIdx = 1;

    for i = 1:numUAVs
        extra = i <= remainder;
        chunkSize = baseSize + extra;
        endIdx = startIdx + chunkSize - 1;

        uavID = uavIDs{sortedIdx(i)};
        if div == 'v'   % Horizontal division next
            area = struct('startRow', startIdx, 'endRow', endIdx, ...
                          'startCol', 1, 'endCol', gridCols);

        else    % Vertical division next
            area = struct('startRow', 1, 'endRow', gridRows, ...
                          'startCol', startIdx, 'endCol', endIdx);
        end

        uavDivisions(uavID) = area;
        startIdx = endIdx + 1;
    end
end

% Local function to assign area, starting point and time
function [uavNewMap] = assignAreaStartingPointandTime(grid, uavPosMap, div, mat, uavDivisions)
    uavNewMap = containers.Map('KeyType', 'int32', 'ValueType', 'any');
    stepsToStart = 0;
    stepsToCoverReturn = 0;

    uavIDs = keys(uavPosMap);
    numUAVs = length(uavIDs);

    for i = 1:numUAVs
        uavID = uavIDs{i};
        currentPos = uavPosMap(uavID);
        area = uavDivisions(uavID);

        if div == 'v'   % Horizontal division next
            subStart = mat(1) + area.startRow - 1;
            subEnd = mat(1) + area.endRow - 1;
            colStart = mat(3);
            colEnd = mat(4);

            target1 = [subStart, colEnd];
            target2 = [subEnd, colEnd];

            maxZ = max(max(grid(subStart:subEnd, colStart:colEnd))) + 1;

            subRows = subEnd - subStart + 1;
            subCols = colEnd - colStart + 1;

        else    % Vertical division next
            rowStart = mat(1);
            rowEnd = mat(2);
            subStart = mat(3) + area.startCol - 1;
            subEnd = mat(3) + area.endCol - 1;

            target1 = [rowEnd, subStart];
            target2 = [rowEnd, subEnd];

            maxZ = max(max(grid(rowStart:rowEnd, subStart:subEnd))) + 1;

            subRows = rowEnd - rowStart + 1;
            subCols = subEnd - subStart + 1;
        end

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
        if div == 'v'   % Horizontal division next
            result.rowStart = subStart;
            result.rowEnd = subEnd;
            result.colStart = colStart;
            result.colEnd = colEnd;

        else    % Vertical division next
            result.rowStart = rowStart;
            result.rowEnd = rowEnd;
            result.colStart = subStart;
            result.colEnd = subEnd;
        end

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