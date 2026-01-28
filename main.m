function main()
%MAIN Snake Game - Main Entry Point
%   Run this function to start the game.
%
%   Controls:
%       Arrow Keys  - Change direction
%       +/=         - Increase speed (faster)
%       -/_         - Decrease speed (slower)
%       Space/P     - Pause/Resume
%       Esc/Q       - Quit
%       R           - Restart (when game over)
%
%   Features:
%       - Good Apple (red): Eat to grow and score points
%       - Bad Apple (purple): Eat to shrink (game over if too short)
%       - Bad apples disappear and reappear randomly
%       - Adjustable game speed

clc;
clear;
close all;

%% Initialize game components
gameState = game.GameState();
renderer = graphics.Renderer();
gameTimer = [];

%% Start game
startGame();

%% ==================== HELPER FUNCTIONS ====================

    function startGame()
        % Initialize and start the game
        renderer.createWindow(@keyPressCallback, @closeGame);
        createTimer();
        renderer.render(gameState);
        start(gameTimer);
    end

    function createTimer()
        % Create the game timer
        if ~isempty(gameTimer) && isvalid(gameTimer)
            stop(gameTimer);
            delete(gameTimer);
        end
        
        gameTimer = timer(...
            'ExecutionMode', 'fixedRate', ...
            'Period', gameState.TimerPeriod, ...
            'TimerFcn', @gameLoop, ...
            'ErrorFcn', @timerError);
    end

    function updateTimerSpeed()
        % Update timer period when speed changes
        if ~isempty(gameTimer) && isvalid(gameTimer)
            wasRunning = strcmp(gameTimer.Running, 'on');
            if wasRunning
                stop(gameTimer);
            end
            gameTimer.Period = gameState.TimerPeriod;
            if wasRunning && ~gameState.IsPaused && ~gameState.IsGameOver
                start(gameTimer);
            end
        end
    end

    function gameLoop(~, ~)
        % Main game loop - called by timer
        if ~renderer.isValid()
            closeGame();
            return;
        end
        
        if gameState.IsPaused || gameState.IsGameOver
            return;
        end
        
        % Store previous game over state
        wasGameOver = gameState.IsGameOver;
        
        % Update game state
        gameState.update();
        
        % Check if game just ended
        if gameState.IsGameOver && ~wasGameOver
            handleGameOver();
            return;
        end
        
        % Render current state
        renderer.render(gameState);
    end

    function handleGameOver()
        % Handle game over
        if ~isempty(gameTimer) && isvalid(gameTimer)
            stop(gameTimer);
        end
        renderer.render(gameState);
        renderer.showGameOverOverlay(gameState.GameOverMessage, gameState.Score);
    end

    function keyPressCallback(~, event)
        % Handle keyboard input
        switch event.Key
            % Direction controls
            case 'uparrow'
                gameState.trySetDirection([0, 1]);
                
            case 'downarrow'
                gameState.trySetDirection([0, -1]);
                
            case 'leftarrow'
                gameState.trySetDirection([-1, 0]);
                
            case 'rightarrow'
                gameState.trySetDirection([1, 0]);
                
                % Speed controls
            case {'equal', 'add'}  % + key (= on main keyboard, + on numpad)
                gameState.increaseSpeed();
                updateTimerSpeed();
                renderer.updateTitle(gameState);
                
            case {'hyphen', 'subtract'}  % - key
                gameState.decreaseSpeed();
                updateTimerSpeed();
                renderer.updateTitle(gameState);
                
                % Pause
            case {'space', 'p'}
                togglePause();
                
                % Quit
            case {'escape', 'q'}
                closeGame();
                
                % Restart
            case 'r'
                if gameState.IsGameOver
                    restartGame();
                end
        end
    end

    function togglePause()
        % Toggle pause state
        if gameState.IsGameOver
            return;
        end
        
        gameState.togglePause();
        
        if gameState.IsPaused
            if ~isempty(gameTimer) && isvalid(gameTimer)
                stop(gameTimer);
            end
            renderer.showPauseOverlay();
        else
            renderer.hidePauseOverlay();
            if ~isempty(gameTimer) && isvalid(gameTimer)
                start(gameTimer);
            end
        end
        
        renderer.updateTitle(gameState);
    end

    function restartGame()
        % Restart the game
        if ~isempty(gameTimer) && isvalid(gameTimer)
            stop(gameTimer);
        end
        
        gameState.reset();
        renderer.clearAll();
        createTimer();
        renderer.render(gameState);
        start(gameTimer);
    end

    function closeGame(~, ~)
        % Clean up and close the game
        if ~isempty(gameTimer) && isvalid(gameTimer)
            stop(gameTimer);
            delete(gameTimer);
        end
        
        renderer.close();
    end

    function timerError(~, event)
        % Handle timer errors gracefully
        warning('Timer error: %s', event.Data.message);
    end

end
