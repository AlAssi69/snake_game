classdef AppleSpawner
    %APPLESPAWNER Handles apple spawning logic
    %   Provides safe spawning that avoids snake and other apples
    
    methods (Static)
        function pos = spawn(snakePositions, excludePositions, gridSize)
            %SPAWN Spawn an apple at a random safe position
            %   snakePositions - Nx2 matrix of snake segment positions
            %   excludePositions - Mx2 matrix of positions to avoid (other apples)
            %   gridSize - Size of the grid
            %   Returns [x, y] position or empty if grid is full
            
            available = true(gridSize, gridSize);
            
            % Mark snake positions as unavailable
            for i = 1:size(snakePositions, 1)
                x = snakePositions(i, 1);
                y = snakePositions(i, 2);
                if x >= 1 && x <= gridSize && y >= 1 && y <= gridSize
                    available(x, y) = false;
                end
            end
            
            % Mark excluded positions (other apples)
            if ~isempty(excludePositions)
                for i = 1:size(excludePositions, 1)
                    x = excludePositions(i, 1);
                    y = excludePositions(i, 2);
                    if x >= 1 && x <= gridSize && y >= 1 && y <= gridSize
                        available(x, y) = false;
                    end
                end
            end
            
            % Find available positions
            [rows, cols] = find(available);
            if isempty(rows)
                pos = [];  % Grid full - win condition
                return;
            end
            
            idx = randi(length(rows));
            pos = [rows(idx), cols(idx)];
        end
        
        function timeout = generateBadAppleTimeout()
            %GENERATEBADAPPLETIMEOUT Generate random timeout for bad apple
            %   Returns time in seconds before the bad apple should disappear
            minTime = utils.Config.BadAppleMinTime;
            maxTime = utils.Config.BadAppleMaxTime;
            timeout = minTime + (maxTime - minTime) * rand();
        end
    end
end