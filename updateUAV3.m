%Function to update the UAV's data (single UAV fail case)
function [division, clientsMap] = updateUAV3(clientID, division, clientsMap, coveredAreaMap)

    % Extract numeric keys from coveredAreaMap
    coveredKeysCell = keys(coveredAreaMap);
    coveredKeys = cell2mat(coveredKeysCell);

    % Remove clientID from the list
    coveredKeys(coveredKeys == clientID) = [];

    % Find the highest key among the remaining ones
        highestKey = max(coveredKeys);

    % Remove all other keys from clientsMap
    clientKeys = cell2mat(keys(clientsMap));
    for i = 1:length(clientKeys)
        key = clientKeys(i);
        if key ~= highestKey
            remove(clientsMap, key);
        end
    end

    % Update division
    if division == 'v'
        division = 'h';

    else
        division = 'v';
    end
end