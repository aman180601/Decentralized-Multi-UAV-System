% Function to retrieve all stored messages
function [messages] = getReceivedMessages(portNo)
    readyFile = sprintf("listener_ready_%d.txt", portNo);
    if exist(readyFile, 'file')
        fid = fopen(readyFile, 'r');
        messages = textscan(fid, '%s', 'Delimiter', '\n');
        fclose(fid);
        messages = messages{1}; % Extract cell array of messages
    else
        messages = {}; % No messages received yet
    end
end