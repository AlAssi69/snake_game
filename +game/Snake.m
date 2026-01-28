classdef Snake < handle
    %SNAKE Represents the snake entity
    %   Handles snake state, movement, growth, and shrinking
    
    properties
        Segments        % Nx2 matrix of [x, y] positions (head is first row)
        Direction       % Current movement direction [dx, dy]
        NextDirection   % Buffered direction for next frame
    end
    
    properties (Dependent)
        Head            % Current head position
        Body            % Body segments (excluding head)
        Length          % Number of segments
    end
    
    methods
        function obj = Snake()
            %SNAKE Constructor - initialize snake at starting position
            obj.reset();
        end
        
        function reset(obj)
            %RESET Reset snake to initial state
            startPos = utils.Config.InitialSnakePosition;
            initLength = utils.Config.InitialSnakeLength;
            
            % Create snake segments (head + body extending left)
            obj.Segments = zeros(initLength, 2);
            for i = 1:initLength
                obj.Segments(i, :) = [startPos(1) - (i-1), startPos(2)];
            end
            
            obj.Direction = utils.Config.InitialDirection;
            obj.NextDirection = utils.Config.InitialDirection;
        end
        
        function head = get.Head(obj)
            %GET.HEAD Get current head position
            head = obj.Segments(1, :);
        end
        
        function body = get.Body(obj)
            %GET.BODY Get body segments (excluding head)
            if size(obj.Segments, 1) > 1
                body = obj.Segments(2:end, :);
            else
                body = [];
            end
        end
        
        function len = get.Length(obj)
            %GET.LENGTH Get number of segments
            len = size(obj.Segments, 1);
        end
        
        function newHead = move(obj)
            %MOVE Move snake forward in current direction
            %   Returns new head position
            obj.Direction = obj.NextDirection;
            newHead = obj.Head + obj.Direction;
            
            % Normal movement: add new head, remove tail
            obj.Segments = [newHead; obj.Segments(1:end-1, :)];
        end
        
        function newHead = moveAndGrow(obj)
            %MOVEANDGROW Move snake forward and grow by one segment
            %   Returns new head position
            obj.Direction = obj.NextDirection;
            newHead = obj.Head + obj.Direction;
            
            % Growth: add new head, keep all body (no tail removal)
            obj.Segments = [newHead; obj.Segments];
        end
        
        function newHead = moveAndShrink(obj)
            %MOVEANDSHRINK Move snake forward and shrink by one segment
            %   Returns new head position
            obj.Direction = obj.NextDirection;
            newHead = obj.Head + obj.Direction;
            
            % Shrink: add new head, remove TWO tail segments (move + shrink)
            if size(obj.Segments, 1) > 1
                obj.Segments = [newHead; obj.Segments(1:end-2, :)];
            else
                obj.Segments = newHead;
            end
        end
        
        function success = trySetDirection(obj, newDirection)
            %TRYSETDIRECTION Attempt to change direction
            %   Returns true if direction was changed, false if invalid (180 turn)
            
            % Check if this would be a 180-degree turn
            if isequal(obj.Direction, -newDirection)
                success = false;
                return;
            end
            
            obj.NextDirection = newDirection;
            success = true;
        end
        
        function positions = getPositions(obj)
            %GETPOSITIONS Get all segment positions
            positions = obj.Segments;
        end
    end
end