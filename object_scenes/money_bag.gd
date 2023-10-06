extends Area3D

@onready var game_manager: Node3D = $"../game_manager"
var is_picked_up = false
var angle = 0
@export var amp = 0.5
@export var freq = 0.5
@export var speed = 6
var carrier: CharacterBody3D

# Called when the node enters the scene tree for the first time.
func _physics_process(delta):
	if is_picked_up and carrier:
		var slot = carrier.get_node("money_bag_slot")
		position.x = move_toward(position.x, slot.global_position.x, speed * delta)
		position.y = move_toward(position.y, slot.global_position.y, speed * delta)
		position.z = move_toward(position.z, slot.global_position.z, speed * delta)
	else:
		angle += 2 * 3.14 * delta
		position.y = sin(angle * freq) * amp + 2
		


func _on_body_entered(body):
	if body.is_in_group("player") and not is_picked_up:
		is_picked_up = true
		carrier = body
		game_manager.grab_bag(0)
