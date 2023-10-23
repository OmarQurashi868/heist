extends Node

var current_map: String = "LevelTest"
var current_map_path: String = "res://scenes/levels/level_test.tscn"
var requested_scene_path: String = ""
var requested_scene: Node3D
var current_root_node: Window
var is_local_game = true
var local_players_num = 1
var load_progress: Array = [0.0]
var fake_progress: float = 0.0

var players: Dictionary = {}


func _ready():
	on_loading_start()


func _process(delta):
	# Check if a level is loading
	if ResourceLoader.load_threaded_get_status(requested_scene_path, load_progress) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			if load_progress[0] > fake_progress:
				fake_progress = load_progress[0]
			LoadingScreen.get_node("Panel/Panel/VBoxContainer/ProgressBar").value = fake_progress * 100
	# Check if level has finished loading
	elif ResourceLoader.load_threaded_get_status(requested_scene_path) == ResourceLoader.THREAD_LOAD_LOADED:
			fake_progress = move_toward(fake_progress, 1.0, delta * 1.5)
			LoadingScreen.get_node("Panel/Panel/VBoxContainer/ProgressBar").value = fake_progress * 100
			if fake_progress == 1.0:
				requested_scene = ResourceLoader.load_threaded_get(requested_scene_path).instantiate()
				current_root_node.add_child.call_deferred(requested_scene)
				requested_scene.ready.connect(on_loading_end)


func swap_scene(current_scene: Node, new_scene_path):
	on_loading_start()
	requested_scene_path = new_scene_path
	
	# Request background loading of new scene
	ResourceLoader.load_threaded_request(requested_scene_path)
	
	current_root_node = current_scene.get_parent()
	current_scene.queue_free()


func on_loading_start():
	LoadingScreen.show()


func on_loading_end():
	LoadingScreen.hide()
