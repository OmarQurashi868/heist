# Money Bag System Documentation

## Overview

The Money Bag is a central gameplay element in the Heist game. It's what players compete for, and successfully returning it to a team's base scores points. This document details how the Money Bag system works and how it interacts with other game components.

## File Location

`scenes/entities/money_bag.gd`

## Properties

```gdscript
@export var amp = 0.5           # Amplitude of floating animation
@export var freq = 0.5          # Frequency of floating animation
@export var speed = 12          # Speed at which bag follows carrier
var is_picked_up = false        # Whether the bag is being carried
var is_cashed_in = false        # Whether the bag has been scored
var carrier: CharacterBody3D    # The player carrying the bag
var angle = 0                   # Used for floating animation
var money_bag_void_pos = Vector3(999, 999, 999)  # Position when bag is hidden
var is_parent_ready = false     # Whether parent nodes are initialized
```

## Signals

```gdscript
signal money_bag_picked_up(team)  # Emitted when a player picks up the bag
```

## Core Functionality

### Initialization

The Money Bag connects to the GameManager's `game_setup` signal to ensure it only starts processing when the game is fully initialized:

```gdscript
func _ready():
    get_node("../GameManager").game_setup.connect(func(): is_parent_ready = true)
```

### Movement Logic

In `_physics_process()`, the Money Bag has two behavioral states:

1. **When carried by a player:**
   ```gdscript
   if is_picked_up and carrier:
       var slot = carrier.get_node("MoneyBagSlot")
       position.x = move_toward(position.x, slot.global_position.x, speed * delta)
       position.y = move_toward(position.y, slot.global_position.y, speed * delta)
       position.z = move_toward(position.z, slot.global_position.z, speed * delta)
   ```
   The bag smoothly follows the carrier's "MoneyBagSlot" position.

2. **When not carried (floating at spawn):**
   ```gdscript
   elif not is_cashed_in:
       angle += 2 * 3.14 * delta
       var spawn_pos = get_node("../" + LobbyManager.current_map + "/MoneyBagSpawn").global_position
       position.x = move_toward(position.x, spawn_pos.x, delta)
       position.z = move_toward(position.z, spawn_pos.z, delta)
       position.y = spawn_pos.y + sin(angle * freq) * amp
   ```
   The bag floats at its spawn point with a sine wave animation.

### Player Interaction

The Money Bag detects when a player enters its area and attaches to them:

```gdscript
func _on_body_entered(body):
    if body.is_in_group("player") and not is_picked_up and not body.is_stunned:
        is_picked_up = true
        carrier = body
        var carrier_team = body.get_groups()[1]
        var player_id = body.player_id
        emit_signal("money_bag_picked_up", player_id, carrier_team)
```

This triggers the `money_bag_picked_up` signal, which is caught by the level manager and forwarded to the GameManager.

### States and Transitions

The Money Bag has three primary states:
1. **Idle/Floating**: At spawn point, waiting to be picked up
2. **Carried**: Attached to a player
3. **Cashed In**: Temporarily hidden after being scored

#### Dropping the Bag

When a player is damaged or killed while carrying the bag:

```gdscript
func on_bag_drop():
    is_picked_up = false
    carrier = null
```

#### Scoring the Bag

When a player returns the bag to their team's base:

```gdscript
func on_bag_cash_in():
    is_picked_up = false
    carrier = null
    is_cashed_in = true
    position = money_bag_void_pos  # Move bag to "void" position
    $bag_respawn_time.start()      # Start respawn timer
```

#### Respawning

After the respawn timer expires:

```gdscript
func _on_bag_respawn_time_timeout():
    is_cashed_in = false
    game_manager.respawn_bag()  # Calls function to reposition bag at spawn
```

## Interaction with Other Systems

### GameManager Integration

The Money Bag connects closely with the GameManager for:
- Notifying when it's picked up
- Handling the respawn process
- Coordinating with the scoring system

### Player Integration

Players interact with the Money Bag through:
- Collision detection (picking up)
- The MoneyBagSlot node (positioning while carried)
- The GameManager's `grab_bag()` and `drop_bag()` functions

## Extending the Money Bag System

To modify or extend the Money Bag functionality:

1. **Add Effects**: Add particle effects or sound effects to bag pickup/drop events
2. **Modify Physics**: Adjust `amp`, `freq`, and `speed` for different movement behavior
3. **Add Power-ups**: Extend the system to give carriers special abilities or modifiers
4. **Special Interactions**: Create special interactions with level elements or other players

## Best Practices

When working with the Money Bag system:

1. Always handle the bag through GameManager functions for consistency
2. Ensure new player characters include a properly positioned MoneyBagSlot
3. When creating new levels, always include a MoneyBagSpawn node
4. Use the existing signals to handle custom events related to the money bag