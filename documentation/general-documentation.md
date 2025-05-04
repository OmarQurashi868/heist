# Heist Game Documentation

## Project Overview

"Heist" is a multiplayer game inspired by Conker's Bad Fur Day heist mode. In this game, players compete to collect money bags and return them to their team's base to score points, while battling other players who can stun them and steal the money.

## Table of Contents

1. [Project Structure](#project-structure)
2. [Game Flow](#game-flow)
3. [Core Systems](#core-systems)
   - [Player System](#player-system)
   - [State Machine](#state-machine)
   - [Weapon System](#weapon-system)
   - [Team Management](#team-management)
   - [Money Bag System](#money-bag-system)
4. [Scene Management](#scene-management)
5. [Input System](#input-system)
6. [Multiplayer System](#multiplayer-system)
7. [Contributing Guidelines](#contributing-guidelines)

## Project Structure

The project is organized into several directories:

- `scenes/`: Contains all scene files (.tscn)
  - `entities/`: Player and other interactive game objects
  - `game/`: UI screens and game management scenes
  - `levels/`: Game level scenes
- `scripts/`: Contains standalone script files (.gd)
  - `states/`: State machine implementation for player behaviors
- `resources/`: Contains game resources and data files
- `assets/`: Contains textures, models, and other media files

## Game Flow

1. **Main Menu**: Players select the level and number of local players
2. **Game Initialization**: The GameManager spawns players and sets up the level
3. **Gameplay Loop**:
   - Players move around the level
   - Players can attack each other with weapons
   - Players try to collect the money bag and return it to their base
   - When a player returns the money bag to their base, their team scores a point
   - The money bag respawns at its designated location

## Core Systems

### Player System

The player is implemented in `scenes/entities/Player.gd` and is the primary controllable character.

#### Key Components:

- **Movement**: Players move using WASD keys, with camera control affecting movement direction
- **Combat**: Players can attack with weapons (Z key by default)
- **States**: Player behavior is managed through a state machine
- **Teams**: Players belong to teams (red, blue, green, yellow)
- **Health**: Players have health and can be stunned or killed

#### Player Properties:

```gdscript
var player_id = 0          # Unique identifier for each player
var team_id                # The team this player belongs to
const FULL_HEALTH = 10.0   # Maximum health value
@export var health = 10.0  # Current health
@export var weapon: Weapon # Player's equipped weapon
var has_money = false      # Whether player is carrying the money bag
var is_stunned = false     # Whether player is stunned (can't move)
var is_dead = false        # Whether player is dead
```

### State Machine

The state machine system (`scripts/state.gd` and `scripts/states/StateMachine.gd`) controls player behavior by switching between different states.

#### States:

- **Base**: Normal movement state
- **Jump**: Player is jumping
- **Fall**: Player is falling
- **Attack**: Player is attacking
- **Hurt**: Player is stunned after taking damage
- **Dead**: Player is dead and waiting to respawn

Each state has:
- `on_enter()`: Called when entering the state
- `on_exit()`: Called when exiting the state
- `phys_proc(delta)`: Called during physics processing

State transitions happen in response to player input or external events (e.g., taking damage).

### Weapon System

The weapon system consists of base and derived weapon classes.

#### Base Weapon (`scripts/weapon.gd`):

```gdscript
@export var weapon_name: String
@export var weapon_tier: int
@export var cooldown_duration: float
@export var weight: float = 0
@export var can_attack_move: bool = false
@export var animation_name: String
```

#### Weapon Types:

- **Melee Weapons** (`scripts/weapon_melee.gd`): Close-range weapons with a hitbox
- **Hitscan Weapons** (`scripts/weapon_hitscan.gd`): Ranged weapons that instantly hit targets

#### Attack System:

Attacks are defined in `scripts/attack.gd` with properties:

```gdscript
var damage: float
var stun_timer: float
var knockback_force: float
var knockback_source: Vector3
```

### Team Management

Teams are managed by the `GameManager` and implement the following structure:

```gdscript
class Team:
    var name: String       # Team name (red, blue, green, yellow)
    var color: Color       # Team color
    var score: int         # Team score
    var spawn_position: Vector3  # Where team members spawn
    var has_money: bool    # Whether a team member has the money
```

### Money Bag System

The money bag (`scenes/entities/money_bag.gd`) is the central gameplay element:

- Floats at a spawn point when not carried
- Can be picked up by players
- Is dropped when the carrier is damaged
- When carried to the team's base, awards a point
- Respawns after a delay

```gdscript
var is_picked_up = false   # Whether the bag is being carried
var is_cashed_in = false   # Whether the bag has been scored
var carrier: CharacterBody3D  # The player carrying the bag
```

## Scene Management

The game uses a scene management system handled by `scripts/lobby_manager.gd`:

- **Scene Loading**: Background loading of scenes with progress tracking
- **Scene Swapping**: Transitions between scenes
- **Level Selection**: Manages available levels and selection

## Input System

The game's input system is defined in `project.godot` with these key actions:

- Movement: Arrow keys or WASD
- Jump: Spacebar
- Attack: Z key or gamepad trigger

Custom input actions can be added in the Godot project settings.

## Multiplayer System

The game supports local multiplayer with split-screen:

- Up to 4 players on a single machine
- Dynamically adjusts viewport sizes based on player count
- Each player has their own camera and controls
- Teams are color-coded for easy identification

## Contributing Guidelines

When contributing to this project:

1. **Understanding the Code**: Read this documentation thoroughly before making changes
2. **Following Conventions**:
   - Use PascalCase for class names
   - Use snake_case for variables and functions
   - Organize new scripts in appropriate directories
3. **Testing**:
   - Test changes with multiple player configurations
   - Ensure backward compatibility with existing systems
4. **Adding Features**:
   - New weapons should extend the Weapon base class
   - New player states should extend the State base class
   - New levels should include spawn points for all teams and a money bag spawn

### Working with the State Machine

When adding new player behaviors:
1. Create a new state script extending `State`
2. Implement the required methods (`on_enter`, `on_exit`, `phys_proc`)
3. Add the state to the StateMachine node in the player scene
4. Add transitions to/from your state in relevant states

### Adding New Weapons

To add a new weapon:
1. Create a script extending either `WeaponMelee` or `WeaponHitscan`
2. Create a scene for the weapon with the appropriate nodes
3. Add the weapon data to `resources/weapon_data.gd`
4. Set up animations in the player's AnimationTree

### Creating New Levels

New levels should include:
1. A root node with the level name
2. SpawnPoint0, SpawnPoint1, etc. for each team
3. A MoneyBagSpawn node
4. Team bases with appropriate collision detection

## Technical Details

- **Game Engine**: Godot 4.2
- **Programming Language**: GDScript
- **Rendering**: GL Compatibility mode
- **Input**: Supports keyboard, mouse, and gamepad
- **Export Targets**: Windows Desktop, Web

---

*This documentation is a living document and may be updated as the project evolves.*