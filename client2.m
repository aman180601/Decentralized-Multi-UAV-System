clc; clear;

% Global configuration
grid = [12 19 7 14 18 3 15 6 8 11 10 5;
        5 3 8 10 6 18 12 14 15 5 11 3;
        18 7 15 11 14 7 18 10 12 3 5 18;
        3 8 12 5 10 8 6 11 18 18 3 7;
        16 15 18 3 11 15 14 5 6 7 18 8;
        9 12 6 18 5 12 10 3 14 8 7 15;
        14 18 14 7 3 18 11 18 10 15 8 12;
        7 6 10 8 18 6 5 7 11 12 15 18;
        20 14 11 15 7 14 3 8 5 18 12 6;
        12 10 5 12 8 10 18 15 3 6 18 14;
        4 11 3 18 15 11 7 12 18 14 6 10;
        6 5 18 6 12 5 8 18 7 10 14 11;
        ];
threshold = 10;
minHeight = 3;
totalClients = 4;
buffer = 5;
speed = 2;
serverIP = 'localhost';
serverPort = 6000;

% Client configuration
clientID = 2; % A unique positive integer for each client
portNo = 6002;
ipAddress = "127.0.0.1";
clientsMap = containers.Map([1,3,4],{{6001,"127.0.0.1"},{6003,"127.0.0.1"},{6004,"127.0.0.1"}});
division = 'v';
mat = [2, 12, 1, 12]; % [x1, x2, y1, y2]
Xs = 1;
Ys = 2;
Zs = grid(Xs,Ys) + 1;
X = Xs;
Y = Ys;
Z = Zs;
maxHeight = max(minHeight -1, max(grid(:))) + 4 + clientID;
Xm = -1;
Ym = -1;
Zm = -1;

% Unique ready file for this client's listener
readyFile = sprintf("listener_ready_%d.txt", portNo);

% Remove old ready file (if exists) to avoid false detection
if exist(readyFile, 'file')
    delete(readyFile);
end

% Launch background listener
disp("Launching listener...");
cmd = sprintf('!matlab -nosplash -nodesktop -r "backgroundListener(%d)" &', portNo);
evalc(cmd);

% Setup UDP
u = udpport("Datagram", "IPV4");
disp("Client is running...");
pause(5);

% Send initial coordinates to server
message = sprintf('%d,%.2f,%.2f', clientID, X - 0.5, Y - 0.5);
write(u, uint8(message), serverIP, serverPort);
disp("Sent: " + message);
pause(1 / speed);

% Wait for this client's listener to create its ready file
timeout = max(40, (max(minHeight -1, max(grid(:))) + totalClients) / speed) + buffer; % Max wait time in seconds
tStart = tic;

% Move the client up
while Z ~= maxHeight
    Z = Z + 1;

    % Send coordinates to server
    message = sprintf('%d,%.2f,%.2f', clientID, X - 0.5, Y - 0.5);
    write(u, uint8(message), serverIP, serverPort);
    disp("Sent: " + message);
    pause(1 / speed);
end

while ~exist(readyFile, 'file')
    if toc(tStart) > timeout
        error("Listener did not start in time for Client " + clientID);
    end
    pause(1);
end

disp("Listener is now running for Client " + clientID + ". Sending messages...");

while  toc(tStart) < timeout
        pause(0.1);
end

initiate(grid, threshold, minHeight, totalClients, buffer, speed, serverIP, serverPort, clientID, portNo, ipAddress, clientsMap, division, mat, X, Y, Z, maxHeight, Xm, Ym, Zm, u, Xs, Ys, Zs);