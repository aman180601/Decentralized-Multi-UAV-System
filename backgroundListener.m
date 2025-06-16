% Function to initiate the background listener for given port
function backgroundListener(portNo)
    % Create UDP port for listening
    u = udpport("Datagram", "IPV4", "LocalPort", portNo);
    disp("Listening on port " + portNo + "...");

    % Create a ready file specific to this port
    readyFile = sprintf("listener_ready_%d.txt", portNo);
    fid = fopen(readyFile, 'w');
    fclose(fid);

    while true
        if u.NumDatagramsAvailable > 0
            datagram = read(u, 1, "uint8");
            data = char(datagram.Data(:)');
            fid = fopen(readyFile, 'a');
            fprintf(fid, "%s\n", data);
            fclose(fid);
            disp("Received on port " + portNo + ": " + data);
        end
        pause(0.05);
    end
end