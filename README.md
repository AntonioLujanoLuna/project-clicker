# Project-Clicker

A resource gathering and management game built with LÖVE2D.

## Features

- Resource gathering and collection mechanics
- Automated resource collection with robots
- Building construction system
- Pollution management
- Camera controls for navigating the world
- Save/load system for game progress
- Sound effects and audio controls
- First-time tutorial for new players
- Error handling and crash prevention

## Controls

- **Left Mouse Button**: Click resources to gather them, click resource bits to collect them
- **Middle Mouse Button**: Pan the camera
- **Mouse Wheel**: Zoom in/out
- **R**: Reset camera position
- **E**: Toggle edge scrolling
- **C**: Toggle auto-collection of resources near the camera
- **H**: Open help panel
- **S**: Open settings panel
- **1**: Open robots panel
- **2**: Open research panel
- **Escape**: Close all panels

## Recent Improvements

### 1. Save/Load System
- Game state is automatically saved every 5 minutes
- Manual save/load available in the settings panel
- Saves resources, buildings, robots, and research progress

### 2. Error Handling and Crash Prevention
- Comprehensive logging system with different severity levels
- Safe function call wrappers to prevent crashes
- Global error handler to display user-friendly error messages

### 3. Performance Optimization
- Object pooling for resource bits to reduce memory allocation
- Spatial partitioning for efficient collision detection
- Improved resource bit physics and cleanup

### 4. Sound System
- Sound effects for key actions (clicking, collecting, building)
- Background ambient sound
- Volume controls for master, SFX, and music
- Automatic placeholder sound generation if sound files are missing

### 5. Tutorial System
- Step-by-step guidance for new players
- Highlights important UI elements
- Tracks player progress through tutorial steps

## Development

### Project Structure
- `src/`: Source code files
  - `main.lua`: Entry point and main loop
  - `game.lua`: Core game mechanics and state
  - `ui.lua`: User interface elements
  - `resources.lua`: Resource definitions and behavior
  - `robots.lua`: Robot definitions and behavior
  - `buildings.lua`: Building definitions and behavior
  - `pollution.lua`: Pollution system
  - `camera.lua`: Camera controls and viewport management
  - `config.lua`: Game configuration settings
  - `log.lua`: Logging system
  - `utils.lua`: Utility functions
  - `audio.lua`: Sound system
  - `tutorial.lua`: Tutorial system
- `lib/`: External libraries
  - `json.lua`: JSON serialization/deserialization
- `assets/`: Game assets
  - `sounds/`: Sound effects and music

### Running the Game
1. Install LÖVE2D from [love2d.org](https://love2d.org/)
2. Clone this repository
3. Run the game with `love .` from the project directory

## Future Improvements
- More resource types and buildings
- Tech tree for research progression
- Improved graphics and animations
- Multiplayer support
- Mobile touch controls

## License
This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- LÖVE framework developers
- Solarpunk community for inspiration
- Environmental awareness initiatives 