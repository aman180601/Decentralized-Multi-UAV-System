% Decoding function for 'd' type strings
function [data_map] = decodeD(encoded_strings)

    % Initialize the map to store id -> (x, y) pairs
    data_map = containers.Map('KeyType', 'int32', 'ValueType', 'any');
    
    % Process each encoded string in the list
    for i = 1:numel(encoded_strings)
        encoded_str = encoded_strings{i};
        
        % Split the encoded string into parts
        parts = strsplit(encoded_str, ':');
        
        % Check if the format is valid
        if numel(parts) ~= 3
            error('Invalid encoded string format. Expected format "d:x1,x2,y1,y2:id"');
        end
        
        % Extract the character, area, and id
        char = parts{1};
        area_part = parts{2};
        id = parts{3};

        % Check if the message code is valid
        if char ~= 'd'
            error('Received message code is not valid');
        end

        % Convert id to numeric value
        id = str2double(id);

        % Split the coordinates part
        area = strsplit(area_part, ',');
        
        % Check if coordinates are valid
        if numel(area) ~= 4
            error('Invalid coordinates format. Expected "x1,x2,y1,y2"');
        end
        
        % Convert coordinates to numeric values
        x1 = str2double(area{1});
        x2 = str2double(area{2});
        y1 = str2double(area{3});
        y2 = str2double(area{4});
        
        % Check if id or coordinates are numeric
        if isnan(x1) || isnan(x2) || isnan(y1) || isnan(y2) || isnan(id)
            error('Non-numeric values in id or area');
        end
        
        % Add the id and (x, y) pair to the map
        data_map(int32(id)) = [x1, x2, y1, y2];
    end
end