# Snake Game - MATLAB Edition

A classic Snake game implementation in MATLAB with modern features including Good/Bad apples, adjustable speed, session high scores, and a clean modular architecture.

## Features

- **Classic Snake Gameplay**: Navigate the snake to eat apples and grow
- **Good Apples (Red)**: Eat to grow longer and score points
- **Bad Apples (Purple)**: Avoid these! They shrink your snake
- **Disappearing Bad Apples**: Bad apples disappear and reappear randomly
- **Adjustable Speed**: Speed up or slow down the game to match your skill
- **Session High Score**: Track your best score during the session
- **Pause Control**: Pause button and keyboard shortcut
- **Instructions Window**: Persistent help window with controls and tips

## Requirements

- MATLAB R2016b or later (uses modern graphics and timer features)
- No additional toolboxes required

## Installation

1. Clone or download this repository
2. Open MATLAB
3. Navigate to the `Snake Game` folder
4. Run `main` in the MATLAB command window

```matlab
>> main
```

## How to Play

### Objective

Guide the snake to eat **red apples** to grow and score points. Avoid **purple apples** (they shrink you), walls, and your own tail!

### Controls

| Key | Action |
|-----|--------|
| Arrow Up | Move North |
| Arrow Down | Move South |
| Arrow Left | Move West |
| Arrow Right | Move East |
| `+` / `=` | Increase speed (faster) |
| `-` / `_` | Decrease speed (slower) |
| Space / `P` | Pause / Resume |
| `Esc` / `Q` | Quit game |
| `R` | Restart (when game over) |

You can also click the **Pause** button in the game window.

### Game Elements

| Element | Color | Effect |
|---------|-------|--------|
| Snake Head | Dark Green | The front of your snake |
| Snake Body | Light Green | Follows the head |
| Good Apple | Red | +1 length, +1 score |
| Bad Apple | Purple | -1 length (danger!) |

### Game Over Conditions

The game ends when:
- The snake hits a wall
- The snake collides with its own body
- The snake shrinks to less than 2 segments (from bad apples)

### Tips

- Plan your path ahead to avoid getting trapped
- The bad apple disappears after 3-8 seconds and reappears elsewhere
- Adjust the speed to match your skill level
- Watch out when your snake gets long - it's easy to trap yourself!

## Project Structure

```
Snake Game/
├── main.m                      # Entry point - run this to play
├── README.md                   # This file
├── Docs.md                     # Original requirements specification
│
├── +game/                      # Game logic package
│   ├── Snake.m                 # Snake entity (movement, growth)
│   ├── GameState.m             # Overall game state management
│   └── CollisionDetector.m     # Collision detection logic
│
├── +graphics/                  # Visualization package
│   ├── Renderer.m              # Main game rendering
│   ├── InstructionsWindow.m    # Instructions popup window
│   └── Colors.m                # Color definitions
│
└── +utils/                     # Utilities package
    ├── Config.m                # Game configuration settings
    └── AppleSpawner.m          # Safe apple spawning logic
```

## Architecture

The game uses MATLAB's package system (`+folder` notation) to organize code into logical modules:

### Game Package (`+game`)

- **Snake.m**: Handle class representing the snake entity. Manages segments, movement, growth, and direction changes.
- **GameState.m**: Handle class managing overall game state including score, high score, pause state, and apple timing.
- **CollisionDetector.m**: Static methods for detecting collisions with walls, self, and apples.

### Graphics Package (`+graphics`)

- **Renderer.m**: Handle class managing the game window, axes, and all visual elements. Uses efficient handle-based updates to prevent flickering.
- **InstructionsWindow.m**: Separate figure window displaying game instructions.
- **Colors.m**: Constant class defining all colors used in the game.

### Utils Package (`+utils`)

- **Config.m**: Constant class containing all game configuration values (grid size, speeds, timings).
- **AppleSpawner.m**: Static methods for safely spawning apples in unoccupied positions.

## Configuration

Game settings can be modified in `+utils/Config.m`:

| Setting | Default | Description |
|---------|---------|-------------|
| `GridSize` | 20 | Grid dimensions (20x20) |
| `CellSize` | 25 | Pixels per grid cell |
| `BaseGameSpeed` | 0.15 | Base timer period (seconds) |
| `MinSpeedFactor` | 0.5 | Fastest speed (2x normal) |
| `MaxSpeedFactor` | 2.0 | Slowest speed (0.5x normal) |
| `BadAppleMinTime` | 3.0 | Minimum bad apple visible time |
| `BadAppleMaxTime` | 8.0 | Maximum bad apple visible time |
| `MinSnakeLength` | 2 | Game over if snake shorter |

## Development

### Adding New Features

1. **New game mechanics**: Add to `+game/GameState.m`
2. **Visual changes**: Modify `+graphics/Renderer.m`
3. **New colors**: Add to `+graphics/Colors.m`
4. **Configuration options**: Add to `+utils/Config.m`

### Timer-Based Game Loop

The game uses MATLAB's `timer` object for the main loop:
- Runs at a configurable fixed rate
- Handles pause/resume by stopping/starting the timer
- Speed changes require recreating the timer with new period

## License

This project is provided as-is for educational purposes.

## Acknowledgments

Based on the classic Snake game, implemented as a MATLAB programming exercise demonstrating:
- Object-oriented programming in MATLAB
- Handle classes and events
- Timer-based animation
- Figure and axes graphics
- Package organization
