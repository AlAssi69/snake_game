classdef GameState < handle
    %GAMESTATE Manages overall game state
    %   Handles game logic, score, speed, and apple management
    
    properties
        Snake               % Snake object
        GoodApple           % [x, y] position of good apple
        BadApple            % [x, y] position of bad apple (empty if hidden)
        Score               % Current score
        HighScore           % Highest score this session
        SpeedFactor         % Current speed factor (1.0 = normal)
        IsPaused            % Whether game is paused
        IsGameOver          % Whether game has ended
        GameOverMessage     % Message to display on game over
        
        % Bad apple timing
        BadAppleSpawnTime   % Time when bad apple was spawned
        BadAppleTimeout     % How long until bad apple disappears
        BadAppleHidden      % Whether bad apple is currently hidden
        BadAppleHideTime    % Time when bad apple was hidden
    end
    
    properties (Dependent)
        GridSize            % Grid size from config
        TimerPeriod         % Current timer period based on speed
    end
    
    events
        StateChanged        % Fired when game state changes
        SpeedChanged        % Fired when speed factor changes
    end
    
    methods
        function obj = GameState()
            %GAMESTATE Constructor
            obj.Snake = game.Snake();
            obj.HighScore = 0;
            obj.reset();
        end
        
        function reset(obj)
            %RESET Reset game to initial state
            obj.Snake.reset();
            obj.Score = 0;
            % Note: HighScore is NOT reset - it persists across games
            obj.SpeedFactor = utils.Config.DefaultSpeedFactor;
            obj.IsPaused = false;
            obj.IsGameOver = false;
            obj.GameOverMessage = '';
            
            % Spawn apples
            obj.GoodApple = utils.AppleSpawner.spawn(...
                obj.Snake.getPositions(), [], obj.GridSize);
            obj.spawnBadApple();
        end
        
        function gridSize = get.GridSize(obj) %#ok<MANU>
            %GET.GRIDSIZE Get grid size from config
            gridSize = utils.Config.GridSize;
        end
        
        function period = get.TimerPeriod(obj)
            %GET.TIMERPERIOD Get current timer period
            period = utils.Config.calculateTimerPeriod(obj.SpeedFactor);
        end
        
        function spawnBadApple(obj)
            %SPAWNBADAPPLE Spawn a new bad apple with timeout
            obj.BadApple = utils.AppleSpawner.spawn(...
                obj.Snake.getPositions(), obj.GoodApple, obj.GridSize);
            obj.BadAppleSpawnTime = tic;
            obj.BadAppleTimeout = utils.AppleSpawner.generateBadAppleTimeout();
            obj.BadAppleHidden = false;
        end
        
        function hideBadApple(obj)
            %HIDEBADAPPLE Hide the bad apple temporarily
            obj.BadApple = [];
            obj.BadAppleHidden = true;
            obj.BadAppleHideTime = tic;
        end
        
        function update(obj)
            %UPDATE Main game update - called each frame
            if obj.IsPaused || obj.IsGameOver
                return;
            end
            
            % Check bad apple timeout
            obj.updateBadAppleTimer();
            
            % Calculate new head position
            newHead = obj.Snake.Head + obj.Snake.NextDirection;
            
            % Check collision
            collision = game.CollisionDetector.check(...
                newHead, obj.Snake, obj.GoodApple, obj.BadApple, obj.GridSize);
            
            switch collision
                case 'wall'
                    obj.triggerGameOver('Wall collision!');
                    return;
                    
                case 'self'
                    obj.triggerGameOver('Self collision!');
                    return;
                    
                case 'good'
                    obj.handleGoodApple();
                    
                case 'bad'
                    obj.handleBadApple();
                    
                case 'none'
                    obj.Snake.move();
            end
        end
        
        function updateBadAppleTimer(obj)
            %UPDATEBADAPPLETIMER Check and handle bad apple timing
            if obj.BadAppleHidden
                % Check if it's time to respawn
                elapsed = toc(obj.BadAppleHideTime);
                if elapsed >= utils.Config.BadAppleRespawnDelay
                    obj.spawnBadApple();
                end
            else
                % Check if it's time to hide
                if ~isempty(obj.BadApple)
                    elapsed = toc(obj.BadAppleSpawnTime);
                    if elapsed >= obj.BadAppleTimeout
                        obj.hideBadApple();
                    end
                end
            end
        end
        
        function handleGoodApple(obj)
            %HANDLEGOODAPPLE Handle eating a good apple
            obj.Snake.moveAndGrow();
            obj.Score = obj.Score + 1;
            
            % Update high score if needed
            if obj.Score > obj.HighScore
                obj.HighScore = obj.Score;
            end
            
            % Respawn good apple
            excludePositions = obj.BadApple;
            obj.GoodApple = utils.AppleSpawner.spawn(...
                obj.Snake.getPositions(), excludePositions, obj.GridSize);
            
            % Check win condition
            if isempty(obj.GoodApple)
                obj.triggerGameOver('You WIN! Grid full!');
            end
        end
        
        function handleBadApple(obj)
            %HANDLEBADAPPLE Handle eating a bad apple
            minLength = utils.Config.MinSnakeLength;
            
            if obj.Snake.Length <= minLength
                obj.triggerGameOver('Snake too short!');
                return;
            end
            
            obj.Snake.moveAndShrink();
            
            % Respawn bad apple at new location
            obj.spawnBadApple();
        end
        
        function triggerGameOver(obj, message)
            %TRIGGERGAMEOVER End the game
            obj.IsGameOver = true;
            obj.GameOverMessage = message;
        end
        
        function togglePause(obj)
            %TOGGLEPAUSE Toggle pause state
            if obj.IsGameOver
                return;
            end
            obj.IsPaused = ~obj.IsPaused;
        end
        
        function increaseSpeed(obj)
            %INCREASESPEED Make game faster
            oldFactor = obj.SpeedFactor;
            obj.SpeedFactor = utils.Config.increaseSpeed(obj.SpeedFactor);
            if oldFactor ~= obj.SpeedFactor
                notify(obj, 'SpeedChanged');
            end
        end
        
        function decreaseSpeed(obj)
            %DECREASESPEED Make game slower
            oldFactor = obj.SpeedFactor;
            obj.SpeedFactor = utils.Config.decreaseSpeed(obj.SpeedFactor);
            if oldFactor ~= obj.SpeedFactor
                notify(obj, 'SpeedChanged');
            end
        end
        
        function success = trySetDirection(obj, newDirection)
            %TRYSETDIRECTION Attempt to change snake direction
            success = obj.Snake.trySetDirection(newDirection);
        end
    end
end