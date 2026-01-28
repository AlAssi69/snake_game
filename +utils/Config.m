classdef Config
    %CONFIG Game configuration settings
    %   Central place for all game configuration values
    
    properties (Constant)
        % Grid settings
        GridSize = 20;           % 20x20 grid
        CellSize = 25;           % pixels per cell
        
        % Snake initial settings
        InitialSnakeLength = 3;
        InitialSnakePosition = [10, 10];  % Center of grid
        InitialDirection = [1, 0];        % Moving right
        
        % Speed settings
        BaseGameSpeed = 0.15;    % Base period in seconds (lower = faster)
        MinSpeedFactor = 0.5;    % Minimum speed multiplier (fastest)
        MaxSpeedFactor = 2.0;    % Maximum speed multiplier (slowest)
        SpeedStep = 0.1;         % Speed change per key press
        DefaultSpeedFactor = 1.0; % Starting speed factor
        
        % Bad apple timeout settings
        BadAppleMinTime = 3.0;   % Minimum time before disappearing (seconds)
        BadAppleMaxTime = 8.0;   % Maximum time before disappearing (seconds)
        BadAppleRespawnDelay = 1.0;  % Delay before respawning (seconds)
        
        % Game over conditions
        MinSnakeLength = 2;      % Game over if snake length drops below this
    end
    
    methods (Static)
        function speed = calculateTimerPeriod(speedFactor)
            %CALCULATETIMERPERIOD Calculate actual timer period from speed factor
            %   speedFactor < 1 = faster, speedFactor > 1 = slower
            speed = utils.Config.BaseGameSpeed * speedFactor;
        end
        
        function newFactor = increaseSpeed(currentFactor)
            %INCREASESPEED Decrease speed factor (make game faster)
            newFactor = max(utils.Config.MinSpeedFactor, ...
                currentFactor - utils.Config.SpeedStep);
        end
        
        function newFactor = decreaseSpeed(currentFactor)
            %DECREASESPEED Increase speed factor (make game slower)
            newFactor = min(utils.Config.MaxSpeedFactor, ...
                currentFactor + utils.Config.SpeedStep);
        end
    end
end