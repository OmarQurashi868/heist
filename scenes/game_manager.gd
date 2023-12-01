extends Node3D

class Team:
	var name: String
	var color: Color
	var score: int
	var spawn_position: Vector3
	var has_money: bool
	
	func _init(given_name: String, given_color: Color, given_spawn_position = Vector3.ZERO):
		self.name = given_name
		self.color = given_color
		self.spawn_position = given_spawn_position
		self.score = 0
		self.has_money = false
	
	func add_score():
		self.score += 1

@onready var money_bag: Area3D = $"../MoneyBag"
@onready var money_bag_scene: PackedScene = preload("res://object_scenes/money_bag.tscn")
@onready var grid_container: GridContainer = $"../GridContainer"
@onready var sub_viewport_container: PackedScene = preload("res://object_scenes/sub_viewport_container.tscn")
@onready var score_label_path: String = "../HBoxContainer/ScoreLabel"
@export var player_scene: PackedScene = preload("res://object_scenes/player.tscn")
#@export_range(2,8) var local_players_num = 4

var level_scene_path = LobbyManager.current_map_path
var carrier_player_id = -1

var teams: Array[Team] = [
	Team.new("red", Color(1.0, 0, 0, 1)),
	Team.new("blue", Color(0, 0, 1.0, 1)),
	Team.new("green", Color(0, 1.0, 0, 1)),
	Team.new("yellow", Color(1.0, 1.0, 0, 1))
]

signal game_setup

func _ready():
	initialize_game.call_deferred()


func initialize_game():
	var level_scene = load(level_scene_path)
	var level = level_scene.instantiate()
	get_parent().add_child(level)
	prepare_teams()
	get_tree().root.size_changed.connect(on_viewport_size_changed)
	if LobbyManager.local_players_num == 1:
		grid_container.columns = 1
	elif LobbyManager.local_players_num == 2:
		grid_container.columns = 2
	else:
		grid_container.columns = ceil(LobbyManager.local_players_num / 2.0)
	for i in range(LobbyManager.local_players_num):
		spawn_player(i, i % 4)
	on_viewport_size_changed()
	LobbyManager.on_loading_end()
	game_setup.emit()

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


func spawn_player(player_id: int, team_id: int) -> void:
	# Spawn new player and modify its properties
	var player = player_scene.instantiate()
	player.name += str(player_id)
	player.player_id = player_id
	player.team_id = team_id
	player.add_to_group(teams[team_id].name)
	# This function needs to be called because all of it's calls need to happen at the end
	parent_and_adjust.call_deferred(player, teams[team_id].spawn_position)
	
	# Change the material for each player
	var mesh: MeshInstance3D = player.get_node("MeshInstance3D")
	var new_material = StandardMaterial3D.new()
	new_material.albedo_color = teams[team_id].color
	mesh.material_override = new_material
	
	# Declare and rename cameras
	var camera_node = player.get_node("Camera3D")
	var camera_slot = player.get_node("CameraSlot")
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


func prepare_teams() -> void:
	for i in range(len(teams)):
		teams[i].spawn_position = get_node("../" + LobbyManager.current_map + "/SpawnPoint" + str(i)).global_position


func grab_bag(player_id, team_name) -> void:
	var team = get_team_by_name(team_name)
	carrier_player_id = player_id
	team.has_money = true
	var carrier = get_player_by_id(player_id)
	carrier.has_money = true


func touch_base(player_id, team_id) -> void:
	if player_id == carrier_player_id and teams[team_id].has_money:
		teams[team_id].add_score()
		var score_label = get_node(score_label_path + str(team_id))
		score_label.text = str(teams[team_id].score)
		drop_bag()
		money_bag.on_bag_cash_in()


func respawn_bag() -> void:
	var money_bag_spawn_pos = get_node("../" + LobbyManager.current_map + "/MoneyBagSpawn").global_position
	money_bag.global_position = money_bag_spawn_pos


func rename_money_bag(new_money_bag):
	new_money_bag.name = "MoneyBag"


func drop_bag():
	carrier_player_id = -1
	var carrier_team = get_carrier_team()
	if carrier_team:
		carrier_team.has_money = false
	money_bag.on_bag_drop()


func parent_and_adjust(player: CharacterBody3D, team_spawn: Vector3) -> void:
	# This was seperated because the second call needs to happen after the first one
	# and the first one needs to be call_deffered
	get_parent().add_child(player)
	player.global_position = team_spawn + Vector3(randf() * 5, team_spawn.y, randf() * 5) 
	
	# Rotate  camera to the center of the map
	player.look_at(Vector3(0, player.position.y, 0))


func get_team_by_name(team_name: String) -> Team:
	for team in teams:
		if team.name == team_name:
			return team
	return null


func get_carrier_team() -> Team:
	for team in teams:
		if team.has_money:
			return team
	return null


func get_player_by_id(player_id: int) -> CharacterBody3D:
	var players = get_tree().get_nodes_in_group("player")
	for player in players:
		if player.player_id == player_id:
			return player
	return null


func respawn_player(player: Player):
	player.global_position = teams[player.team_id].spawn_position
	# Rotate  camera to the center of the map
	player.look_at(Vector3(0, player.position.y, 0))
	player.state_machine.spawn_player()
