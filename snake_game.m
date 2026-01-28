function snake_game()
%SNAKE_GAME Classic Snake game with Good and Bad Apples
%   Run this function to start the game.
%   Controls:
%       Arrow Keys - Change direction
%       Space/P    - Pause/Resume
%       Esc/Q      - Quit
%       R          - Restart (when game over)

%% ==================== GAME CONFIGURATION ====================
% Grid settings
gridSize = 20;           % 20x20 grid
cellSize = 25;           % pixels per cell

% Colors
colors = struct(...
    'background', [0.95, 0.95, 0.95], ...   % Light gray
    'gridLines', [0.85, 0.85, 0.85], ...    % Grid lines
    'snakeHead', [0.2, 0.6, 0.2], ...       % Dark green
    'snakeBody', [0.4, 0.8, 0.4], ...       % Light green
    'goodApple', [0.9, 0.2, 0.2], ...       % Red
    'badApple', [0.5, 0.1, 0.5], ...        % Purple
    'text', [0.2, 0.2, 0.2] ...             % Dark gray
    );

% Game speed (seconds between updates)
gameSpeed = 0.15;

%% ==================== GAME STATE VARIABLES ====================
snake = [];              % Nx2 matrix of [x, y] coordinates
direction = [1, 0];      % Current movement direction
nextDirection = [1, 0];  % Buffered direction for next frame
goodApple = [];          % [x, y] position
badApple = [];           % [x, y] position
score = 0;
isPaused = false;
isGameOver = false;

%% ==================== GRAPHICS HANDLES ====================
fig = [];
ax = [];
snakeHandles = [];       % Array of rectangle handles for snake
goodAppleHandle = [];
badAppleHandle = [];
pauseTextHandle = [];
gameOverTextHandle = [];
gameTimer = [];

%% ==================== INITIALIZATION ====================
initGame();

%% ==================== NESTED FUNCTIONS ====================

    function initGame()
        % Initialize or reset the game state
        
        % Reset state variables
        snake = [10, 10; 9, 10; 8, 10];  % Start at center, length 3, moving right
        direction = [1, 0];
        nextDirection = [1, 0];
        score = 0;
        isPaused = false;
        isGameOver = false;
        
        % Create figure if it doesn't exist
        if isempty(fig) || ~isvalid(fig)
            createFigure();
        end
        
        % Clear any existing graphics
        clearGraphics();
        
        % Spawn apples
        goodApple = spawnApple([]);
        badApple = spawnApple(goodApple);
        
        % Draw initial state
        drawGrid();
        updateGraphics();
        updateTitle();
        
        % Start timer
        if isempty(gameTimer) || ~isvalid(gameTimer)
            createTimer();
        end
        start(gameTimer);
    end

    function createFigure()
        % Create the game figure window
        figWidth = gridSize * cellSize + 50;
        figHeight = gridSize * cellSize + 50;
        
        fig = figure(...
            'Name', 'Snake Game - Score: 0', ...
            'NumberTitle', 'off', ...
            'MenuBar', 'none', ...
            'ToolBar', 'none', ...
            'Resize', 'off', ...
            'Position', [100, 100, figWidth, figHeight], ...
            'Color', colors.background, ...
            'KeyPressFcn', @keyPressCallback, ...
            'CloseRequestFcn', @closeGame);
        
        % Create axes
        ax = axes(fig, ...
            'Units', 'pixels', ...
            'Position', [25, 25, gridSize * cellSize, gridSize * cellSize], ...
            'XLim', [0, gridSize], ...
            'YLim', [0, gridSize], ...
            'XTick', [], ...
            'YTick', [], ...
            'Box', 'on', ...
            'Color', colors.background, ...
            'XColor', colors.gridLines, ...
            'YColor', colors.gridLines);
        hold(ax, 'on');
        axis(ax, 'equal');
    end

    function createTimer()
        % Create the game timer
        gameTimer = timer(...
            'ExecutionMode', 'fixedRate', ...
            'Period', gameSpeed, ...
            'TimerFcn', @gameLoop, ...
            'ErrorFcn', @timerError);
    end

    function drawGrid()
        % Draw grid lines
        for i = 0:gridSize
            line(ax, [i, i], [0, gridSize], 'Color', colors.gridLines, 'LineWidth', 0.5);
            line(ax, [0, gridSize], [i, i], 'Color', colors.gridLines, 'LineWidth', 0.5);
        end
    end

    function clearGraphics()
        % Clear all game graphics (but keep grid)
        if ~isempty(snakeHandles)
            delete(snakeHandles(isvalid(snakeHandles)));
            snakeHandles = [];
        end
        if ~isempty(goodAppleHandle) && isvalid(goodAppleHandle)
            delete(goodAppleHandle);
            goodAppleHandle = [];
        end
        if ~isempty(badAppleHandle) && isvalid(badAppleHandle)
            delete(badAppleHandle);
            badAppleHandle = [];
        end
        if ~isempty(pauseTextHandle) && isvalid(pauseTextHandle)
            delete(pauseTextHandle);
            pauseTextHandle = [];
        end
        if ~isempty(gameOverTextHandle) && isvalid(gameOverTextHandle)
            delete(gameOverTextHandle);
            gameOverTextHandle = [];
        end
        
        % Clear axes and redraw grid
        if ~isempty(ax) && isvalid(ax)
            cla(ax);
            hold(ax, 'on');
        end
    end

    function pos = spawnApple(excludePositions)
        % Spawn an apple at a random position not occupied by snake or excluded positions
        available = true(gridSize, gridSize);
        
        % Mark snake positions as unavailable
        for i = 1:size(snake, 1)
            if snake(i, 1) >= 1 && snake(i, 1) <= gridSize && ...
                    snake(i, 2) >= 1 && snake(i, 2) <= gridSize
                available(snake(i, 1), snake(i, 2)) = false;
            end
        end
        
        % Mark excluded positions (other apple)
        if ~isempty(excludePositions)
            for i = 1:size(excludePositions, 1)
                if excludePositions(i, 1) >= 1 && excludePositions(i, 1) <= gridSize && ...
                        excludePositions(i, 2) >= 1 && excludePositions(i, 2) <= gridSize
                    available(excludePositions(i, 1), excludePositions(i, 2)) = false;
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

    function result = checkCollision(head)
        % Check what the head collides with
        
        % Wall collision
        if head(1) < 1 || head(1) > gridSize || ...
                head(2) < 1 || head(2) > gridSize
            result = 'wall';
            return;
        end
        
        % Self collision (check against body, not head)
        for i = 2:size(snake, 1)
            if isequal(head, snake(i, :))
                result = 'self';
                return;
            end
        end
        
        % Apple collisions
        if ~isempty(goodApple) && isequal(head, goodApple)
            result = 'good';
        elseif ~isempty(badApple) && isequal(head, badApple)
            result = 'bad';
        else
            result = 'none';
        end
    end

    function gameLoop(~, ~)
        % Main game loop - called by timer
        if isPaused || isGameOver
            return;
        end
        
        % Apply buffered direction
        direction = nextDirection;
        
        % Calculate new head position
        newHead = snake(1, :) + direction;
        
        % Check collision
        collision = checkCollision(newHead);
        
        switch collision
            case 'wall'
                triggerGameOver('Wall collision!');
                return;
                
            case 'self'
                triggerGameOver('Self collision!');
                return;
                
            case 'good'
                % Grow snake (add new head, keep all body)
                snake = [newHead; snake];
                score = score + 1;
                
                % Respawn good apple
                goodApple = spawnApple(badApple);
                
                % Check win condition
                if isempty(goodApple)
                    triggerGameOver('You WIN! Grid full!');
                    return;
                end
                
            case 'bad'
                % Move and shrink snake
                if size(snake, 1) <= 2
                    % Snake would be too short
                    triggerGameOver('Snake too short!');
                    return;
                end
                % Remove tail segment (shrink by 1)
                snake = [newHead; snake(1:end-2, :)];
                
                % Respawn bad apple
                badApple = spawnApple(goodApple);
                
            case 'none'
                % Normal movement (add head, remove tail)
                snake = [newHead; snake(1:end-1, :)];
        end
        
        % Update display
        updateGraphics();
        updateTitle();
    end

    function updateGraphics()
        % Update all game graphics efficiently
        if isempty(ax) || ~isvalid(ax)
            return;
        end
        
        % Delete old snake handles
        if ~isempty(snakeHandles)
            delete(snakeHandles(isvalid(snakeHandles)));
        end
        snakeHandles = gobjects(size(snake, 1), 1);
        
        % Draw snake body (from tail to head)
        for i = size(snake, 1):-1:1
            x = snake(i, 1) - 1;  % Convert to 0-based for drawing
            y = snake(i, 2) - 1;
            
            if i == 1
                % Head - darker green
                snakeHandles(i) = rectangle(ax, ...
                    'Position', [x + 0.05, y + 0.05, 0.9, 0.9], ...
                    'FaceColor', colors.snakeHead, ...
                    'EdgeColor', 'none', ...
                    'Curvature', [0.2, 0.2]);
            else
                % Body - lighter green
                snakeHandles(i) = rectangle(ax, ...
                    'Position', [x + 0.1, y + 0.1, 0.8, 0.8], ...
                    'FaceColor', colors.snakeBody, ...
                    'EdgeColor', 'none', ...
                    'Curvature', [0.1, 0.1]);
            end
        end
        
        % Draw good apple (red circle)
        if ~isempty(goodApple)
            if ~isempty(goodAppleHandle) && isvalid(goodAppleHandle)
                delete(goodAppleHandle);
            end
            x = goodApple(1) - 1;
            y = goodApple(2) - 1;
            goodAppleHandle = rectangle(ax, ...
                'Position', [x + 0.15, y + 0.15, 0.7, 0.7], ...
                'FaceColor', colors.goodApple, ...
                'EdgeColor', [0.7, 0.1, 0.1], ...
                'LineWidth', 1.5, ...
                'Curvature', [1, 1]);
        end
        
        % Draw bad apple (purple circle)
        if ~isempty(badApple)
            if ~isempty(badAppleHandle) && isvalid(badAppleHandle)
                delete(badAppleHandle);
            end
            x = badApple(1) - 1;
            y = badApple(2) - 1;
            badAppleHandle = rectangle(ax, ...
                'Position', [x + 0.15, y + 0.15, 0.7, 0.7], ...
                'FaceColor', colors.badApple, ...
                'EdgeColor', [0.3, 0.05, 0.3], ...
                'LineWidth', 1.5, ...
                'Curvature', [1, 1]);
        end
        
        drawnow limitrate;
    end

    function updateTitle()
        % Update figure title with score
        if ~isempty(fig) && isvalid(fig)
            if isPaused
                fig.Name = sprintf('Snake Game - Score: %d [PAUSED]', score);
            elseif isGameOver
                fig.Name = sprintf('Snake Game - Score: %d [GAME OVER]', score);
            else
                fig.Name = sprintf('Snake Game - Score: %d', score);
            end
        end
    end

    function keyPressCallback(~, event)
        % Handle keyboard input
        switch event.Key
            case 'uparrow'
                % Can't go up if moving down
                if ~isequal(direction, [0, -1])
                    nextDirection = [0, 1];
                end
                
            case 'downarrow'
                % Can't go down if moving up
                if ~isequal(direction, [0, 1])
                    nextDirection = [0, -1];
                end
                
            case 'leftarrow'
                % Can't go left if moving right
                if ~isequal(direction, [1, 0])
                    nextDirection = [-1, 0];
                end
                
            case 'rightarrow'
                % Can't go right if moving left
                if ~isequal(direction, [-1, 0])
                    nextDirection = [1, 0];
                end
                
            case {'space', 'p'}
                togglePause();
                
            case {'escape', 'q'}
                closeGame();
                
            case 'r'
                if isGameOver
                    restartGame();
                end
        end
    end

    function togglePause()
        % Toggle pause state
        if isGameOver
            return;
        end
        
        isPaused = ~isPaused;
        
        if isPaused
            % Show pause text
            pauseTextHandle = text(ax, gridSize/2, gridSize/2, 'PAUSED', ...
                'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'middle', ...
                'FontSize', 24, ...
                'FontWeight', 'bold', ...
                'Color', colors.text, ...
                'BackgroundColor', [1, 1, 1, 0.8]);
        else
            % Remove pause text
            if ~isempty(pauseTextHandle) && isvalid(pauseTextHandle)
                delete(pauseTextHandle);
                pauseTextHandle = [];
            end
        end
        
        updateTitle();
    end

    function triggerGameOver(message)
        % Handle game over state
        isGameOver = true;
        
        if ~isempty(gameTimer) && isvalid(gameTimer)
            stop(gameTimer);
        end
        
        % Show game over text
        gameOverTextHandle = text(ax, gridSize/2, gridSize/2, ...
            {message, sprintf('Final Score: %d', score), 'Press R to Restart'}, ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'middle', ...
            'FontSize', 18, ...
            'FontWeight', 'bold', ...
            'Color', colors.text, ...
            'BackgroundColor', [1, 1, 1, 0.9]);
        
        updateTitle();
    end

    function restartGame()
        % Restart the game
        if ~isempty(gameTimer) && isvalid(gameTimer)
            stop(gameTimer);
        end
        initGame();
    end

    function closeGame(~, ~)
        % Clean up and close the game
        if ~isempty(gameTimer) && isvalid(gameTimer)
            stop(gameTimer);
            delete(gameTimer);
        end
        
        if ~isempty(fig) && isvalid(fig)
            delete(fig);
        end
    end

    function timerError(~, event)
        % Handle timer errors gracefully
        warning('Timer error: %s', event.Data.message);
    end

end
