extends Node3D

@onready var money_bag: Area3D = $"../money_bag"
# @onready var player: CharacterBody3D = $"../Player"
var team_scores = {"red": 0, "blue": 0, "green": 0, "yellow": 0}
var team_order = ["red", "blue", "green", "yellow" ]
@export var players_num = 4
@export var player_scene: PackedScene = preload("res://object_scenes/player.tscn")

func spawn_player():
	for i in range(players_num):
		var plr = player_scene.instantiate()
		plr.name += str(i+1)
		get_parent().add_child.call_deferred(plr)
		plr.add_to_group(team_order[i])
		print(plr.get_groups())
	

func _ready():
	spawn_player()

func touch_base(player_id, team):
	# if player.has_money:
		team_scores[team] += 1
	# print(team_scores)

func grab_bag(player_id):
	money_bag.is_picked_up = true
	# player.has_money = true
	
