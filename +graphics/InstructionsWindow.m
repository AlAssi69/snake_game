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
            
            % Create figure
            obj.Figure = figure(...
                'Name', 'Snake Game - Instructions', ...
                'NumberTitle', 'off', ...
                'MenuBar', 'none', ...
                'ToolBar', 'none', ...
                'Resize', 'off', ...
                'Position', [650, 100, 320, 450], ...
                'Color', [0.95, 0.95, 0.95]);
            
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
                'Position', [0, 0.88, 1, 0.1], ...
                'String', 'SNAKE GAME', ...
                'FontSize', 18, ...
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
            };
            
            uicontrol(panel, ...
                'Style', 'text', ...
                'Units', 'normalized', ...
                'Position', [0.05, 0.02, 0.9, 0.85], ...
                'String', instructions, ...
                'FontSize', 9, ...
                'FontName', 'Consolas', ...
                'HorizontalAlignment', 'left', ...
                'BackgroundColor', [1, 1, 1], ...
                'ForegroundColor', [0.2, 0.2, 0.2]);
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
    end
end
