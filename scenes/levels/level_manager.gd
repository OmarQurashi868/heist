extends Node3D

@onready var game_manager: Node3D = $"../../game_manager"
signal baseTouched

func _on_base_red_body_entered(body):
	baseTouched.emit()
	if body.is_in_group("player") and body.is_in_group("red"):
		game_manager.touch_base(body.player_id, "red")


func _on_base_blue_body_entered(body):
	if body.is_in_group("player") and body.is_in_group("blue"):
		game_manager.touch_base(body.player_id, "blue")


func _on_base_green_body_entered(body):
	if body.is_in_group("player") and body.is_in_group("green"):
		game_manager.touch_base(body.player_id, "green")


func _on_base_yellow_body_entered(body):
	if body.is_in_group("player") and body.is_in_group("yellow"):
		game_manager.touch_base(body.player_id, "yellow")
