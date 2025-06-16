% Function to clear received messages
function clearReceivedMessages(portNo)
    readyFile = sprintf("listener_ready_%d.txt", portNo);
    if exist(readyFile, 'file')
        fid = fopen(readyFile, 'w'); % Open in write mode to clear contents
        fclose(fid);
    end
end