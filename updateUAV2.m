% Function to update the UAV's data (two UAVs left/fail case)
function [clientsMap] = updateUAV2(clientsMap, coveredAreaMap)
    
    % Get keys from both maps
    clientKeys = cell2mat(keys(clientsMap));
    coveredKeys = cell2mat(keys(coveredAreaMap));

    % Loop through clientMap and remove keys not in coveredAreaMap
    for i = 1:length(clientKeys)
        key = clientKeys(i);
        if ~ismember(key, coveredKeys)
            remove(clientsMap, key);
        end
    end
end