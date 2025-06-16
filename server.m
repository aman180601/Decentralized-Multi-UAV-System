function server()
        clc; clear;
    
    % UDP receiver settings
    serverPort = 6000;
    u = udpport("Datagram", "IPV4", "LocalPort", serverPort);
    
    % Figure setup
    figure;
    hold on;
    grid on;
    xlim([0, 12]);
    ylim([0, 12]);
    xlabel('X Coordinate');
    ylabel('Y Coordinate');
    title('Real-time Client Position Tracking');
    
    xticks(0:1:12);
    yticks(0:1:12);
    ax = gca;
    ax.GridAlpha = 0.5; % Grid line transparency
    ax.GridLineStyle = '--'; % Solid grid lines
    ax.XColor = [0.5 0.5 0.5]; % Gray grid lines
    ax.YColor = [0.5 0.5 0.5];
    
    % Initialize markers for two clients
    client1_plot = text(NaN, NaN, '1', 'FontSize', 10, 'Color', 'r', 'FontWeight', 'bold');
    client2_plot = text(NaN, NaN, '2', 'FontSize', 10, 'Color', 'b', 'FontWeight', 'bold');
    client3_plot = text(NaN, NaN, '3', 'FontSize', 10, 'Color', 'g', 'FontWeight', 'bold');
    client4_plot = text(NaN, NaN, '4', 'FontSize', 10, 'Color', 'm', 'FontWeight', 'bold');
    
    % Storage for client coordinates
    client_positions = containers.Map('KeyType', 'int32', 'ValueType', 'any');
    
    % Persistent map to store patch handles per grid cell
    persistent cellPatches;
    if isempty(cellPatches)
        cellPatches = containers.Map;
    end
    
    disp("Server is running...");
    
    while true
        % Check if data is available
        if u.NumDatagramsAvailable > 0
            % Read **one** datagram at a time
            datagram = read(u, 1, "uint8");
    
            % Convert received data safely
            data = char(datagram.Data(:)');  % Ensure row vector
    
            % Debugging: Print raw received data
            fprintf("Raw Data Received: %s\n", data);
    
            % Parse message
            tokens = strsplit(strtrim(data), ',');  % Trim spaces/newlines
            if numel(tokens) == 3
                clientID = str2double(tokens{1});
                x = str2double(tokens{3});
                y = str2double(tokens{2});
    
                fprintf('Received from Client %d: (%.2f, %.2f)\n', clientID, x, y);
    
                % Store new position
                client_positions(int32(clientID)) = [x, y];
    
                % Determine grid cell (round to nearest lower integer)
                cellX = floor(x);
                cellY = floor(y);
    
                % Unique key for the grid cell
                cellKey = sprintf('%d_%d', cellX, cellY);
    
                % Choose color based on client ID
                switch clientID
                    case 1, cellColor = [1, 0.8, 0.8]; % Light red
                    case 2, cellColor = [0.8, 0.8, 1]; % Light blue
                    case 3, cellColor = [0.8, 1, 0.8]; % Light green
                    case 4, cellColor = [1, 0.8, 1];   % Light magenta
                    otherwise, cellColor = [1, 1, 1];  % Fallback to white (not really used)
                end
    
                % Update the patch color if it exists, otherwise create it
                if isKey(cellPatches, cellKey)
                    h = cellPatches(cellKey);
                    if isgraphics(h, 'patch')  % Check if it's a valid patch object
                        set(h, 'FaceColor', cellColor);
                    else
                        xPatch = [cellX, cellX+1, cellX+1, cellX];
                        yPatch = [cellY, cellY,   cellY+1, cellY+1];
                        patchHandle = patch(xPatch, yPatch, cellColor, ...
                                            'EdgeColor', 'none', ...
                                            'FaceAlpha', 0.4);
                        uistack(patchHandle, 'bottom');
                        cellPatches(cellKey) = patchHandle;
                    end
                else
                    xPatch = [cellX, cellX+1, cellX+1, cellX];
                    yPatch = [cellY, cellY,   cellY+1, cellY+1];
                    patchHandle = patch(xPatch, yPatch, cellColor, ...
                                        'EdgeColor', 'none', ...
                                        'FaceAlpha', 0.4);
                    uistack(patchHandle, 'bottom');
                    cellPatches(cellKey) = patchHandle;
                end
    
                % Update plot
                if clientID == 1
                    set(client1_plot, 'Position', [x, y]);
                elseif clientID == 2
                    set(client2_plot, 'Position', [x, y]);
                elseif clientID == 3
                    set(client3_plot, 'Position', [x, y]);
                elseif clientID == 4
                    set(client4_plot, 'Position', [x, y]);
                end
    
                drawnow; % Refresh plot
            else
                warning("Invalid data format: %s", data);
            end
        end
        pause(0.05); % Prevent CPU overload
    end

end