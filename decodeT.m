% Decoding function for 't' type strings
function [x1, x2, y1, y2, x, y, z, t1, t2] = decodeT(encoded_strings)
    
    % Check if the list contains a single message or not
    if numel(encoded_strings) ~= 1
        error('There should be a single received message');
    end

    encoded_str = encoded_strings{1};
        
    % Split the encoded string into parts
    parts = strsplit(encoded_str, ':');
        
    % Check if the format is valid
    if numel(parts) ~= 4
        error('Invalid encoded string format. Expected format "g:x1,x2,y1,y2:x,y,z,t1,t2"');
    end
        
    % Extract the character, area, coordinates and timings
    char = parts{1};
    area_part = parts{2};
    coords_part = parts{3};
    timings_part = parts{4};

    % Check if the message code is valid
    if char ~= 't'
        error('Received message code is not valid');
    end

    % Split the area part
    area = strsplit(area_part, ',');

    % Check if area is valid
    if numel(area) ~= 4
        error('Invalid coordinates format. Expected "x1,x2,y1,y2"');
    end

    % Split the coordinates part
    coords = strsplit(coords_part, ',');
        
    % Check if coordinates are valid
    if numel(coords) ~= 3
        error('Invalid coordinates format. Expected "x,y,z"');
    end

    % Split the timings part
    timings = strsplit(timings_part, ',');
        
    % Check if coordinates are valid
    if numel(timings) ~= 2
        error('Invalid timings format. Expected "t1,t2"');
    end

    % Convert area to numeric values
    x1 = str2double(area{1});
    x2 = str2double(area{2});
    y1 = str2double(area{3});
    y2 = str2double(area{4});
        
    % Convert coordinates to numeric values
    x = str2double(coords{1});
    y = str2double(coords{2});
    z = str2double(coords{3});

    % Convert timings to numeric values
    t1 = str2double(timings{1});
    t2 = str2double(timings{2});
        
    % Check if the coordinates are numeric
    if isnan(x1) || isnan(x2) || isnan(y1) || isnan(y2) || isnan(x) || isnan(y) || isnan(z) || isnan(t1) || isnan(t2)
        error('Non-numeric values in timings or coordinates');
    end
end