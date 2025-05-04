# Main Menu System Documentation

## Overview

The Main Menu system provides the starting interface for the game, allowing players to configure game settings, select levels, and start different game modes. It handles level discovery and setup of game parameters through the Lobby Manager.

## File Location

`scenes/game/main_menu.gd`

## Level Class

The Main Menu defines a custom Level class to store information about available levels:

```gdscript
class Level:
    var lvl_name: String   # Name of the level
    var lvl_path: String   # File path to the level scene
    var lvl_id: int        # Unique identifier for the level
```

## Properties

```gdscript
@onready var game_scene_path = "res://scenes/game/game.tscn"
@onready var menu_container = get_node("MarginContainer/MenuSeperator")
enum MENUES {LOCAL, ONLINE, OPTIONS}
var levels_path = "res://scenes/levels"
var levels: Array[Level]
var open_menu: MENUES
```

## Core Functionality

### Menu Initialization

When the Main Menu loads, it discovers available levels and sets up UI elements:

```gdscript
func _ready():
    levels = get_all_levels()
    for level in levels:
        var level_name = snake_to_space(level.lvl_name)
        menu_container.get_node("LocalButtons/LevelOption").add_item(level_name, level.lvl_id)
    LobbyManager.local_players_num = menu_container.get_node("LocalButtons/PlayersNumOption").selected + 2
    LobbyManager.on_loading_end()
    _on_level_option_item_selected(0)
```

This initialization:
1. Discovers all level files in the levels directory
2. Populates the level selection dropdown
3. Sets initial values in the Lobby Manager
4. Selects the first level by default

### Level Discovery

The Main Menu automatically finds all available levels in the project:

```gdscript
func get_all_levels() -> Array[Level]:
    var dir = DirAccess.open(levels_path)
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while file_name != "":
            file_name = file_name.trim_suffix(".remap")
            if file_name.ends_with(".tscn") and not file_name.begins_with("."):
                var new_level = Level.new()
                new_level.lvl_name = file_name.trim_suffix(".tscn")
                new_level.lvl_path = dir.get_current_dir() + "/" + file_name
                new_level.lvl_id = levels.size()
                levels.append(new_level)
            file_name = dir.get_next()
    return levels
```

This mechanism:
1. Opens the levels directory
2. Identifies all .tscn files that don't start with a dot
3. Creates Level objects with appropriate metadata
4. Returns the collection of found levels

### Game Startup

When the player starts the game, the Main Menu transitions to the game scene:

```gdscript
func start_game():
    LobbyManager.swap_scene(self, game_scene_path)
```

This leverages the Lobby Manager's scene swapping functionality to load the game with a proper loading screen.

### Menu Navigation

The Main Menu supports different submenu sections (local play, online play, options):

```gdscript
func switch_menu(new_menu: MENUES):
    menu_container.get_node("LocalButtons").hide()
    menu_container.get_node("OnlineButtons").hide()
    
    match new_menu:
        MENUES.LOCAL:
            menu_container.get_node("LocalButtons").show()
        MENUES.ONLINE:
            menu_container.get_node("OnlineButtons").show()
        MENUES.OPTIONS:
            pass
```

### Configuration Storage

When options are selected, they're stored in the Lobby Manager:

```gdscript
func _on_players_num_option_item_selected(index):
    LobbyManager.local_players_num = index + 2

func _on_level_option_item_selected(index):
    LobbyManager.current_map = snake_to_pascal(levels[index].lvl_name)
    LobbyManager.current_map_path = levels[index].lvl_path
```

### String Formatting Utilities

The Main Menu includes utilities to format level names properly:

```gdscript
func snake_to_pascal(input: String) -> String:
    var pascal = input
    pascal[0] = pascal[0].to_upper()
    for i in range(pascal.length()):
        if pascal[i] == "_":
            pascal [i + 1] = pascal[i + 1].to_upper()
    pascal = pascal.replace("_", "")
    return pascal

func snake_to_space(input: String) -> String:
    var space = input
    space[0] = space[0].to_upper()
    for i in range(space.length()):
        if space[i] == "_":
            space [i + 1] = space[i + 1].to_upper()
    space = space.replace("_", " ")
    return space
```

These functions convert snake_case filenames to more readable formats:
- `snake_to_pascal`: Converts "level_test" to "LevelTest" (for internal use)
- `snake_to_space`: Converts "level_test" to "Level Test" (for display)

## UI Structure

The Main Menu UI is organized with:

1. **Main Buttons**: Play Local, Play Online, Options, Exit
2. **Local Game Settings**: Level selection, player count
3. **Online Game Settings**: (placeholder for future implementation)
4. **Options Menu**: (placeholder for future implementation)
5. **Confirmation Dialog**: For exit confirmation

## Integration with Game Systems

### Lobby Manager Integration

The Main Menu closely integrates with the Lobby Manager to:
- Store level selection
- Configure player count
- Manage scene transitions

### Level Discovery

The Main Menu's level discovery system automatically detects level files, making it easy to add new levels without modifying the menu code.

## Best Practices

When working with the Main Menu:

1. **Adding Levels**: Simply place new level scenes in the `scenes/levels/` directory
2. **Naming Conventions**: Use snake_case for level files (e.g., `cool_new_level.tscn`)
3. **Menu Extensions**: Add new menu options by following the existing pattern and update the MENUES enum
4. **Scene References**: Keep scene paths updated if project structure changes

## Extending the Main Menu

To modify or extend the Main Menu:

1. **New Game Modes**: Add additional menu sections and corresponding logic
2. **Settings Options**: Implement game settings like audio volume, controls, etc.
3. **UI Enhancement**: Improve visual design, animations, or layout
4. **Level Previews**: Add thumbnails or previews for level selection
5. **Save/Load**: Add functionality to save and load game progress