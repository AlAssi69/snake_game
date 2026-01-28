## Snake Game Requirement Specification (MATLAB)

This document outlines the functional and non-functional requirements for developing a variation of the classic Snake game in the MATLAB environment. The game features standard mechanics with the addition of a "Bad Apple" penalty system.

---

### 1. Game Overview

The objective is to control a snake on a 2D grid, navigating it to eat "Good Apples" to grow in length and score points, while avoiding "Bad Apples," walls, and the snake's own tail.

### 2. Functional Requirements

#### 2.1 Game Entities

The game consists of three primary distinct entities interacting within a bounded space.

* **The Snake:**
* Must consist of a "Head" and a "Body."
* The body follows the path of the head.
* **Initial State:** Starts at a fixed length (e.g., 3 units) in the center of the grid.
* **Movement:** Moves continuously in the current direction at a fixed speed.


* **Good Apple (Target):**
* Appears at a random coordinate on the grid that is currently not occupied by the snake.
* Visualized as a distinct color (e.g., Red).


* **Bad Apple (Obstacle):**
* Appears at a random coordinate on the grid not occupied by the snake or the Good Apple.
* Visualized as a distinct color different from the snake and Good Apple (e.g., Purple or Black).



#### 2.2 Game Mechanics

* **Direction Control:** The snake changes direction based on user input (Up, Down, Left, Right). The snake cannot immediately reverse direction (e.g., cannot go Left if currently moving Right).
* **Growth Logic:** When the Snake Head occupies the same coordinate as a **Good Apple**:
* The Good Apple is removed.
* The Snake's length increases by one unit (a new segment is added to the tail).
* A new Good Apple spawns immediately.
* The Score increments.


* **Shrink Logic:** When the Snake Head occupies the same coordinate as a **Bad Apple**:
* The Bad Apple is removed.
* The Snake's length decreases by one unit (the last segment of the tail is removed).
* If the Snake's length drops below a critical threshold (e.g., length < 2), the game ends.
* A new Bad Apple spawns at a new random location.


* **Collision Detection (Game Over Conditions):** The game ends immediately if:
* **Wall Collision:** The Snake Head exceeds the grid boundaries.
* **Self Collision:** The Snake Head occupies the same coordinate as any part of its own Body.
* **Starvation:** The snake shrinks to a length of zero or one via Bad Apples.



#### 2.3 User Interface (UI) & Controls

| Input Key | Action |
| --- | --- |
| **Arrow Up** | Change direction North |
| **Arrow Down** | Change direction South |
| **Arrow Left** | Change direction West |
| **Arrow Right** | Change direction East |
| **Spacebar / P** | Pause / Resume Game |
| **Esc / Q** | Quit Game |

* **Score Display:** The current score must be visible at all times, located in the title bar or a text overlay within the figure.

---

### 3. Non-Functional Requirements

#### 3.1 Visualization

* **Platform:** The game must be rendered entirely within a standard MATLAB Figure window.
* **Aesthetics:**
* The grid should be clean and minimalist.
* Entities should be rendered using distinct shapes or distinct colors (e.g., squares for body segments, circles for apples) to ensure "nice" visualization as requested.
* The graphics must update without flickering.



#### 3.2 Performance

* **Frame Rate:** The game loop must run at a speed that is playable—not too fast to control, nor too slow to be boring.
* **Responsiveness:** Key presses must be registered immediately. There should be no perceptible lag between pressing a key and the snake changing direction in the next frame update.

#### 3.3 Robustness

* **Spawn Safety:** Neither Good nor Bad Apples should ever spawn *inside* the snake's body.
* **Boundary Handling:** The system must handle grid coordinates strictly as integers to prevent floating-point errors in collision detection.

---

### 4. Edge Cases to Handle

1. **Opposite Input:** User presses "Down" while moving "Up" (Input should be ignored).
2. **Simultaneous Spawn:** Ensuring a Bad Apple and Good Apple do not spawn on the exact same tile.
3. **Full Grid:** In the unlikely event the snake fills the entire screen, the game should trigger a "Win" state or end gracefully to prevent an infinite loop looking for an empty spawn point.