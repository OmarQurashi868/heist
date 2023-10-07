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
@export var player_scene: PackedScene = preload("res://object_scenes/player.tscn")
@export_range(1,4) var players_num = 4
@export var current_map = "LevelTest"

var carrier_player_id = -1

var teams: Array[Team] = [
	Team.new("red", Color(1.0, 0, 0, 1)),
	Team.new("blue", Color(0, 0, 1.0, 1)),
	Team.new("green", Color(0, 1.0, 0, 1)),
	Team.new("yellow", Color(1.0, 1.0, 0, 1))
]

func _ready():
	prepare_teams()
	spawn_players()


func spawn_players() -> void:
	for i in range(players_num):
		# Spawn new player and modify its properties
		var player = player_scene.instantiate()
		player.name += str(i)
		player.player_id = i
		player.add_to_group(teams[i].name)
		print(teams[i].name)
		
		# This function needs to be called because all of it's calls need to happen at the end
		parent_and_adjust.call_deferred(player, teams[i].spawn_position)
		
		# Change the material for each player
		var mesh: MeshInstance3D = player.get_node("MeshInstance3D")
		var new_material = StandardMaterial3D.new()
		new_material.albedo_color = teams[i].color
		mesh.material_override = new_material
		
		# Declare and rename cameras
		var camera_node = player.get_node("Camera3D")
		var camera_slot = player.get_node("CameraSlot")
		camera_node.name += str(i)
		
		# Reparent camera to Subviewports
		var viewport_path = "GridContainer/SubViewportContainer" + str(i) + "/SubViewport"
		var viewport = get_parent().get_node(viewport_path)
		camera_node.get_parent().remove_child(camera_node)
		viewport.add_child(camera_node)

		# Set up remote_transform
		var remote_transform = RemoteTransform3D.new()
		remote_transform.remote_path = camera_node.get_path()
		camera_slot.add_child(remote_transform)


func prepare_teams() -> void:
	for i in range(len(teams)):
		teams[i].spawn_position = get_node("../" + current_map + "/SpawnPoint" + str(i)).global_position


func touch_base(player_id, team_id) -> void:
	if player_id == carrier_player_id and teams[team_id].has_money:
		teams[team_id].add_score()
		print(teams[team_id].score)


func grab_bag(player_id, team_name) -> void:
	var team = get_team_by_name(team_name)
	carrier_player_id = player_id
	team.has_money = true


func drop_bag():
	carrier_player_id = -1
	var carrier_team = get_carrier_team()
	carrier_team.has_money = false

func parent_and_adjust(player: CharacterBody3D, team_spawn: Vector3) -> void:
	# This was seperated because the second call needs to happen after the first one
	# and the first one needs to be call_deffered
	get_parent().add_child(player)
	player.global_position = team_spawn
	
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
