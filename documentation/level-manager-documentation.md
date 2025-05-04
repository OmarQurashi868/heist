# Level Manager Documentation

## Overview

The Level Manager handles level-specific interactions, particularly the team bases and their interactions with players and the money bag. It's responsible for connecting various game elements and forwarding events to the GameManager.

## File Location

`scenes/levels/level_manager.gd`

## Properties

```gdscript
@onready var game_manager: Node3D = $"../../GameManager"
@onready var money_bag: Node3D = $"../../MoneyBag"
```

## Core Functionality

### Initialization

The Level Manager connects to the Money Bag's signal to detect when a player picks it up:

```gdscript
func _ready():
    money_bag.connect("money_bag_picked_up", _on_money_bag_picked_up)
```

### Team Base Interaction

The Level Manager handles player interactions with team bases, determining when a player has successfully scored by bringing the money bag to their team's base:

```gdscript
func _on_base_red_body_entered(body):
    if body.is_in_group("player") and body.is_in_group("red"):
        game_manager.touch_base(body.player_id, 0)

func _on_base_blue_body_entered(body):
    if body.is_in_group("player") and body.is_in_group("blue"):
        game_manager.touch_base(body.player_id, 1)

func _on_base_green_body_entered(body):
    if body.is_in_group("player") and body.is_in_group("green"):
        game_manager.touch_base(body.player_id, 2)

func _on_base_yellow_body_entered(body):
    if body.is_in_group("player") and body.is_in_group("yellow"):
        game_manager.touch_base(body.player_id, 3)
```

Each base checks if:
1. The entering body is a player
2. The player belongs to the correct team
3. If true, it calls `touch_base()` on the GameManager

### Money Bag Events

The Level Manager forwards Money Bag pickup events to the GameManager:

```gdscript
func _on_money_bag_picked_up(player_id, team):
    game_manager.grab_bag(player_id, team)
```

## Level Structure Requirements

Each level should include:

1. **Team Bases**: One for each team, named "BaseRed", "BaseBlue", etc.
2. **Spawn Points**: One for each team, named "SpawnPoint0", "SpawnPoint1", etc.
3. **Money Bag Spawn**: A position where the money bag appears
4. **Level Manager**: This script attached to manage interactions

## Integration with Game Systems

### GameManager Connection

The Level Manager acts as an intermediary between level elements and the GameManager:
- Reports player base touches to trigger scoring
- Forwards money bag pickup events
- Relies on GameManager for actual game logic implementation

### Money Bag Connection

The Level Manager connects to the Money Bag's signals to detect pickup events and forward them to the GameManager.

### Player Interaction

The Level Manager detects when players enter team bases and verifies:
- The player belongs to the correct team
- Triggers score events via the GameManager

## Example Level Setup

A typical level setup includes:

```
LevelExample/
├── BaseRed (Area3D)
├── BaseBlue (Area3D)
├── BaseGreen (Area3D)
├── BaseYellow (Area3D)
├── SpawnPoint0 (Marker3D)
├── SpawnPoint1 (Marker3D)
├── SpawnPoint2 (Marker3D)
├── SpawnPoint3 (Marker3D)
├── MoneyBagSpawn (Marker3D)
└── LevelManager (Node3D with level_manager.gd)
```

## Best Practices

When working with the Level Manager:

1. **Consistent Naming**: Follow the established naming conventions for bases, spawn points, etc.
2. **Signal Connections**: Ensure all bases are connected to the appropriate Level Manager functions
3. **Team Validation**: Always check team membership before triggering score events
4. **GameManager Delegation**: Let the GameManager handle actual game logic, keeping the Level Manager focused on detection

## Extending the Level System

To modify or extend the level system:

1. **Level Features**: Add level-specific traps, obstacles, or power-ups
2. **Dynamic Elements**: Add moving platforms or changing environments
3. **Environmental Effects**: Implement weather or lighting effects that impact gameplay
4. **Team Mechanics**: Add team-specific advantages or challenges

## Level Design Tips

When creating new levels:

1. Place spawn points with adequate spacing to prevent immediate player conflicts
2. Position the money bag spawn in a central or contested area
3. Design team bases to have balanced accessibility
4. Create interesting paths and obstacles between key locations