extends Node3D

@onready var game_manager: Node3D = $"../../GameManager"

func _on_base_red_body_entered(body):
	if body.is_in_group("player") and body.is_in_group("red"):
		game_manager.touch_base(body.player_id, 0)


func _on_base_blue_body_entered(body):
	if body.is_in_group("player") and body.is_in_group("blue"):
		game_manager.touch_base(body.player_id, 1)


func _on_base_green_body_entered(body):
	if body.is_in_group("player") and body.is_in_group("green"):
		game_manager.touch_base(body.player_id, 2)


func _on_base_yellow_body_entered(body):
	if body.is_in_group("player") and body.is_in_group("yellow"):
		game_manager.touch_base(body.player_id, 3)
