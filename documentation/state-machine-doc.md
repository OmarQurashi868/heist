# State Machine System Documentation

## Overview

The State Machine system manages player behavior by organizing different actions and conditions into discrete states. This architecture enables clean separation of concerns and makes it easy to add new behaviors without modifying existing code. The system follows a classic state pattern implementation.

## File Structure

- `scripts/state.gd`: Base state class
- `scripts/states/StateMachine.gd`: State machine controller
- `scripts/states/Base.gd`: Default movement state
- `scripts/states/Jump.gd`: Jumping state
- `scripts/states/Fall.gd`: Falling state
- `scripts/states/Attack.gd`: Attack state
- `scripts/states/Hurt.gd`: Hurt/stunned state
- `scripts/states/Dead.gd`: Dead state

## Core Classes

### State Base Class

The `State` class (`scripts/state.gd`) serves as the foundation for all states:

```gdscript
extends Node
class_name State

var state_machine: StateMachine  # Reference to parent state machine
var player: Player               # Reference to player object

func _ready():
    state_machine = get_parent()
    player = state_machine.player

func on_enter():
    pass  # Called when state becomes active

func on_exit():
    pass  # Called when leaving this state

func phys_proc(_delta):
    pass  # Called during physics processing while in this state
```

### State Machine Controller

The `StateMachine` class (`scripts/states/StateMachine.gd`) manages state transitions:

```gdscript
extends Node
class_name StateMachine

var player: Player
var current_state: State
const DEFAULT_STATE = "Base"

func _enter_tree():
    player = get_parent() as Player
    current_state = get_node(DEFAULT_STATE) as State

func phys_proc(delta):
    current_state.phys_proc(delta)

func change_state(new_state: String):
    current_state.on_exit()
    current_state = get_node(new_state) as State
    current_state.on_enter()

func spawn_player():
    player.health = player.FULL_HEALTH
    player.animation_tree.set("parameters/dead/transition_request", "alive")
    player.is_dead = false
    player.is_stunned = false
    change_state("Base")
```

## State Implementations

### Base State

The default movement state, handling regular player movement and input:

```gdscript
# Key functions from Base.gd
func on_enter():
    player.animation_tree.set("parameters/basejumpfall/transition_request", "base")

func phys_proc(delta):
    player.handle_movement(delta, (player.SPEED - player.weapon.weight) / player.SPEED)
    player.handle_jump(delta)
    player.handle_attack()
    
    player.animation_tree.set("parameters/base/blend_position", 
        Vector2(player.side_vector, player.forward_vector / player.SPEED))
    
    if not player.is_on_floor():
        if player.velocity.y > 0:
            state_machine.change_state("Jump")
        elif player.velocity.y < 0:
            state_machine.change_state("Fall")
```

### Jump State

Active while player is moving upward after jumping:

```gdscript
# Key functions from Jump.gd
func on_enter():
    player.animation_tree.set("parameters/basejumpfall/transition_request", "jump")

func phys_proc(delta):
    player.handle_movement(delta, (player.SPEED - player.weapon.weight) / player.SPEED)
    player.handle_attack()
    
    if player.velocity.y < 0:
        state_machine.change_state("Fall")
    if player.is_on_floor():
        state_machine.change_state("Base")
```

### Fall State

Active while player is falling:

```gdscript
# Key functions from Fall.gd
func on_enter():
    player.animation_tree.set("parameters/basejumpfall/transition_request", "fall")

func phys_proc(delta):
    player.handle_movement(delta, (player.SPEED - player.weapon.weight) / player.SPEED)
    player.handle_attack()
    
    if player.is_on_floor():
        state_machine.change_state("Base")
```

### Attack State

Active while player is performing an attack:

```gdscript
# Key functions from Attack.gd
func on_enter():
    player.animation_tree.set("parameters/weapon_anim/transition_request", player.weapon.animation_name)
    player.animation_tree.set("parameters/attack/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE) 

func phys_proc(delta):
    if player.weapon.can_attack_move:
        player.handle_movement(delta, (player.SPEED - player.weapon.weight) / player.SPEED)
    else:
        player.velocity = player.velocity.move_toward(Vector3(0, player.velocity.y, 0), player.ACCEL)
    
    if !player.animation_tree.get("parameters/attack/active"):
        state_machine.change_state("Base")

func on_exit():
    player.weapon.stop_attack()
```

### Hurt State

Active when player takes damage:

```gdscript
# Key functions from Hurt.gd
func on_enter():
    player.animation_tree.set("parameters/swing/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
    player.animation_tree.set("parameters/hurt/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
    $DamageSFX.play()
    player.is_stunned = true

func phys_proc(_delta):
    player.velocity = player.velocity.move_toward(Vector3(0, player.velocity.y, 0), player.ACCEL)

func on_exit():
    player.is_stunned = false
```

### Dead State

Active when player dies:

```gdscript
# Key functions from Dead.gd
func on_enter():
    player.animation_tree.set("parameters/swing/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
    player.animation_tree.set("parameters/hurt/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
    player.animation_tree.set("parameters/dead/transition_request", "dead")
    $DeathSFX.play()
    player.is_stunned = true

func phys_proc(_delta):
    player.velocity = player.velocity.move_toward(Vector3(0, player.velocity.y, 0), player.ACCEL)

func on_exit():
    player.is_stunned = false
```

## State Transitions

State transitions occur under these conditions:

1. **Base → Jump**: Player presses jump while on floor
2. **Jump → Fall**: Player's Y velocity becomes negative
3. **Jump/Fall → Base**: Player touches floor
4. **Base/Jump/Fall → Attack**: Player triggers an attack
5. **Attack → Base**: Attack animation completes
6. **Base/Jump/Fall/Attack → Hurt**: Player takes damage
7. **Hurt → Base**: After stun timer completes
8. **Any → Dead**: Player health reaches zero
9. **Dead → Base**: After respawn timer and position reset

## Animation Integration

States closely interact with the animation system:

1. **State Entry**: Updates AnimationTree parameters
   ```gdscript
   player.animation_tree.set("parameters/basejumpfall/transition_request", "jump")
   ```

2. **During State**: Updates blend parameters
   ```gdscript
   player.animation_tree.set("parameters/base/blend_position", Vector2(player.side_vector, player.forward_vector / player.SPEED))
   ```

3. **State Exit**: Sometimes resets animations
   ```gdscript
   player.animation_tree.set("parameters/swing/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
   ```

## Adding New States

To add a new state:

1. **Create a new script** extending the `State` class
2. **Implement required functions**:
   ```gdscript
   func on_enter():
       # Setup when entering state
       
   func phys_proc(delta):
       # State behavior during physics processing
       
   func on_exit():
       # Cleanup when exiting state
   ```
3. **Add node to StateMachine** in the player scene
4. **Add transitions** to and from your state in other states

## Example: Adding a "Crouch" State

```gdscript
# Crouch.gd
extends State

func on_enter():
    player.animation_tree.set("parameters/basejumpfall/transition_request", "crouch")
    # Reduce player collision height
    player.get_node("CollisionShape").shape.height = 1.0

func phys_proc(delta):
    # Slower movement while crouched
    player.handle_movement(delta, 0.5)
    player.handle_attack()
    
    # Check for uncrouch input
    if Input.is_action_just_released("crouch"):
        state_machine.change_state("Base")

func on_exit():
    # Restore collision height
    player.get_node("CollisionShape").shape.height = 2.0
```

Then add transitions in the Base state:
```gdscript
# In Base.gd phys_proc()
if Input.is_action_just_pressed("crouch"):
    state_machine.change_state("Crouch")
```

## Common Issues and Solutions

1. **State Transitions Not Working**:
   - Ensure state nodes are direct children of StateMachine
   - Check for typos in state names when calling change_state()

2. **State Behavior Bugs**:
   - Verify on_enter() and on_exit() are properly implemented
   - Check if states are correctly handling player properties

3. **Animation Issues**:
   - Ensure AnimationTree parameters match those in the actual AnimationTree
   - Check for proper animation connections in the AnimationTree editor

4. **Stuck in State**:
   - Add debug logging to track state transitions
   - Ensure exit conditions are achievable

## Best Practices

1. **Keep States Focused**: Each state should have a single responsibility
2. **Clean Entry/Exit**: Always reset what you modify in on_exit()
3. **Avoid Dependencies**: States should only need player and state_machine references
4. **Input Handling**: Consider where input should be handled (state or player)
5. **Logging**: Add debug logging for state transitions during development