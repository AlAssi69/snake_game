classdef Renderer < handle
    %RENDERER Handles all game visualization
    %   Manages figure, axes, and all game graphics
    
    properties (Access = private)
        Figure              % Figure handle
        Axes                % Axes handle
        SnakeHandles        % Array of rectangle handles for snake
        GoodAppleHandle     % Handle for good apple
        BadAppleHandle      % Handle for bad apple
        PauseTextHandle     % Handle for pause overlay
        GameOverTextHandle  % Handle for game over overlay
        GridSize            % Size of the grid
        CellSize            % Size of each cell in pixels
    end
    
    methods
        function obj = Renderer()
            %RENDERER Constructor
            obj.GridSize = utils.Config.GridSize;
            obj.CellSize = utils.Config.CellSize;
            obj.SnakeHandles = [];
        end
        
        function createWindow(obj, keyPressCallback, closeCallback)
            %CREATEWINDOW Create the game window
            figWidth = obj.GridSize * obj.CellSize + 50;
            figHeight = obj.GridSize * obj.CellSize + 50;
            
            obj.Figure = figure(...
                'Name', 'Snake Game - Score: 0', ...
                'NumberTitle', 'off', ...
                'MenuBar', 'none', ...
                'ToolBar', 'none', ...
                'Resize', 'off', ...
                'Position', [100, 100, figWidth, figHeight], ...
                'Color', graphics.Colors.Background, ...
                'KeyPressFcn', keyPressCallback, ...
                'CloseRequestFcn', closeCallback);
            
            % Create axes
            obj.Axes = axes(obj.Figure, ...
                'Units', 'pixels', ...
                'Position', [25, 25, obj.GridSize * obj.CellSize, obj.GridSize * obj.CellSize], ...
                'XLim', [0, obj.GridSize], ...
                'YLim', [0, obj.GridSize], ...
                'XTick', [], ...
                'YTick', [], ...
                'Box', 'on', ...
                'Color', graphics.Colors.Background, ...
                'XColor', graphics.Colors.GridLines, ...
                'YColor', graphics.Colors.GridLines);
            hold(obj.Axes, 'on');
            axis(obj.Axes, 'equal');
            
            % Draw grid
            obj.drawGrid();
        end
        
        function drawGrid(obj)
            %DRAWGRID Draw grid lines
            for i = 0:obj.GridSize
                line(obj.Axes, [i, i], [0, obj.GridSize], ...
                    'Color', graphics.Colors.GridLines, 'LineWidth', 0.5);
                line(obj.Axes, [0, obj.GridSize], [i, i], ...
                    'Color', graphics.Colors.GridLines, 'LineWidth', 0.5);
            end
        end
        
        function render(obj, gameState)
            %RENDER Render the current game state
            if ~obj.isValid()
                return;
            end
            
            obj.renderSnake(gameState.Snake);
            obj.renderGoodApple(gameState.GoodApple);
            obj.renderBadApple(gameState.BadApple);
            obj.updateTitle(gameState);
            
            drawnow limitrate;
        end
        
        function renderSnake(obj, snake)
            %RENDERSNAKE Render the snake
            % Delete old handles
            if ~isempty(obj.SnakeHandles)
                delete(obj.SnakeHandles(isvalid(obj.SnakeHandles)));
            end
            
            segments = snake.getPositions();
            obj.SnakeHandles = gobjects(size(segments, 1), 1);
            
            % Draw from tail to head (so head is on top)
            for i = size(segments, 1):-1:1
                x = segments(i, 1) - 1;  % Convert to 0-based for drawing
                y = segments(i, 2) - 1;
                
                if i == 1
                    % Head - darker, slightly larger
                    obj.SnakeHandles(i) = rectangle(obj.Axes, ...
                        'Position', [x + 0.05, y + 0.05, 0.9, 0.9], ...
                        'FaceColor', graphics.Colors.SnakeHead, ...
                        'EdgeColor', 'none', ...
                        'Curvature', [0.2, 0.2]);
                else
                    % Body - lighter, slightly smaller
                    obj.SnakeHandles(i) = rectangle(obj.Axes, ...
                        'Position', [x + 0.1, y + 0.1, 0.8, 0.8], ...
                        'FaceColor', graphics.Colors.SnakeBody, ...
                        'EdgeColor', 'none', ...
                        'Curvature', [0.1, 0.1]);
                end
            end
        end
        
        function renderGoodApple(obj, position)
            %RENDERGOODAPPLE Render the good apple
            if ~isempty(obj.GoodAppleHandle) && isvalid(obj.GoodAppleHandle)
                delete(obj.GoodAppleHandle);
                obj.GoodAppleHandle = [];
            end
            
            if isempty(position)
                return;
            end
            
            x = position(1) - 1;
            y = position(2) - 1;
            obj.GoodAppleHandle = rectangle(obj.Axes, ...
                'Position', [x + 0.15, y + 0.15, 0.7, 0.7], ...
                'FaceColor', graphics.Colors.GoodApple, ...
                'EdgeColor', graphics.Colors.GoodAppleEdge, ...
                'LineWidth', 1.5, ...
                'Curvature', [1, 1]);
        end
        
        function renderBadApple(obj, position)
            %RENDERBADAPPLE Render the bad apple
            if ~isempty(obj.BadAppleHandle) && isvalid(obj.BadAppleHandle)
                delete(obj.BadAppleHandle);
                obj.BadAppleHandle = [];
            end
            
            if isempty(position)
                return;
            end
            
            x = position(1) - 1;
            y = position(2) - 1;
            obj.BadAppleHandle = rectangle(obj.Axes, ...
                'Position', [x + 0.15, y + 0.15, 0.7, 0.7], ...
                'FaceColor', graphics.Colors.BadApple, ...
                'EdgeColor', graphics.Colors.BadAppleEdge, ...
                'LineWidth', 1.5, ...
                'Curvature', [1, 1]);
        end
        
        function showPauseOverlay(obj)
            %SHOWPAUSEOVERLAY Show pause text
            if ~isempty(obj.PauseTextHandle) && isvalid(obj.PauseTextHandle)
                return;  % Already showing
            end
            
            obj.PauseTextHandle = text(obj.Axes, ...
                obj.GridSize/2, obj.GridSize/2, 'PAUSED', ...
                'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'middle', ...
                'FontSize', 24, ...
                'FontWeight', 'bold', ...
                'Color', graphics.Colors.Text, ...
                'BackgroundColor', graphics.Colors.OverlayBackground);
        end
        
        function hidePauseOverlay(obj)
            %HIDEPAUSEOVERLAY Hide pause text
            if ~isempty(obj.PauseTextHandle) && isvalid(obj.PauseTextHandle)
                delete(obj.PauseTextHandle);
                obj.PauseTextHandle = [];
            end
        end
        
        function showGameOverOverlay(obj, message, score)
            %SHOWGAMEOVEROVERLAY Show game over text
            if ~isempty(obj.GameOverTextHandle) && isvalid(obj.GameOverTextHandle)
                delete(obj.GameOverTextHandle);
            end
            
            obj.GameOverTextHandle = text(obj.Axes, ...
                obj.GridSize/2, obj.GridSize/2, ...
                {message, sprintf('Final Score: %d', score), '', 'Press R to Restart'}, ...
                'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'middle', ...
                'FontSize', 18, ...
                'FontWeight', 'bold', ...
                'Color', graphics.Colors.Text, ...
                'BackgroundColor', graphics.Colors.OverlayBackground);
        end
        
        function updateTitle(obj, gameState)
            %UPDATETITLE Update figure title
            if ~obj.isValid()
                return;
            end
            
            speedPercent = round(100 / gameState.SpeedFactor);
            
            if gameState.IsPaused
                status = '[PAUSED]';
            elseif gameState.IsGameOver
                status = '[GAME OVER]';
            else
                status = '';
            end
            
            obj.Figure.Name = sprintf('Snake Game - Score: %d | Speed: %d%% %s', ...
                gameState.Score, speedPercent, status);
        end
        
        function clearOverlays(obj)
            %CLEAROVERLAYS Remove all overlay text
            obj.hidePauseOverlay();
            if ~isempty(obj.GameOverTextHandle) && isvalid(obj.GameOverTextHandle)
                delete(obj.GameOverTextHandle);
                obj.GameOverTextHandle = [];
            end
        end
        
        function clearAll(obj)
            %CLEARALL Clear all graphics for restart
            obj.clearOverlays();
            
            if ~isempty(obj.SnakeHandles)
                delete(obj.SnakeHandles(isvalid(obj.SnakeHandles)));
                obj.SnakeHandles = [];
            end
            if ~isempty(obj.GoodAppleHandle) && isvalid(obj.GoodAppleHandle)
                delete(obj.GoodAppleHandle);
                obj.GoodAppleHandle = [];
            end
            if ~isempty(obj.BadAppleHandle) && isvalid(obj.BadAppleHandle)
                delete(obj.BadAppleHandle);
                obj.BadAppleHandle = [];
            end
            
            if ~isempty(obj.Axes) && isvalid(obj.Axes)
                cla(obj.Axes);
                hold(obj.Axes, 'on');
                obj.drawGrid();
            end
        end
        
        function valid = isValid(obj)
            %ISVALID Check if figure and axes are still valid
            valid = ~isempty(obj.Figure) && isvalid(obj.Figure) && ...
                ~isempty(obj.Axes) && isvalid(obj.Axes);
        end
        
        function close(obj)
            %CLOSE Close the figure
            if ~isempty(obj.Figure) && isvalid(obj.Figure)
                delete(obj.Figure);
            end
        end
    end
end