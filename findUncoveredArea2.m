% Function to find uncovered area divisions (2 UAVs left/fail case)
function [newUncoveredArea] = findUncoveredArea2(uncoveredArea, coveredAreaMap)

    numUncovered = size(uncoveredArea, 1);
    keysCovered = keys(coveredAreaMap);
    numCovered = length(keysCovered);

    keepIdx = true(numUncovered, 1);

    for i = 1:numUncovered
        for j = 1:numCovered
            covered = coveredAreaMap(keysCovered{j});
            if isequal(uncoveredArea(i, :), covered)
                keepIdx(i) = false;
                break;  % no need to check further if match is found
            end
        end
    end

    newUncoveredArea = uncoveredArea(keepIdx, :);
end
