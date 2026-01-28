classdef GameController < handle
    %GAMECONTROLLER Manages game lifecycle, timer, and input
    %   Coordinates between GameState and Renderer, handles all game control
    
    properties (Access = private)
        GameState               % Game state object
        Renderer                % Renderer object
        InstructionsWindow      % Instructions window object
        GameTimer               % Timer for game loop
    end
    
    methods
        function obj = GameController()
            %GAMECONTROLLER Constructor - initialize all components
            obj.GameState = game.GameState();
            obj.Renderer = graphics.Renderer();
            obj.InstructionsWindow = graphics.InstructionsWindow();
            obj.GameTimer = [];
        end
        
        function start(obj)
            %START Initialize and start the game
            obj.Renderer.createWindow(...
                @obj.onKeyPress, ...
                @obj.onClose, ...
                @obj.togglePause);
            obj.InstructionsWindow.show();
            obj.createTimer();
            obj.Renderer.render(obj.GameState);
            start(obj.GameTimer);
        end
        
        function delete(obj)
            %DELETE Destructor - clean up resources
            obj.cleanup();
        end
    end
    
    methods (Access = private)
        %% Timer Management
        
        function createTimer(obj)
            %CREATETIMER Create the game timer
            if ~isempty(obj.GameTimer) && isvalid(obj.GameTimer)
                stop(obj.GameTimer);
                delete(obj.GameTimer);
            end
            
            obj.GameTimer = timer(...
                'ExecutionMode', 'fixedRate', ...
                'Period', obj.GameState.TimerPeriod, ...
                'TimerFcn', @obj.onGameLoop, ...
                'ErrorFcn', @obj.onTimerError);
        end
        
        function updateTimerSpeed(obj)
            %UPDATETIMERSPEED Update timer period when speed changes
            if ~isempty(obj.GameTimer) && isvalid(obj.GameTimer)
                wasRunning = strcmp(obj.GameTimer.Running, 'on');
                if wasRunning
                    stop(obj.GameTimer);
                end
                obj.GameTimer.Period = obj.GameState.TimerPeriod;
                if wasRunning && ~obj.GameState.IsPaused && ~obj.GameState.IsGameOver
                    start(obj.GameTimer);
                end
            end
        end
        
        function stopTimer(obj)
            %STOPTIMER Stop the game timer
            if ~isempty(obj.GameTimer) && isvalid(obj.GameTimer)
                stop(obj.GameTimer);
            end
        end
        
        function startTimer(obj)
            %STARTTIMER Start the game timer
            if ~isempty(obj.GameTimer) && isvalid(obj.GameTimer)
                start(obj.GameTimer);
            end
        end
        
        %% Game Loop
        
        function onGameLoop(obj, ~, ~)
            %ONGAMELOOP Main game loop - called by timer
            if ~obj.Renderer.isValid()
                obj.cleanup();
                return;
            end
            
            if obj.GameState.IsPaused || obj.GameState.IsGameOver
                return;
            end
            
            % Store previous game over state
            wasGameOver = obj.GameState.IsGameOver;
            
            % Update game state
            obj.GameState.update();
            
            % Check if game just ended
            if obj.GameState.IsGameOver && ~wasGameOver
                obj.handleGameOver();
                return;
            end
            
            % Render current state
            obj.Renderer.render(obj.GameState);
        end
        
        function handleGameOver(obj)
            %HANDLEGAMEOVER Handle game over state
            obj.stopTimer();
            obj.Renderer.render(obj.GameState);
            obj.Renderer.showGameOverOverlay(...
                obj.GameState.GameOverMessage, ...
                obj.GameState.Score, ...
                obj.GameState.HighScore);
        end
        
        %% Input Handling
        
        function onKeyPress(obj, ~, event)
            %ONKEYPRESS Handle keyboard input
            switch event.Key
                % Direction controls
                case 'uparrow'
                    obj.GameState.trySetDirection([0, 1]);
                    
                case 'downarrow'
                    obj.GameState.trySetDirection([0, -1]);
                    
                case 'leftarrow'
                    obj.GameState.trySetDirection([-1, 0]);
                    
                case 'rightarrow'
                    obj.GameState.trySetDirection([1, 0]);
                    
                    % Speed controls
                case {'equal', 'add'}  % + key
                    obj.GameState.increaseSpeed();
                    obj.updateTimerSpeed();
                    obj.Renderer.updateTitle(obj.GameState);
                    
                case {'hyphen', 'subtract'}  % - key
                    obj.GameState.decreaseSpeed();
                    obj.updateTimerSpeed();
                    obj.Renderer.updateTitle(obj.GameState);
                    
                    % Pause
                case {'space', 'p'}
                    obj.togglePause();
                    
                    % Quit
                case {'escape', 'q'}
                    obj.cleanup();
                    
                    % Restart
                case 'r'
                    if obj.GameState.IsGameOver
                        obj.restartGame();
                    end
            end
        end
        
        %% Game Control
        
        function togglePause(obj, ~, ~)
            %TOGGLEPAUSE Toggle pause state
            if obj.GameState.IsGameOver
                return;
            end
            
            obj.GameState.togglePause();
            
            if obj.GameState.IsPaused
                obj.stopTimer();
                obj.Renderer.showPauseOverlay();
            else
                obj.Renderer.hidePauseOverlay();
                obj.startTimer();
            end
            
            obj.Renderer.updatePauseButton(obj.GameState.IsPaused);
            obj.Renderer.updateTitle(obj.GameState);
        end
        
        function restartGame(obj)
            %RESTARTGAME Restart the game
            obj.stopTimer();
            obj.GameState.reset();
            obj.Renderer.clearAll();
            obj.createTimer();
            obj.Renderer.render(obj.GameState);
            obj.startTimer();
        end
        
        %% Cleanup
        
        function onClose(obj, ~, ~)
            %ONCLOSE Handle window close request
            obj.cleanup();
        end
        
        function cleanup(obj)
            %CLEANUP Clean up all resources
            if ~isempty(obj.GameTimer) && isvalid(obj.GameTimer)
                stop(obj.GameTimer);
                delete(obj.GameTimer);
                obj.GameTimer = [];
            end
            
            obj.Renderer.close();
            obj.InstructionsWindow.close();
        end
        
        function onTimerError(~, ~, event)
            %ONTIMERERROR Handle timer errors gracefully
            warning('Timer error: %s', event.Data.message);
        end
    end
end