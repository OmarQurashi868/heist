extends Node
class_name Attack

var damage: float
var knockback_force: float
var knockback_source: Vector3
var stun_timer: float

func _init(given_damage = 0, given_knockback_force = 0, given_knockback_source = Vector3.ZERO, given_stun_timer = 0):
	damage = given_damage
	knockback_force = given_knockback_force
	knockback_source = given_knockback_source
	stun_timer = given_stun_timer
