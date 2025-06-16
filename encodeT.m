% Encoding function for 't' type strings
function [encoded_str] = encodeT(x1, x2, y1, y2, x, y, z, t1, t2)
    encoded_str = sprintf('t:%d,%d,%d,%d:%d,%d,%d:%d,%d', x1, x2, y1, y2, x, y, z, t1, t2);
end