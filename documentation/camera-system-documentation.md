# Camera System Documentation

## Overview

The Camera System in Heist manages how players view the game world. It handles split-screen functionality for multiple local players, camera movement and positioning for individual players, and the way camera perspective affects player movement direction.

## Split-Screen Implementation

### Viewport Setup

For local multiplayer, the game creates separate viewports for each player:

```gdscript
func spawn_player(player_id: int, team_id: int) -> void:
    # ...
    
    # Declare and rename cameras
    var camera_node = player.get_node("Camera3D")
    var camera_slot = player.get_node("CameraArm/CameraSlot")
    camera_node.name += str(player_id)
    
    # Create new subviewport
    var new_svp_container: SubViewportContainer = sub_viewport_container.instantiate()
    new_svp_container.name += str(player_id)
    grid_container.add_child(new_svp_container)
    
    # Reparent camera to Subviewports
    var viewport_path = "GridContainer/SubViewportContainer" + str(player_id) + "/SubViewport"
    var viewport = get_parent().get_node(viewport_path)
    camera_node.get_parent().remove_child(camera_node)
    viewport.add_child(camera_node)

    # Set up remote_transform
    var remote_transform = RemoteTransform3D.new()
    remote_transform.remote_path = camera_node.get_path()
    camera_slot.add_child(remote_transform)
```

### Viewport Layout Management

The game dynamically arranges viewports based on the number of players:

```gdscript
func on_viewport_size_changed():
    var current_resolution = DisplayServer.window_get_size()
    var viewport_containers = get_tree().get_nodes_in_group("subviewportcontainer")
    # Calculate subviewport resolution
    var player_resolution = Vector2.ZERO
    if LobbyManager.local_players_num == 1:
        player_resolution = current_resolution
    elif LobbyManager.local_players_num == 2:
        player_resolution.x = current_resolution.x / 2.0
        player_resolution.y = current_resolution.y / ceil(LobbyManager.local_players_num / 2.0)
    else:
        player_resolution.x = current_resolution.x / ceil(LobbyManager.local_players_num / 2.0)
        player_resolution.y = current_resolution.y / 2.0
    var resolution_per_player = player_resolution
    
    for container in viewport_containers:
        container.get_node("SubViewport").size = resolution_per_player
```

## Player Camera Structure

Each player has a camera system consisting of:

1. **CameraArm**: A spatial node that rotates around the player
2. **CameraSlot**: A position marker where the camera is attached
3. **Camera3D**: The actual camera providing the player's view

```gdscript
@onready var camera_arm = $CameraArm
@onready var camera_slot =  $CameraArm/CameraSlot
```

## Camera Movement & Control

### Camera Rotation

The camera rotates with player input:

```gdscript
func handle_movement(_delta, factor: float = 1.0):
    # ...
    var input_vec_3d = Vector3(input_vec.x, 0, input_vec.y)
    
    # Rotate camera left or right according to player input
    camera_arm.rotate_y(-input_vec_3d.x / 30)
    # ...
```

### Camera Positioning

When players move, the camera is positioned to properly follow them:

```gdscript
func handle_movement(_delta, factor: float = 1.0):
    # ...
    if move_vec_2d != Vector2.ZERO:
        # Rotate player so it's facing its movement vector
        rotation.y = rotate_toward(rotation.y, rotation.y + move_vec_2d.angle_to(basis_z_2d), 0.1)
        # Counteract player rotation so the camera is stationary
        camera_arm.rotation.y = rotate_toward(camera_arm.rotation.y, camera_arm.rotation.y-move_vec_2d.angle_to(basis_z_2d), 0.1)
    if move_vec_2d == Vector2.ZERO:
        # Slowly pan back camera to behind the character
        camera_arm.rotation.y = lerp_angle(camera_arm.rotation.y, 0, 0.01)
```

### Camera-Relative Movement

Player movement is calculated relative to the camera's perspective:

```gdscript
func handle_movement(_delta, factor: float = 1.0):
    var cam_basis = camera_arm.global_transform.basis
    
    var cam_forward = -cam_basis.z
    var cam_right = cam_basis.x

    var cam_forward_xz = Vector3(cam_forward.x, 0, cam_forward.z).normalized()
    var cam_right_xz = Vector3(cam_right.x, 0, cam_right.z).normalized()
    
    var input_vec = Input.get_vector("ui_left", "ui_right", "ui_down", "ui_up")
    
    # Calculate movement direction relative to camera orientation
    var movement_vec = input_vec.x * cam_right_xz + input_vec.y * cam_forward_xz
```

## Camera Connection with RemoteTransform3D

The camera is connected to the player via `RemoteTransform3D`:

```gdscript
# Set up remote_transform
var remote_transform = RemoteTransform3D.new()
remote_transform.remote_path = camera_node.get_path()
camera_slot.add_child(remote_transform)
```

This setup ensures:
1. The camera follows the player
2. Camera transformations can be managed independently of player transformations
3. The camera can be easily detached if needed

## Initial Camera Setup

When a player spawns, the camera is oriented to face the center of the map:

```gdscript
func parent_and_adjust(player: CharacterBody3D, team_spawn: Vector3) -> void:
    # ...
    player.global_position = team_spawn + Vector3(randf() * 5, team_spawn.y, randf() * 5) 
    
    # Rotate camera to the center of the map
    player.look_at(Vector3(0, player.position.y, 0))
```

Similarly, when respawning:

```gdscript
func respawn_player(player: Player):
    player.global_position = teams[player.team_id].spawn_position
    # Rotate camera to the center of the map
    player.look_at(Vector3(0, player.position.y, 0))
    player.state_machine.spawn_player()
```

## Camera Constraints

While not explicitly coded, the camera system:
- Maintains a fixed distance from the player
- Automatically repositions when the player rotates
- Gradually returns to a position behind the player when not moving

## State-Based Camera Behavior

The camera maintains its position and orientation regardless of player state (attacking, jumping, etc.), ensuring consistent view throughout gameplay.

## Resolution and Window Handling

The camera system listens for window resolution changes:

```gdscript
get_tree().root.size_changed.connect(on_viewport_size_changed)
```

When the window size changes, all viewports are automatically resized to maintain proper proportions.

## Technical Requirements

For developers extending the camera system:
1. Each player character must include a `CameraArm` node with a `CameraSlot` child
2. New player classes should preserve the camera rotation and movement code
3. Viewport containers must be in the "subviewportcontainer" group for proper resizing
