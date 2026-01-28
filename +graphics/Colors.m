classdef Colors
    %COLORS Color definitions for game entities
    %   Central place for all color values used in rendering
    
    properties (Constant)
        % Background and grid
        Background = [0.95, 0.95, 0.95];   % Light gray
        GridLines = [0.85, 0.85, 0.85];    % Subtle grid lines
        
        % Snake colors
        SnakeHead = [0.2, 0.6, 0.2];       % Dark green
        SnakeBody = [0.4, 0.8, 0.4];       % Light green
        
        % Apple colors
        GoodApple = [0.9, 0.2, 0.2];       % Red
        GoodAppleEdge = [0.7, 0.1, 0.1];   % Darker red edge
        BadApple = [0.5, 0.1, 0.5];        % Purple
        BadAppleEdge = [0.3, 0.05, 0.3];   % Darker purple edge
        
        % UI colors
        Text = [0.2, 0.2, 0.2];            % Dark gray text
        OverlayBackground = [1, 1, 1, 0.9]; % White semi-transparent
    end
end