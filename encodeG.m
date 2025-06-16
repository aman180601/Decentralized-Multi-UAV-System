% Encoding function for 'g' type strings
function [encoded_str] = encodeG(x, y, z, t1, t2)
    encoded_str = sprintf('g:%d,%d,%d:%d,%d', x, y, z, t1, t2);
end