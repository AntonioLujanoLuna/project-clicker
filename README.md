# project-clicker

An eco-themed clicker game built with LÖVE (Love2D) where players manage resources and balance growth with environmental impact.

## Description

project-clicker is a solarpunk-inspired clicker game where players rebuild a sustainable society after an environmental collapse. Gather resources, construct buildings, and deploy specialized robots while managing pollution levels. The game emphasizes the balance between industrial growth and environmental preservation.

## Features

- Resource gathering (Wood, Stone, Food)
- Automated production buildings
- Specialized robot workers
- Environmental pollution system
- Research and upgrades
- Particle effects for resource gathering
- Dynamic UI with resource tracking

## Prerequisites

- [LÖVE](https://love2d.org/) 11.4 or later
- Windows, macOS, or Linux

## Installation

1. Install LÖVE from [https://love2d.org/](https://love2d.org/)
2. Clone this repository:
```bash
git clone https://github.com/AntonioLujanoLuna/project-clicker.git
cd project-clicker
```

## Running the Game

### Windows
- Double-click the `game.love` file (if packaged)
- Or drag the game folder onto `love.exe`
- Or run from command line:
```bash
"C:\Program Files\LOVE\love.exe" .
```

### macOS
```bash
/Applications/love.app/Contents/MacOS/love .
```

### Linux
```bash
love .
```

## How to Play

1. Click on resource nodes (Wood, Stone, Food) to gather resources
2. Build automated production buildings to generate resources over time
3. Deploy robots to help with resource gathering and management
4. Monitor and manage pollution levels using green technology
5. Research new technologies to improve efficiency
6. Balance growth with environmental impact

## Controls

- Left Mouse Button: Gather resources, interact with UI
- Escape: Quit game

## Development

The game is structured in modules:
- `main.lua`: Entry point and Love2D lifecycle
- `src/game.lua`: Core game state and logic
- `src/resources.lua`: Resource management
- `src/buildings.lua`: Building construction and production
- `src/robots.lua`: Robot creation and behavior
- `src/pollution.lua`: Environmental impact system
- `src/ui.lua`: User interface elements

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- LÖVE framework developers
- Solarpunk community for inspiration
- Environmental awareness initiatives 