# 3D Character Game in Godot

This project is a 3D character game created in Godot Engine where you control a hero character fighting against enemies.

## How to Run the Project

1. Open Godot Engine
2. Click on "Import" in the Project Manager
3. Navigate to the project folder and select the `project.godot` file
4. Click "Open"
5. Once the project is loaded, click the "Play" button in the top-right corner or press F5

## Game Features

- 3D character movement with animations
- Combat system with attacks and health
- Enemy AI that follows and attacks the player
- Score system for defeating enemies
- Platform boundaries to keep characters on the playing field
- Enemy spawning system

## Controls

- W/S or Up/Down Arrow keys: Move forward/backward
- A/D or Left/Right Arrow keys: Move left/right
- Space: Jump
- F: Attack

## Game Mechanics

- **Movement**: The player can move in all four directions and jump.
- **Combat**: Press F to attack. You must be close to an enemy to hit them.
- **Health**: Your health is displayed in the top-left corner. If it reaches zero, you die.
- **Score**: You earn points for defeating enemies.
- **Boundaries**: You cannot fall off the platform.
- **Enemies**: Enemies will chase you when you get close and attack when in range.

## Character Models

The project includes 3D character models:
- Hero character with idle, walk, and attack animations
- Enemy character with idle, walk, and attack animations

## Troubleshooting

If the character models don't appear:
1. Make sure all FBX files are properly imported
2. Check the console for any error messages
3. Try restarting the Godot editor

If animations don't work:
1. Make sure the animation files are properly imported
2. Check if the AnimationPlayer has the animations in its library

## Known Issues

When first importing the project, you might need to reimport the character model files:

1. In the Godot editor, go to the FileSystem panel
2. Navigate to `assets/characters/hero` and `assets/characters/enemy`
3. Right-click on each FBX file and select "Reimport"