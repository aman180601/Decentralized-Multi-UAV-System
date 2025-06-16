% Encoding function for 'r' type strings
function [encoded_str] = encodeR(x, y, z, id)
    encoded_str = sprintf('r:%d,%d,%d:%d', x, y, z, id);
end