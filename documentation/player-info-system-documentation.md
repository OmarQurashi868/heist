# Player Info System Documentation

## Overview

The Player Info system (`scripts/player_info.gd`) provides a data structure for tracking player information in the Heist game. It allows the game to maintain relevant player data, particularly useful for networking, session management, and team assignment.

## PlayerInfo Class

The `PlayerInfo` class is a simple data container with the following properties:

```gdscript
class_name PlayerInfo

var p_id: int                      # Unique player identifier
var p_name: String                 # Player's display name
var p_team_id: int                 # Team assignment (0-3 for red, blue, green, yellow)
var p_local_players: Array[PlayerInfo] # Local players for split-screen (used in network scenarios)
```

## Usage

The `PlayerInfo` class is primarily used as a data transfer object to:

1. Represent player data in a clean, structured way
2. Pass player information between game systems
3. Store player configuration for game session setup

## Integration with Game Systems

While currently minimally implemented, the `PlayerInfo` class is designed to interface with several systems:

### Lobby Manager

The Lobby Manager would use `PlayerInfo` to:
- Track players joining a game session
- Assign teams based on player preferences
- Share player information when transitioning between scenes

```gdscript
# Example usage in Lobby Manager (conceptual)
var players_info = []

func add_player(id: int, name: String, team_id: int):
    var new_player = PlayerInfo.new()
    new_player.p_id = id
    new_player.p_name = name
    new_player.p_team_id = team_id
    players_info.append(new_player)
```

### Game Manager

The Game Manager would use `PlayerInfo` to:
- Spawn players with correct identifiers and team assignments
- Track player-specific data during gameplay
- Handle respawning while maintaining player identity

```gdscript
# Example usage in Game Manager (conceptual)
func spawn_player_from_info(player_info: PlayerInfo):
    var player = player_scene.instantiate()
    player.player_id = player_info.p_id
    player.team_id = player_info.p_team_id
    # Additional setup...
```

### Local Multiplayer Support

The `p_local_players` array enables split-screen configuration:

```gdscript
# Example for setting up local multiplayer (conceptual)
func setup_local_multiplayer(player_count: int):
    var host_player = PlayerInfo.new()
    host_player.p_id = 0
    host_player.p_name = "Player 1"
    host_player.p_team_id = 0
    
    # Create additional local players
    for i in range(1, player_count):
        var local_player = PlayerInfo.new()
        local_player.p_id = i
        local_player.p_name = "Player " + str(i+1)
        local_player.p_team_id = i % 4  # Assign to teams 0-3
        host_player.p_local_players.append(local_player)
    
    return host_player
```

## Current Implementation Status

In the current codebase, the `PlayerInfo` class is defined but minimally utilized. It appears to be part of a planned networking or session management system that hasn't been fully implemented yet.

The class is ready to be expanded upon for:
1. Online multiplayer functionality
2. More sophisticated team assignment
3. Player statistics tracking
4. Save/load player preferences

## Extension Points

To expand the `PlayerInfo` system, consider adding:

### Additional Player Properties

```gdscript
var p_color: Color          # Player's custom color
var p_character: String     # Selected character/model
var p_ready: bool           # Ready status in lobby
var p_ping: int             # Network latency
var p_score: int            # Player's current score
```

### Methods for Data Management

```gdscript
func to_dictionary() -> Dictionary:
    # Convert player info to dictionary for network transmission or saving
    var dict = {
        "id": p_id,
        "name": p_name,
        "team_id": p_team_id,
        "local_players": []
    }
    for player in p_local_players:
        dict["local_players"].append(player.to_dictionary())
    return dict

static func from_dictionary(dict: Dictionary) -> PlayerInfo:
    # Create player info from dictionary
    var player_info = PlayerInfo.new()
    player_info.p_id = dict["id"]
    player_info.p_name = dict["name"]
    player_info.p_team_id = dict["team_id"]
    
    for player_dict in dict["local_players"]:
        player_info.p_local_players.append(from_dictionary(player_dict))
    
    return player_info
```

## Integration Strategy

To better integrate the `PlayerInfo` system:

1. Modify the Lobby Manager to create and manage PlayerInfo instances
2. Update the Game Manager to accept PlayerInfo for player creation
3. Add UI elements to display player information
4. Create a player