extends Area3D

@onready var game_manager: Node3D = $"../GameManager"
@export var amp = 0.5
@export var freq = 0.5
@export var speed = 12
signal money_bag_picked_up(team)
var is_picked_up = false
var is_cashed_in = false
var carrier: CharacterBody3D
var angle = 0
var money_bag_void_pos = Vector3(999, 999, 999)
var is_parent_ready = false


func _ready():
	#position = money_bag_void_pos
	#game_manager.respawn_bag.call_deferred()
	get_node("../GameManager").ready.connect(func(): is_parent_ready = true)

# Called when the node enters the scene tree for the first time.
func _physics_process(delta):
	if (is_parent_ready):
		if is_picked_up and carrier:
			var slot = carrier.get_node("MoneyBagSlot")
			position.x = move_toward(position.x, slot.global_position.x, speed * delta)
			position.y = move_toward(position.y, slot.global_position.y, speed * delta)
			position.z = move_toward(position.z, slot.global_position.z, speed * delta)
		elif not is_cashed_in:
			angle += 2 * 3.14 * delta
			var spawn_pos = get_node("../" + LobbyManager.current_map + "/MoneyBagSpawn").global_position
			position.x = move_toward(position.x, spawn_pos.x, delta)
			position.z = move_toward(position.z, spawn_pos.z, delta)
			position.y = spawn_pos.y + sin(angle * freq) * amp


func _on_body_entered(body):
	if body.is_in_group("player") and not is_picked_up and not body.is_stunned:
		is_picked_up = true
		carrier = body
		var carrier_team = body.get_groups()[1]
		var player_id = body.player_id
		emit_signal("money_bag_picked_up", player_id, carrier_team)


func on_bag_drop():
	is_picked_up = false
	carrier = null


func on_bag_cash_in():
	is_picked_up = false
	carrier = null
	is_cashed_in = true
	position = money_bag_void_pos
	$bag_respawn_time.start()


func _on_bag_respawn_time_timeout():
	is_cashed_in = false
	game_manager.respawn_bag()
