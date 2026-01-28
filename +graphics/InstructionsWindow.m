classdef InstructionsWindow < handle
    %INSTRUCTIONSWINDOW Persistent window showing game instructions
    %   Displays controls and game information in a separate figure
    
    properties (Access = private)
        Figure      % Figure handle
    end
    
    methods
        function obj = InstructionsWindow()
            %INSTRUCTIONSWINDOW Constructor
            obj.Figure = [];
        end
        
        function show(obj)
            %SHOW Create and display the instructions window
            if ~isempty(obj.Figure) && isvalid(obj.Figure)
                figure(obj.Figure);  % Bring to front
                return;
            end
            
            % Create figure - bigger size for better readability
            obj.Figure = figure(...
                'Name', 'Snake Game - Instructions', ...
                'NumberTitle', 'off', ...
                'MenuBar', 'none', ...
                'ToolBar', 'none', ...
                'Resize', 'on', ...
                'Position', [500, 100, 500, 700], ...
                'Color', [0.95, 0.95, 0.95], ...
                'CloseRequestFcn', @(~,~) obj.onCloseRequest());
            
            % Create panel for content
            panel = uipanel(obj.Figure, ...
                'Units', 'normalized', ...
                'Position', [0.05, 0.05, 0.9, 0.9], ...
                'BackgroundColor', [1, 1, 1], ...
                'BorderType', 'none');
            
            % Title
            uicontrol(panel, ...
                'Style', 'text', ...
                'Units', 'normalized', ...
                'Position', [0, 0.92, 1, 0.08], ...
                'String', 'SNAKE GAME - INSTRUCTIONS', ...
                'FontSize', 20, ...
                'FontWeight', 'bold', ...
                'BackgroundColor', [1, 1, 1], ...
                'ForegroundColor', [0.2, 0.5, 0.2]);
            
            % Instructions text
            instructions = {
                '--- OBJECTIVE ---'
                ''
                'Eat RED apples to grow and score.'
                'Avoid PURPLE apples (they shrink you).'
                'Don''t hit walls or yourself!'
                ''
                '--- CONTROLS ---'
                ''
                'Arrow Keys    Move snake'
                '+ / =         Speed up'
                '- / _         Slow down'
                'Space / P     Pause game'
                'Esc / Q       Quit game'
                'R             Restart (game over)'
                ''
                '--- GAME ELEMENTS ---'
                ''
                'Red Apple     +1 length, +1 score'
                'Purple Apple  -1 length (danger!)'
                ''
                'Purple apples disappear and'
                'reappear at random intervals.'
                ''
                '--- TIPS ---'
                ''
                'Plan your path ahead!'
                'Don''t get trapped by your tail.'
                'Adjust speed to your skill level.'
                ''
                '--- HOW TO PLAY ---'
                ''
                '1. Use arrow keys to control the snake direction'
                '2. Eat red apples to grow longer and increase score'
                '3. Avoid purple apples as they will shrink you'
                '4. The game ends if you hit a wall or yourself'
                '5. Adjust game speed with + and - keys'
                '6. Press Space or P to pause at any time'
                '7. Press R to restart after game over'
                ''
                'Close this window to start the game!'
                };
            
            % Create scrollable text area
            % Convert cell array to string with newlines
            instructionsText = strjoin(instructions, sprintf('\n'));
            
            % Create scrollable edit control
            % Setting Max=2 enables multiline mode and automatic scrolling
            % Enable must be 'on' for scrollbar to be interactive
            uicontrol(panel, ...
                'Style', 'edit', ...
                'Units', 'normalized', ...
                'Position', [0.05, 0.05, 0.9, 0.87], ...
                'String', instructionsText, ...
                'FontSize', 10, ...
                'FontName', 'Consolas', ...
                'HorizontalAlignment', 'left', ...
                'BackgroundColor', [1, 1, 1], ...
                'ForegroundColor', [0.2, 0.2, 0.2], ...
                'Max', 2, ...  % Enable multiline and scrolling (Max > Min)
                'Min', 0, ...
                'Enable', 'on');  % Must be 'on' for scrollbar to work
        end
        
        function onCloseRequest(obj)
            %ONCLOSEREQUEST Handle close request - allow uiwait to continue
            if ~isempty(obj.Figure) && isvalid(obj.Figure)
                uiresume(obj.Figure);  % Release uiwait
            end
            obj.close();
        end
        
        function close(obj)
            %CLOSE Close the instructions window
            if ~isempty(obj.Figure) && isvalid(obj.Figure)
                delete(obj.Figure);
            end
            obj.Figure = [];
        end
        
        function valid = isValid(obj)
            %ISVALID Check if window is still open
            valid = ~isempty(obj.Figure) && isvalid(obj.Figure);
        end
        
        function fig = getFigure(obj)
            %GETFIGURE Get the figure handle
            fig = obj.Figure;
        end
    end
end