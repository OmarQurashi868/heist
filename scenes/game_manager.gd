extends Node3D

@onready var money_bag: Area3D = $"../money_bag"
@onready var player: CharacterBody3D = $"../Player"
@onready var level_1: Node3D = $"../level1"
@export var player_scene: PackedScene = preload("res://object_scenes/player.tscn")
@export var players_num = 4

# Taking the spawns nodes positions
@onready var team_red_spawner_position = get_node("../level_1/team_red_spawn").global_position
@onready var team_blue_spawner_position = get_node("../level_1/team_blue_spawn").global_position
@onready var team_green_spawner_position = get_node("../level_1/team_green_spawn").global_position
@onready var team_yellow_spawner_position = get_node("../level_1/team_yellow_spawn").global_position

var team_scores = {"red": 0, "blue": 0, "green": 0, "yellow": 0}
var team_order = ["red", "blue", "green", "yellow" ]


func spawn_player():
	var team_spawns = [team_red_spawner_position, team_blue_spawner_position, team_green_spawner_position, team_yellow_spawner_position]
	for i in range(players_num):
		var plr = player_scene.instantiate()
		plr.name += str(i+1)
		get_parent().add_child.call_deferred(plr)
		plr.add_to_group(team_order[i])
		var playerrs = get_tree().get_nodes_in_group(team_order[i])
		plr.global_position = team_spawns[i]
		print(team_spawns[i])
			
		
		
		
		
		
		
		
			
		
	

func _ready():
	spawn_player()

func touch_base(player_id, team):
	# if player.has_money:
		team_scores[team] += 1
	# print(team_scores)

func grab_bag(player_id):
	money_bag.is_picked_up = true
	# player.has_money = true
	
