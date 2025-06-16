% Function to find uncovered area divisions 
function [missingAreas] = findUncoveredArea(mainArea, uavAreasMap, div)

    keysArray = cell2mat(keys(uavAreasMap));
    uavAreas = [];

    % Construct the 2D array
    for i = 1:length(keysArray)
        uavAreas = [uavAreas; uavAreasMap(keysArray(i))];
    end

    % Define main range based on division type
    if div == 'v'
        mainLow = mainArea(1);
        mainHigh = mainArea(2);
    else
        mainLow = mainArea(3);
        mainHigh = mainArea(4);
    end

    % Extract intervals from UAV areas
    intervals = [];
    if ~isempty(uavAreas)
        for i = 1:size(uavAreas,1)
            if div == 'v'
                a = uavAreas(i,1);
                b = uavAreas(i,2);
            else
                a = uavAreas(i,3);
                b = uavAreas(i,4);
            end
            intervals = [intervals; a, b];
        end
    end

    % Handle no UAV coverage
    if isempty(intervals)
        missingAreas = mainArea;
        return;
    end

    % Sort intervals
    intervals = sortrows(intervals, 1);

    % Find missing intervals
    missingIntervals = [];
    if intervals(1,1) > mainLow
        missingIntervals = [missingIntervals; mainLow, intervals(1,1)-1];
    end
    for i = 1:size(intervals,1)-1
        if intervals(i,2) < intervals(i+1,1) - 1
            missingIntervals = [missingIntervals; intervals(i,2)+1, intervals(i+1,1)-1];
        end
    end
    if intervals(end,2) < mainHigh
        missingIntervals = [missingIntervals; intervals(end,2)+1, mainHigh];
    end

    % Build missing rectangles
    missingAreas = [];
    for i = 1:size(missingIntervals,1)
        if div == 'v'
            missingAreas = [missingAreas; ...
                missingIntervals(i,1), missingIntervals(i,2), mainArea(3), mainArea(4)];
        else
            missingAreas = [missingAreas; ...
                mainArea(1), mainArea(2), missingIntervals(i,1), missingIntervals(i,2)];
        end
    end
end
