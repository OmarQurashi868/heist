extends Node

var current_map: String = "LevelTest"
var current_map_path: String = "res://scenes/levels/level_test.tscn"
var is_local_game = true
var local_players_num = 1

var players: Dictionary = {}


func _ready():
	LoadingScreen.show()


func swap_scene(current_scene: Node, new_scene_path):
	on_loading_start()
	
	var new_scene: Node = load(new_scene_path).instantiate()
	var root_node = current_scene.get_parent()
	
	current_scene.queue_free()
	root_node.add_child.call_deferred(new_scene)
	#new_scene.ready.connect(on_loading_end)
	new_scene.tree_entered.connect(on_loading_end)


func on_loading_start():
	LoadingScreen.show()


func on_loading_end():
	LoadingScreen.hide()
