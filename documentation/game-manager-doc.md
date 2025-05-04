# Game Manager Documentation

## Overview

The Game Manager is the central coordination system for the Heist game, responsible for game initialization, player spawning, team management, score tracking, and handling the money bag mechanics. It serves as the core logic hub that connects all gameplay systems.

## File Structure

- `scenes/game/game_manager.gd`: Main game manager script

## Core Components

### Team Class

The `Team` inner class manages team-specific data:

```gdscript
class Team:
    var name: String               # Team identifier (red, blue, green, yellow)
    var color: Color               # Team color for visual identification
    var score: int                 # Current team score
    var spawn_position: Vector3    # Where team members spawn
    var has_money: bool            # Whether a team member has the money
    
    func _init(given_name: String, given_color: Color, given_spawn_position = Vector3.ZERO):
        self.name = given_name
        self.color = given_color
        self.spawn_position = given_spawn_position
        self.score = 0
        self.has_money = false
    
    func add_score():
        self.score += 1
```

### Key Properties

```gdscript
@onready var money_bag: Area3D = $"../MoneyBag"
@onready var money_bag_scene: PackedScene = preload("res://scenes/entities/money_bag