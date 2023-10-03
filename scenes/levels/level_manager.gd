extends Node3D

@onready var game_manager: Node3D = $"../../game_manager"

func _on_base_red_body_entered(body):
	if body.is_in_group("player") and body.is_in_group("red"):
		game_manager.add_score("red")


func _on_base_blue_body_entered(body):
	if body.is_in_group("player") and body.is_in_group("blue"):
		game_manager.add_score("blue")


func _on_base_green_body_entered(body):
	if body.is_in_group("player") and body.is_in_group("green"):
		game_manager.add_score("green")


func _on_base_yellow_body_entered(body):
	if body.is_in_group("player") and body.is_in_group("yellow"):
		game_manager.add_score("yellow")
