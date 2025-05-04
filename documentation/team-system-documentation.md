# Team System Documentation

## Overview

The Team System in Heist manages player groups, team scoring, spawn positions, and team-specific gameplay mechanics. Teams are a fundamental organizational structure, allowing players to compete against each other while collaborating with teammates.

## Team Class Definition

The `Team` class is defined within the `GameManager` script (`scenes/game/game_manager.gd`):

```gdscript
class Team:
    var name: String           # Team identifier (red, blue, green, yellow)
    var color: Color           # Visual representation color
    var score: int             # Number of successfully cashed-in money bags
    var spawn_position: Vector3 # Where team members appear after spawning
    var has_money: bool        # Whether any team member carries the money bag
    
    func _init(given_name: String, given_color: Color, given_spawn_position = Vector3.ZERO):
        self.name = given_name
        self.color = given_color
        self.spawn_position = given_spawn_position
        self.score = 0
        self.has_money = false
    
    func add_score():
        self.score += 1
```

## Team Initialization

Teams are initialized in the `GameManager` with predefined colors:

```gdscript
var teams: Array[Team] = [
    Team.new("red", Color(1.0, 0, 0, 1)),
    Team.new("blue", Color(0, 0, 1.0, 1)),
    Team.new("green", Color(0, 1.0, 0, 1)),
    Team.new("yellow", Color(1.0, 1.0, 0, 1))
]
```

## Team Mechanics

### Spawn Points

Each team has a designated spawn position in the level, used when:
- Players first join the game
- Players respawn after death

Spawn points are retrieved from the level scene:

```gdscript
func prepare_teams() -> void:
    for i in range(len(teams)):
        teams[i].spawn_position = get_node("../" + LobbyManager.current_map + "/SpawnPoint" + str(i)).global_position
```

### Team Bases

Each team has a base where players return with the money bag to score points. These are set up in the level scene with collision detection:

```gdscript
func _on_base_red_body_entered(body):
    if body.is_in_group("player") and body.is_in_group("red"):
        game_manager.touch_base(body.player_id, 0)
```

### Team Assignment

Players are assigned to teams during player creation:

```gdscript
func spawn_player(player_id: int, team_id: int) -> void:
    # ...
    player.team_id = team_id
    player.add_to_group(teams[team_id].name)
    # ...
    
    # Visual team identification
    var mesh: MeshInstance3D = player.get_node("weasel/rig/Skeleton3D/Body")
    var new_material = StandardMaterial3D.new()
    new_material.albedo_color = teams[team_id].color
    mesh.set_surface_override_material(2, new_material)
    # ...
```

### Scoring System

When a player carrying the money bag returns to their team's base, the team scores a point:

```gdscript
func touch_base(player_id, team_id) -> void:
    if player_id == carrier_player_id and teams[team_id].has_money:
        teams[team_id].add_score()
        var score_label = get_node(score_label_path + str(team_id))
        score_label.text = str(teams[team_id].score)
        drop_bag()
        money_bag.on_bag_cash_in()
```

## Team Identification

### Group System

Players belonging to a team are added to a group named after the team. This enables easy team-based checks:

```gdscript
# Adding player to team group
player.add_to_group(teams[team_id].name)

# Checking if player belongs to a team
if body.is_in_group("player") and body.is_in_group("red"):
    # Team-specific logic
```

### Visual Distinction

Players are visually differentiated by team through material color assignment:

```gdscript
var mesh: MeshInstance3D = player.get_node("weasel/rig/Skeleton3D/Body")
var new_material = StandardMaterial3D.new()
new_material.albedo_color = teams[team_id].color
mesh.set_surface_override_material(2, new_material)
```

## Team Helper Functions

The GameManager provides utility functions for team operations:

```gdscript
# Get team by name
func get_team_by_name(team_name: String) -> Team:
    for team in teams:
        if team.name == team_name:
            return team
    return null

# Get team currently carrying the money bag
func get_carrier_team() -> Team:
    for team in teams:
        if team.has_money:
            return team
    return null
```

## Money Bag Team Interactions

When a player picks up the money bag, their team is marked as having the money:

```gdscript
func grab_bag(player_id, team_name) -> void:
    var team = get_team_by_name(team_name)
    carrier_player_id = player_id
    team.has_money = true
    var carrier = get_player_by_id(player_id)
    carrier.has_money = true
```

When the money bag is dropped or scored, the team's status is updated:

```gdscript
func drop_bag():
    carrier_player_id = -1
    var carrier_team = get_carrier_team()
    if carrier_team:
        carrier_team.has_money = false
    money_bag.on_bag_drop()
```

## Score Display

Each team's score is displayed in the UI through score labels:

```gdscript
# When a team scores
teams[team_id].add_score()
var score_label = get_node(score_label_path + str(team_id))
score_label.text = str(teams[team_id].score)
```

## Level Design Integration

Level designers need to include these elements for proper team functionality:
- SpawnPoint0, SpawnPoint1, etc. - One for each team
- Base collision areas with appropriate signal connections
- Team-specific visual elements (optional)
