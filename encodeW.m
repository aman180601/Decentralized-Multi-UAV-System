% Encoding function for 'w' type strings
function [encoded_str] = encodeW(x, y, z, id)
    encoded_str = sprintf('w:%d,%d,%d:%d', x, y, z, id);
end