classdef CollisionDetector
    %COLLISIONDETECTOR Handles collision detection logic
    %   Detects wall, self, and apple collisions
    
    methods (Static)
        function result = check(head, snake, goodApple, badApple, gridSize)
            %CHECK Check what the head collides with
            %   Returns: 'wall', 'self', 'good', 'bad', or 'none'
            
            % Wall collision
            if head(1) < 1 || head(1) > gridSize || ...
                    head(2) < 1 || head(2) > gridSize
                result = 'wall';
                return;
            end
            
            % Self collision (check against body, not current head position)
            body = snake.Body;
            for i = 1:size(body, 1)
                if isequal(head, body(i, :))
                    result = 'self';
                    return;
                end
            end
            
            % Good apple collision
            if ~isempty(goodApple) && isequal(head, goodApple)
                result = 'good';
                return;
            end
            
            % Bad apple collision
            if ~isempty(badApple) && isequal(head, badApple)
                result = 'bad';
                return;
            end
            
            result = 'none';
        end
        
        function isCollision = checkWall(position, gridSize)
            %CHECKWALL Check if position is outside grid
            isCollision = position(1) < 1 || position(1) > gridSize || ...
                position(2) < 1 || position(2) > gridSize;
        end
        
        function isCollision = checkSelf(head, snakeBody)
            %CHECKSELF Check if head collides with body
            isCollision = false;
            for i = 1:size(snakeBody, 1)
                if isequal(head, snakeBody(i, :))
                    isCollision = true;
                    return;
                end
            end
        end
        
        function isCollision = checkPoint(position, targetPoint)
            %CHECKPOINT Check if two positions are the same
            isCollision = ~isempty(targetPoint) && isequal(position, targetPoint);
        end
    end
end