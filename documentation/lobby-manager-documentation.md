# Lobby Manager Documentation

## Overview

The Lobby Manager is a singleton (autoload) that handles scene management, level switching, loading screens, and game configuration data. It persists across scene changes to maintain game state and provide a smooth transition between different parts of the game.

## File Location

`scripts/lobby_manager.gd`

## Properties

```gdscript
# Level management
var current_map: String = "LevelTest"
var current_map_path: String = "res://scenes/levels/level_test.tscn"
var requested_scene_path: String = "res://scenes/levels/level_test.tscn"
var requested_scene: Node3D

# Game configuration
var is_local_game = true
var local_players_num = 1

# Loading screen
var load_progress: Array = [0.0]
var fake_progress: float = 0.0

# Player data
var players: Dictionary = {}
var current_root_node: Window
```

## Core Functionality

### Initialization

When the game starts, Lobby Manager automatically initializes and triggers the loading screen:

```gdscript
func _ready():
    on_loading_start()
```

### Scene Loading System

The Lobby Manager implements a background loading system for scenes using Godot's `ResourceLoader` thread-loading capabilities:

```gdscript
func _process(delta):
    # Check if a level is loading
    if ResourceLoader.load_threaded_get_status(requested_scene_path, load_progress) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
        if load_progress[0] > fake_progress:
            fake_progress = load_progress[0]
        LoadingScreen.get_node("Panel/Panel/VBoxContainer/ProgressBar").value = fake_progress * 100
    # Check if level has finished loading
    elif ResourceLoader.load_threaded_get_status(requested_scene_path) == ResourceLoader.THREAD_LOAD_LOADED:
        fake_progress = move_toward(fake_progress, 1.0, delta * 1.5)
        LoadingScreen.get_node("Panel/Panel/VBoxContainer/ProgressBar").value = fake_progress * 100
        if fake_progress == 1.0:
            requested_scene = ResourceLoader.load_threaded_get(requested_scene_path).instantiate()
            current_root_node.add_child.call_deferred(requested_scene)
            requested_scene.ready.connect(on_loading_end)
```

This system:
1. Tracks loading progress and updates the loading screen
2. Uses a "fake progress" value to ensure smooth progress bar animation
3. Adds the new scene only when fully loaded
4. Connects to the scene's ready signal to hide the loading screen

### Scene Switching

The Lobby Manager provides a clean way to transition between scenes:

```gdscript
func swap_scene(current_scene: Node, new_scene_path):
    on_loading_start()
    requested_scene_path = new_scene_path
    
    # Request background loading of new scene
    ResourceLoader.load_threaded_request(requested_scene_path)
    
    current_root_node = current_scene.get_parent()
    current_scene.queue_free()
```

This method:
1. Shows the loading screen
2. Starts background loading of the new scene
3. Stores the parent node for later use
4. Removes the current scene

### Loading Screen Control

The Lobby Manager controls the visibility of the loading screen:

```gdscript
func on_loading_start():
    LoadingScreen.show()

func on_loading_end():
    LoadingScreen.hide()
```

## Game Configuration

The Lobby Manager stores critical game configuration that needs to persist between scenes:

1. **Map Selection**: `current_map` and `current_map_path` store the selected level
2. **Player Count**: `local_players_num` defines the number of local players
3. **Game Mode**: `is_local_game` differentiates between local and network play

## Interaction with Other Systems

### Main Menu Integration

The Main Menu sets game parameters through the Lobby Manager:
- Map selection
- Number of players
- Game mode

Example from `main_menu.gd`:
```gdscript
func _on_players_num_option_item_selected(index):
    LobbyManager.local_players_num = index + 2

func _on_level_option_item_selected(index):
    LobbyManager.current_map = snake_to_pascal(levels[index].lvl_name)
    LobbyManager.current_map_path = levels[index].lvl_path
```

### Game Manager Integration

The Game Manager accesses Lobby Manager data to initialize the game:
- Player count for viewport setup
- Map name for level initialization
- Spawn points access

### Level References

Levels and entities can access Lobby Manager data:
```gdscript
get_node("../" + LobbyManager.current_map + "/MoneyBagSpawn").global_position
```

## Best Practices

When working with the Lobby Manager:

1. **Scene Transitions**: Always use `swap_scene()` for transitions to ensure proper loading behavior
2. **Loading Events**: Call `on_loading_end()` when a scene is fully initialized and ready to interact with
3. **Data Storage**: Store only essential cross-scene data in the Lobby Manager
4. **Path Access**: Use `LobbyManager.current_map` to correctly access level-specific nodes

## Extending the Lobby Manager

To modify or extend the Lobby Manager:

1. **Network Play**: Add network multiplayer functionality by extending the players dictionary
2. **Save/Load**: Implement save game functionality
3. **Configuration**: Add game settings management
4. **UI Integration**: Create a more dynamic loading screen with tips or mini-games