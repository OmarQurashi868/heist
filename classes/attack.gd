extends Node
class_name Attack

var damage: float
var knockback_force: float
var knockback_source: Vector3
var stun_timer: float

func _init(damage = 0, knock_force = 0, knockback_source = Vector3.ZERO, stun_timer = 0):
	damage = damage
	knockback_force = knockback_force
	knockback_source = knockback_source
	stun_timer = stun_timer
