# Animation System Documentation

## Overview

The animation system in the Heist game controls character movements, attacks, and state transitions. It uses Godot's AnimationPlayer and AnimationTree systems to create fluid, state-based animations with blending between different actions.

## Components

The animation system consists of these key components:

1. **AnimationPlayer**: Stores and plays individual animations
2. **AnimationTree**: Manages animation blending and transitions
3. **State Machine**: Controls which animations play based on player state
4. **Animation Parameters**: Values that control blending and transitions

## Player Animation Structure

In the Player scene (`scenes/entities/Player.gd`), you'll find these animation components:

```gdscript
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var animation_player = $weasel/AnimationPlayer as AnimationPlayer
@onready var animation_tree = $AnimationTree as AnimationTree
```

## Animation States

The animation system is tightly integrated with the player's state machine. Each state typically corresponds to a specific animation or animation blend:

### Base State

In the base movement state, animations blend between idle, walking, and running based on the player's velocity:

```gdscript
# In Base.gd
func phys_proc(delta):
    # [...]
    player.animation_tree.set("parameters/base/blend_position", Vector2(player.side_vector, player.forward_vector / player.SPEED))
```

The blend position is a 2D vector where:
- X axis (side_vector): Represents side movement (left/right strafing)
- Y axis (forward_vector/SPEED): Represents forward/backward movement

### Jump and Fall States

These states trigger specific animations when the player leaves the ground:

```gdscript
# In Jump.gd
func on_enter():
    player.animation_tree.set("parameters/basejumpfall/transition_request", "jump")

# In Fall.gd
func on_enter():
    player.animation_tree.set("parameters/basejumpfall/transition_request", "fall")
```

### Attack State

The attack animation depends on the equipped weapon:

```gdscript
# In Attack.gd
func on_enter():
    player.animation_tree.set("parameters/weapon_anim/transition_request", player.weapon.animation_name)
    player.animation_tree.set("parameters/attack/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
```

This code:
1. Selects the appropriate weapon animation based on the equipped weapon
2. Fires a one-shot animation for the attack

### Hurt and Dead States

These states play when the player takes damage or dies:

```gdscript
# In Hurt.gd
func on_enter():
    player.animation_tree.set("parameters/swing/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
    player.animation_tree.set("parameters/hurt/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
    player.is_stunned = true

# In Dead.gd
func on_enter():
    player.animation_tree.set("parameters/swing/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
    player.animation_tree.set("parameters/hurt/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
    player.animation_tree.set("parameters/dead/transition_request", "dead")
```

Note how animations can be aborted (like swing and hurt) when transitioning to dead state.

## AnimationTree Structure

The AnimationTree likely contains the following structure:

1. **Base Blend Space**: Blends between idle, walk, and run based on velocity
2. **Base/Jump/Fall State Machine**: Transitions between grounded movement and aerial states
3. **Attack OneShot**: Plays attack animations once
4. **Hurt OneShot**: Plays hurt animation once
5. **Dead State Machine**: Transitions between alive and dead states
6. **Weapon Animation Selector**: Chooses between different weapon animations

## Weapon Animations

Weapons define an `animation_name` property that's used to select the appropriate attack animation:

```gdscript
# In weapon.gd
@export var animation_name: String
```

This name is referenced in the Attack state to choose the correct animation.

## Animation Tree Parameters

Key parameters used in the animation system:

| Parameter | Type | Description |
|-----------|------|-------------|
| parameters/base/blend_position | Vector2 | Controls blending in the base movement blend space |
| parameters/basejumpfall/transition_request | String | Transitions between "base", "jump", or "fall" |
| parameters/weapon_anim/transition_request | String | Selects weapon animation based on equipped weapon |
| parameters/attack/request | Int | Triggers attack animation |
| parameters/swing/request | Int | Controls weapon swing animation |
| parameters/hurt/request | Int | Triggers hurt animation |
| parameters/dead/transition_request | String | Transitions between "alive" and "dead" |

## Integration with State Machine

The animation system is tightly integrated with the player state machine:

1. Each state's `on_enter()` method typically sets animation parameters
2. Some states (like Attack) monitor animation completion to transition out
3. The StateMachine's `spawn_player()` method resets animation states on respawn

## Best Practices

When working with the animation system:

1. **State Consistency**: Ensure animation states align with player states
2. **Transition Management**: Properly abort animations when switching states
3. **Weapon Integration**: New weapons should specify appropriate animation_name
4. **Parameter Naming**: Follow existing parameter naming conventions
5. **Blend Spaces**: Use blend spaces for smooth transitions between animations

## Extending the Animation System

To modify or extend the animation system:

1. **New Animations**: Add them to the AnimationPlayer
2. **AnimationTree Updates**: Add new animations to the AnimationTree with appropriate transitions
3. **State Integration**: Update state scripts to trigger new animations
4. **Weapon Animations**: Add new weapon_anim transitions for new weapon types

## Technical Details

- Godot uses a node-based animation graph in the AnimationTree
- Transitions can be requested by name using transition_request parameters
- OneShot nodes play animations once and can be fired or aborted
- Blend spaces can blend between multiple animations based on parameters

## Common Issues

- **Animation Stuck**: Often caused by not properly aborting one-shot animations
- **No Animation Playing**: Check if state_machine.change_state() was called properly
- **Wrong Animation**: Verify weapon.animation_name matches transitions in AnimationTree