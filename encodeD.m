% Encoding function for 'd' type strings
function [encoded_str] = encodeD(x1, x2, y1, y2, id)
    encoded_str = sprintf('d:%d,%d,%d,%d:%d', x1, x2, y1, y2, id);
end