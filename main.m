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
%       - Session high score tracking
%       - Instructions window
%
%   See also: game.GameController, game.GameState, graphics.Renderer

clc;
clear;
close all force;

% Create and start the game controller
controller = game.GameController();
controller.start();

end