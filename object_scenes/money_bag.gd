extends Area3D

@onready var game_manager: Node3D = $"../GameManager"
var is_picked_up = false
@export var amp = 0.5
@export var freq = 0.5
@export var speed = 6
signal money_bag_picked_up(team)
var carrier: CharacterBody3D
var angle = 0


# Called when the node enters the scene tree for the first time.
func _physics_process(delta):
	if is_picked_up and carrier:
		var slot = carrier.get_node("MoneyBagSlot")
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
		var carrier_team = body.get_groups()[1]
		var player_id = body.player_id
		#print(carrier)
		emit_signal("money_bag_picked_up", player_id, carrier_team)
