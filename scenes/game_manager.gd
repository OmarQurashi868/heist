extends Node3D

@onready var money_bag: Area3D = $"../money_bag"
#@onready var player: CharacterBody3D = $"../Player"
@export var player_scene: PackedScene = preload("res://object_scenes/player.tscn")
@export var players_num = 4
@export var current_map = "level_1"

# Taking the spawns nodes positions
@onready var team_red_spawner_position = get_node("../" + current_map + "/team_red_spawn").global_position
@onready var team_blue_spawner_position = get_node("../" + current_map + "/team_blue_spawn").global_position
@onready var team_green_spawner_position = get_node("../" + current_map + "/team_green_spawn").global_position
@onready var team_yellow_spawner_position = get_node("../" + current_map + "/team_yellow_spawn").global_position

var team_scores = {"red": 0, "blue": 0, "green": 0, "yellow": 0}
var team_order = ["red", "blue", "green", "yellow" ]

func spawn_player():
	var team_spawns = [team_red_spawner_position, team_blue_spawner_position, team_green_spawner_position, team_yellow_spawner_position]
	for i in range(players_num):
		# Spawn new player > modify its properties > move position to spawn point
		var plr = player_scene.instantiate()
		plr.name += str(i + 1)
		plr.player_id += i
		plr.add_to_group(team_order[i])
		get_parent().add_child.call_deferred(plr)
		plr.global_position = team_spawns[i]
		
		# Declare and rename cameras
		var camera_node = plr.get_node("Camera3D")
		var camera_slot = plr.get_node("camera_slot")
		camera_node.name += str(i + 1)
		
		# Reparent camera to Subviewports
		var viewport_path = "GridContainer/SubViewportContainer" + str(i + 1) + "/SubViewport"
		var viewport = get_parent().get_node(viewport_path)
		camera_node.get_parent().remove_child(camera_node)
		viewport.add_child(camera_node)

		# Set up remote_transform
		var remote_transform = RemoteTransform3D.new()
		remote_transform.remote_path = camera_node.get_path()
		camera_slot.add_child(remote_transform)


func _ready():
	spawn_player()

func touch_base(player_id, team):
	# if player.has_money:
		team_scores[team] += 1
	# print(team_scores)

func grab_bag(player_id):
	pass
	# player.has_money = true
	
