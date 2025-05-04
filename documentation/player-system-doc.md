# Player System Documentation

## Overview

The Player system is a core component of the Heist game, handling character movement, combat, animations, and interactions with the environment. Players are implemented as `CharacterBody3D` nodes with multiple components handling different aspects of player functionality.

## File Structure

- `scenes/entities/Player.gd`: Main player script
- `scenes/entities/player.tscn`: Player scene with all necessary nodes

## Player Components

### Nodes Hierarchy

```
Player (CharacterBody3D)
├── AnimationPlayer
├── AnimationTree
├── StateMachine
│   ├── Base
│   ├── Jump
│   ├── Fall
│   ├── Attack
│   ├── Hurt
│   └── Dead
├── CameraArm
│   └── CameraSlot
├── MoneyBagSlot
├── weasel (3D model)
│   └── rig
│       └── Skeleton3D
│           └── BoneAttachment3D
│               └── RemoteTransform3D (connects to weapon)
└── WeaponBat (or other weapon)
```

### Key Properties

```gdscript
var player_id = 0           # Player's unique identifier
var team_id                 # Player's team (0-3 for red, blue, green, yellow)
const FULL_HEALTH = 10.0    # Maximum health
@export var health = 10.0   # Current health
@export var weapon: Weapon  # Currently equipped weapon
const RESPAWN_TIMER = 1     # Time before respawning
const SPEED = 10.0          # Movement speed
const JUMP_VELOCITY = 15.0  # Jump force
const ROTATION_SPEED = 1.5  # Turn speed
const GRAVITY_FACTOR = 4.0  # Gravity multiplier
const ACCEL = 0.5           # Acceleration
var has_money = false       # Whether player carries money bag
var is_stunned = false      # Whether player is stunned
var is_dead = false         # Whether player is dead
```

## Core Functions

### Movement System

```gdscript
func handle_movement(_delta, factor: float = 1.0)
```

The movement system uses a camera-relative control scheme:
1. Gets camera orientation
2. Translates player input (WASD/arrow keys) to camera-relative directions
3. Rotates player to face movement direction
4. Applies movement vector with speed and acceleration
5. Tracks forward motion and turning angle for animation blending
6. Camera follows player with smooth rotation

Movement speed is affected by the equipped weapon's weight via the `factor` parameter.

### Gravity & Jumping

```gdscript
func handle_gravity(delta)
func handle_jump(_delta)
```

Gravity is constantly applied when not on floor. Jump is triggered by the "ui_accept" action (Space by default), applying upward velocity.

### Combat System

```gdscript
func handle_attack()
func take_damage(attack: Attack)
func die()
func stop_attack()
```

- `handle_attack()`: Triggers weapon attack when player presses attack button
- `take_damage()`: Processes incoming damage, applies knockback, triggers stun
- `die()`: Handles player death, starts respawn timer
- `stop_attack()`: Cancels current attack

## Player Lifecycle

1. **Initialization**:
   - Sets up weapon connections
   - Configures animation tree

2. **Physics Process**:
   - Applies gravity
   - Delegates to current state for behavior
   - Calls `move_and_slide()` to apply movement

3. **State Transitions**:
   - Managed by the StateMachine
   - States change based on player actions or external events

4. **Death & Respawn**:
   - On death, transitions to Dead state
   - After timer, `game_manager.respawn_player()` is called
   - Player repositions to team spawn point
   - State resets to Base

## Interaction with Other Systems

### Weapon System
- Player holds reference to current weapon
- Weapon attacks are triggered through `weapon.attack()`
- Weapon is attached via RemoteTransform3D to skeleton bone

### Animation System
- Uses AnimationTree with blend spaces and state machines
- Movement parameters (forward_vector, side_vector) drive blending
- States trigger animation transitions

### Camera System
- Camera follows player via CameraArm
- Player rotation is compensated to maintain camera orientation
- Camera gradually returns to behind-player position when not moving

### Money Bag System
- Player can pick up money bag (`has_money = true`)
- Drops bag when damaged
- Can cash in bag at team base

## Technical Details

### Movement Calculations

The movement system uses vector mathematics to handle camera-relative movement:

```gdscript
var cam_forward_xz = Vector3(cam_forward.x, 0, cam_forward.z).normalized()
var cam_right_xz = Vector3(cam_right.x, 0, cam_right.z).normalized()

var input_vec = Input.get_vector("ui_left", "ui_right", "ui_down", "ui_up")
var movement_vec = input_vec.x * cam_right_xz + input_vec.y * cam_forward_xz
```

### Player State Synchronization

When multiple players are active, each has:
- Unique player_id
- Team assignment
- Separate viewport and camera

## Common Issues and Solutions

1. **Player Rotation Issues**:
   - Check the rotation calculations in handle_movement()
   - Ensure camera_arm rotations are properly compensated

2. **Animation Glitches**:
   - Verify animation tree connections
   - Check that state transitions properly reset animations

3. **Weapon Attachment Problems**:
   - Ensure RemoteTransform3D path is correctly set to the weapon
   - Check weapon attachment bone in the skeleton

4. **Movement Feel**:
   - Adjust SPEED, ACCEL, and ROTATION_SPEED for desired responsiveness
   - Weapon weight affects movement speed - balance for gameplay

## Adding New Player Features

1. **New Abilities**:
   - Add new handler methods similar to `handle_attack()`
   - Add appropriate state transitions

2. **New Animations**:
   - Add animation to AnimationPlayer
   - Connect to AnimationTree
   - Trigger from appropriate state

3. **New Player Properties**:
   - Add to Player.gd
   - Initialize in _ready() if needed
   - Update in appropriate states

4. **New Player Types**:
   - Consider subclassing Player for special types
   - Or use composition with attachable components