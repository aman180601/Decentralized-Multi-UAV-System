% Decoding function for 'w' type strings
function [data_map] = decodeW(encoded_strings)

    % Initialize the map to store id -> (x, y) pairs
    data_map = containers.Map('KeyType', 'int32', 'ValueType', 'any');
    
    % Process each encoded string in the list
    for i = 1:numel(encoded_strings)
        encoded_str = encoded_strings{i};
        
        % Split the encoded string into parts
        parts = strsplit(encoded_str, ':');
        
        % Check if the format is valid
        if numel(parts) ~= 3
            error('Invalid encoded string format. Expected format "w:x,y,z:id"');
        end
        
        % Extract the character, coordinates, and id
        char = parts{1};
        coords_part = parts{2};
        id = parts{3};

        % Check if the message code is valid
        if char ~= 'w'
            error('Received message code is not valid');
        end

        % Convert id to numeric value
        id = str2double(id);

        % Split the coordinates part
        coords = strsplit(coords_part, ',');
        
        % Check if coordinates are valid
        if numel(coords) ~= 3
            error('Invalid coordinates format. Expected "x,y,z"');
        end
        
        % Convert coordinates to numeric values
        x = str2double(coords{1});
        y = str2double(coords{2});
        z = str2double(coords{3});
        
        % Check if id or coordinates are numeric
        if isnan(x) || isnan(y) || isnan(z) || isnan(id)
            error('Non-numeric values in id or coordinates');
        end
        
        % Add the id and (x, y) pair to the map
        data_map(int32(id)) = [x, y, z];
    end
end