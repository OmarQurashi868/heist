extends Control

class Level:
	var lvl_name: String
	var lvl_path: String
	var lvl_id: int

@onready var game_scene_path = "res://scenes/game.tscn"
enum MENUES {LOCAL, ONLINE, OPTIONS}
var levels_path = "res://scenes/levels"
var levels: Array[Level]
var open_menu: MENUES


func _ready():
	print(snake_to_pascal("level_test"))
	levels = get_all_levels()
	for level in levels:
		$MenuSeperator/LocalButtons/LevelOption.add_item(level.lvl_name, level.lvl_id)
	LobbyManager.local_players_num = $MenuSeperator/LocalButtons/PlayersNumOption.selected + 2
	


func start_game():
	get_tree().change_scene_to_file(game_scene_path)


func switch_menu(new_menu: MENUES):
	$MenuSeperator/LocalButtons.hide()
	
	match new_menu:
		MENUES.LOCAL:
			$MenuSeperator/LocalButtons.show()
		MENUES.ONLINE:
			pass
		MENUES.OPTIONS:
			pass


func get_all_levels() -> Array[Level]:
	var dir = DirAccess.open(levels_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tscn"):
				var new_level = Level.new()
				new_level.lvl_name = file_name.replace(".tscn", "")
				new_level.lvl_path = dir.get_current_dir() + file_name
				new_level.lvl_id = levels.size()
				levels.append(new_level)
			file_name = dir.get_next()
	return levels

func _on_exit_button_button_up():
	get_tree().quit()


func _on_players_num_option_item_selected(index):
	LobbyManager.local_players_num = index + 2


func _on_play_local_button_button_up():
	start_game()


func _on_play_local_menu_button_button_up():
	switch_menu(MENUES.LOCAL)


func _on_level_option_item_selected(index):
	LobbyManager.current_map = snake_to_pascal(levels[index].lvl_name)
	LobbyManager.current_map_path = levels[index].lvl_path


func snake_to_pascal(input: String) -> String:
	var pascal = input
	pascal[0] = pascal[0].to_upper()
	for i in range(pascal.length()):
		if pascal[i] == "_":
			pascal [i + 1] = pascal[i + 1].to_upper()
	pascal = pascal.replace("_", "")
	return pascal
